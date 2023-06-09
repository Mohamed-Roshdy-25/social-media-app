// ignore_for_file: must_be_immutable, unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/firebase_notification_api.dart';
import 'package:flutter_learn_app/global_method.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

// ignore: use_key_in_widget_constructors
class NewPostScreen extends StatefulWidget {

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  var textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    globalMethods.registerNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if(state is SocialCreatePostSuccessState){
          fireApi.sendNotifyFromFirebase(
              title: '${SocialCubit.get(context).userModel?.name} added new post',
              body: 'click me to go to the post',
              sendNotifyTo: "/topics/$uId",
              type: 'post',
            postId: state.postId,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar:
              defaultAppBar(context: context, title: 'Create Post', actions: [
            defaultTextButton(
              onPressed: () {
                var now = DateTime.now();

                if (SocialCubit.get(context).postImage == null) {
                  SocialCubit.get(context).createPost(
                    dataTime: now.toString(),
                    text: textController.text,
                  );
                } else {
                  SocialCubit.get(context).uploadPostImage(
                    dataTime: now.toString(),
                    text: textController.text,
                  );
                }

                textController.clear();
              },
              text: 'Post',
            ),
          ]),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if(state is SocialCreatePostLoadingState)
                  const LinearProgressIndicator(),
                if(state is SocialCreatePostLoadingState)
                  const SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: SocialCubit.get(context).userModel?.image != null? NetworkImage('${SocialCubit.get(context).userModel!.image}') : null,
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: Text(
                        SocialCubit.get(context).userModel?.name??'',
                        style: const TextStyle(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'What is on your mind ...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                if(SocialCubit.get(context).postImage != null)
                  Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    Container(
                      height: 140.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0,),
                          image: DecorationImage(
                            image: FileImage(SocialCubit.get(context).postImage as File),
                            fit: BoxFit.cover,
                          )),
                    ),
                    IconButton(
                      onPressed: () {
                        SocialCubit.get(context).removePostImage();
                      },
                      icon: const CircleAvatar(
                        radius: 20.0,
                        child: Icon(
                          Icons.close,
                          size: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          SocialCubit.get(context).getPostImage();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              IconBroken.Image,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              'add photo',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          '# tags',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
