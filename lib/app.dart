import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fota_uploader/config/theme/app_theme.dart';
import 'package:fota_uploader/core/utils/app_strings.dart';
import 'package:fota_uploader/features/splash/screens/splash_screen.dart';

import 'config/navigation/navigation.dart';

class FotaUploaderApp extends StatelessWidget {
  const FotaUploaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        ScreenUtil.configure(data: MediaQuery.of(context));
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          theme: appTheme(),
          navigatorKey: navigatorKey,
          home: SplashScreen(),
        );
      },
    );
  }
}
