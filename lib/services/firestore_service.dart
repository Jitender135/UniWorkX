import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addStudent(Map<String, dynamic> studentData) {
    return _db.collection('users').add(studentData);
  }

  Future<void> addPendingCompany(Map<String, dynamic> companyData) {
    return _db.collection('pending_companies').add(companyData);
  }

  Stream<QuerySnapshot> getPendingCompanies() {
    return _db
        .collection('pending_companies')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: false)
        .snapshots();
  }

  Future<QuerySnapshot> getPendingCompaniesOnce() {
    return _db
        .collection('pending_companies')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .get();
  }

  /// Approves a pending company:
  /// Moves company data to 'approved_companies' collection
  /// Deletes from 'pending_companies'
  Future<void> approveCompany(String id, Map<String, dynamic> companyData) async {
    final pendingCompanyRef = _db.collection('pending_companies').doc(id);
    final approvedCompaniesRef = _db.collection('approved_companies');

    final batch = _db.batch();

    final newApprovedCompanyRef = approvedCompaniesRef.doc();
    batch.set(newApprovedCompanyRef, companyData);

    batch.delete(pendingCompanyRef);

    return batch.commit();
  }

  Future<void> declineCompany(String id) {
    return _db.collection('pending_companies').doc(id).delete();
  }

  /// Checks company status by email:
  /// Returns 'pending', 'approved', or null
  Future<String?> getCompanyStatusByEmail(String email) async {
    final query = await _db
        .collection('pending_companies')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['status'] as String;
    }

    final approvedQuery = await _db
        .collection('approved_companies')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (approvedQuery.docs.isNotEmpty) {
      return 'approved';
    }

    return null;
  }
}
//