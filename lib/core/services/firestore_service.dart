import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCollection(String collectionPath) async {
    try {
      final querySnapshot = await _firestore.collection(collectionPath).get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Stream<List<Map<String, dynamic>>> getCollectionStream(String collectionPath) {
    try {
      return _firestore.collection(collectionPath).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList();
      });
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getDocument(String collectionPath, String documentId) async {
    try {
      final docSnapshot = await _firestore.collection(collectionPath).doc(documentId).get();
      if (docSnapshot.exists) {
        return {
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        };
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getCollectionWithQuery(
    String collectionPath, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? where,
  }) async {
    try {
      Query query = _firestore.collection(collectionPath);

      if (where != null) {
        where.forEach((field, value) {
          query = query.where(field, isEqualTo: value);
        });
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<void> updateDocument(String collectionPath, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<void> setDocument(String collectionPath, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Stream<Map<String, dynamic>?> getDocumentStream(String collectionPath, String documentId) {
    try {
      return _firestore.collection(collectionPath).doc(documentId).snapshots().map((docSnapshot) {
        if (docSnapshot.exists) {
          return {
            'id': docSnapshot.id,
            ...docSnapshot.data()!,
          };
        }
        return null;
      });
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }

  Future<void> deleteDocument(String collectionPath, String documentId) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException._fromFirebaseException(e);
    } catch (e) {
      throw FirestoreException('Unknown error occurred: ${e.toString()}');
    }
  }
}

class FirestoreException implements Exception {
  final String message;
  final String? code;

  FirestoreException(this.message, [this.code]);

  factory FirestoreException._fromFirebaseException(FirebaseException e) {
    String message;
    switch (e.code) {
      case 'permission-denied':
        message = 'You do not have permission to access this data.';
        break;
      case 'unavailable':
        message = 'The service is currently unavailable. Please try again later.';
        break;
      case 'deadline-exceeded':
        message = 'The operation took too long to complete. Please try again.';
        break;
      case 'not-found':
        message = 'The requested data was not found.';
        break;
      case 'already-exists':
        message = 'The data you are trying to create already exists.';
        break;
      case 'resource-exhausted':
        message = 'Quota exceeded. Please try again later.';
        break;
      case 'failed-precondition':
        message = 'The operation failed due to a conflict. Please refresh and try again.';
        break;
      case 'aborted':
        message = 'The operation was aborted due to a conflict. Please try again.';
        break;
      case 'out-of-range':
        message = 'The operation was attempted past the valid range.';
        break;
      case 'unimplemented':
        message = 'This operation is not implemented or not supported.';
        break;
      case 'internal':
        message = 'An internal error occurred. Please try again later.';
        break;
      case 'data-loss':
        message = 'Unrecoverable data loss or corruption.';
        break;
      default:
        message = e.message ?? 'An unknown error occurred.';
    }
    return FirestoreException(message, e.code);
  }

  @override
  String toString() => 'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
}