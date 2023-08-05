
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/models/social_app/social_user_model.dart';
import 'package:flutter_learn_app/modules/social_app/chat_detail/chat_details_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: SocialCubit.get(context).users,
        builder: (context, snapshot) {

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              SocialUserModel userModel = SocialUserModel.fromJson(snapshot.data?.docs[index].data());

              return buildChatItem(userModel, context);
            },
            separatorBuilder: (context, index) => Divider(
              thickness: 1.0,
              color: Colors.grey[300],
            ),
            itemCount: snapshot.data?.docs.length??0,
          );
        }
    );
  }

  Widget buildChatItem(SocialUserModel model, context) => InkWell(
        onTap: () {
          navigateTo(
            context,
            ChatDetailsScreen(
              userModel: model,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(children: [
            CircleAvatar(
              radius: 25.0,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(
                '${model.image}',
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            Text(
              '${model.name}',
              style: const TextStyle(
                height: 1.4,
              ),
            ),
          ]),
        ),
      );
}
