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
  /// Logs the activity
  Future<void> approveCompany(String id, Map<String, dynamic> companyData) async {
    final pendingCompanyRef = _db.collection('pending_companies').doc(id);
    final approvedCompaniesRef = _db.collection('approved_companies');

    // Get the pending company data before deletion for logging
    final pendingDoc = await pendingCompanyRef.get();
    final pendingData = pendingDoc.data();

    final batch = _db.batch();

    final newApprovedCompanyRef = approvedCompaniesRef.doc();
    batch.set(newApprovedCompanyRef, companyData);

    batch.delete(pendingCompanyRef);

    await batch.commit();

    // Log activity after successful approval
    await logActivity(
      type: 'company_approved',
      activity: 'Company approved',
      additionalData: {
        'companyId': id,
        'companyName': pendingData?['name'] ?? companyData['name'] ?? 'Unknown',
      },
    );
  }

  /// Declines a pending company and logs the activity
  Future<void> declineCompany(String id) async {
    // Get company data before deletion for logging
    final companyDoc = await _db.collection('pending_companies').doc(id).get();
    final companyData = companyDoc.data();

    // Delete from pending companies
    await _db.collection('pending_companies').doc(id).delete();

    // Log activity
    await logActivity(
      type: 'company_declined',
      activity: 'Company declined',
      additionalData: {
        'companyId': id,
        'companyName': companyData?['name'] ?? 'Unknown',
      },
    );
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

  // NEW METHODS FOR REAL-TIME DASHBOARD FUNCTIONALITY

  /// Get approved companies stream for real-time dashboard
  Stream<QuerySnapshot> getApprovedCompanies() {
    return _db
        .collection('approved_companies')
        .orderBy('approvedAt', descending: true)
        .snapshots();
  }

  /// Get all users stream (both students and companies) for real-time dashboard
  Stream<QuerySnapshot> getAllUsers() {
    return _db
        .collection('users')
        .snapshots();
  }

  /// Get recent activities stream for real-time dashboard
  Stream<QuerySnapshot> getRecentActivities() {
    return _db
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

  /// Log activities for dashboard tracking
  Future<void> logActivity({
    required String type,
    required String activity,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      await _db.collection('activities').add({
        'type': type,
        'activity': activity,
        'timestamp': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// Log user registration activity (call this when students register)
  Future<void> logUserRegistration(String userId, String userType) async {
    await logActivity(
      type: 'user_registered',
      activity: 'New user registered',
      additionalData: {
        'userId': userId,
        'userType': userType,
      },
    );
  }

  /// Log company registration activity (call this when companies register)
  Future<void> logCompanyRegistration(String companyId, String companyName) async {
    await logActivity(
      type: 'company_registered',
      activity: 'New company registered',
      additionalData: {
        'companyId': companyId,
        'companyName': companyName,
      },
    );
  }

  /// Enhanced addStudent method with activity logging
  Future<void> addStudentWithLogging(Map<String, dynamic> studentData) async {
    final docRef = await _db.collection('users').add(studentData);

    // Log the user registration
    await logUserRegistration(
      docRef.id,
      studentData['type'] ?? 'student',
    );
  }

  /// Enhanced addPendingCompany method with activity logging
  Future<void> addPendingCompanyWithLogging(Map<String, dynamic> companyData) async {
    final docRef = await _db.collection('pending_companies').add(companyData);

    // Log the company registration
    await logCompanyRegistration(
      docRef.id,
      companyData['name'] ?? 'Unknown Company',
    );
  }

  /// Get total counts for dashboard (alternative method if streams are heavy)
  Future<Map<String, int>> getDashboardCounts() async {
    try {
      final pendingCompanies = await _db
          .collection('pending_companies')
          .where('status', isEqualTo: 'pending')
          .get();

      final approvedCompanies = await _db
          .collection('approved_companies')
          .get();

      final totalUsers = await _db
          .collection('users')
          .get();

      return {
        'pendingCompanies': pendingCompanies.docs.length,
        'approvedCompanies': approvedCompanies.docs.length,
        'totalUsers': totalUsers.docs.length,
      };
    } catch (e) {
      print('Error getting dashboard counts: $e');
      return {
        'pendingCompanies': 0,
        'approvedCompanies': 0,
        'totalUsers': 0,
      };
    }
  }
}