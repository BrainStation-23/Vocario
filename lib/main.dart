import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vocario/core/routing/app_router.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/theme/app_theme.dart';
import 'package:vocario/core/providers/app_providers.dart';
import 'package:vocario/core/providers/language_provider.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  LoggerService.info('App starting...');
  
  runApp(
    const ProviderScope(
      child: VocarioApp(),
    ),
  );
}

class VocarioApp extends ConsumerWidget {
  const VocarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(languageNotifierProvider);

    return MaterialApp.router(
      title: 'Vocario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: AppRouter.router,
    );
  }
}
