import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

Future<DateTime?> showCommunityDeadlinePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final normalizedFirstDate = _dateOnly(firstDate ?? DateTime.now());
  final normalizedLastDate = _dateOnly(
    lastDate ?? DateTime.now().add(const Duration(days: 3650)),
  );
  final normalizedInitialDate = _clampDate(
    _dateOnly(initialDate),
    normalizedFirstDate,
    normalizedLastDate,
  );

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext bottomSheetContext) {
      return CommunityDeadlinePicker(
        firstDate: normalizedFirstDate,
        lastDate: normalizedLastDate,
        initialDate: normalizedInitialDate,
      );
    },
  );
}

class CommunityDeadlinePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;

  const CommunityDeadlinePicker({
    super.key,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
  });

  @override
  State<CommunityDeadlinePicker> createState() =>
      _CommunityDeadlinePickerState();
}

class _CommunityDeadlinePickerState extends State<CommunityDeadlinePicker> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.writeBackground,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMonthNavigator(),
              const SizedBox(height: 12),
              _buildWeekdayHeader(),
              const SizedBox(height: 4),
              _buildCalendar(),
              const SizedBox(height: 16),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.inputBorder,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '모집 마감일',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedDate.year}년 ${_selectedDate.month}월 '
            '${_selectedDate.day}일',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '마감일을 선택해주세요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigator() {
    final canGoToPreviousMonth = _canMoveToMonth(-1);
    final canGoToNextMonth = _canMoveToMonth(1);

    return Row(
      children: [
        Expanded(
          child: Text(
            '${_visibleMonth.year}년 ${_visibleMonth.month}월',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
        _buildMonthButton(
          icon: Icons.chevron_left_rounded,
          semanticLabel: '이전 달',
          enabled: canGoToPreviousMonth,
          onTap: () => _moveMonth(-1),
        ),
        const SizedBox(width: 4),
        _buildMonthButton(
          icon: Icons.chevron_right_rounded,
          semanticLabel: '다음 달',
          enabled: canGoToNextMonth,
          onTap: () => _moveMonth(1),
        ),
      ],
    );
  }

  Widget _buildMonthButton({
    required IconData icon,
    required String semanticLabel,
    required bool enabled,
    required void Function() onTap,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? AppColors.black : AppColors.unselectedItem,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = <String>['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: weekdays
          .map(
            (String weekday) => Expanded(
              child: Center(
                child: Text(
                  weekday,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: weekday == '일' || weekday == '토'
                        ? AppColors.textSecondary
                        : AppColors.black,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    final leadingEmptyDays = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final cellCount = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cellCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index < leadingEmptyDays ||
            index >= leadingEmptyDays + daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(
          _visibleMonth.year,
          _visibleMonth.month,
          index - leadingEmptyDays + 1,
        );
        return _buildDateCell(date);
      },
    );
  }

  Widget _buildDateCell(DateTime date) {
    final isSelected = _isSameDate(date, _selectedDate);
    final isToday = _isSameDate(date, _dateOnly(DateTime.now()));
    final isEnabled =
        !date.isBefore(widget.firstDate) && !date.isAfter(widget.lastDate);

    return Semantics(
      label:
          '${date.year}년 ${date.month}월 ${date.day}일'
          '${isSelected ? ', 선택됨' : ''}',
      button: true,
      enabled: isEnabled,
      selected: isSelected,
      child: InkWell(
        onTap: isEnabled
            ? () {
                setState(() {
                  _selectedDate = date;
                });
              }
            : null,
        customBorder: const CircleBorder(),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.primary)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: !isEnabled
                    ? AppColors.unselectedItem
                    : isSelected
                    ? AppColors.white
                    : AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: '취소',
            onTap: () => Navigator.of(context).pop(),
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionButton(
            label: '선택하기',
            onTap: () => Navigator.of(context).pop(_selectedDate),
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required void Function() onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isPrimary ? null : Border.all(color: AppColors.inputBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isPrimary ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }

  bool _canMoveToMonth(int offset) {
    final targetMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + offset,
    );
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);

    return !targetMonth.isBefore(firstMonth) && !targetMonth.isAfter(lastMonth);
  }

  void _moveMonth(int offset) {
    if (!_canMoveToMonth(offset)) return;

    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _clampDate(DateTime date, DateTime firstDate, DateTime lastDate) {
  if (date.isBefore(firstDate)) return firstDate;
  if (date.isAfter(lastDate)) return lastDate;
  return date;
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
