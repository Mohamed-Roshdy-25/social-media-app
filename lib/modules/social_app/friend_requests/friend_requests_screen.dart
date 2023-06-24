import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Friend Requests'),
      ),
      body: SafeArea(
        child: BlocBuilder<SocialCubit, SocialStates>(
  builder: (context, state) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(uId).snapshots(),
          builder: (context, snapshot) {
            List friendRequests = List.from(snapshot.data?['receivingRequests']??[]);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                itemBuilder: (context, index) => requestItem(friendRequests[index]),
                separatorBuilder: (context, index) => const SizedBox(height: 20,),
                itemCount: friendRequests.length,
              ),
            );
          },
        );
  },
),
      ),
    );
  }

  requestItem(friendRequest) {
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
                    '${friendRequest?['userImage']}',
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
                            '${friendRequest['userName']}',
                            style: const TextStyle(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    await removeFollowRequest(friendRequest['userId'], friendRequest['userName'], friendRequest['userImage'], friendRequest['userToken'], uId??'');
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: defaultColor)
                    ),
                    child: const Text('Reject',style: TextStyle(color: defaultColor),),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await followUser(uId??'', friendRequest['userId']);
                    fireApi.sendNotifyFromFirebase(title: 'Friend Request Response', body: '${SocialCubit.get(context).userModel?.name} accepted your friend request', sendNotifyTo: friendRequest['userToken'], type: 'friend request response');
                    await removeFollowRequest(friendRequest['userId'], friendRequest['userName'], friendRequest['userImage'], friendRequest['userToken'], uId??'');
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                    decoration: BoxDecoration(
                        color: defaultColor,
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: const Text('Accept',style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    await FirebaseFirestore.instance.collection('users').doc(followedUserId).update({
      'following': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> updateFollowers(String userId, String followedUserId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'followers': FieldValue.arrayUnion([followedUserId]),
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


