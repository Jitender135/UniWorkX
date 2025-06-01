enum ApplicationStatus {
  applied,
  underReview,
  shortlisted,
  completed,
}

class Application {
  final String jobTitle;
  final String company;
  final String appliedDate;
  final ApplicationStatus status;

  Application({
    required this.jobTitle,
    required this.company,
    required this.appliedDate,
    required this.status,
  });
}