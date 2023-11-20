import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qf/notifications.dart';
import 'colors.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  OneSignal.Debug.setLogLevel(OSLogLevel.info);
  OneSignal.initialize("57be7846-370e-477a-972a-342998cc0b43");
  OneSignal.Notifications.requestPermission(true);
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  OneSignal.Notifications.addClickListener((event) {
    navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(),
      ),
    );
  });

  await Future.delayed(const Duration(seconds: 2));
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!);
      },
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Quality Foods',
      theme: ThemeData(
        primaryColor: primary(),
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(),
    ),
  );
}
