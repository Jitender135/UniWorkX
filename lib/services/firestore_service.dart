import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Existing methods...
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

  Future<void> approveCompany(String id, Map<String, dynamic> companyData) async {
    final pendingCompanyRef = _db.collection('pending_companies').doc(id);
    final approvedCompaniesRef = _db.collection('approved_companies');

    final pendingDoc = await pendingCompanyRef.get();
    final pendingData = pendingDoc.data();

    final batch = _db.batch();

    final newApprovedCompanyRef = approvedCompaniesRef.doc();
    batch.set(newApprovedCompanyRef, companyData);

    batch.delete(pendingCompanyRef);

    await batch.commit();

    await logActivity(
      type: 'company_approved',
      activity: 'Company approved',
      additionalData: {
        'companyId': id,
        'companyName': pendingData?['name'] ?? companyData['name'] ?? 'Unknown',
      },
    );
  }

  Future<void> declineCompany(String id) async {
    final companyDoc = await _db.collection('pending_companies').doc(id).get();
    final companyData = companyDoc.data();

    await _db.collection('pending_companies').doc(id).delete();

    await logActivity(
      type: 'company_declined',
      activity: 'Company declined',
      additionalData: {
        'companyId': id,
        'companyName': companyData?['name'] ?? 'Unknown',
      },
    );
  }

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

  // NEW JOB MANAGEMENT METHODS

  /// Post a new job to Firestore
  Future<String> postJob(Job job) async {
    try {
      final docRef = await _db.collection('jobs').add(job.toMap());

      // Log the job posting activity
      await logActivity(
        type: 'job_posted',
        activity: 'New job posted',
        additionalData: {
          'jobId': docRef.id,
          'jobTitle': job.title,
          'company': job.company,
          'companyId': job.companyId,
        },
      );

      return docRef.id;
    } catch (e) {
      print('Error posting job: $e');
      rethrow;
    }
  }

  /// Get all active jobs stream for student dashboard
  Stream<QuerySnapshot> getActiveJobs() {
    return _db
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get jobs by company ID
  Stream<QuerySnapshot> getJobsByCompany(String companyId) {
    return _db
        .collection('jobs')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get jobs with filters
  Stream<QuerySnapshot> getFilteredJobs({
    String? category,
    String? location,
    bool? isUrgent,
    String? experienceLevel,
  }) {
    Query query = _db.collection('jobs').where('isActive', isEqualTo: true);

    if (category != null && category != 'All') {
      if (category == 'Urgent') {
        query = query.where('isUrgent', isEqualTo: true);
      } else if (category == 'Remote') {
        query = query.where('location', isEqualTo: 'Remote');
      } else {
        query = query.where('category', isEqualTo: category);
      }
    }

    if (location != null) {
      query = query.where('location', isEqualTo: location);
    }

    if (isUrgent != null) {
      query = query.where('isUrgent', isEqualTo: isUrgent);
    }

    if (experienceLevel != null) {
      query = query.where('experienceLevel', isEqualTo: experienceLevel);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  /// Search jobs by title or description
  Future<List<Job>> searchJobs(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation. For better search, consider using Algolia or similar
      final querySnapshot = await _db
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .get();

      final jobs = querySnapshot.docs
          .map((doc) => Job.fromMap(doc.data(), doc.id))
          .where((job) =>
      job.title.toLowerCase().contains(searchTerm.toLowerCase()) ||
          job.description.toLowerCase().contains(searchTerm.toLowerCase()) ||
          job.company.toLowerCase().contains(searchTerm.toLowerCase()) ||
          job.tags.any((tag) => tag.toLowerCase().contains(searchTerm.toLowerCase())))
          .toList();

      return jobs;
    } catch (e) {
      print('Error searching jobs: $e');
      return [];
    }
  }

  /// Update job status (activate/deactivate)
  Future<void> updateJobStatus(String jobId, bool isActive) async {
    try {
      await _db.collection('jobs').doc(jobId).update({'isActive': isActive});

      await logActivity(
        type: 'job_status_updated',
        activity: 'Job status updated',
        additionalData: {
          'jobId': jobId,
          'isActive': isActive,
        },
      );
    } catch (e) {
      print('Error updating job status: $e');
      rethrow;
    }
  }

  /// Delete a job
  Future<void> deleteJob(String jobId) async {
    try {
      await _db.collection('jobs').doc(jobId).delete();

      await logActivity(
        type: 'job_deleted',
        activity: 'Job deleted',
        additionalData: {
          'jobId': jobId,
        },
      );
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }

  /// Get job by ID
  Future<Job?> getJobById(String jobId) async {
    try {
      final doc = await _db.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return Job.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting job: $e');
      return null;
    }
  }

  /// Get job statistics for company dashboard
  Future<Map<String, int>> getJobStatistics(String companyId) async {
    try {
      final allJobs = await _db
          .collection('jobs')
          .where('companyId', isEqualTo: companyId)
          .get();

      final activeJobs = allJobs.docs.where((doc) => doc.data()['isActive'] == true).length;
      final urgentJobs = allJobs.docs.where((doc) => doc.data()['isUrgent'] == true).length;
      final totalJobs = allJobs.docs.length;

      return {
        'totalJobs': totalJobs,
        'activeJobs': activeJobs,
        'urgentJobs': urgentJobs,
        'inactiveJobs': totalJobs - activeJobs,
      };
    } catch (e) {
      print('Error getting job statistics: $e');
      return {
        'totalJobs': 0,
        'activeJobs': 0,
        'urgentJobs': 0,
        'inactiveJobs': 0,
      };
    }
  }

  // Existing methods continue...
  Stream<QuerySnapshot> getApprovedCompanies() {
    return _db
        .collection('approved_companies')
        .orderBy('approvedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _db.collection('users').snapshots();
  }

  Stream<QuerySnapshot> getRecentActivities() {
    return _db
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots();
  }

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

  Future<void> addStudentWithLogging(Map<String, dynamic> studentData) async {
    final docRef = await _db.collection('users').add(studentData);
    await logUserRegistration(docRef.id, studentData['type'] ?? 'student');
  }

  Future<void> addPendingCompanyWithLogging(Map<String, dynamic> companyData) async {
    final docRef = await _db.collection('pending_companies').add(companyData);
    await logCompanyRegistration(docRef.id, companyData['name'] ?? 'Unknown Company');
  }

  Future<Map<String, int>> getDashboardCounts() async {
    try {
      final pendingCompanies = await _db
          .collection('pending_companies')
          .where('status', isEqualTo: 'pending')
          .get();

      final approvedCompanies = await _db.collection('approved_companies').get();
      final totalUsers = await _db.collection('users').get();
      final totalJobs = await _db.collection('jobs').get();

      return {
        'pendingCompanies': pendingCompanies.docs.length,
        'approvedCompanies': approvedCompanies.docs.length,
        'totalUsers': totalUsers.docs.length,
        'totalJobs': totalJobs.docs.length,
      };
    } catch (e) {
      print('Error getting dashboard counts: $e');
      return {
        'pendingCompanies': 0,
        'approvedCompanies': 0,
        'totalUsers': 0,
        'totalJobs': 0,
      };
    }
  }
}