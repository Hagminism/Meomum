import 'package:image_picker/image_picker.dart';
import 'package:meomum/feature/community/domain/model/community_post_image.dart';

class CommunityPostFormMedia {
  final XFile? localFile;
  final CommunityPostImage? existingImage;

  const CommunityPostFormMedia.local({
    required XFile file,
  }) : localFile = file,
       existingImage = null;

  const CommunityPostFormMedia.remote({
    required CommunityPostImage image,
  }) : localFile = null,
       existingImage = image;

  bool get isLocal => localFile != null;

  String get path => localFile?.path ?? existingImage!.storagePath;
}
