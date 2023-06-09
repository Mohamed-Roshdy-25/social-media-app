import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_learn_app/shared/styles/colors.dart';
import 'package:flutter_learn_app/shared/styles/icon_broken.dart';

class UserImagesScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> images;
  const UserImagesScreen({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(IconBroken.Arrow___Left_Square,color: defaultColor,)),
        elevation: 10,
        title: const Text('My Images',style: TextStyle(color: defaultColor,fontSize: 15),),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(IconBroken.Image,color: defaultColor,),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return buildPostItem(
                    images[index], context, index);
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: 10,
              ),
              itemCount: images.length,
            ),
            const SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostItem(QueryDocumentSnapshot<Map<String, dynamic>> model, context, index) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 5.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Image(image: NetworkImage('${model['postImage']}')),
      ),
    );
  }
}
