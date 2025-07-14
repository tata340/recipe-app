class AppwriteHelper {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '6871be210034a4edc491';
  static const String bucketId = '6871c481001bc0d0b02a'; // replace with actual bucket ID

  static String getPreviewUrl(String fileId) {
  return '$endpoint/storage/buckets/$bucketId/files/$fileId/preview?project=6871be210034a4edc491';
}


}
