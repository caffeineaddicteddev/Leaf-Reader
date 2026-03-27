import 'package:go_router/go_router.dart';

import 'screens/library/library_screen.dart';
import 'screens/processing/processing_screen.dart';
import 'screens/reader/reader_screen.dart';
import 'screens/settings/settings_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String library = '/';
  static const String settings = '/settings';
  static const String processingPattern = '/processing/:bookId';
  static const String readerPattern = '/reader/:bookId';

  static String processing(String bookId) => '/processing/$bookId';
  static String reader(String bookId) => '/reader/$bookId';
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: AppRoutes.library, builder: (_, _) => const LibraryScreen()),
    GoRoute(
      path: AppRoutes.processingPattern,
      builder: (_, GoRouterState state) =>
          ProcessingScreen(bookId: state.pathParameters['bookId'] ?? ''),
    ),
    GoRoute(
      path: AppRoutes.readerPattern,
      builder: (_, GoRouterState state) =>
          ReaderScreen(bookId: state.pathParameters['bookId'] ?? ''),
    ),
    GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
  ],
);
