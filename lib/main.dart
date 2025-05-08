import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> initializeApp() async {
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    log('Environment variables loaded successfully');

    // Initialize Supabase
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Missing Supabase credentials in .env file');
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    log('Supabase initialized successfully');
  } catch (e, stackTrace) {
    log('Failed to initialize app', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeApp();
    runApp(const ProviderScope(child: AuracleApp()));
  } catch (e) {
    log('Fatal error during app initialization', error: e);
    // You might want to show a user-friendly error screen here
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize app. Please try again later.',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ),
      ),
    );
  }
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
