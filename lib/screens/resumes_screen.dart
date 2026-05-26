import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider to fetch resumes from Supabase
final resumesProvider = FutureProvider<List<dynamic>>((ref) async {
  final supabase = Supabase.instance.client;
  final response = await supabase.from('resumes').select().order('updated_at', ascending: false);
  return response as List<dynamic>;
});

class ResumesScreen extends ConsumerWidget {
  const ResumesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsyncValue = ref.watch(resumesProvider);

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate600),
          onPressed: () => context.pop(),
        ),
        title: Text('My Resumes', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppTheme.blue600),
            onPressed: () {
              // Route to resume builder with empty ID
              context.push('/builder/new');
            },
          )
        ],
      ),
      body: resumesAsyncValue.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];
              return _buildResumeCard(context, resume);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            child: const Icon(LucideIcons.filePlus, size: 48, color: AppTheme.blue600),
          ),
          const SizedBox(height: 24),
          Text('No resumes yet', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Create your first ATS-friendly resume', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/builder/new');
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Create Resume'),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, dynamic resume) {
    final title = resume['title'] ?? 'Untitled Resume';
    final updatedAt = resume['updated_at'] != null 
        ? DateTime.parse(resume['updated_at']).toLocal().toString().split(' ')[0] 
        : 'Unknown date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          context.push('/builder/${resume['id']}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: AppTheme.cardDecoration,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.blue50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.fileText, color: AppTheme.blue600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Updated $updatedAt', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppTheme.slate400),
            ],
          ),
        ),
      ),
    );
  }
}
