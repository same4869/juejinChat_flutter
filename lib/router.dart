import 'package:go_router/go_router.dart';
import 'package:juejin_chat_demo/widgets/settings_screen.dart';

import 'widgets/chat_history.dart';
import 'widgets/chat_screen.dart';

final router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => ChatScreen(),
  ),
  GoRoute(
    path: '/history',
    builder: (context, state) => ChatHistory(),
  ),
  GoRoute(
    path: '/settings',
    builder: (context, state) => SettingsScreen(),
  )
]);
