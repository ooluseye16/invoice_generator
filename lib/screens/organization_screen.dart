import 'package:flutter/material.dart';

class OrganizationScreen extends StatelessWidget {
  static const routeName = '/organization';
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  0, // TODO: Replace with actual organization list length
              itemBuilder: (context, index) {
                return const Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                        'Organization Name'), // TODO: Replace with actual org name
                    subtitle: Text(
                        'Created by: User Name'), // TODO: Replace with actual user
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
              context, '/create-organization'); // TODO: Add this route
        },
        label: const Text('Create Organization'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
