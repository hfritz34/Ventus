import 'package:flutter/material.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventus'),
      ),
      body: const Center(
        child: Text('Your alarms will appear here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add alarm screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
