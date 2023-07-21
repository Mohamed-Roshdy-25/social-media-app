import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/friend_requests/friend_requests_screen.dart';
import 'package:flutter_learn_app/modules/social_app/post_details/post_details_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/widgets/Post_item_widget.dart';

class FeedsScreen extends StatefulWidget {
  const FeedsScreen({Key? key}) : super(key: key);

  @override
  State<FeedsScreen> createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
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
    if (message.data['type'] == 'friend request') {
      navigateTo(context, const FriendRequestsScreen());
    }
    if (message.data['type'] == 'like') {
      navigateTo(context, PostDetailsScreen(postId: message.data['postId']));
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SocialCubit, SocialStates>(
      builder: (context, state) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: SocialCubit.get(context).posts,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                if (snapshot.data?.docs.isNotEmpty ?? false) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return PostItemWidget(model: snapshot.data?.docs[index],context: context,);
                    },
                    itemCount: snapshot.data?.docs.length ?? 0,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/no_posts.png'),
                        Text(
                          'No Feeds',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Search for your friends and sent a friend request to them to show their feeds here and yours',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    );
  }
}
