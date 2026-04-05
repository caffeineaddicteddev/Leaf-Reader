import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/library/library_screen.dart';
import 'screens/processing/processing_screen.dart';
import 'screens/reader/reader_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/leaf_bottom_nav.dart';

class AppRoutes {
  const AppRoutes._();

  static const String library = '/';
  static const String settings = '/settings';
  static const String processingPattern = '/processing/:bookId';
  static const String readerPattern = '/reader/:bookId';

  static String processing(String bookId) => '/processing/$bookId';
  static String reader(String bookId, {double? initialScrollOffset}) =>
      initialScrollOffset == null || initialScrollOffset == 0.0
      ? '/reader/$bookId'
      : '/reader/$bookId?offset=$initialScrollOffset';
}

enum AppNavigationDirection { forward, backward }

AppNavigationDirection _directionFromState(GoRouterState state) {
  final Object? extra = state.extra;
  if (extra is AppNavigationDirection) {
    return extra;
  }
  return AppNavigationDirection.forward;
}

CustomTransitionPage<void> _buildSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  final AppNavigationDirection direction = _directionFromState(state);
  final Offset beginOffset = direction == AppNavigationDirection.forward
      ? const Offset(1, 0)
      : const Offset(-1, 0);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final Animation<Offset> offsetAnimation = Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeOutCubic,
        ),
      );
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      pageBuilder: (
        BuildContext context,
        GoRouterState state,
        Widget child,
      ) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: Scaffold(
            body: child,
            bottomNavigationBar: LeafBottomNav(
              currentIndex: state.matchedLocation == AppRoutes.settings ? 1 : 0,
            ),
          ),
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final AppNavigationDirection direction = _directionFromState(state);
            final Offset beginOffset =
                direction == AppNavigationDirection.forward
                    ? const Offset(1, 0)
                    : const Offset(-1, 0);
            final Animation<Offset> offsetAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeOutCubic,
              ),
            );
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.library,
          pageBuilder: (_, GoRouterState state) => const NoTransitionPage<void>(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (_, GoRouterState state) => const NoTransitionPage<void>(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.processingPattern,
      pageBuilder: (_, GoRouterState state) => _buildSlidePage(
        state: state,
        child: ProcessingScreen(bookId: state.pathParameters['bookId'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.readerPattern,
      pageBuilder: (_, GoRouterState state) => _buildSlidePage(
        state: state,
        child: ReaderScreen(
          bookId: state.pathParameters['bookId'] ?? '',
          initialScrollOffset: double.tryParse(
            state.uri.queryParameters['offset'] ?? '',
          ),
        ),
      ),
    ),
  ],
);
