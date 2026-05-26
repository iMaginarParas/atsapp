import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  final String resumeId;
  const ResumeBuilderScreen({super.key, required this.resumeId});

  @override
  ConsumerState<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  Map<String, dynamic> _resumeData = {
    'personalInfo': {},
    'experience': [],
    'education': [],
    'skills': [],
    'summary': '',
  };
  String _resumeTitle = 'Untitled Resume';
  
  // Controllers for Personal Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.resumeId != 'new') {
      _loadResume();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadResume() async {
    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('resumes').select().eq('id', widget.resumeId).single();
      
      setState(() {
        _resumeTitle = data['title'] ?? 'Untitled Resume';
        if (data['resume_data'] != null) {
          _resumeData = Map<String, dynamic>.from(data['resume_data']);
          
          final personalInfo = _resumeData['personalInfo'] ?? {};
          _fullNameController.text = personalInfo['fullName'] ?? '';
          _emailController.text = personalInfo['email'] ?? '';
          _phoneController.text = personalInfo['phone'] ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading resume: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResume() async {
    // Update local state first
    _resumeData['personalInfo'] = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    };

    setState(() => _isLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      if (widget.resumeId == 'new') {
        final data = await supabase.from('resumes').insert({
          'user_id': user.id,
          'title': _resumeTitle,
          'resume_data': _resumeData,
        }).select().single();
        if (mounted) context.pushReplacement('/builder/${data['id']}');
      } else {
        await supabase.from('resumes').update({
          'title': _resumeTitle,
          'resume_data': _resumeData,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.resumeId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume saved')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving resume: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && widget.resumeId != 'new' && _resumeData['personalInfo'] == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.slate600),
          onPressed: () => context.pop(),
        ),
        title: Text(_resumeTitle, style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton.icon(
            onPressed: _saveResume,
            icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.save, size: 18),
            label: const Text('Save'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.blue600),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _saveResume();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        onStepTapped: (step) {
          setState(() => _currentStep = step);
        },
        steps: [
          Step(
            title: const Text('Personal Info'),
            content: _buildPersonalInfoForm(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Experience'),
            content: _buildExperienceForm(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Education'),
            content: _buildEducationForm(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Skills'),
            content: _buildSkillsForm(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildExperienceForm() {
    final experience = List<Map<String, dynamic>>.from(_resumeData['experience'] ?? []);
    return Column(
      children: [
        ...experience.asMap().entries.map((entry) {
          final index = entry.key;
          final exp = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.slate200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Experience ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: AppTheme.rose500),
                        onPressed: () {
                          setState(() {
                            experience.removeAt(index);
                            _resumeData['experience'] = experience;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: exp['title'] ?? '',
                    decoration: const InputDecoration(labelText: 'Job Title'),
                    onChanged: (val) {
                      experience[index]['title'] = val;
                      _resumeData['experience'] = experience;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: exp['company'] ?? '',
                    decoration: const InputDecoration(labelText: 'Company'),
                    onChanged: (val) {
                      experience[index]['company'] = val;
                      _resumeData['experience'] = experience;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: exp['startDate'] ?? '',
                          decoration: const InputDecoration(labelText: 'Start Date (e.g. Jan 2020)'),
                          onChanged: (val) {
                            experience[index]['startDate'] = val;
                            _resumeData['experience'] = experience;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: exp['endDate'] ?? '',
                          decoration: const InputDecoration(labelText: 'End Date (or Present)'),
                          onChanged: (val) {
                            experience[index]['endDate'] = val;
                            _resumeData['experience'] = experience;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: exp['description'] ?? '',
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (val) {
                      experience[index]['description'] = val;
                      _resumeData['experience'] = experience;
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              experience.add({'title': '', 'company': '', 'startDate': '', 'endDate': '', 'description': '', 'bullets': []});
              _resumeData['experience'] = experience;
            });
          },
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add Experience'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.blue50,
            foregroundColor: AppTheme.blue600,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationForm() {
    final education = List<Map<String, dynamic>>.from(_resumeData['education'] ?? []);
    return Column(
      children: [
        ...education.asMap().entries.map((entry) {
          final index = entry.key;
          final edu = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppTheme.slate200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Education ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: AppTheme.rose500),
                        onPressed: () {
                          setState(() {
                            education.removeAt(index);
                            _resumeData['education'] = education;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: edu['degree'] ?? '',
                    decoration: const InputDecoration(labelText: 'Degree'),
                    onChanged: (val) {
                      education[index]['degree'] = val;
                      _resumeData['education'] = education;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: edu['school'] ?? '',
                    decoration: const InputDecoration(labelText: 'School / University'),
                    onChanged: (val) {
                      education[index]['school'] = val;
                      _resumeData['education'] = education;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: edu['startDate'] ?? '',
                          decoration: const InputDecoration(labelText: 'Start Date'),
                          onChanged: (val) {
                            education[index]['startDate'] = val;
                            _resumeData['education'] = education;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: edu['endDate'] ?? '',
                          decoration: const InputDecoration(labelText: 'End Date'),
                          onChanged: (val) {
                            education[index]['endDate'] = val;
                            _resumeData['education'] = education;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              education.add({'degree': '', 'school': '', 'startDate': '', 'endDate': ''});
              _resumeData['education'] = education;
            });
          },
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Add Education'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.blue50,
            foregroundColor: AppTheme.blue600,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSkillsForm() {
    final skills = List<String>.from(_resumeData['skills'] ?? []);
    final skillController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: skillController,
                decoration: const InputDecoration(labelText: 'Add Skill (e.g. Flutter, React)'),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() {
                      skills.add(val.trim());
                      _resumeData['skills'] = skills;
                    });
                    skillController.clear();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.plus, color: AppTheme.blue600),
              onPressed: () {
                final val = skillController.text.trim();
                if (val.isNotEmpty) {
                  setState(() {
                    skills.add(val);
                    _resumeData['skills'] = skills;
                  });
                  skillController.clear();
                }
              },
            )
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                setState(() {
                  skills.remove(skill);
                  _resumeData['skills'] = skills;
                });
              },
              backgroundColor: AppTheme.blue50,
              labelStyle: const TextStyle(color: AppTheme.blue600),
              deleteIconColor: AppTheme.blue600,
            );
          }).toList(),
        ),
      ],
    );
  }
}
