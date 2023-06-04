// ignore_for_file: prefer_typing_uninitialized_variables

class PostModel {
  String? name;
  String? uId;
  String? image;
  String? dataTime;
  String? text;
  String? postImage;
  int? likesCount;
  List<String>? likes;
  List? comments;

  PostModel({
    this.name,
    this.uId,
    this.image,
    this.dataTime,
    this.text,
    this.postImage,
    this.likesCount,
    this.likes,
    this.comments,
  });

  PostModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    uId = json['uId'];
    image = json['image'];
    dataTime = json['dataTime'];
    text = json['text'];
    postImage = json['postImage'];
    likesCount = json['likesCount'];
    likes = List<String>.from(json['likes']??[]);
    comments = List<dynamic>.from(json['comments']??[]);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uId': uId,
      'image': image,
      'dataTime': dataTime,
      'text': text,
      'postImage': postImage,
      'likesCount': likesCount,
      'likes': List<dynamic>.from(likes!),
      'comments': List<dynamic>.from(comments!),
    };
  }
}


