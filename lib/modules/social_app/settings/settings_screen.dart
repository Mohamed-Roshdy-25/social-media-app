import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:flutter_learn_app/modules/social_app/new_post/new_post_screen.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:flutter_learn_app/modules/social_app/user_images/user_images_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';
import 'package:flutter_learn_app/shared/widgets/Post_item_widget.dart';

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
                  if (userSnapshot.data == null) {
                    return Container();
                  }
                  bool _isFriend =
                      userSnapshot.data?['friends']?.contains(uId) ?? false;
                  var requestsIds = userSnapshot.data?['receivingRequests']
                          .map((request) => request['userId'])
                          .toList() ??
                      [];
                  bool _isRequested = requestsIds.contains(uId) ?? false;
                  bool _isRequestMe =
                      userSnapshot.data?['sendingRequests']?.contains(uId) ??
                          false;
                  if (userSnapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .where('uId', isEqualTo: widget.userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  currentUserPosts = snapshot.data?.docs ?? [];
                              List<QueryDocumentSnapshot<Map<String, dynamic>>>
                                  currentUserImages = currentUserPosts
                                      .where((element) =>
                                          element['postImage'] != '')
                                      .toList();

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
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
                                          child: Container(
                                            clipBehavior: Clip.antiAlias,
                                            height: 120,
                                            width: 120,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                shape: BoxShape.circle),
                                            child: Image.network(
                                              '${userSnapshot.data?['image']}',
                                              fit: BoxFit.cover,
                                              loadingBuilder: (_, child, ImageChunkEvent?loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: SizedBox(
                                                    height: 55,
                                                    width: 55,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      strokeWidth: 1.2,
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                clipBehavior: Clip.antiAlias,
                                                height: 120,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    shape: BoxShape.circle),
                                              ),
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
                                            onTap: () => navigateTo(
                                                context,
                                                UserImagesScreen(
                                                    images: currentUserImages)),
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
                                      if (!_isRequestMe)
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
                                                    if (_isFriend) {
                                                      Future.wait([
                                                        unfriendUser(uId ?? '',
                                                            widget.userId),
                                                        unfollowUser(uId ?? '',
                                                            widget.userId),
                                                      ]);

                                                      // FirebaseMessaging.instance
                                                      //     .unsubscribeFromTopic(
                                                      //         widget.userId);
                                                    } else if (_isRequested) {
                                                      Future.wait([
                                                        unfollowUser(uId ?? '',
                                                            widget.userId),
                                                        removeFriendRequest(
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.uId ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.name ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.image ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.token ??
                                                              '',
                                                          widget.userId,
                                                        ),
                                                      ]);
                                                    } else {
                                                      Future.wait([
                                                        followUser(
                                                            SocialCubit.get(
                                                                        context)
                                                                    .userModel
                                                                    ?.uId ??
                                                                '',
                                                            widget.userId),
                                                        sendFriendRequest(
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.uId ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.name ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.image ??
                                                              '',
                                                          SocialCubit.get(
                                                                      context)
                                                                  .userModel
                                                                  ?.token ??
                                                              '',
                                                          widget.userId,
                                                        ),
                                                      ]);

                                                      fireApi.sendNotifyFromFirebase(
                                                          title:
                                                              'Friend Request',
                                                          body:
                                                              '${SocialCubit.get(context).userModel?.name} asked you to be a friends',
                                                          sendNotifyTo:
                                                              userSnapshot
                                                                      .data?[
                                                                  'token'],
                                                          type:
                                                              'friend request');
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
                                                  : _isFriend
                                                      ? 'UnFriend'
                                                      : _isRequested
                                                          ? 'Request sent'
                                                          : 'Add Friend',
                                            ),
                                          ),
                                        ),
                                      if (_isRequestMe)
                                        Expanded(
                                            child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                                onPressed: () async {
                                                  await friendUser(
                                                      uId ?? '', widget.userId);
                                                  // FirebaseMessaging.instance.subscribeToTopic(friendRequest['userId']);
                                                  fireApi.sendNotifyFromFirebase(
                                                      title:
                                                          'Friend Request Response',
                                                      body:
                                                          '${SocialCubit.get(context).userModel?.name} accepted your friend request',
                                                      sendNotifyTo: userSnapshot
                                                          .data?['token'],
                                                      type:
                                                          'friend request response');
                                                  await removeFriendRequest(
                                                      widget.userId,
                                                      userSnapshot
                                                          .data?['name'],
                                                      userSnapshot
                                                          .data?['image'],
                                                      userSnapshot
                                                          .data?['token'],
                                                      uId ?? '');
                                                },
                                                child: const Text(
                                                  'Accept request',
                                                )),
                                            OutlinedButton(
                                                onPressed: () async {
                                                  Future.wait([
                                                    unfollowUser(uId ?? '',
                                                        widget.userId),
                                                    removeFriendRequest(
                                                        widget.userId,
                                                        userSnapshot
                                                            .data?['name'],
                                                        userSnapshot
                                                            .data?['image'],
                                                        userSnapshot
                                                            .data?['token'],
                                                        uId ?? ''),
                                                  ]);
                                                },
                                                child: const Text(
                                                  'Reject request',
                                                )),
                                          ],
                                        )),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      if (_isSameUser)
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
                                  if (currentUserPosts.isNotEmpty)
                                    Column(
                                      children: [
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return PostItemWidget(model: currentUserPosts[index]);
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
                                  if (currentUserPosts.isEmpty)
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          'There is no posts',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade600),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (widget.userId == uId)
                                          OutlinedButton(
                                            onPressed: () => navigateTo(
                                                context, const NewPostScreen()),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 100),
                                              child: Text(
                                                'Post one !',
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                ],
                              );
                            },
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
            );
          },
        ),
      ),
    );
  }

  // Future<void> sendFollowRequest(
  //   String userId,
  //   String userName,
  //   String userImage,
  //   String userToken,
  //   String followedUserId,
  // ) async {
  //   await Future.wait([
  //     updateSendingRequests(userId, followedUserId),
  //     updateReceivingRequests(userId, userName, userImage, userToken, followedUserId),
  //   ]);
  // }

  //Sending friend request

  Future<void> sendFriendRequest(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await Future.wait([
      updateSendingRequests(userId, followedUserId),
      updateReceivingRequests(
          userId, userName, userImage, userToken, followedUserId),
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

  // Future<void> removeFollowRequest(
  //   String userId,
  //   String userName,
  //   String userImage,
  //   String userToken,
  //   String followedUserId,
  // ) async {
  //   await Future.wait([
  //     removeSendingRequests(userId, followedUserId),
  //     removeReceivingRequests(
  //         userId, userName, userImage, userToken, followedUserId),
  //   ]);
  // }

  // Remove sending request

  Future<void> removeFriendRequest(
    String userId,
    String userName,
    String userImage,
    String userToken,
    String followedUserId,
  ) async {
    await Future.wait([
      removeSendingRequests(userId, followedUserId),
      removeReceivingRequests(
          userId, userName, userImage, userToken, followedUserId),
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

  Future<void> unfriendUser(String userId, String unfollowedUserId) async {
    try {
      removeFriend(userId, unfollowedUserId);
    } catch (error) {
      showErrorDialog(
          error: 'Failed to unfollow user: $error', context: context);
    }
  }

  Future<void> removeFriend(String userId, String unfollowedUserId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'friends': FieldValue.arrayRemove([unfollowedUserId]),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(unfollowedUserId)
        .update({
      'friends': FieldValue.arrayRemove([userId]),
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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(unfollowedUserId)
        .update({
      'following': FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> removeFollowers(String userId, String unfollowedUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(unfollowedUserId)
        .update({
      'followers': FieldValue.arrayRemove([userId]),
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'followers': FieldValue.arrayRemove([unfollowedUserId]),
    });
  }

  Future<void> friendUser(String followedUserId, String userId) async {
    try {
      updateFriends(followedUserId, userId);
    } catch (error) {
      showErrorDialog(error: 'Failed to follow user: $error', context: context);
    }
  }

  Future<void> updateFriends(String followedUserId, String userId) async {
    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'friends': FieldValue.arrayUnion([followedUserId]),
    });

    FirebaseFirestore.instance.collection('users').doc(followedUserId).update({
      'friends': FieldValue.arrayUnion([userId]),
    });
  }
}
