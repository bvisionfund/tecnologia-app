import 'package:flutter/material.dart';
import 'package:tecnologia_app/models/reservation.dart';
import 'package:tecnologia_app/screens/completed_reservations_screen.dart';
import 'package:tecnologia_app/screens/driver_ratings_screen.dart';
import 'package:tecnologia_app/screens/driver_reservations_screen.dart';
import 'package:tecnologia_app/screens/rate_client_screen.dart';
import 'package:tecnologia_app/screens/rate_driver_screen.dart';

import 'models/availability_slot.dart';
import 'screens/admin_home_screen.dart';
import 'screens/availability_screen.dart';
import 'screens/driver_detail_screen.dart';
import 'screens/driver_home_screen.dart';
import 'screens/driver_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/user/map_driver_list_screen.dart';
import 'shared/request_closest_driver_screen.dart';

class Routes {
  static const login = '/';
  static const register = '/register';
  static const home = '/home';
  static const mapDrivers = '/map_drivers';
  static const requestClosest = '/request_closest_driver';
  static const driverHome = '/driver_home';
  static const adminHome = '/admin_home';
  static const availability = '/availability';
  static const drivers = '/drivers';
  static const driverDetail = '/driver_detail';
  static const reservation = '/reservation';
  static const myReservation = '/my_reservation';
  static const completedReservations = '/completed_reservation';
  static const rateClient = '/rate_client';
  static const rateDriver = '/rate_driver';
  static const driverRatings = '/ratings_driver';
  static const profile = '/profile';
  static const driverReservations = '/driver_reservations';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.driverRatings:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DriverRatingsScreen(driverId: id),
        );
      case Routes.rateDriver:
        final reservation = settings.arguments as Reservation;
        return MaterialPageRoute(
          builder: (_) => RateDriverScreen(reservation: reservation),
        );
      case Routes.completedReservations:
        return MaterialPageRoute(
          builder: (_) => const CompletedReservationsScreen(),
        );
      case Routes.rateClient:
        final reservation = settings.arguments as Reservation;
        return MaterialPageRoute(
          builder: (_) => RateClientScreen(reservation: reservation),
        );
      case Routes.driverReservations:
        return MaterialPageRoute(
          builder: (_) => const DriverReservationsScreen(),
        );
      case Routes.mapDrivers:
        return MaterialPageRoute(builder: (_) => const MapDriverListScreen());
      case Routes.requestClosest:
        return MaterialPageRoute(
          builder: (_) => const RequestClosestDriverScreen(),
        );
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.myReservation:
        return MaterialPageRoute(
          builder: (_) => const UserReservationsScreen(),
        );
      case Routes.driverHome:
        return MaterialPageRoute(builder: (_) => const DriverHomeScreen());
      case Routes.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case Routes.availability:
        return MaterialPageRoute(builder: (_) => const AvailabilityScreen());
      case Routes.drivers:
        return MaterialPageRoute(builder: (_) => const DriverListScreen());
      case Routes.driverDetail:
        final id = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DriverDetailScreen(driverId: id),
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
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
        );
    }
  }
}
