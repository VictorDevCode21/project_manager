import 'package:go_router/go_router.dart';
import 'package:web_project_manager/views/landing_page_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LandingPageView(),
      routes: [

]),
  ],
);
