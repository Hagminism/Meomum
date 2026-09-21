import 'package:flutter/material.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchField extends StatefulWidget {
  final String query;
  final void Function(String query) onChanged;
  final void Function() onSubmitted;
  final bool autofocus;

  const MapSearchField({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    this.autofocus = false,
  });

  @override
  State<MapSearchField> createState() => _MapSearchFieldState();
}

class _MapSearchFieldState extends State<MapSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant MapSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.query) return;

    _controller.value = TextEditingValue(
      text: widget.query,
      selection: TextSelection.collapsed(offset: widget.query.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: '매장 검색',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '매장 검색',
            style: TextStyle(
              color: AppColors.primary,
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.hintIcon,
                      size: 24,
                      semanticLabel: '검색',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, child) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              if (value.text.isEmpty)
                                const IgnorePointer(
                                  child: Text(
                                    '상호명, 지점명, 주소로 검색',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.placeholderText,
                                      fontFamily: 'Pretendard',
                                      fontSize: 16,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              EditableText(
                                controller: _controller,
                                focusNode: _focusNode,
                                autofocus: widget.autofocus,
                                cursorColor: AppColors.primary,
                                backgroundCursorColor: AppColors.textSecondary,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.search,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: AppColors.black,
                                  fontFamily: 'Pretendard',
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                onChanged: widget.onChanged,
                                onSubmitted: _handleSubmitted,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted();
  }
}
