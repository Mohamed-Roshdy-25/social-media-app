// ignore_for_file: sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/comments/comments_screen.dart';
import 'package:flutter_learn_app/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:flutter_learn_app/modules/social_app/likes/likes_screen.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:flutter_learn_app/modules/social_app/user_images/user_images_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  const SettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool _isSameUser = widget.userId == uId;
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SocialCubit, SocialStates>(
          builder: (context, state) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_isSameUser ? uId : widget.userId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if(userSnapshot.data == null){
                    return Container();
                  }
                  bool _isFollow =
                      userSnapshot.data?['followers']?.contains(uId) ?? false;
                  var requestsIds = userSnapshot.data?['receivingRequests']
                          .map((request) => request['userId'])
                          .toList() ??
                      [];
                  bool _isRequested = requestsIds.contains(uId) ?? false;
                  if (userSnapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .snapshots(),
                            builder: (context, snapshot) {
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  currentUserPosts = snapshot.data?.docs
                                          .where((element) =>
                                              element['uId'] ==
                                              (_isSameUser
                                                  ? CacheHelper.getData(
                                                      key: 'uId')
                                                  : widget.userId))
                                          .toList() ??
                                      [];
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  currentUserImages = currentUserPosts
                                      .where((element) =>
                                          element['postImage'] != '')
                                      .toList();

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 190.0,
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.bottomCenter,
                                      children: [
                                        Align(
                                          child: Container(
                                            height: 140.0,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(4.0),
                                                  topRight:
                                                      Radius.circular(4.0),
                                                ),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '${userSnapshot.data?['cover']}'),
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          alignment:
                                              AlignmentDirectional.topCenter,
                                        ),
                                        CircleAvatar(
                                          radius: 64.0,
                                          backgroundColor: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: CircleAvatar(
                                            radius: 60.0,
                                            backgroundImage: NetworkImage(
                                              '${userSnapshot.data?['image']}',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    '${userSnapshot.data?['name']}',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    '${userSnapshot.data?['bio']}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${currentUserPosts.length}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                Text(
                                                  'Posts',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              children: [
                                                Text(
                                                  currentUserImages.length
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                Text(
                                                  'Photos',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              navigateTo(
                                                  context,
                                                  UserImagesScreen(
                                                      images:
                                                          currentUserImages));
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              children: [
                                                Text(
                                                  userSnapshot
                                                          .data?['followers']
                                                          ?.length
                                                          .toString() ??
                                                      '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                Text(
                                                  'Followers',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            child: Column(
                                              children: [
                                                Text(
                                                  userSnapshot
                                                          .data?['following']
                                                          .length
                                                          .toString() ??
                                                      '',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                Text(
                                                  'Following',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            onTap: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: widget.userId == uId
                                              ? () async {
                                                  await Future.wait([
                                                    SocialCubit.get(context)
                                                        .signOut(),
                                                    CacheHelper.removeData(
                                                        key: 'uId'),
                                                  ]);
                                                  navigateAndFinish(context,
                                                      SocialLoginScreen());
                                                }
                                              : () async {
                                                  if (_isFollow) {
                                                    await unfollowUser(
                                                        uId ?? '',
                                                        widget.userId);
                                                    FirebaseMessaging.instance
                                                        .unsubscribeFromTopic(
                                                            widget.userId);
                                                  } else if (_isRequested) {
                                                    removeFollowRequest(
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.uId ??
                                                          '',
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.name ??
                                                          '',
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.image ??
                                                          '',
                                                      SocialCubit.get(context)
                                                          .userModel
                                                          ?.token ??
                                                          '',
                                                      widget.userId,
                                                    );
                                                  } else {
                                                    await sendFollowRequest(
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.uId ??
                                                          '',
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.name ??
                                                          '',
                                                      SocialCubit.get(context)
                                                              .userModel
                                                              ?.image ??
                                                          '',
                                                      SocialCubit.get(context)
                                                          .userModel
                                                          ?.token ??
                                                          '',
                                                      widget.userId,
                                                    );
                                                    fireApi.sendNotifyFromFirebase(title: 'Friend Request', body: '${SocialCubit.get(context).userModel?.name} asked you to be a friends', sendNotifyTo: userSnapshot.data?['token'], type: 'friend request');
                                                    // await followUser(uId ?? '',
                                                    //     widget.userId);
                                                    // FirebaseMessaging.instance
                                                    //     .subscribeToTopic(
                                                    //         widget.userId);
                                                  }
                                                },
                                          child: Text(
                                            widget.userId == uId
                                                ? 'Logout'
                                                : _isFollow
                                                    ? 'UnFollow'
                                                    : _isRequested
                                                        ? 'Request sent'
                                                        : 'Follow',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      OutlinedButton(
                                        onPressed: () {
                                          navigateTo(
                                              context, EditProfileScreen());
                                        },
                                        child: const Icon(
                                          IconBroken.Edit,
                                          size: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    children: [
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return buildPostItem(
                                              currentUserPosts[index],
                                              context,
                                              index);
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                          height: 8.0,
                                        ),
                                        itemCount: currentUserPosts.length,
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          },
        ),
      ),
    );
  }

  Widget buildPostItem(
      QueryDocumentSnapshot<Map<String, dynamic>>? model, context, index) {
    String uid = CacheHelper.getData(key: 'uId') ?? '';
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
            Row(
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
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: PopupMenuButton<String>(
                    onSelected: (String value) async {
                      switch (value) {
                        case 'option1':
                          if (model['uId'] == uId) {
                            await FirebaseFirestore.instance
                                .collection('posts')
                                .doc(model.id)
                                .delete();
                          } else {
                            showErrorDialog(
                                error:
                                    'You don\'t have access to delete this post',
                                context: context);
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'option2',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              'Edit',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: defaultColor),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option1',
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Text(
                              'Delete',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_horiz,
                    ),
                  ),
                ),
              ],
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
              child: Container(
                width: double.infinity,
                child: Wrap(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6.0),
                      child: Container(
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
                      child: Container(
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
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      onTap: () => showBottomSheet(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .95,
                        ),
                        context: context, builder: (context) => LikesScreen(likes: model['likes']),),
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
                      onTap: () => showBottomSheet(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * .95,
                        ),
                        context: context, builder: (context) => CommentsScreen(postId: model.id, uploadedById: model['uId'],),),
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
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * .95,
                      ),
                      context: context,
                      builder: (context) => CommentsScreen(
                        postId: model.id,
                        uploadedById: model['uId'],
                      ),
                    ),
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

                      final postOwnerDocs = await FirebaseFirestore.instance.collection('users').doc(model['uId']).get();

                      if(model['uId'] != uid) {
                        fireApi.sendNotifyFromFirebase(title: '${SocialCubit.get(context).userModel?.name} likes your post', sendNotifyTo: postOwnerDocs['token'], type: 'like', postId: model.id,uploadedBy: model['uId'], body: '');
                      }


                      _isLiked = true;
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isLiked
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
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

  Future<void> sendFollowRequest(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await Future.wait([
      updateSendingRequests(userId, followedUserId),
      updateReceivingRequests(userId, userName, userImage, userToken,followedUserId),
    ]);
  }

  Future<void> updateSendingRequests(
      String userId, String followedUserId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'sendingRequests': FieldValue.arrayUnion([followedUserId]),
    });
  }

  Future<void> updateReceivingRequests(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followedUserId)
        .update({
      'receivingRequests': FieldValue.arrayUnion([
        {
          'userId': userId,
          'userName': userName,
          'userToken': userToken,
          'userImage': userImage,
        }
      ]),
    });
  }

  Future<void> removeFollowRequest(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await Future.wait([
      removeSendingRequests(userId, followedUserId),
      removeReceivingRequests(userId, userName, userImage, userToken,followedUserId),
    ]);
  }

  Future<void> removeSendingRequests(
      String userId, String followedUserId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'sendingRequests': FieldValue.arrayRemove([followedUserId]),
    });
  }

  Future<void> removeReceivingRequests(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followedUserId)
        .update({
      'receivingRequests': FieldValue.arrayRemove([
        {
          'userId': userId,
          'userName': userName,
          'userToken': userToken,
          'userImage': userImage,
        }
      ]),
    });
  }

  Future<void> followUser(String userId, String followedUserId) async {
    try {
      await Future.wait([
        updateFollowing(userId, followedUserId),
        updateFollowers(userId, followedUserId),
      ]);
    } catch (error) {
      showErrorDialog(error: 'Failed to follow user: $error', context: context);
    }
  }

  Future<void> updateFollowing(String userId, String followedUserId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'following': FieldValue.arrayUnion([followedUserId]),
    });
  }

  Future<void> updateFollowers(String userId, String followedUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(followedUserId)
        .update({
      'followers': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> unfollowUser(String userId, String unfollowedUserId) async {
    try {
      await Future.wait([
        removeFollowing(userId, unfollowedUserId),
        removeFollowers(userId, unfollowedUserId),
      ]);
    } catch (error) {
      showErrorDialog(
          error: 'Failed to unfollow user: $error', context: context);
    }
  }

  Future<void> removeFollowing(String userId, String unfollowedUserId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'following': FieldValue.arrayRemove([unfollowedUserId]),
    });
  }

  Future<void> removeFollowers(String userId, String unfollowedUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(unfollowedUserId)
        .update({
      'followers': FieldValue.arrayRemove([userId]),
    });
  }
}
