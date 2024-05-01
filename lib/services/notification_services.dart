import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:whatsapp/whatsapp.dart';
import 'package:background_fetch/background_fetch.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();




 
Future <void> initNotifications() async {
  

  //configuracion solo en android
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
}

Future <void> showNotification({required int idNotification}) async {


  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    !.requestNotificationsPermission();

  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    !.requestExactAlarmsPermission();


  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'notification_channel_Id', 
    'notification_channel_Name',
    importance: Importance.max,
    priority: Priority.high,
  );

  // configuracion IOS
  /* const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(); */
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  
  await flutterLocalNotificationsPlugin.zonedSchedule(
    idNotification,
    'Titulo de la notificacion',
    'Contenido de la notificacion',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 40)),
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime


  );

  

  /* await flutterLocalNotificationsPlugin.show(
    1, 
    'Notificación de cambio de aceite', 
    'Acuerdese de realizar el cambio de aceite', 
    notificationDetails
  ); */


}