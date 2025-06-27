import 'package:flutter/material.dart';
import 'models/availability_slot.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/driver_list_screen.dart';
import 'screens/driver_detail_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/profile_screen.dart';

class Routes {
  static const login = '/';
  static const home = '/home';
  static const drivers = '/drivers';
  static const driverDetail = '/driver_detail';
  static const reservation = '/reservation';
  static const profile = '/profile';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.drivers:
        return MaterialPageRoute(builder: (_) => const DriverListScreen());
      case Routes.driverDetail:
        final driverId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DriverDetailScreen(driverId: driverId),
        );
      case Routes.reservation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReservationScreen(
            driverId: args['driverId'] as String,
            slot: args['slot'] as AvailabilitySlot,
          ),
        );
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}