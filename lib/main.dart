import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

void main(){
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class ChatMessage{
  String date, msg, id;
  ChatMessage({this.date, this.msg, this.id});
}

class MyApp extends StatefulWidget{
  @override
  _State createState() => new _State();
}

class _State extends State<MyApp>{
  SocketIO socketIO;
  TextEditingController inputMsg;
  String randomID = '';
  int conn = 0;
  List<ChatMessage> listChat = new List<ChatMessage>();

  @override
  void initState() {
    var rng = new Random();
    randomID = 'USER'+rng.nextInt(10000).toString();
    inputMsg = new TextEditingController();
    initSocketIO();
  }

  initSocketIO(){
    //update the domain before using
    socketIO = SocketIOManager().createSocketIO("http://192.168.2.3:3002", "/room", query: "userId=100", socketStatusCallback: _socketStatus);
    
    //call init socket before doing anything
    socketIO.init();

    //subscribe event
    socketIO.subscribe("new_message", _getMessage);
    socketIO.subscribe("socket_connections", _getConnections);

    //connect socket
    socketIO.connect();
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
  }

  void _sendMessage() async {
    if (socketIO != null) {
      String jsonData = '{msg: "'+inputMsg.text+'",id: '+randomID+'}';
      socketIO.sendMessage("send message", jsonData);
      inputMsg.clear();
    }
  }

  void _getMessage(dynamic data){
    print(data);
    Map<String,dynamic> map = new Map<String,dynamic>();
    map = json.decode(data);
    setState(() {
      listChat.add(new ChatMessage(date: map['date'], msg: map['msg'], id: map['id']));
    });
  }

  void _getConnections(dynamic data){
    print(data);
    Map<String,dynamic> map = new Map<String, dynamic>();
    map = json.decode(data);
    setState(()=>conn = map['socket']);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: new Text('Chat Messaging with Socket.io'),
      ),
      body: new SingleChildScrollView(
        padding: new EdgeInsets.all(16.0),
        child: new Container(
          child: new Column(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text('Your ID: '+randomID),
                  new Text('Total Connections: '+conn.toString())
                ],
              ),
              new ListView.builder(
                physics: ScrollPhysics(),
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: listChat.length,
                  itemBuilder: ((ctx, idx){
                    return _msgContainer(listChat[idx]);
                  }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: new Padding(
                  padding: new EdgeInsets.all(5.0),
              child: new TextField(
                controller: inputMsg,
                decoration: new InputDecoration.collapsed(hintText: 'Send a Message'),
              ),
              )
            ),
            Expanded(
              flex: 1,
              child: new FlatButton.icon(onPressed: _sendMessage, icon: Icon(Icons.send), label: new Text('')),
            )
          ],
        ),
        elevation: 9.0,
        shape: CircularNotchedRectangle(),
        color: Colors.white,
        notchMargin: 8.0,
      ),
    );
  }

  Widget _msgContainer(ChatMessage chat){
    if (chat.id != randomID){
      return new Container(
        decoration: new BoxDecoration(border: new Border.all(color: Colors.black), borderRadius: new BorderRadius.circular(10.0)),
        margin: new EdgeInsets.all(3.0),
        padding: new EdgeInsets.only(top: 16.0, bottom: 16.0, right: 8.0, left: 8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(chat.id+'('+chat.date+')', style: new TextStyle(color: Colors.grey),),
            new Text(chat.msg, )
          ],
        ),
      );
    }else{
      return new Container(
        decoration: new BoxDecoration(border: new Border.all(color: Colors.black), borderRadius: new BorderRadius.circular(10.0)),
        margin: new EdgeInsets.all(3.0),
        padding: new EdgeInsets.only(top: 16.0, bottom: 16.0, right: 8.0, left: 8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text('YOU', style: new TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            new Text(chat.msg, )
          ],
        ),
      );
    }
  }
}