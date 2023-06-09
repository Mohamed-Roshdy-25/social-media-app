// ignore_for_file: avoid_print, must_be_immutable

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/social_layout.dart';
import 'package:flutter_learn_app/modules/social_app/social_register/cubit/cubit.dart';
import 'package:flutter_learn_app/modules/social_app/social_register/cubit/states.dart';
import 'package:flutter_learn_app/shared/components/components.dart';

// ignore: use_key_in_widget_constructors
class SocialRegisterScreen extends StatelessWidget {
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var phoneController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (context) => SocialRegisterCubit(),
      child: BlocConsumer<SocialRegisterCubit, SocialRegisterStates>(
        listener: (context, state) {
          if (state is SocialCreateUserSuccessState) {
            navigateAndFinish(context, SocialLayout());
          }
        },
        builder: (context, state) {
          var shopRegisterCubit = SocialRegisterCubit.get(context);

          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGISTER',
                          style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Register now to communicate with new friends',
                          style:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        defaultFormField(
                          keyboardtype: TextInputType.name,
                          controller: nameController,
                          labeltext: 'Name',
                          prefix: Icons.person,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          keyboardtype: TextInputType.emailAddress,
                          controller: emailController,
                          labeltext: 'Email',
                          prefix: Icons.email_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          keyboardtype: TextInputType.visiblePassword,
                          controller: passwordController,
                          obscure: shopRegisterCubit.obscure,
                          labeltext: 'Password',
                          prefix: Icons.lock,
                          suffix: shopRegisterCubit.suffix,
                          suffixpressed: () {
                            shopRegisterCubit.changeObscure();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is too short';
                            } else {
                              return null;
                            }
                          },
                          onSubmit: (value) {
                            if (formKey.currentState!.validate()) {
                              SocialRegisterCubit.get(context).userRegister(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                                phone: phoneController.text
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        defaultFormField(
                          keyboardtype: TextInputType.phone,
                          controller: phoneController,
                          labeltext: 'Phone Number',
                          prefix: Icons.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your phone';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        ConditionalBuilder(
                          condition: state is! SocialRegisterLoadingState,
                          builder: (context) => defaultButton(
                            function: () {
                              if (formKey.currentState!.validate()) {
                                SocialRegisterCubit.get(context).userRegister(
                                    name: nameController.text,
                                    email: emailController.text,
                                    password: passwordController.text,
                                    phone: phoneController.text
                                );
                              }
                            },
                            text: 'register',
                            isUpperCase: true,
                          ),
                          fallback: (context) =>
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
