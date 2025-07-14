import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../constants/appwrite_config.dart';

class AppwriteService {
  final Client client = Client()
    ..setEndpoint(AppwriteConfig.endpoint)
    ..setProject(AppwriteConfig.projectId);

  late final Storage storage;

  AppwriteService() {
    storage = Storage(client);
  }

  Future<models.File> uploadFile(File file) async {
    return await storage.createFile(
      bucketId: AppwriteConfig.bucketId,
      fileId: ID.unique(),
      file: InputFile.fromPath(path: file.path),
    );
  }

  /// Builds a URL to access a file from Appwrite Storage
  String getImageUrl(String fileId) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.bucketId}/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }
}
