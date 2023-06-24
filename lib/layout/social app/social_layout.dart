import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/global_method.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/friend_requests/friend_requests_screen.dart';
import 'package:flutter_learn_app/modules/social_app/new_post/new_post_screen.dart';
import 'package:flutter_learn_app/modules/social_app/post_details/post_details_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class SocialLayout extends StatefulWidget {
  const SocialLayout({Key? key}) : super(key: key);

  @override
  State<SocialLayout> createState() => _SocialLayoutState();
}

class _SocialLayoutState extends State<SocialLayout> {

  Future<void> setupInteractedMessage() async {
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async {
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
  }

  @override
  void initState() {
    super.initState();
    uId = CacheHelper.getData(key: 'uId');
    globalMethods.registerNotification(context);
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialCubit()..getPosts(),
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
                IconButton(
                  onPressed: () {
                    navigateTo(context, const FriendRequestsScreen());
                  },
                  icon: const Icon(IconBroken.Add_User),
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
      ),
    );
  }
}
