import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/comments/comments_screen.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';
import 'package:uuid/uuid.dart';

class PostDetailsScreen extends StatefulWidget {
  final String postId;
  const PostDetailsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _focusNode = FocusNode();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: BlocBuilder<SocialCubit, SocialStates>(
          builder: (context, state) {
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildPostItem(snapshot.data!, context);
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

  Widget buildPostItem(DocumentSnapshot<Map<String, dynamic>> model, context) {
    String uid = CacheHelper.getData(key: 'uId');
    bool _isLiked = model['likes'].contains(uid) ?? false;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () =>
                                navigateTo(context, SettingsScreen(userId: model['uId'])),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 25.0,
                                  backgroundImage: NetworkImage(
                                    '${model['image']}',
                                  ),
                                ),
                                const SizedBox(
                                  width: 15.0,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
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
                                        '${model['dataTime'].split(':')[0]}:${model['dataTime'].split(':')[1]}',
                                        style:
                                            Theme.of(context).textTheme.bodySmall?.copyWith(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
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
                                            '${model['comments'].length.toString()} comments',
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
                                  onTap: () => _focusNode.requestFocus(),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(model.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Container();
                          }
                          return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    CommentWidget(
                                      commentId: snapshot.data?['comments'][index]['commentId'],
                                      commentBody: snapshot.data?['comments'][index]['commentBody'],
                                      commenterId: snapshot.data?['comments'][index]['userId'],
                                      commenterName: snapshot.data?['comments'][index]['name'],
                                      commenterImageUrl: snapshot.data?['comments'][index]['userImageUrl'],
                                      taskId: model.id,
                                      comment: snapshot.data?['comments'][index],
                                      taskOwner: model['uId'],
                                    ),
                                    if(index == snapshot.data?['comments'].length -1)
                                      const SizedBox(height: 30,)
                                  ],
                                );
                              },
                              separatorBuilder: (ctx, index) {
                                return Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                );
                              },
                              itemCount: snapshot
                                  .data?['comments'].length);
                        }),
                  )
                ],
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: TextField(
                  focusNode: _focusNode,
                  maxLength: 200,
                  controller: _commentController,
                  style: const TextStyle(
                    color: Colors.blue,
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    filled: true,
                    fillColor: Theme.of(context)
                        .scaffoldBackgroundColor,
                    enabledBorder:
                    const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink),
                    ),
                    errorBorder:
                    const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.red),
                    ),
                    focusedBorder:
                    const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.pink),
                    ),
                  ),
                  onTapOutside: (event) => _focusNode.unfocus(),
                ),
              ),
              Flexible(
                  flex: 1,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MaterialButton(
                      onPressed: () async {
                        if (_commentController.text.isEmpty) {
                          showErrorDialog(error: 'Comment can\'t be less than 1 characters', context: context);
                        }
                        else {
                          final commentId = const Uuid().v4();

                          User? user = _auth.currentUser;

                          String uid = user!.uid;

                          final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

                          FirebaseFirestore.instance.collection('posts').doc(model.id).update({'comments': FieldValue
                              .arrayUnion([
                            {
                              'userId': userDoc.get('uId'),
                              'commentId': commentId,
                              'name': userDoc.get('name'),
                              'commentBody': _commentController.text,
                              'time': Timestamp.now(),
                              'userImageUrl': userDoc.get('image'),
                            }
                          ])
                          });

                          // DocumentSnapshot<Map<String, dynamic>> userDocument = await FirebaseFirestore.instance.collection('users').doc(uploadedById).get();

                          // String commenterName = userDoc.get('name');
                          //
                          // String token = userDocument.get('token');

                          // if(uploadedById != uid) {
                          //   // fireApi.sendNotifyFromFirebase(title: 'comment from $commenterName', body: _commentController.text, sendNotifyTo: token, type: 'comment', taskID: postId,uploadedById: uploadedById);
                          // }

                          _commentController.clear();
                        }
                      },
                      color: Colors.pink.shade700,
                      elevation: 10,
                      shape:
                      RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                              13),
                          side: BorderSide
                              .none),
                      child: const Padding(
                        padding:
                        EdgeInsets.symmetric(
                            vertical: 7),
                        child: Text(
                          'Post',
                          style: TextStyle(
                              color: Colors.white,
                              // fontSize: 20,
                              fontWeight:
                              FontWeight
                                  .bold),
                        ),
                      ),
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
