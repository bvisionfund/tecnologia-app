import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: ReservaChoferesApp()));
}

class ReservaChoferesApp extends StatelessWidget {
  const ReservaChoferesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safrider',
      theme: ThemeData(
        // Color principal (appBar, elementos destacados)
        primaryColor: AppColors.navy,

        // Fondo por defecto
        scaffoldBackgroundColor: AppColors.navy,

        // Texto por defecto
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.silverGrey),
          bodyMedium: TextStyle(color: AppColors.silverGrey),
        ),

        // Inputs de texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.navy.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.silverGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.forestGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(color: AppColors.silverGrey),
        ),

        // Botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forestGreen,
            foregroundColor: AppColors.navy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),

        // TextButtons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.silverGrey),
        ),

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          elevation: 0,
          titleTextStyle: TextStyle(color: AppColors.silverGrey, fontSize: 20),
          iconTheme: IconThemeData(color: AppColors.silverGrey),
        ),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
