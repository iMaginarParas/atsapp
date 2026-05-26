import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.blue600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.fileText, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Text('ATS Pro', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppTheme.slate600),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppTheme.blue50,
              child: Text('JS', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.blue600)),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Welcome back, Job Seeker',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn().slideY(begin: 0.1),
              
              const SizedBox(height: 8),
              
              Text(
                'Here is what is happening with your applications today.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Quick Actions Grid
              Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildActionCard(context, 'Resume Builder', 'Create ATS-friendly resumes', LucideIcons.layoutTemplate, AppTheme.blue600, AppTheme.blue50, delay: 300, onTap: () => context.push('/resumes')),
                  _buildActionCard(context, 'Job Tracker', 'Manage your applications', LucideIcons.list, Colors.amber.shade600, Colors.amber.shade50, delay: 400, onTap: () => context.push('/job-tracker')),
                  _buildActionCard(context, 'Email Outreach', 'AI drafted emails', LucideIcons.mail, Colors.teal.shade600, Colors.teal.shade50, delay: 500, onTap: () => context.push('/email-outreach')),
                  _buildActionCard(context, 'Interview Prep', 'Mock sessions with AI', LucideIcons.mic, Colors.purple.shade600, Colors.purple.shade50, delay: 600, onTap: () => context.push('/interview-prep')),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activity Shell
              Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 16),
              Container(
                decoration: AppTheme.cardDecoration,
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(LucideIcons.activity, color: AppTheme.slate300, size: 48),
                    const SizedBox(height: 16),
                    Text('No recent activity', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Start building your resume to see updates here.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color iconColor, Color bgColor, {required int delay, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9), delay: delay.ms);
  }
}
