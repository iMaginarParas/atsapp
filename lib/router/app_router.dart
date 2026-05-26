import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/resumes_screen.dart';
import '../screens/resume_builder_screen.dart';
import '../screens/job_tracker_screen.dart';
import '../screens/email_outreach_screen.dart';
import '../screens/interview_prep_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/resumes',
      builder: (context, state) => const ResumesScreen(),
    ),
    GoRoute(
      path: '/builder/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ResumeBuilderScreen(resumeId: id);
      },
    ),
    GoRoute(
      path: '/job-tracker',
      builder: (context, state) => const JobTrackerScreen(),
    ),
    GoRoute(
      path: '/email-outreach',
      builder: (context, state) => const EmailOutreachScreen(),
    ),
    GoRoute(
      path: '/interview-prep',
      builder: (context, state) => const InterviewPrepScreen(),
    ),
  ],
);
