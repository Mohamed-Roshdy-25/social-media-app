import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/modules/social_app/friend_requests/friend_requests_screen.dart';
import 'package:flutter_learn_app/modules/social_app/post_details/post_details_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

GlobalMethods globalMethods = GlobalMethods();

class GlobalMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

   void showErrorDialog({required String error, required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Error occured'),
                ),
              ],
            ),
            content: Text(
              error,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  void registerNotification(context) {
    User? user = _auth.currentUser;
    String? uid = user?.uid;

    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      configureLocalNotifications(message,context);
      showLocalNotification(message.notification ?? const RemoteNotification());
    });

    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        FirebaseFirestore.instance.collection('users').doc(uid).update({
          'token': token,
        });
      }
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  void configureLocalNotifications(RemoteMessage message, context) {
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iOSInitializationSettings =
    const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (message.data['type'] == 'post') {
          navigateTo(context, PostDetailsScreen(postId: message.data['postId']));
        }
        if (message.data['type'] == 'comment') {
          navigateTo(context, PostDetailsScreen(postId: message.data['postId']));
        }
        if(message.data['type'] == 'friend request'){
          navigateTo(context, const FriendRequestsScreen());
        }
        if (message.data['type'] == 'like') {
          navigateTo(context, PostDetailsScreen(postId: message.data['postId']));
        }
      },
    );
  }

   void showLocalNotification(RemoteNotification remoteNotification) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "com.example.flutter_learn_app",
      "sociality",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      remoteNotification.hashCode,
      remoteNotification.title,
      remoteNotification.body,
      notificationDetails,
      payload: null,
    );
  }
}
