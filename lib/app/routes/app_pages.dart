import 'package:get/get.dart';
import '../feature/auth/view/login_view.dart';
import '../feature/auth/view/register_view.dart';



part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.register, page: () => const RegisterView()),
  //   GetPage(name: Routes.home, page: () => const HomeView()),
  //   GetPage(name: Routes.dashboard, page: () => const DashboardView()),
  //   GetPage(name: Routes.history, page: () => const HistoryView()),
  //   GetPage(name: Routes.profile, page: () => const ProfileView()),
  // ];
  ];
}
