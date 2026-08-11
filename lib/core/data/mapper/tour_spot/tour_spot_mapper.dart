import 'package:meomum/core/data/dto/tour_spot/tour_spot_dto.dart';
import 'package:meomum/core/domain/model/tour_spot/tour_spot.dart';

extension TourSpotDtoMapper on TourSpotDto {
  // 좌표를 파싱할 수 없으면 지도에 표시할 수 없으므로 null을 반환한다.
  TourSpot? toModel() {
    final id = contentId;
    final latitude = double.tryParse(mapY ?? '');
    final longitude = double.tryParse(mapX ?? '');

    if (id == null || id.isEmpty || latitude == null || longitude == null) {
      return null;
    }

    return TourSpot(
      id: id,
      title: (title != null && title!.isNotEmpty) ? title! : '이름 없음',
      latitude: latitude,
      longitude: longitude,
      address: _resolveAddress(),
      distanceMeter: double.tryParse(dist ?? ''),
      contentTypeId: contentTypeId,
      thumbnailImageUrl: _resolveThumbnailImageUrl(),
      tel: (tel != null && tel!.isNotEmpty) ? tel : null,
      copyrightDivisionCode: cpyrhtDivCd,
    );
  }

  String? _resolveAddress() {
    final base = addr1;
    if (base == null || base.isEmpty) return null;

    final detail = addr2;
    if (detail != null && detail.isNotEmpty) {
      return '$base $detail';
    }

    return base;
  }

  String? _resolveThumbnailImageUrl() {
    if (firstImage2 != null && firstImage2!.isNotEmpty) {
      return firstImage2;
    }
    if (firstImage != null && firstImage!.isNotEmpty) {
      return firstImage;
    }
    return null;
  }
}
