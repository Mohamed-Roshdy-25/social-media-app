// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_learn_app/layout/social%20app/social_layout.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/cubit/cubit.dart';
import 'package:flutter_learn_app/modules/social_app/social_login/cubit/states.dart';
import 'package:flutter_learn_app/modules/social_app/social_register/social_register_screen.dart';
import 'package:flutter_learn_app/shared/components/components.dart';
import 'package:flutter_learn_app/shared/components/constants.dart';
import 'package:flutter_learn_app/shared/network/local/cache_helper.dart';

class SocialLoginScreen extends StatelessWidget {

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit, SocialLoginStates>(
        listener: (context, state) {
          if(state is SocialLoginErrorState)
            {
              showToast(text: state.error, state: ToastStates.ERROR,);
            }
          if(state is SocialLoginSuccessState)
            {
              uId = state.uId;
              CacheHelper.saveData(
                  key: 'uId', value: state.uId)
                  .then((value) {
                navigateAndFinish(
                  context,
                  const SocialLayout(),
                );
              });
            }
        },
        builder: (context, state) {
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
                          'LOGIN',
                          style:
                          Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Login now to communicate with new friends',
                          style:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        defaultFormField(
                          keyboardtype: TextInputType.emailAddress,
                          controller: emailController,
                          labeltext: 'Email',
                          prefix: Icons.email_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email is too short';
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
                          obscure: SocialLoginCubit.get(context).obscure,
                          labeltext: 'Password',
                          prefix: Icons.lock,
                          suffix: SocialLoginCubit.get(context).suffix,
                          suffixpressed: () {
                            SocialLoginCubit.get(context).changeObscure();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is too short';
                            } else {
                              return null;
                            }
                          },
                          onSubmit: (value) {
                            if (formKey.currentState!.validate())
                            {
                              SocialLoginCubit.get(context).userLogin(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 30.0,
                        ),
                        ConditionalBuilder(
                          condition: state is! SocialLoginLoadingState,
                          builder: (context) => defaultButton(
                            function: () {
                              if (formKey.currentState!.validate())
                              {
                                SocialLoginCubit.get(context).userLogin(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );
                              }
                            },
                            text: 'login',
                            isUpperCase: true,
                          ),
                          fallback: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                            ),
                            defaultTextButton(
                              text: 'register now',
                              onPressed: () {
                                navigateTo(
                                  context,
                                  SocialRegisterScreen(),
                                );
                              },
                            ),
                          ],
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
