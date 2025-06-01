class Job {
  final String title;
  final String company;
  final String pay;
  final String location;
  final String duration;
  final String description;
  final List<String> tags;
  final bool isUrgent;

  Job({
    required this.title,
    required this.company,
    required this.pay,
    required this.location,
    required this.duration,
    required this.description,
    required this.tags,
    required this.isUrgent,
  });
}