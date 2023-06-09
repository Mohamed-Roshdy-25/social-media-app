// ignore_for_file: prefer_typing_uninitialized_variables

class SocialUserModel
{
   String? name;
   String? email;
   String? phone;
   String? uId;
   String? image;
   String? cover;
   String? bio;
   String? token;
   bool? isEmailVerified;
   List<String>? following;
   List<String>? followers;



   SocialUserModel({
      this.name,
      this.email,
      this.phone,
      this.uId,
      this.image,
      this.cover,
      this.bio,
      this.token,
      this.isEmailVerified,
      this.following,
      this.followers,
   });

   SocialUserModel.fromJson(Map<String, dynamic>? json)
   {
      name = json?['name'];
      email = json?['email'];
      phone = json?['phone'];
      uId = json?['uId'];
      image = json?['image'];
      cover = json?['cover'];
      bio = json?['bio'];
      token = json?['token'];
      isEmailVerified = json?['isEmailVerified'];
      following = List<String>.from(json?['following']??[]);
      followers = List<String>.from(json?['followers']??[]);
   }

   Map<String, dynamic> toMap()
   {
      return{
         'name': name,
         'email': email,
         'phone': phone,
         'uId': uId,
         'image': image,
         'cover': cover,
         'bio': bio,
         'token': token,
         'isEmailVerified': isEmailVerified,
         'following': List<dynamic>.from(following??[]),
         'followers': List<dynamic>.from(followers??[]),
      };
   }
}