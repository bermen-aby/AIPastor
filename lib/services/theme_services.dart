import 'package:flutter/material.dart';

import '../variables.dart';

class ThemeServices {
  backgroundImage(BuildContext context) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(isDarkModeVar
            ? 'assets/images/bg/bg_b_01.jpg'
            : 'assets/images/bg/bg_w_01.jpg'),
        fit: BoxFit.cover,
      ),
    );
  }
}
