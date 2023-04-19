// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/social_layout.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:flutter_learn_app/shared/bloc_observer.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/cubit/cubit.dart';
import 'package:flutter_learn_app/shared/cubit/states.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/network/remote/dio_helper.dart';
import 'package:flutter_learn_app/shared/styles/themes.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async
{
  print('on background message');
  print(message.data.toString());

  showToast(text: 'on background message', state: ToastStates.SUCCESS,);
}

void main() {
  BlocOverrides.runZoned(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      var token = await FirebaseMessaging.instance.getToken();

      print(token);


      // foreground fcm
      FirebaseMessaging.onMessage.listen((event)
      {
        print('on message');
        print(event.data.toString());

        showToast(text: 'on message', state: ToastStates.SUCCESS,);
      });

      // when click on notification to open app
      FirebaseMessaging.onMessageOpenedApp.listen((event)
      {
        print('on message opened app');
        print(event.data.toString());

        showToast(text: 'on message opened app', state: ToastStates.SUCCESS,);
      });

      // background fcm
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      DioHelper.init();
      await CacheHelper.init();



      Widget? widget;


      uId = CacheHelper.getData(key: 'uId');



      if(uId != null)
        {
          widget = SocialLayout();
        }
      else
        {
          widget = SocialLoginScreen();
        }

      runApp(MyApp(

        startWidget: widget,
      ));
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyApp extends StatelessWidget {

  final Widget? startWidget;

  // ignore: prefer_const_constructors_in_immutables, use_key_in_widget_constructors
  MyApp({this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [

        BlocProvider(
          create: (context) => AppCubit()
          //   ..changeAppMode(
          //   fromShared: isDark,
          // )
          ,
        ),
        BlocProvider(
          create: (context) => SocialCubit()
            ..getUserData()..getPosts(),
        ),
      ],
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            darkTheme: darkTheme,
            theme: lightTheme,
            home: startWidget,
          );
        },
      ),
    );
  }
}
