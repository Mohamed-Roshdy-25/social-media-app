import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/new_post/new_post_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/cubit/cubit.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

// ignore: use_key_in_widget_constructors
class SocialLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    uId = CacheHelper.getData(key: 'uId');
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppCubit(),
          ),
          BlocProvider(
            create: (context) => SocialCubit()
              ..getUserData()
              ..getPosts(),
          ),
        ],
        child: BlocConsumer<SocialCubit, SocialStates>(
          listener: (context, state) {

            if (state is SocialNewPostState) {
              navigateTo(context, NewPostScreen());
            }
          },
          builder: (context, state) {
            var cubit = SocialCubit.get(context);

            return Scaffold(
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(IconBroken.Notification),
                  ),
                ],
              ),
              body: cubit.screens[cubit.currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeBottomNav(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Home,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Chat,
                    ),
                    label: 'Chats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Paper_Upload,
                    ),
                    label: 'Post',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Location,
                    ),
                    label: 'Users',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      IconBroken.Profile,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
        ));
  }
}
