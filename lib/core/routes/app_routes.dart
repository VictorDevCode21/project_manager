import 'package:prolab_unimet/views/dashboard_view.dart';
import 'package:prolab_unimet/views/landing_page_view.dart';
import 'package:prolab_unimet/views/layouts/admin_layout.dart';
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
        ShellRoute(
          builder: (context, state, child) => AdminLayout(child: child),
          routes: [
            GoRoute(
              path: '/admin-dashboard',
              builder: (context, state) => const DashboardView(),
            ),
            // GoRoute(
            //   path: '/admin-projects',
            //   builder: (context, state) => const ProjectsView(),
            // ),
            // GoRoute(
            //   path: '/admin-tasks',
            //   builder: (context, state) => const Placeholder(),
            // ),
          ],
        ),
      ],
    ),
  ],
);
