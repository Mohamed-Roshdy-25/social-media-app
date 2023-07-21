import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

// ignore: use_key_in_widget_constructors
class UsersScreen extends StatefulWidget {
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FocusNode _focusNode = FocusNode();
  String? _searchText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
        child: Column(
          children: [
            TextField(
              focusNode: _focusNode,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: defaultColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                prefixIcon: const Icon(IconBroken.Search),
                hintText: 'search for users....',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onTapOutside: (event) => _focusNode.unfocus(),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('name', isGreaterThanOrEqualTo: _searchText)
                    .where('name', isLessThan:( _searchText??'') + 'z')
                    .snapshots(),
                builder: (context, snapshot) {
                  return Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data?.docs.length??0,
                      itemBuilder: (context, index) => _searchItem(context,snapshot.data?.docs[index]),
                      separatorBuilder: (context, index) => const SizedBox(height: 30,),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }

  _searchItem(context,model){
    return InkWell(
      onTap: () => navigateTo(context, SettingsScreen(userId: model?['uId']??'')),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.grey.shade300,
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