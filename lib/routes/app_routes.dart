import 'package:flutter/widgets.dart';

import '../pages/home_page.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/home': (c) => const HomePage(),
  };
}
