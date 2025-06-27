import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ReservaChoferesApp()));
}

class ReservaChoferesApp extends StatelessWidget {
  const ReservaChoferesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Choferes',
      theme: ThemeData(primarySwatch: Colors.brown),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.login,
    );
  }
}