import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/social_layout.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:flutter_learn_app/shared/bloc_observer.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/network/remote/dio_helper.dart';
import 'package:flutter_learn_app/shared/styles/themes.dart';


void main() {
  BlocOverrides.runZoned(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      DioHelper.init();
      await CacheHelper.init();

      Widget? widget;



      uId = CacheHelper.getData(key: 'uId');


      if (uId != null) {
        widget = SocialLayout();
      }
      else {
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

  final Widget startWidget;

  const MyApp({Key? key, required this.startWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialCubit()..getPosts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: lightTheme,
        theme: lightTheme,
        home: startWidget,
      ),
    );
  }
}
