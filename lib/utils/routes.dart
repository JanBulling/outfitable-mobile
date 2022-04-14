import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ui/screens/add_clothing_screen.dart';
import 'dependency_injection.dart';

// Bloc / Cubit
import '../cubits/tensorflow_cubit.dart';
import '../services/tensorflow_service.dart';

// Screens
import '../ui/screens/classification_screen.dart';
import '../ui/screens/general/start_screen.dart';
import '../ui/screens/closet_details_screen.dart';

const String ROUTE_START = "/";
const String ROUTE_CLASSIFICATION = "classification";
const String ROUTE_ADD_CLOTHING = "add_clothing";
const String ROUTE_CLOSET_DETAILS = "closet_details";

class Routes {
  static Route? generateRoute(RouteSettings settings) {
    Map? args;
    if (settings.arguments != null) args = settings.arguments as Map;

    switch (settings.name) {
      case ROUTE_START:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const StartScreen(),
        );

      case ROUTE_CLASSIFICATION:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => TensorflowCubit(injector<TensorflowService>()),
            child: const ClassificationScreen(),
          ),
        );

      case ROUTE_ADD_CLOTHING:
        return MaterialPageRoute(
          builder: (_) => AddClothingScreen(args == null ? null : Map<String, dynamic>.from(args)),
        );

      case ROUTE_CLOSET_DETAILS:
        int type = args!["type"];
        return MaterialPageRoute(
          builder: (_) => ClosetDetailsScreen(type),
        );

      default:
        return null;
    }
  }
}
