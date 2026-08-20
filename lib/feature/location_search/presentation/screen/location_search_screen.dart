import 'package:flutter/material.dart';
import 'package:meomum/feature/location_search/presentation/component/location_search_item.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_action.dart';
import 'package:meomum/feature/location_search/presentation/screen/location_search_state.dart';
import 'package:meomum/ui/app_colors.dart';

class LocationSearchScreen extends StatelessWidget {
  final LocationSearchState state;
  final void Function(LocationSearchAction) onAction;

  const LocationSearchScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.writeBackground,
      appBar: AppBar(
        backgroundColor: AppColors.writeBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.placeholderText,
          ),
          onPressed: () => onAction(const LocationSearchAction.tapBack()),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
            child: TextFormField(
              initialValue: state.query,
              autofocus: true,
              cursorColor: AppColors.primary,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                onAction(LocationSearchAction.changeQuery(value));
              },
              onFieldSubmitted: (_) {
                onAction(const LocationSearchAction.search());
              },
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
              decoration: const InputDecoration(
                hintText: '장소, 주소를 검색해 보세요',
                hintStyle: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.placeholderText,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.hintIcon,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        titleSpacing: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.uploadButton,
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Text(
          state.errorMessage!,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.feedMetaText,
          ),
        ),
      );
    }

    if (state.places.isEmpty) {
      return const Center(
        child: Text(
          '검색어를 입력하여 장소를 찾아보세요',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.feedMetaText,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.places.length,
      itemBuilder: (context, index) {
        final place = state.places[index];
        return LocationSearchItem(
          place: place,
          onTap: (selected) {
            onAction(LocationSearchAction.selectPlace(selected));
          },
        );
      },
    );
  }
}
