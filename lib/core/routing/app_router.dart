import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/presentation/screens/home/home_screen.dart';
import 'package:vocario/presentation/screens/settings/settings_screen.dart';
import 'package:vocario/presentation/screens/about/about_screen.dart';
import 'package:vocario/presentation/screens/licensing/licensing_screen.dart';
import 'package:vocario/presentation/screens/summaries/summaries_screen.dart';
import 'package:vocario/presentation/screens/summaries/summary_details_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String audioSummarizer = '/audio-summarizer';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String licensing = '/licensing';
  static const String summaries = '/summaries';
  static const String summaryDetails = '/summaries/:id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: summaries,
        name: 'summaries',
        builder: (context, state) => const SummariesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'summaryDetails',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SummaryDetailsScreen(recordingId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: audioSummarizer,
        name: 'audioSummarizer',
        builder: (context, state) => const Placeholder(
          child: Center(
            child: Text('Audio Summarizer Screen'),
          ),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: licensing,
        name: 'licensing',
        builder: (context, state) => const LicensingScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}