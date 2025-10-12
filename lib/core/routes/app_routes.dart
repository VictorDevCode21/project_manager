import 'package:prolab_unimet/views/landing_page_view.dart';
import 'package:prolab_unimet/views/login_view.dart';
import 'package:prolab_unimet/views/register_view.dart';
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
        GoRoute(path: '/login', builder: (context, state) => LoginView()),
      ],
    ),
  ],
);
