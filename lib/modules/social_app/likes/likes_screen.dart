import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class LikesScreen extends StatefulWidget {
  final List<dynamic> likes;
  const LikesScreen({Key? key, required this.likes}) : super(key: key);

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uId', whereIn: widget.likes)
            .snapshots(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data?.docs.length??0,
              itemBuilder: (context, index) => _searchItem(context,snapshot.data?.docs[index]),
              separatorBuilder: (context, index) => const SizedBox(height: 30,),
            ),
          );
        });
  }

  _searchItem(context,model){
    return InkWell(
      onTap: () => navigateTo(context, SettingsScreen(userId: model?['uId']??'')),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              '${model!['image']}',
            ),
          ),
          const SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: Row(
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
          ),
          const SizedBox(
            width: 15.0,
          ),
          const Icon(
            IconBroken.Arrow___Right_2,
            color: defaultColor,
            size: 16.0,
          ),
        ],
      ),
    );
  }
}
