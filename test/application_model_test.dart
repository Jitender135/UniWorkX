import 'package:flutter_test/flutter_test.dart';
import 'package:uni_work_x_01/models/application.dart';

void main() {
  test('Application model creates correct instance', () {
    final app = Application(
      jobTitle: 'Campus Assistant',
      company: 'UniX',
      appliedDate: '2025-05-26',
      status: ApplicationStatus.applied,
    );

    expect(app.jobTitle, 'Campus Assistant');
    expect(app.company, 'UniX');
    expect(app.status, ApplicationStatus.applied);
  });
}