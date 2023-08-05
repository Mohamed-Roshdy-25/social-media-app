import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/widgets/comment_widget.dart';
import 'package:uuid/uuid.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;
  final String uploadedById;
  const CommentsBottomSheet({Key? key, required this.postId, required this.uploadedById}) : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .snapshots(),
      builder: (context, snapshot) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 6,
                margin: const EdgeInsets.only(top: 16, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ((snapshot.data?['comments'] as List?)?.isEmpty??false) ? const Center(child: Text('No Comments'),) : ListView.builder(
                          itemBuilder:  (context, index) =>  Column(
                            children: [
                              CommentWidget(
                                commentId: snapshot.data?['comments'][index]['commentId']??'',
                                commentBody: snapshot.data?['comments'][index]['commentBody']??'',
                                commenterId: snapshot.data?['comments'][index]['userId']??'',
                                commenterName: snapshot.data?['comments'][index]['name']??'',
                                commenterImageUrl: snapshot.data?['comments'][index]['userImageUrl']??'',
                                postId: widget.postId,
                                comment: snapshot.data?['comments'][index],
                                postOwner: widget.uploadedById,
                              ),
                              Divider(
                                color: Colors.grey.withOpacity(0.3),
                                thickness: 1,
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                          itemCount: snapshot.data?['comments'].length,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
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
                                        color: Colors.blue),
                                  ),
                                  errorBorder:
                                  const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red),
                                  ),
                                  focusedBorder:
                                  const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
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

                                        await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({'comments': FieldValue
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


                                          DocumentSnapshot<Map<String, dynamic>> postOwnerDocument = await FirebaseFirestore.instance.collection('users').doc(widget.uploadedById).get();

                                          String commenterName = currentUserDoc.get('name');

                                          String token = postOwnerDocument.get('token');

                                          if(widget.uploadedById != uid) {
                                            fireApi.sendNotifyFromFirebase(title: '$commenterName add comment on your post', body: _commentController.text, sendNotifyTo: token, type: 'comment', postId: widget.postId,uploadedBy: widget.uploadedById);
                                          }

                                          _commentController.clear();


                                        });
                                      }
                                    },
                                    color: Colors.blue.shade700,
                                    padding: EdgeInsets.zero,
                                    elevation: 10,
                                    shape:
                                    RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(13),
                                        side: BorderSide.none,
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 15),
                                      child: Image.asset('assets/images/ic_send.png'
                                      ,height: 20,
                                      width: 20,),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        );
      }
    );
  }
}