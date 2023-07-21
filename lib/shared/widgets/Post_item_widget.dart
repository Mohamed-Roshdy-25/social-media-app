import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/modules/social_app/comments/comments_screen.dart';
import 'package:flutter_learn_app/modules/social_app/likes/likes_screen.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class PostItemWidget extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? model;
  final BuildContext context;
  const PostItemWidget({Key? key, this.model, required this.context}) : super(key: key);

  @override
  State<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  @override
  Widget build(BuildContext context) {
    String uid = CacheHelper.getData(key: 'uId')??'';
    bool _isLiked = widget.model?['likes']?.contains(uid) ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 5.0,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => navigateTo(
                  context, SettingsScreen(userId: widget.model?['uId'] ?? '')),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: NetworkImage(
                        '${widget.model?['image']}',
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
                                '${widget.model?['name']}',
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
                            '${widget.model?['dataTime']?.split(':')[0]}:${widget.model?['dataTime']?.split(':')[1]}',
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
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) async {
                          switch (value) {
                            case 'option1':
                              if (widget.model?['uId'] == uId) {
                                await FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc(widget.model?.id)
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 5.0),
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 5.0),
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
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.grey[300],
            ),
            if (widget.model?['text'] != '')
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  '${widget.model?['text']}',
                ),
              ),
            if (widget.model?['postImage'] != '')
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 15.0,
                ),
                child: Center(child: FadeInImage.assetNetwork(
                  image: '${widget.model?['postImage']}',
                  placeholder: 'assets/images/animation_lk9uqpkz_small.gif',
                  imageErrorBuilder: (context, error, stackTrace) => Center(child: Image.asset('assets/images/animation_lk9uqpkz_small.gif'),),
                )),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                              '${widget.model?['likesCount']}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      onTap: () => showBottomSheet(
                        context: context,
                        builder: (context) =>
                            LikesScreen(likes: widget.model?['likes']),
                      ),
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
                              (widget.model?['comments'].length.toString()??'') + ' comments',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      onTap: () => showBottomSheet(
                        context: context,
                        builder: (context) => CommentsScreen(
                          postId: widget.model?.id??'',
                          uploadedById: widget.model?['uId'],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 1.0,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => showBottomSheet(
                        context: context,
                        builder: (context) => CommentsScreen(
                          postId: widget.model?.id??'',
                          uploadedById: widget.model?['uId'],
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Colors.grey.shade300,
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
                            .doc(widget.model?.id)
                            .update({
                          'likes': FieldValue.arrayRemove([uid]),
                          'likesCount': FieldValue.increment(-1),
                        });

                        _isLiked = false;
                      } else {
                        await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.model?.id)
                            .update({
                          'likes': FieldValue.arrayUnion([uid]),
                          'likesCount': FieldValue.increment(1),
                        });

                        final postOwnerDocs = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.model?['uId'])
                            .get();

                        if (widget.model?['uId'] != uid) {
                          fireApi.sendNotifyFromFirebase(
                              title:
                              '${SocialCubit.get(context).userModel?.name} likes your post',
                              sendNotifyTo: postOwnerDocs['token'],
                              type: 'like',
                              postId: widget.model?.id,
                              uploadedBy: widget.model?['uId'],
                              body: '');
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
            ),
          ],
        ),
      ),
    );
  }
}
