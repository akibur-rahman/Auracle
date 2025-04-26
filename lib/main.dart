import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    log('Loaded .env file successfully');
  } catch (e) {
    log('Failed to load .env file: $e');
    // Continue without the .env file for development
  }

  try {
    await Supabase.initialize(
      url:
          dotenv.env['SUPABASE_URL'] ??
          'https://placeholder-supabase-url.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder-anon-key',
    );
    log('Initialized Supabase successfully');
  } catch (e) {
    log('Failed to initialize Supabase: $e');
    // Continue without Supabase for UI development
  }

  runApp(const ProviderScope(child: AuracleApp()));
}

class AuracleApp extends ConsumerWidget {
  const AuracleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auracle',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
