import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jinx/widgets/replymessagewidget.dart';

import 'package:chat_bubbles/chat_bubbles.dart';
import '../models/message_model.dart';


class GroupMessageBubble extends StatelessWidget {


  final MessageModel message;
  final time;
  final bool isMe;
  final Key key;

  GroupMessageBubble(
      this.message,
      this.time,
      this.isMe,
      this.key
      );

  final currentUserId=FirebaseAuth.instance.currentUser!.uid;
  final String? currentUserName = FirebaseAuth.instance.currentUser?.displayName;


  report (context)async{
    showDialog(context: context, builder: (context){return AlertDialog(

        title: Text('Report message',style:TextStyle(color:Colors.red )),
        backgroundColor: Color(0xfff1efe5),
        content: Text('are you sure you want to report this message?'),
        actions: [
          TextButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
              onPressed:  ()async{

                await FirebaseFirestore.instance.collection('reports').doc(message.messageId).collection('details').doc(currentUserId).set({
                  'reportedTime':DateTime.now(),
                  'reportedById':currentUserId,
                  'reportedBy':currentUserName,
                  'messageId':message.messageId,
                  'messageOwner':message.name,
                  'messageOwnerId':message.messageId,
                  'message':message.message,
                  'type':'messageGroup'


                });


                Navigator.of(context).pop();
                showDialog(context: context, builder: (context){return AlertDialog(
                    backgroundColor: Color(0xfff1efe5),
                    content: Text("Report sent",style: TextStyle(color: Colors.purple),));});
              }),



          TextButton(
            child: Text(
              'No',
              style: TextStyle(fontSize: 18,color: Colors.purple),
            ),
            onPressed: () {
              Navigator.of(context).pop();

            },
          ),
        ]

    );});

  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress:!isMe? ()=>report(context):null,
      child: Row(
        //mainAxisSize: MainAxisSize.min,



          mainAxisAlignment: isMe?MainAxisAlignment.end :MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            !isMe? Padding(
              padding: EdgeInsets.only(left: 5),
              child: CachedNetworkImage(
                imageUrl: message.photo,
                imageBuilder: (context, imageProvider) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                placeholder: (context, url) => Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: AssetImage('assets/defaultprofile.jpeg'), fit: BoxFit.cover),
                    )),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ):Container(),


            Container(
              //key: key,

              // width: MediaQuery.of(context).size.width,

              padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 2
              ),
              margin: const EdgeInsets.symmetric(
                  vertical: 1,
                  horizontal:2
              ),
              child: Column(

                //putting the text to on the corner of the bubble
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment:MainAxisAlignment.start ,
                children: <Widget> [

                  !isMe?Padding(

                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      //5f use username straight in here
                        message.name,
                        style: TextStyle(//fontSize: ,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                            //color: Colors.primaries[Random().nextInt(Colors.primaries.length)]

    ),
                        )
                    ):Container(),

                  if (message.replyMessage != null)Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: buildReply(),
                  ),

                  BubbleSpecialThree(
                    //sent: true,
                    //seen: true,
                    text:  message.message,

                    //tail: false,
                    color: isMe?Colors.purple:Colors.brown,
                    //sent: true,
                    //seen: true,
                    isSender: isMe,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text('$time',style: TextStyle(color: Colors.white,fontSize: 8),),
                  ),
                ],
              ) ,
            ),

          ]),
    );



  }
  Widget buildReply() => Container(
    //color: Colors.grey,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all( Radius.circular(10),
          //topRight:  Radius.circular(10)
        ),

      ),
      child:DisplayReplyMessageWidget(
        message,
      ));
}
