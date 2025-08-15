import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'constants/app_strings.dart';
import 'constants/app_theme.dart';
import 'constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/subscription_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_tabs.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const SyncMyScheduleApp());
}

class SyncMyScheduleApp extends StatelessWidget {
  const SyncMyScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.theme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainTabs(),
          '/profile': (context) => const ProfileScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
        },
      ),
    );
  }
}
