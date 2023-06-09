
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/global_method.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/comments/comments_screen.dart';
import 'package:flutter_learn_app/modules/social_app/post_details/post_details_screen.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

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
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(postId: message.data['postId']),
          ));
    }
    // if (message.data['type'] == 'comment') {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => TaskDetailsScreen(
    //           taskId: message.data['task_id'],
    //           uploadedBy: message.data['uploaded_by'],
    //         ),
    //       ));
    // }
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
          if(snapshot.hasData) {
            return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return buildPostItem(
                  snapshot.data?.docs[index], context, index);
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 8.0,
            ),
            itemCount: snapshot.data?.docs.length ?? 0,
          );
          }else
            {
              return const Center(child: CircularProgressIndicator(),);
            }

        });
  },
);
  }

  Widget buildPostItem(QueryDocumentSnapshot<Map<String, dynamic>>? model, context, index) {
    String uid = CacheHelper.getData(key: 'uId');
    bool _isLiked = model?['likes']?.contains(uid) ?? false;
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => navigateTo(context, SettingsScreen(userId: model?['uId']??'')),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25.0,
                    backgroundImage: NetworkImage(
                      '${model!['image']}',
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${model['name']}',
                              style: const TextStyle(
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: defaultColor,
                              size: 16.0,
                            ),
                          ],
                        ),
                        Text(
                          '${model['dataTime']?.split(':')[0]}:${model['dataTime']?.split(':')[1]}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_horiz,
                      size: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            Divider(
              thickness: 1.0,
              color: Colors.grey[300],
            ),
            const SizedBox(
              height: 15.0,
            ),
            if (model['text'] != '')
              Text(
                '${model['text']}',
              ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
                top: 5.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6.0),
                      child: SizedBox(
                        height: 25.0,
                        child: MaterialButton(
                          onPressed: () {},
                          minWidth: 1.0,
                          padding: EdgeInsets.zero,
                          child: Text(
                            '#software',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: defaultColor,
                                    ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6.0),
                      child: SizedBox(
                        height: 25.0,
                        child: MaterialButton(
                          onPressed: () {},
                          minWidth: 1.0,
                          padding: EdgeInsets.zero,
                          child: Text(
                            '#flutter',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: defaultColor,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (model['postImage'] != '')
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 15.0,
                ),
                child: Image(image: NetworkImage('${model['postImage']}')),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              IconBroken.Heart,
                              size: 16.0,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              '${model['likesCount']}',
                              style:
                              Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              IconBroken.Chat,
                              size: 16.0,
                              color: Colors.amber,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              model['comments'].length.toString() + ' comments',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.grey[300],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => showBottomSheet(
                      context: context, builder: (context) => CommentsScreen(postId: model.id, uploadedById: model['uId'],),),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18.0,
                          backgroundImage: NetworkImage(
                            SocialCubit.get(context).userModel?.image ?? '',
                          ),
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(
                          'write a comment ...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    String uid = CacheHelper.getData(key: 'uId');

                    if (_isLiked) {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(model.id)
                          .update({
                        'likes': FieldValue.arrayRemove([uid]),
                        'likesCount': FieldValue.increment(-1),
                      });

                      _isLiked = false;
                    } else {
                      await FirebaseFirestore.instance
                          .collection('posts')
                          .doc(model.id)
                          .update({
                        'likes': FieldValue.arrayUnion([uid]),
                        'likesCount': FieldValue.increment(1),
                      });

                      _isLiked = true;
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                        size: 16.0,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Text(
                        'like',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
