import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/shared/components/components.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17.0,
            backgroundImage: NetworkImage(
              commenterImageUrl,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                ),
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
                            // fontSize: 12
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}