// ignore_for_file: sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/comments/comments_screen.dart';
import 'package:flutter_learn_app/modules/social_app/edit_profile/edit_profile_screen.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/social_login_screen.dart';
import 'package:flutter_learn_app/modules/social_app/user_images/user_images_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SocialCubit.get(context).getUserData();
    return BlocBuilder<SocialCubit, SocialStates>(
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;

        if(state is SocialGetUserLoadingState){
          return const Center(child: CircularProgressIndicator(),);
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .snapshots(),
                builder: (context, snapshot) {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> currentUserPosts = snapshot.data?.docs.where((element) => element['uId'] == CacheHelper.getData(key: 'uId')).toList()??[];
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> currentUserImages = currentUserPosts.where((element) => element['postImage'] != '').toList();
                  
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 190.0,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Align(
                            child: Container(
                              height: 140.0,
                              width: double.infinity,
                              decoration:  BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        '${userModel?.cover}'),
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            alignment: AlignmentDirectional.topCenter,
                          ),
                          CircleAvatar(
                            radius: 64.0,
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            child: CircleAvatar(
                              radius: 60.0,
                              backgroundImage: NetworkImage(
                                '${userModel?.image}',
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
                      '${userModel?.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '${userModel?.bio}',
                      style: Theme.of(context).textTheme.bodySmall,
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
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Posts',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                                    '${currentUserImages.length}',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Photos',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              onTap: () {
                                navigateTo(context, UserImagesScreen(images: currentUserImages));
                              },
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              child: Column(
                                children: [
                                  Text(
                                    '10K',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Followers',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                                    '64',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Followings',
                                    style: Theme.of(context).textTheme.bodySmall,
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
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              await CacheHelper.removeData(key: 'uId');
                              uId = null;
                              navigateAndFinish(context, SocialLoginScreen());
                            },
                            child: const Text(
                              'Logout',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0,),
                        OutlinedButton(
                          onPressed: (){
                            navigateTo(context, EditProfileScreen());
                          },
                          child: const Icon(
                            IconBroken.Edit,
                            size: 16.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20,),
                    BlocBuilder<SocialCubit, SocialStates>(
                      builder: (context, state) {
                        return ConditionalBuilder(
                          condition: state is! SocialGetPostsLoadingState,
                          builder: (context) => Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return buildPostItem(
                                      currentUserPosts[index], context, index);
                                },
                                separatorBuilder: (context, index) => const SizedBox(
                                  height: 8.0,
                                ),
                                itemCount: currentUserPosts.length,
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                            ],
                          ),
                          fallback: (context) => const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }

  Widget buildPostItem(QueryDocumentSnapshot<Map<String, dynamic>>? model, context, index) {
    String uid = CacheHelper.getData(key: 'uId');
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
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 16.0,
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
                              style:
                              Theme.of(context).textTheme.bodySmall,
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
                              model['comments'].length.toString() + ' comments',
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
                    onTap: () => showBottomSheet(
                      context: context, builder: (context) => CommentsScreen(postId: model.id, uploadedById: model['uId'],),),
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
                    // if (_isLiked) {
                    // _unlikePost();
                    // setState(() {
                    // _isLiked = false;
                    // });
                    // } else {
                    // _likePost();
                    // setState(() {
                    // _isLiked = true;
                    // });
                    // }

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
                        _isLiked ? Icons.favorite : Icons.favorite_border_outlined,
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
}
