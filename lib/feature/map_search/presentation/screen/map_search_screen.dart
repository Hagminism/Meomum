import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_store_list_item.dart';
import 'package:meomum/feature/map_search/presentation/component/map_search_field.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_action.dart';
import 'package:meomum/feature/map_search/presentation/screen/map_search_state.dart';
import 'package:meomum/ui/app_colors.dart';

class MapSearchScreen extends StatelessWidget {
  final MapSearchState state;
  final void Function(MapSearchAction action) onAction;
  final void Function(CommercialStore store)? onStoreSelected;

  const MapSearchScreen({
    super.key,
    required this.state,
    required this.onAction,
    this.onStoreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.homeBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => onAction(const MapSearchAction.backPressed()),
          tooltip: '지도 화면으로 돌아가기',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          '장소 검색',
          style: TextStyle(
            color: AppColors.black,
            fontFamily: 'Pretendard',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: MapSearchField(
                query: state.query,
                autofocus: true,
                onChanged: (query) {
                  onAction(MapSearchAction.queryChanged(query));
                },
                onSubmitted: () {
                  onAction(const MapSearchAction.searchSubmitted());
                },
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (state.isLoading) {
      return Center(
        child: Semantics(
          label: '매장을 검색하는 중입니다',
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final errorMessage = state.errorMessage;
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.snackBarError,
                size: 40,
                semanticLabel: '오류',
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.feedContentText,
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  onAction(const MapSearchAction.retryPressed());
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                color: AppColors.textSecondary,
                size: 40,
                semanticLabel: '검색 결과 없음',
              ),
              SizedBox(height: 12),
              Text(
                '검색 결과가 없습니다.',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '상호명, 지점명 또는 주소를 확인해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isInitial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '찾고 싶은 매장의 이름이나 주소를 입력해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Pretendard',
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final store = state.results[index];
        return MapStoreListItem(
          key: ValueKey(store.id),
          store: store,
          onTap: onStoreSelected == null ? null : () => onStoreSelected!(store),
        );
      },
    );
  }
}
