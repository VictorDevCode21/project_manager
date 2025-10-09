import 'package:flutter_application_landing_page/views/landing_page_view.dart';
import 'package:flutter_application_landing_page/views/register_view.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPageView(),
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterView(),
        ),
      ],
    ),
  ],
);
