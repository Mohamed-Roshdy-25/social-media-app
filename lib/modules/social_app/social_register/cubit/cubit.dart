
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/models/social_app/social_user_model.dart';
import 'package:flutter_learn_app/modules/social_app/social_register/cubit/states.dart';
import 'package:image_picker/image_picker.dart';

class SocialRegisterCubit extends Cubit<SocialRegisterStates> {
  SocialRegisterCubit() : super(SocialRegisterInitialState());

  static SocialRegisterCubit get(context) => BlocProvider.of(context);

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


  void userRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {
    emit(SocialRegisterLoadingState());

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((user) {
      print(user.user!.email);
      print(user.user!.uid);
      FirebaseStorage.instance
          .ref()
          .child('users/${Uri.file(profileImage!.path).pathSegments.last}')
          .putFile(profileImage!)
          .then((value) {
        value.ref.getDownloadURL().then((value) async {
          print(value);

          userCreate(
            name: name,
            email: email,
            phone: phone,
            uId: user.user!.uid,
            image: value,
          );
        }).catchError((error) {
          emit(SocialUploadProfileImageErrorState());
        });
      }).catchError((error) {
        emit(SocialUploadProfileImageErrorState());
      });



    }).catchError((error) {
      emit(SocialRegisterErrorState(error.toString()));
    });
  }

  void userCreate({
    required String name,
    required String email,
    required String phone,
    required String uId,
    String? image,
  }) {
    SocialUserModel model = SocialUserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      bio: 'write your bio ...',
      token: '',
      cover: 'https://img.freepik.com/free-photo/photo-attractive-bearded-young-man-with-cherful-expression-makes-okay-gesture-with-both-hands-likes-something-dressed-red-casual-t-shirt-poses-against-white-wall-gestures-indoor_273609-16239.jpg?t=st=1650614558~exp=1650615158~hmac=a2d57a432e09639b8aa02792eba1592ff56a3a15ac204762d8358f1058092103&w=740',
      image: image??'https://img.freepik.com/free-photo/photo-attractive-bearded-young-man-with-cherful-expression-makes-okay-gesture-with-both-hands-likes-something-dressed-red-casual-t-shirt-poses-against-white-wall-gestures-indoor_273609-16239.jpg?t=st=1650614558~exp=1650615158~hmac=a2d57a432e09639b8aa02792eba1592ff56a3a15ac204762d8358f1058092103&w=740',
      isEmailVerified: false,
      followers: [],
      following: [],
      friends: [],
      sendingRequests: [],
      receivingRequests: [],
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(SocialCreateUserSuccessState(uId));
    }).catchError((error) {
      emit(SocialCreateUserErrorState(error.toString()));
    });
  }

  bool obscure = true;
  IconData suffix = Icons.visibility_outlined;

  void changeObscure() {
    obscure = !obscure;
    suffix =
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(SocialRegisterChangeObscureState());
  }
}
