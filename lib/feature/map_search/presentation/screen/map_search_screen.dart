import 'package:flutter/material.dart';
import 'package:meomum/core/domain/model/commercial_store/commercial_store.dart';
import 'package:meomum/core/presentation/component/custom_app_bar.dart';
import 'package:meomum/feature/map/presentation/component/drawer/map_store_list_item.dart';
import 'package:meomum/feature/map_search/presentation/component/map_search_error_view.dart';
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
      appBar: CustomAppBar(
        title: '장소 검색',
        showBackButton: true,
        backButtonTooltip: '지도 화면으로 돌아가기',
        onBackPressed: () {
          onAction(const MapSearchAction.backPressed());
        },
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

    if (state.errorMessage != null) {
      return MapSearchErrorView(
        onRetry: () {
          onAction(const MapSearchAction.retryPressed());
        },
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
