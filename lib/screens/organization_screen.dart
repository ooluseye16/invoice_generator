import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_generator/providers/organization_provider.dart';
import 'package:invoice_generator/providers/preferences_provider.dart';
import 'package:invoice_generator/screens/home/create_organization.dart';
import 'package:invoice_generator/screens/home/form_screen.dart';

class OrganizationScreen extends ConsumerStatefulWidget {
  static const routeName = '/organization';
  const OrganizationScreen({super.key});

  @override
  ConsumerState<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends ConsumerState<OrganizationScreen> {
  @override
  Widget build(BuildContext context) {
    final organizationsAsync = ref.watch(organizationsProvider);
    final currentOrgId = ref.watch(currentOrganizationIdProvider);

    return organizationsAsync.when(
        loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (error, stack) => Scaffold(
              body: Center(
                child: Text('Error: $error'),
              ),
            ),
        data: (organizations) {
          if (organizations.isEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No organizations yet'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, CreateOrganizationScreen.routeName);
                      },
                      child: const Text('Create New Organization'),
                    ),
                  ],
                ),
              ),
            );
          }

          final org = organizations.firstWhere(
            (org) => org.id == currentOrgId,
            orElse: () => organizations.first,
          );
          return Scaffold(
            drawer: const AppDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).colorScheme.primary,
                                image: org.logoPath != null
                                    ? DecorationImage(
                                        image: FileImage(File(org.logoPath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          org.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrganizationFormScreen(
                      organization: org,
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsData = ref.watch(organizationsProvider);
    final currentOrgId = ref.watch(currentOrganizationIdProvider);
    return organizationsData.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => Text('Error: $error'),
      data: (organizations) => Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Organizations',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      final org = organizations[index];
                      final isSelected = currentOrgId != null
                          ? org.id == currentOrgId
                          : index == 0;

                      return InkWell(
                        onTap: () {
                          ref
                              .read(currentOrganizationIdProvider.notifier)
                              .setCurrentOrganization(org.id);
                          ref
                              .read(currentOrganizationIdProvider.notifier)
                              .clear();
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withOpacity(0.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: org.logoPath != null
                                        ? DecorationImage(
                                            image:
                                                FileImage(File(org.logoPath!)),
                                            fit: BoxFit.cover,
                                            onError: (_, __) {},
                                          )
                                        : null,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  width: 40,
                                  height: 40,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(org.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    Text(org.phoneNumber,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline)),
                                  ],
                                )),
                                if (isSelected)
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text('Delete Organization'),
                                          content: const Text(
                                              'Are you sure you want to delete this organization? This action cannot be undone.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(organizationsProvider
                                                        .notifier)
                                                    .deleteOrganization(org);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                        context, CreateOrganizationScreen.routeName);
                  },
                  child: const Text('Create New Organization'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
