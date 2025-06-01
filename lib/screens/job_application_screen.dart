import 'package:flutter/material.dart';
import '../models/job.dart';

class JobApplicationScreen extends StatefulWidget {
  final Job job;

  const JobApplicationScreen({required this.job, Key? key}) : super(key: key);

  @override
  _JobApplicationScreenState createState() => _JobApplicationScreenState();
}

class _JobApplicationScreenState extends State<JobApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivationController = TextEditingController();
  final _skillsController = TextEditingController();
  String _availability = 'Weekdays (9 AM - 5 PM)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Save Draft', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.job.company,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text('${widget.job.pay} • ', style: TextStyle(fontSize: 12)),
                          Text('${widget.job.location} • ', style: TextStyle(fontSize: 12)),
                          Text(widget.job.duration, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Why are you interested in this role?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _motivationController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Explain your motivation and relevant experience...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please explain your motivation';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Relevant Skills & Experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _skillsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'List your relevant skills, projects, coursework...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe your relevant skills';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Availability',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _availability,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: [
                  'Weekdays (9 AM - 5 PM)',
                  'Evenings (5 PM - 9 PM)',
                  'Weekends',
                  'Flexible'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _availability = value!);
                },
              ),
              SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.attach_file),
                label: Text('Upload Portfolio/Samples'),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: Text('Save Draft'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitApplication();
                  }
                },
                child: Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitApplication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Submitted!'),
        content: Text('Your application has been submitted successfully. You will be notified about the status.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}