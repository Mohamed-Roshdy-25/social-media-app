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
   List<String>? sendingRequests;
   List<ReceivingRequest>? receivingRequests;



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
      this.sendingRequests,
      this.receivingRequests,
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
      sendingRequests = List<String>.from(json?['sendingRequests']??[]);
      receivingRequests = List<ReceivingRequest>.from(json?['receivingRequests'].map((x) => ReceivingRequest.fromJson(x)));
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
         'sendingRequests': List<dynamic>.from(sendingRequests??[]),
         'receivingRequests': List<dynamic>.from(receivingRequests?.map((receivingRequest) => receivingRequest.toMap())??[]),
      };
   }
}

class ReceivingRequest {
   String? uId;
   String? name;
   String? image;
   String? token;

   ReceivingRequest(this.uId, this.name, this.image, this.token);

   ReceivingRequest.fromJson(Map<String, dynamic>? json)
   {
      name = json?['userName'];
      uId = json?['userId'];
      image = json?['userImage'];
      token = json?['userToken'];
   }

   Map<String, dynamic> toMap()
   {
      return{
         'userName': name,
         'userId': uId,
         'userImage': image,
         'userToken': token,
      };
   }
}