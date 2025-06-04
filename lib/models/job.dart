class Job {
  final String? id; // Add ID for Firestore document
  final String title;
  final String company;
  final String companyId; // Add company ID reference
  final String pay;
  final String location;
  final String duration;
  final String description;
  final List<String> tags;
  final bool isUrgent;
  final DateTime createdAt; // Add timestamp
  final DateTime? applicationDeadline; // Add deadline
  final String category; // Add category
  final String experienceLevel; // Add experience level
  final String? requirements; // Add requirements
  final String? responsibilities; // Add responsibilities
  final String? benefits; // Add benefits
  final bool isActive; // Add status

  Job({
    this.id,
    required this.title,
    required this.company,
    required this.companyId,
    required this.pay,
    required this.location,
    required this.duration,
    required this.description,
    required this.tags,
    required this.isUrgent,
    required this.createdAt,
    this.applicationDeadline,
    required this.category,
    required this.experienceLevel,
    this.requirements,
    this.responsibilities,
    this.benefits,
    this.isActive = true,
  });

  // Convert Job to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'companyId': companyId,
      'pay': pay,
      'location': location,
      'duration': duration,
      'description': description,
      'tags': tags,
      'isUrgent': isUrgent,
      'createdAt': createdAt.toIso8601String(),
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'category': category,
      'experienceLevel': experienceLevel,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'isActive': isActive,
    };
  }

  // Create Job from Firestore document
  factory Job.fromMap(Map<String, dynamic> map, String id) {
    return Job(
      id: id,
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      companyId: map['companyId'] ?? '',
      pay: map['pay'] ?? '',
      location: map['location'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isUrgent: map['isUrgent'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      applicationDeadline: map['applicationDeadline'] != null
          ? DateTime.parse(map['applicationDeadline'])
          : null,
      category: map['category'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      requirements: map['requirements'],
      responsibilities: map['responsibilities'],
      benefits: map['benefits'],
      isActive: map['isActive'] ?? true,
    );
  }

  // Create a copy with updated fields
  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? companyId,
    String? pay,
    String? location,
    String? duration,
    String? description,
    List<String>? tags,
    bool? isUrgent,
    DateTime? createdAt,
    DateTime? applicationDeadline,
    String? category,
    String? experienceLevel,
    String? requirements,
    String? responsibilities,
    String? benefits,
    bool? isActive,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyId: companyId ?? this.companyId,
      pay: pay ?? this.pay,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt ?? this.createdAt,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      category: category ?? this.category,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      requirements: requirements ?? this.requirements,
      responsibilities: responsibilities ?? this.responsibilities,
      benefits: benefits ?? this.benefits,
      isActive: isActive ?? this.isActive,
    );
  }
}