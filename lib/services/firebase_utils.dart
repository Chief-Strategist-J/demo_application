import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUtils {
  /// Safely updates a document by first checking if it exists.
  /// If the document doesn't exist, it will create it with the provided data.
  /// Uses set with merge option to handle both create and update operations.
  static Future<void> safeDocumentUpdate(
    DocumentReference docRef,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await docRef.set(data, SetOptions(merge: merge));
    } catch (e) {
      print('Error in safe document update: $e');
      rethrow;
    }
  }

  /// Safely gets a document and handles the case where it might not exist
  static Future<DocumentSnapshot?> safeDocumentGet(
    DocumentReference docRef,
  ) async {
    try {
      final doc = await docRef.get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  /// Batch operation for updating multiple documents safely
  static Future<void> safeBatchUpdate(
    List<MapEntry<DocumentReference, Map<String, dynamic>>> operations,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (final operation in operations) {
      batch.set(operation.key, operation.value, SetOptions(merge: true));
    }
    
    try {
      await batch.commit();
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  /// Check if a document exists without throwing an error
  static Future<bool> documentExists(DocumentReference docRef) async {
    try {
      final doc = await docRef.get();
      return doc.exists;
    } catch (e) {
      print('Error checking document existence: $e');
      return false;
    }
  }

  /// Create document with retry mechanism
  static Future<void> createDocumentWithRetry(
    DocumentReference docRef,
    Map<String, dynamic> data, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        await docRef.set(data, SetOptions(merge: true));
        return;
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          print('Failed to create document after $maxRetries attempts: $e');
          rethrow;
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
  }
}
