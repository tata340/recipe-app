import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

class StorageService {
  final storage = Storage(
    Client()
      ..setEndpoint('https://cloud.appwrite.io/v1')
      ..setProject('6871be210034a4edc491'),
  );

  Future<String> uploadRecipeImage({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      final result = await storage.createFile(
        bucketId: '6871c481001bc0d0b02a',
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: fileName,
          contentType: mimeType,
        ),
      );

      return 'https://cloud.appwrite.io/v1/storage/buckets/recipes-bucket/files/${result.$id}/view?project=6871be210034a4edc491';
    } catch (e) {
      debugPrint('Error uploading recipe image: $e');
      rethrow;
    }
  }

  Future<String> uploadProfileImage({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    try {
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      final result = await storage.createFile(
        bucketId: '6871c481001bc0d0b02a',
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: fileBytes,
          filename: fileName,
          contentType: mimeType,
        ),
      );

      return 'https://cloud.appwrite.io/v1/storage/buckets/profiles-bucket/files/${result.$id}/view?project=6871be210034a4edc491';
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }
}
