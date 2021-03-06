import 'package:chat/View/chatterProfile.dart';
import 'package:chat/View/chatRoom.dart';
import 'package:chat/Widgets/Widget.dart';
import 'package:chat/services/Cons.dart';
import 'package:chat/services/Tservice.dart';
import 'package:chat/services/database.dart';
import 'package:chatbar/chatbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Conversation extends StatefulWidget {
  final String chatroomId;
  Conversation(this.chatroomId);
  @override
  _ConversationState createState() => _ConversationState();
}
class _ConversationState extends State<Conversation> {
  TextEditingController messagetextSendingController = new  TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Database db =new Database();
  Stream messagesStrem;
  bool _needsScroll = false;
  String url;
  
 getImageUrl(String location)async{
    return await Firestore.instance.collection("storage").where("location",isEqualTo: location).getDocuments();
  }
  setImage()async{
          QuerySnapshot snapshot= await getImageUrl('User/Profile/pro${widget.chatroomId.toString().replaceAll("_","").replaceAll(Constants.Name, "",)}.jpg');
          setState(() {
             url= snapshot.documents[0].data["url"].toString();
          });
  }


userInstructor(BuildContext context){
  return showDialog(context: context,builder: (context){
                return AlertDialog(
              contentPadding: EdgeInsets.only(left: 25, right: 25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Container(
                height: 200,
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text('1. You can send messages by typing blelow textbox and press the button to send.'),
                      SizedBox(height: 5,),
                      Text('2. You can translate masseges touch on message and hold on it.'),
                    ],
                  ),
                ),
              ),
              );
            });
}
  
Widget MessageList(){
      return StreamBuilder(
        stream: messagesStrem,
        builder: (context,snapshot){
          if(snapshot.data == null) return Container(
              alignment: Alignment.center,
              child:CircularProgressIndicator(),    
              );
          return ListView.builder( itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(bottom: 62),
                controller: _scrollController,
                itemBuilder: (context,index){
                return MessageHead(snapshot.data.documents[index].data["message"],snapshot.data.documents[index].data["sendBy"]== Constants.Name);
            });
        },
      );
  }
  
  AutoScroll(){
      setState(() {
          _scrollController.animateTo(
             _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,);
        });
  }
  SendMessages(){
    if(messagetextSendingController.text.isNotEmpty){
      Map<String,String> ChatMap = {
        "message":messagetextSendingController.text,
        "sendBy":Constants.Name,
        "time" :DateTime.now().millisecondsSinceEpoch.toString()
      };
      db.setChatRoomMessages(widget.chatroomId,ChatMap);
      messagetextSendingController.text="";
      setState(() {
          SendMessages();
          _scrollController.animateTo(
             _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,);
        });
    }
  }
  @override
  void initState() {
    db.getChatRoomMessages(widget.chatroomId).then((val){
      setState(() {
        messagesStrem=val;
      });
    });
    setImage();
    Constants.Chatter=widget.chatroomId.toString().replaceAll("_","").replaceAll(Constants.Name, "",);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatBar( 
          height: 64,
          profilePic: (url==null )?Image.asset('asset/images/user.png',height: 50,width: 50,fit: BoxFit.cover,):Image.network(url,height: 50,width: 50,fit: BoxFit.cover,),
          username: widget.chatroomId.toString().replaceAll("_","").replaceAll(Constants.Name, "",),
          status: Text(''),
          color: Colors.green.shade400,
          backbuttoncolor: Colors.white,
          backbutton: IconButton(
            icon: Icon(Icons.keyboard_arrow_left,size: 35,),
            onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                builder: (context)=>ChatRoom(),
              ));
            },
            color: Colors.white,
          ),
          
          actions: <Widget>[
            IconButton(
              onPressed: () {
                userInstructor(context);
              },
              icon: Icon(Icons.info),
              color: Colors.white,
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              enabled: true,
              onSelected: (str) {
                  if(str=="Profile"){
                  Navigator.push(context, MaterialPageRoute(
                  builder: (context)=>ChatterProfile(),
                  ));
                  }
              },
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: Text('Profile'),
                ),
              ],
            )
          ],
        ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children:[
            MessageList(),
            Container(
            alignment: Alignment.bottomCenter,
            child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                       Expanded(
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40),color: Colors.green),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                            child: TextField(style: TextStyle(color: Colors.white),
                              controller: messagetextSendingController,
                              decoration: InputDecoration(
                                hintText: "Type Message",
                                hintStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: (){
                          SendMessages();
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            boxShadow: [
                                        BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                spreadRadius: 3,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                            ],
                            
                            gradient: LinearGradient(
                                colors: [
                                  const Color(0xfffff7ff),
                                  const Color(0xffffffff)
                                ]
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(Icons.send),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
    ),
      ),
    );
  }
}


class MessageHead extends StatelessWidget {
  Tservice tservice= new Tservice();
  final String Message;
  final bool isSendbyMe;
  MessageHead(this.Message,this.isSendbyMe);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendbyMe ? Alignment.centerRight:Alignment.centerLeft ,
      padding: EdgeInsets.only(left:isSendbyMe ? 0:10,right: isSendbyMe ? 10:0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
        decoration: BoxDecoration(gradient: LinearGradient(colors: isSendbyMe ?
                [ const Color(0xffffffff), const Color(0xfff3ffff)]:
                [ const Color(0xffffffff), const Color(0xfff3ffff)] 
                ),
                borderRadius : isSendbyMe ? BorderRadius.only(topLeft: Radius.circular(23), topRight: Radius.circular(23),bottomLeft: Radius.circular(23)) :BorderRadius.only(topLeft: Radius.circular(23),topRight: Radius.circular(23), bottomRight: Radius.circular(23))
    ,boxShadow:  [
                      BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 3),
                              ),
                            ],
                ),
        child: GestureDetector(
          onLongPress: (){
            tservice.translate(context,Message.toString());
          },
          child: Text(Message , style: blackTextstyle(),),
        ),
      ),
    );
  }
}

