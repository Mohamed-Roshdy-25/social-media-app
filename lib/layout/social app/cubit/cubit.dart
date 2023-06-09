// ignore_for_file: avoid_print, unnecessary_null_comparison, avoid_function_literals_in_foreach_calls

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/cubit/states.dart';
import 'package:flutter_learn_app/models/social_app/message_model.dart';
import 'package:flutter_learn_app/models/social_app/post_model.dart';
import 'package:flutter_learn_app/models/social_app/social_user_model.dart';
import 'package:flutter_learn_app/modules/social_app/chats/chats_screen.dart';
import 'package:flutter_learn_app/modules/social_app/feeds/feeds_screen.dart';
import 'package:flutter_learn_app/modules/social_app/new_post/new_post_screen.dart';
import 'package:flutter_learn_app/modules/social_app/settings/settings_screen.dart';
import 'package:flutter_learn_app/modules/social_app/users/users_screen.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';
import 'package:image_picker/image_picker.dart';

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit() : super(SocialInitialState());

  static SocialCubit get(context) => BlocProvider.of(context);

  SocialUserModel? userModel;

  Future<void> getUserData() async {
    emit(SocialGetUserLoadingState());

    try {
      await FirebaseFirestore.instance.collection('users').doc(uId)
          .get()
          .then((value) {
        print(value.data());
        userModel = SocialUserModel.fromJson(value.data());

      });

      emit(SocialGetUserSuccessState());
    } catch (e) {
      emit(SocialGetUserErrorState(e as String));
    }
  }

  int currentIndex = 0;

  List<Widget> screens = [
    const FeedsScreen(),
    const ChatsScreen(),
    NewPostScreen(),
    UsersScreen(),
    SettingsScreen(userId: CacheHelper.getData(key: 'uId'),),
  ];

  List<String> titles = [
    'Feeds',
    'Chats',
    'Create Post',
    'Users',
    'Profile',
  ];

  void changeBottomNav(int index)
  {
    if (index == 1)
      {
        getUsers();
      }
    if (index == 2)
    {
      emit(SocialNewPostState());
    }
    else
    {
      currentIndex = index;
      emit(SocialChangeBottomNavState());
    }
  }

  File? profileImage;
  var picker = ImagePicker();

  Future<void> getProfileImage() async {
    // ignore: deprecated_member_use
    var pickedFile = (await picker.getImage(
      source: ImageSource.gallery,
    ));

    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      emit(SocialProfileImagePickedSuccessState());
    } else {
      emit(SocialProfileImagePickedErrorState());
    }
  }

  File? coverImage;

  Future<void> getCoverImage() async {
    var pickedFile = (await picker.pickImage(
      source: ImageSource.gallery,
    ));

    if (pickedFile != null) {
      coverImage = File(pickedFile.path);
      emit(SocialCoverImagePickedSuccessState());
    } else {
      emit(SocialCoverImagePickedErrorState());
    }
  }

  void uploadProfileImage({
    required String name,
    required String phone,
    required String bio,
  }) {
    emit(SocialUserUpdateLoadingState());


    FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
        .putFile(profileImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        updateUser(
          phone: phone,
          name: name,
          bio: bio,
          image: value,
        );
      }).catchError((error) {
        emit(SocialUploadProfileImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadProfileImageErrorState());
    });
  }

  void uploadCoverImage({required String name, required String phone, required String bio}) {
    emit(SocialUserUpdateLoadingState());

    FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(coverImage!.path).pathSegments.last}')
        .putFile(coverImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        updateUser(
          phone: phone,
          name: name,
          bio: bio,
          cover: value,
        );
      }).catchError((error) {
        emit(SocialUploadCoverImageErrorState());
      });
    }).catchError((error) {
      emit(SocialUploadCoverImageErrorState());
    });
  }


  void updateUser({required String name, required String phone, required String bio, String? cover, String? image}) {
    SocialUserModel model = SocialUserModel(
      name: name,
      phone: phone,
      bio: bio,
      image: image ?? userModel?.image,
      cover: cover ?? userModel?.cover,
      email: userModel?.email,
      uId: userModel?.uId,
      isEmailVerified: false,
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel?.uId)
        .update(model.toMap())
        .then((value) {
      getUserData();
    }).catchError((error) {
      emit(SocialUserUpdateErrorState());
    });
  }

  File? postImage;

  Future<void> getPostImage() async {
    var pickedFile = (await picker.pickImage(
      source: ImageSource.gallery,
    ));

    if (pickedFile != null) {
      postImage = File(pickedFile.path);
      emit(SocialPostImagePickedSuccessState());
    } else {
      print('No image selected');
      emit(SocialPostImagePickedErrorState());
    }
  }

  void removePostImage() {
    postImage = null;
    emit(SocialRemovePostImageState());
  }

  void uploadPostImage({required String dataTime, required String text}) {
    emit(SocialCreatePostLoadingState());

    FirebaseStorage.instance
        .ref()
        .child(Uri.file(postImage!.path).pathSegments.last)
        .putFile(postImage!)
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        print(value);
        createPost(
          dataTime: dataTime,
          text: text,
          postImage: value,
        );
      }).catchError((error) {
        emit(SocialCreatePostErrorState());
      });
    }).catchError((error) {
      emit(SocialCreatePostErrorState());
    });
  }

  void createPost({required String dataTime, required String text, String? postImage}) {
    emit(SocialCreatePostLoadingState());

    PostModel model = PostModel(
      name: userModel?.name,
      image: userModel?.image,
      uId: userModel?.uId,
      dataTime: dataTime,
      text: text,
      postImage: postImage ?? '',
      likesCount: 0,
      likes: [],
      comments: [],
    );

    FirebaseFirestore.instance
        .collection('posts')
        .add(model.toMap())
        .then((value) {
      emit(SocialCreatePostSuccessState(value.id));
    }).catchError((error) {
      emit(SocialCreatePostErrorState());
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? posts;

  Future<void> getPosts() async {
    await getUserData();
    emit(SocialGetPostsLoadingState());
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uId).snapshots().listen((user) async {
            print('+++++++++++++++++++++++${user.data()}');
        final followingList = user.data()?['following'];
        followingList.add(uId ?? "");
        posts = FirebaseFirestore.instance
            .collection('posts')
            .where('uId', whereIn: followingList)
            .snapshots();

        emit(SocialGetPostsSuccessState());
      });
    } catch (error){
      emit(SocialGetPostsErrorState(error as String));
    }
  }


  Stream<QuerySnapshot<Map<String, dynamic>>>? users;

  void getUsers() {

      users = FirebaseFirestore.instance.collection('users').where('uId', isNotEqualTo: uId).snapshots();

  }

  void sendMessage({required String receiverId, required String dateTime, required String text}) {
    MessageModel model = MessageModel(
      text: text,
      senderId: userModel?.uId,
      receiverId: receiverId,
      dateTime: dateTime,
    );

    // set my chats

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel?.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(SocialSendMessageSuccessState());
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });

    // set receiver chats

    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel?.uId)
        .collection('messages')
        .add(model.toMap())
        .then((value) {
      emit(SocialSendMessageSuccessState());
    }).catchError((error) {
      emit(SocialSendMessageErrorState());
    });
  }

  List<MessageModel> messages = [];

  void getMessages({required String receiverId}) {
    emit(SocialGetMessagesLoadingState());

      FirebaseFirestore.instance
          .collection('users')
          .doc(userModel?.uId)
          .collection('chats')
          .doc(receiverId)
          .collection('messages')
          .orderBy('dateTime')
          .snapshots().listen((event) {
        messages = [];
        event.docs.forEach((element) {
          messages.add(MessageModel.fromJson(element.data()));
        });
        emit(SocialGetMessagesSuccessState());
      }).onError((error){
        emit(SocialGetMessagesErrorState());
      });

  }

  String searchText = '';

  void search(String inputText){
    searchText = inputText;
    emit(SocialSearchState());
  }

  Future<void> signOut() async {
    emit(SocialSignOutLoadingState());
    try {
     await FirebaseAuth.instance.signOut();

      emit(SocialSignOutSuccessState());
    }on FirebaseException {
      emit(SocialSignOutErrorState());
    }
  }

}
