import 'package:flutter/material.dart';
import 'package:prolab_unimet/providers/auth_provider.dart';
import 'package:prolab_unimet/views/dashboard_view.dart';
import 'package:prolab_unimet/views/landing_page_view.dart';
import 'package:prolab_unimet/views/layouts/admin_layout.dart';
import 'package:prolab_unimet/views/login_view.dart';
import 'package:prolab_unimet/views/projects_view.dart';
import 'package:prolab_unimet/views/register_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Define user roles for authorization
const userRoles = ['USER', 'ADMIN', 'COORDINATOR'];

// ==== Validation method ====
String? _requireAuth(BuildContext context, List<String> allowedRoles) {
  final auth = Provider.of<AuthProvider>(context, listen: false);

  // If the user is not authenticated redirect to login
  if (!auth.isAuthenticated) return '/login';

  // If the user.role is not allowed redirects to login
  if (!allowedRoles.contains(auth.role)) return '/login';

  // If everything is OK keep the normal flow
  return null;
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ===== PUBLIC ROUTES =====
    GoRoute(path: '/', builder: (context, state) => LandingPageView()),
    GoRoute(path: '/login', builder: (context, state) => LoginView()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterView(),
    ),

    // ===== PROTECTED ROUTES =====
    ShellRoute(
      builder: (context, state, child) => AdminLayout(child: child),
      routes: [
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const DashboardView(),
          redirect: (context, state) => _requireAuth(context, userRoles),
        ),
        GoRoute(
          path: '/admin-projects',
          builder: (context, state) => const ProjectsView(),
          redirect: (context, state) => _requireAuth(context, userRoles),
        ),
      ],
    ),
  ],
);
