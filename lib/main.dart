import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Uncomment these lines if using Firebase emulators for development
  // if (kDebugMode) {
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  // }
  
  runApp(const MealTimeApp());
}

class MealTimeApp extends StatelessWidget {
  const MealTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MealTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF58700),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}

