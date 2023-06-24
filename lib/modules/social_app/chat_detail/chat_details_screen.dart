import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/models/social_app/message_model.dart';
import 'package:flutter_learn_app/models/social_app/social_user_model.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class ChatDetailsScreen extends StatefulWidget {
  final SocialUserModel? userModel;

  const ChatDetailsScreen({
    Key? key,
    this.userModel,
  }) : super(key: key);

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  var messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(
                widget.userModel!.image as String,
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Text(
              widget.userModel!.name as String,
            ),
          ],
        ),
      ),
      body: Builder(builder: (context) {
        SocialCubit.get(context)
            .getMessages(receiverId: widget.userModel?.uId as String);

        return BlocBuilder<SocialCubit, SocialStates>(
          builder: (context, state) {
            return ConditionalBuilder(
              condition: state is! SocialGetMessagesLoadingState,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          MessageModel message =
                              SocialCubit.get(context).messages[index];

                          if (SocialCubit.get(context).userModel?.uId ==
                              message.senderId) {
                            return buildMyMessage(message);
                          }

                          return buildMessage(message);
                        },
                        itemCount: SocialCubit.get(context).messages.length,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300] as Color,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(
                          15.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: TextFormField(
                                controller: messageController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'type your message here ...',
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            color: defaultColor,
                            child: MaterialButton(
                              onPressed: () {
                                SocialCubit.get(context).sendMessage(
                                  receiverId: widget.userModel!.uId as String,
                                  dateTime: DateTime.now().toString(),
                                  text: messageController.text,
                                );
                                messageController.clear();
                              },
                              minWidth: 1.0,
                              child: const Icon(
                                IconBroken.Send,
                                size: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              fallback: (context) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Expanded(
                      child: Center(child: Text('Loading Messages ....')),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300] as Color,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(
                          15.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: TextFormField(
                                controller: messageController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'type your message here ...',
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 50.0,
                            color: defaultColor,
                            child: MaterialButton(
                              onPressed: () {
                                SocialCubit.get(context).sendMessage(
                                  receiverId: widget.userModel!.uId as String,
                                  dateTime: DateTime.now().toString(),
                                  text: messageController.text,
                                );
                                messageController.clear();
                              },
                              minWidth: 1.0,
                              child: const Icon(
                                IconBroken.Send,
                                size: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget buildMessage(MessageModel model) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: const BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(
                10.0,
              ),
              topStart: Radius.circular(
                10.0,
              ),
              topEnd: Radius.circular(
                10.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: Text(
            model.text as String,
          ),
        ),
      );

  Widget buildMyMessage(MessageModel model) => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: defaultColor.withOpacity(
              .2,
            ),
            borderRadius: const BorderRadiusDirectional.only(
              bottomStart: Radius.circular(
                10.0,
              ),
              topStart: Radius.circular(
                10.0,
              ),
              topEnd: Radius.circular(
                10.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 10.0,
          ),
          child: Text(
            model.text as String,
          ),
        ),
      );
}
