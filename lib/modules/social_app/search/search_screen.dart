import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/cubit.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';


class SearchScreen extends StatelessWidget {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _searchController = TextEditingController();

  SearchScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
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
                    SocialCubit.get(context).search(value);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isGreaterThanOrEqualTo: SocialCubit.get(context).searchText)
                      .where('name', isLessThan: SocialCubit.get(context).searchText + 'z')
                      .snapshots(),
                  builder: (context, snapshot) {
                    return Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data?.docs.length??0,
                        itemBuilder: (context, index) => _searchItem(context,snapshot.data?.docs[index]),
                        separatorBuilder: (context, index) => const SizedBox(height: 10,),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  _searchItem(context,model){
    return Row(
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
    );
  }
}
