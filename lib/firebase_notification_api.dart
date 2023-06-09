import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseNotificationApi {
  int _messageCount = 0;

   sendNotifyFromFirebase({
    required String title,
    required String body,
    required String sendNotifyTo,
     required String type,
     String? postId,
     String? uploadedBy,
  })async{
     print('sending *******************');
     try {
       await http.post(
         Uri.parse('https://fcm.googleapis.com/fcm/send'),
         headers: <String, String>{
           'Content-Type': 'application/json',
           'Authorization': 'key=AAAALUgmyYs:APA91bE5KUitTvHCAovTqrOsEdINsUxvBMLmfP3E4Es-CBTdcnDTNtNWvQfq9fJGMnA87aIls_yZUaY1tMSUSv-PbEsMo0hrsycZ0akKH3VQtv2M3sVdjI0wCvT-NIifKrOVa-3kUEbl',
         },

         body: constructFCMPayload(body: body,
             title: title,
             sendNotifyTo: sendNotifyTo,
             type: type,
             postId: postId,
             uploadedBy: uploadedBy),
       );
     }catch(error){
       print('${error.toString()} *******************');
     }

     print('sent *******************');
  }


  String constructFCMPayload({
    required String title,
    required String body,
    required String sendNotifyTo,
    required String type,
     String? postId,
     String? uploadedBy,
  }) {
    _messageCount++;
    return jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
          'android_channel_id':'business'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status':'done',
          'type':type,
          'postId':postId,
          'uploaded_by':uploadedBy,
          'count': _messageCount.toString(),
          'body': body,
          'title': title,
        },
        'to': sendNotifyTo,
      },
    );
  }
}

FirebaseNotificationApi fireApi = FirebaseNotificationApi();