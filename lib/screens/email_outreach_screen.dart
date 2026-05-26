import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailOutreachScreen extends ConsumerStatefulWidget {
  const EmailOutreachScreen({super.key});

  @override
  ConsumerState<EmailOutreachScreen> createState() => _EmailOutreachScreenState();
}

class _EmailOutreachScreenState extends ConsumerState<EmailOutreachScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;
  bool _isDrafting = false;

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _draftWithAI() async {
    setState(() => _isDrafting = true);
    // Simulate AI delay for now
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _subjectController.text = "Application for Software Engineer Role";
        _bodyController.text = "Dear Hiring Manager,\n\nI am writing to express my strong interest in the open position at your company. With my background in software development and proven track record of delivering high-quality products, I believe I am an excellent fit for this role.\n\nI would welcome the opportunity to discuss how my skills align with your needs.\n\nBest regards,\nJob Seeker";
        _isDrafting = false;
      });
    }
  }

  Future<void> _sendEmail() async {
    final to = _toController.text.trim();
    if (to.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final supabase = Supabase.instance.client;
      await supabase.functions.invoke('send-outreach-email', body: {
        'to': to,
        'subject': _subjectController.text,
        'body': _bodyController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sent successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate600),
          onPressed: () => context.pop(),
        ),
        title: Text('Email Outreach', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.sparkles, color: Colors.teal),
            onPressed: _draftWithAI,
            tooltip: 'Draft with AI',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.teal.shade600,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.mail, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Strategic Outreach', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Draft high-conversion emails with AI', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: AppTheme.cardDecoration,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _toController,
                    decoration: const InputDecoration(labelText: 'Recipient Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Subject'),
                  ),
                  const SizedBox(height: 16),
                  if (_isDrafting)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(labelText: 'Message Body', alignLabelWithHint: true),
                      maxLines: 8,
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: _isSending
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
