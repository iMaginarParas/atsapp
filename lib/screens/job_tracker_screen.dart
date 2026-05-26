import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to fetch job applications
final jobsProvider = FutureProvider<List<dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return [];
  
  final response = await supabase
      .from('job_applications')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  return response as List<dynamic>;
});

class JobTrackerScreen extends ConsumerWidget {
  const JobTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(jobsProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.slate50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate600),
            onPressed: () => context.pop(),
          ),
          title: Text('Job Tracker', style: Theme.of(context).textTheme.titleLarge),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.plus, color: AppTheme.blue600),
              onPressed: () {
                _showAddJobDialog(context, ref);
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppTheme.blue600,
            unselectedLabelColor: AppTheme.slate400,
            indicatorColor: AppTheme.blue600,
            tabs: [
              Tab(text: 'Applied'),
              Tab(text: 'Interviewing'),
              Tab(text: 'Offered'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: jobsAsyncValue.when(
          data: (jobs) {
            if (jobs.isEmpty) {
              return _buildEmptyState(context, ref);
            }
            return TabBarView(
              children: [
                _buildJobList(context, ref, jobs, 'applied'),
                _buildJobList(context, ref, jobs, 'interviewing'),
                _buildJobList(context, ref, jobs, 'offered'),
                _buildJobList(context, ref, jobs, 'rejected'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.blue50,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.list, size: 48, color: AppTheme.blue600),
          ),
          const SizedBox(height: 24),
          Text('Pipeline is clear', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Track your job applications here.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddJobDialog(context, ref),
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add Application'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(BuildContext context, WidgetRef ref, List<dynamic> allJobs, String status) {
    final jobs = allJobs.where((j) => (j['status'] ?? 'applied') == status).toList();

    if (jobs.isEmpty) {
      return Center(
        child: Text('No jobs in this stage', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.slate400)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return _buildJobCard(context, ref, job);
      },
    );
  }

  Widget _buildJobCard(BuildContext context, WidgetRef ref, dynamic job) {
    final company = job['company'] ?? 'Unknown Company';
    final position = job['position'] ?? 'Unknown Position';
    final location = job['location'] ?? 'Remote';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.blue50,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                company.toString().isNotEmpty ? company.toString()[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.blue600),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(position, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(company, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.mapPin, size: 12, color: AppTheme.slate400),
                      const SizedBox(width: 4),
                      Text(location, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.moreVertical, color: AppTheme.slate400),
              onPressed: () {
                _showJobOptionsBottomSheet(context, ref, job);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJobOptionsBottomSheet(BuildContext context, WidgetRef ref, dynamic job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.slate200, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(LucideIcons.arrowRightCircle, color: AppTheme.blue600),
                title: const Text('Move to Interviewing'),
                onTap: () async {
                  context.pop();
                  await _updateJobStatus(context, ref, job['id'], 'interviewing');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.checkCircle2, color: Colors.green),
                title: const Text('Move to Offered'),
                onTap: () async {
                  context.pop();
                  await _updateJobStatus(context, ref, job['id'], 'offered');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.xCircle, color: Colors.red),
                title: const Text('Move to Rejected'),
                onTap: () async {
                  context.pop();
                  await _updateJobStatus(context, ref, job['id'], 'rejected');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: AppTheme.rose500),
                title: const Text('Delete Application', style: TextStyle(color: AppTheme.rose500)),
                onTap: () async {
                  context.pop();
                  await _deleteJob(context, ref, job['id']);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateJobStatus(BuildContext context, WidgetRef ref, String id, String status) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('job_applications').update({'status': status}).eq('id', id);
      ref.invalidate(jobsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating: $e')));
      }
    }
  }

  Future<void> _deleteJob(BuildContext context, WidgetRef ref, String id) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('job_applications').delete().eq('id', id);
      ref.invalidate(jobsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting: $e')));
      }
    }
  }

  void _showAddJobDialog(BuildContext context, WidgetRef ref) {
    final companyController = TextEditingController();
    final positionController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Job Application'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company')),
              const SizedBox(height: 12),
              TextField(controller: positionController, decoration: const InputDecoration(labelText: 'Position')),
              const SizedBox(height: 12),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final company = companyController.text.trim();
                final position = positionController.text.trim();
                if (company.isEmpty || position.isEmpty) return;

                context.pop();
                try {
                  final supabase = Supabase.instance.client;
                  final userId = supabase.auth.currentUser?.id;
                  if (userId != null) {
                    await supabase.from('job_applications').insert({
                      'user_id': userId,
                      'company': company,
                      'position': position,
                      'location': locationController.text.trim(),
                      'status': 'applied',
                    });
                    ref.invalidate(jobsProvider);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding job: $e')));
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
