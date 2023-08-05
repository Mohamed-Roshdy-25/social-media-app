import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/shared/components/components.dart';

class CommentWidget extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CommentWidget({
    Key? key,
    required this.commentId,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterName,
    required this.commenterId,
    required this.postId,
    required this.comment,
    required this.postOwner,
  }) : super(key: key);

  final String commentId;
  final String commentBody;
  final String commenterImageUrl;
  final String commenterName;
  final String commenterId;
  final String postOwner;
  final String postId;
  final dynamic comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.grey.shade300,
              width: 45,
              height: 45,
              child: Image.network(
                commenterImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade300,
                  width: 45,
                  height: 45,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      commenterName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    InkWell(
                      onTap: () {
                        User? user = _auth.currentUser;

                        String uid = user!.uid;

                        // var comments = [];
                        //
                        // comments.add(comment);

                        if (uid == commenterId || uid == postOwner) {
                          FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .update({
                            'comments': FieldValue.arrayRemove([comment]),
                          });
                        }
                      },
                      child: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  commentBody,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(12, 38),
                      backgroundColor: Colors.green.withOpacity(.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset("assets/images/ic_share.png", width: 16),
                        const SizedBox(width: 8),
                        const Text(
                          "Reply",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       CircleAvatar(
    //         radius: 17.0,
    //         backgroundImage: NetworkImage(
    //           commenterImageUrl,
    //         ),
    //       ),
    //       const SizedBox(
    //         width: 5,
    //       ),
    //       Expanded(
    //         child: InkWell(
    //           borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(20),
    //             bottomRight: Radius.circular(20),
    //             bottomLeft: Radius.circular(20),
    //           ),
    //           onLongPress: () {
    //             showDialog(
    //                 context: context,
    //                 builder: (context) {
    //                   return AlertDialog(
    //                     actions: [
    //                       TextButton(
    //                           onPressed: () async {
    //
    //                             User? user = _auth.currentUser;
    //
    //                             String uid = user!.uid;
    //
    //                             // var comments = [];
    //                             //
    //                             // comments.add(comment);
    //
    //                             if (uid == commenterId || uid == postOwner) {
    //
    //                               FirebaseFirestore.instance
    //                                   .collection('posts')
    //                                   .doc(postId).update({
    //                                 'comments': FieldValue.arrayRemove([comment]),
    //                               });
    //
    //                               Navigator.pop(context);
    //
    //                             } else {
    //                               Navigator.pop(context);
    //                               showErrorDialog(error: 'You don\'t have access to delete this comment', context: context);
    //                             }
    //                           },
    //                           child: Row(
    //                             mainAxisAlignment: MainAxisAlignment.center,
    //                             children: const [
    //                               Icon(
    //                                 Icons.delete,
    //                                 color: Colors.red,
    //                               ),
    //                               SizedBox(
    //                                 width: 10,
    //                               ),
    //                               Text(
    //                                 'Delete',
    //                                 style: TextStyle(
    //                                   color: Colors.red,
    //                                 ),
    //                               )
    //                             ],
    //                           ))
    //                     ],
    //                   );
    //                 });
    //           },
    //           child: Container(
    //             width: double.infinity,
    //             padding: const EdgeInsets.only(left: 10,right: 10,top: 2,bottom: 5),
    //             decoration: BoxDecoration(
    //               color: Colors.grey.shade300,
    //               borderRadius: const BorderRadius.only(
    //                 topRight: Radius.circular(20),
    //                 bottomRight: Radius.circular(20),
    //                 bottomLeft: Radius.circular(20),
    //               )
    //             ),
    //             child: Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 10),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     commenterName,
    //                     style: const TextStyle(
    //                       fontStyle: FontStyle.normal,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                   const SizedBox(
    //                     height: 5,
    //                   ),
    //                   Align(
    //                     alignment: Alignment.centerRight,
    //                     child: Text(
    //                       commentBody,
    //                       style: TextStyle(
    //                         fontStyle: FontStyle.italic,
    //                         color: Colors.grey.shade600,
    //                         // fontSize: 12
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //         ),
    //       ),
    //
    //     ],
    //   ),
    // );
  }
}
