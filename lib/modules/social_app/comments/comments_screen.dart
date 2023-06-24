import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/widgets/comment_widget.dart';
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
                  return ListView.builder(
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
                            DocumentSnapshot<Map<String, dynamic>> postOwnerDocument = await FirebaseFirestore.instance.collection('users').doc(uploadedById).get();

                            String commenterName = currentUserDoc.get('name');

                            String token = postOwnerDocument.get('token');

                            if(uploadedById != uid) {
                              fireApi.sendNotifyFromFirebase(title: '$commenterName add comment on your post', body: _commentController.text, sendNotifyTo: token, type: 'comment', postId: postId,uploadedBy: uploadedById);
                            }

                            _commentController.clear();
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