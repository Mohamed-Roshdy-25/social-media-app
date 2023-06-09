import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;
  final String uploadedById;
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CommentsScreen({Key? key, required this.postId, required this.uploadedById}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Container();
                  }
                  return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (ctx, index) {
                        return Column(
                          children: [
                            CommentWidget(
                              commentId: snapshot.data?['comments'][index]['commentId'],
                              commentBody: snapshot.data?['comments'][index]['commentBody'],
                              commenterId: snapshot.data?['comments'][index]['userId'],
                              commenterName: snapshot.data?['comments'][index]['name'],
                              commenterImageUrl: snapshot.data?['comments'][index]['userImageUrl'],
                              taskId: postId,
                              comment: snapshot.data?['comments'][index],
                              taskOwner: uploadedById,
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
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: TextField(
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

                          final DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

                         await FirebaseFirestore.instance.collection('posts').doc(postId).update({'comments': FieldValue
                              .arrayUnion([
                            {
                              'userId': currentUserDoc.get('uId'),
                              'commentId': commentId,
                              'name': currentUserDoc.get('name'),
                              'commentBody': _commentController.text,
                              'time': Timestamp.now(),
                              'userImageUrl': currentUserDoc.get('image'),
                            }
                          ])
                          }).then((value) async {
                           _commentController.clear();

                            DocumentSnapshot<Map<String, dynamic>> postOwnerDocument = await FirebaseFirestore.instance.collection('users').doc(uploadedById).get();

                            String commenterName = currentUserDoc.get('name');

                            String token = postOwnerDocument.get('token');

                            if(uploadedById != uid) {
                              fireApi.sendNotifyFromFirebase(title: '$commenterName add comment on your post', body: _commentController.text, sendNotifyTo: token, type: 'comment', postId: postId,uploadedBy: uploadedById);
                            }
                          });
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



class CommentWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CommentWidget({Key? key,
    required this.commentId,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterName,
    required this.commenterId,
    required this.taskId,
    required this.comment,
    required this.taskOwner,
  }) : super(key: key);

  final String commentId;
  final String commentBody;
  final String commenterImageUrl;
  final String commenterName;
  final String commenterId;
  final String taskOwner;
  final String taskId;
  final dynamic comment;

  final List<Color> _colors = [
    Colors.orangeAccent,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                      onPressed: () async {

                        User? user = _auth.currentUser;

                        String uid = user!.uid;

                        // var comments = [];
                        //
                        // comments.add(comment);

                        if (uid == commenterId || uid == taskOwner) {

                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(taskId).update({
                            'comments': FieldValue.arrayRemove([comment]),
                          });

                          Navigator.pop(context);

                        } else {
                          Navigator.pop(context);
                          showErrorDialog(error: 'You don\'t have access to delete this comment', context: context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          )
                        ],
                      ))
                ],
              );
            });
      },
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ProfileScreen(
        //       userID: commenterId,
        //     ),
        //   ),
        // );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 5,
          ),
          CircleAvatar(
            radius: 17.0,
            backgroundImage: NetworkImage(
              commenterImageUrl,
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commenterName,
                    style: const TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      commentBody,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

