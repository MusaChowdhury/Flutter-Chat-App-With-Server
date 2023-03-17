import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

late Socket socket;

List<User> users = [];

bool connected = false;
String user_id = "";
bool fond_user = false;

// Future<void> show_user() async {
//   while (true) {
//     print("Printing All Users");
//     for (User i in users) {
//       print(i);
//     }
//     await Future.delayed(const Duration(seconds: 2));
//   }
// }

Future<void> create_socket(String ip, int port) async {
  if (connected == false) {
    try {
      socket = await Socket.connect(ip, port);
      // print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.listen((Uint8List data) {
        // print('Inside listener');
        Map serverResponse = json.decode(String.fromCharCodes(data));
        // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Server: $serverResponse');

        if (!connected && serverResponse["response"] == "failed") {
          // print("Connection with server failed, restarting");
          socket.close();
          connected = false;
          create_socket(ip, port);
        }
        // Test Code , Target Loop Back
        // if(serverResponse["from"] == "TEST")
        //   {
        //     User.received_message("TEST", "OK Loop Back Msg , Lopped Msg: " + serverResponse["data"]);
        //     return;
        //   }
        // Test Code, End Here

        if (!connected && (serverResponse["response"] == "success")) {
          // print("connected to server successfully");
          connected = true;
        }

        if (connected && serverResponse["response"] == "message") {
          User.sent_message(serverResponse["from"], serverResponse["data"]);
        }

        if (connected && serverResponse["response"] == "found") {
          fond_user = true;
        } else if (connected && serverResponse["response"] == "not_found") {
          fond_user = false;
        }
      }, onError: (error) {
        // _destroy(ip, port);
        socket.close();
        create_socket(ip, port);
        connected = false;
      }, onDone: () {
        socket.close();
        create_socket(ip, port);
        connected = false;
      });
    } on Exception {
      // print("Exception -> socket");
    }
  }
}

void main() async {
  //show_user();
  // create_socket(ip, port);

  runApp(Retro_Chat());
}

class Retro_Chat extends StatelessWidget {
  const Retro_Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          //appBar: AppBar(title: Center(child: Text("Connected to Server"))),
          body: SizedBox(
            child: Login_Screen(),
          ),
          bottomSheet: const SizedBox(
            child: Align(
              child: Text("Developed By Musa Chowdhury"),
              alignment: Alignment.bottomCenter,
            ),
            height: 20,
          )),
    );
  }
}

class Login_Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Login_Screen_Page();
  }
}

class Login_Screen_Page extends State<Login_Screen> {
  late TextEditingController name_text_controller;

  var continue_button_disable = true;

  @override
  void initState() {
    super.initState();
    name_text_controller = TextEditingController();
    name_text_controller.addListener(() {
      if (name_text_controller.value.text.isNotEmpty) {
        setState(() {
          continue_button_disable = false;
        });
      } else {
        setState(() {
          continue_button_disable = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 35,
        right: 35,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: name_text_controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Name:IP:Port',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                //fillColor: Colors.grey.shade100,
                //filled: true,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide:
                        const BorderSide(width: 3, color: Colors.green)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    borderSide:
                        const BorderSide(width: 3, color: Colors.purple)),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black),
                minimumSize: MaterialStateProperty.all(Size(90, 50)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                    side: const BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
              onPressed:
                  !continue_button_disable ? _core_fucntion_of_continue : null,
              child: const SizedBox(
                child: Text(
                  "Continue",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _core_fucntion_of_continue() async {
    if (!connected) {
      List<String> parsed = name_text_controller.value.text.split(":");
      print(parsed);
      await create_socket(parsed[1], int.parse(parsed[2]));
      Map<String, String> data = Map();
      data["id"] = parsed[0];
      socket.write(json.encode(data));
      await Future.delayed(const Duration(seconds: 2));
      if (connected) {
        user_id = parsed[0];
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Chat_Page()));
      }
    }
  }

  @override
  void dispose() {
    name_text_controller.dispose();
    super.dispose();
  }
}

class Chat_Page extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Chat_selection();
  }
}

class User {
  late String id;

  List<Message> messages = [];

  User(this.id);

  static void sent_message(String id, String s) {
    User? temp = User.get_user(id);
    if (temp != null) {
      temp.messages.add(Message(s, Message_Type.Send));
    } else {
      User initiated = User(id);
      initiated.messages.add(Message(s, Message_Type.Send));
      users.add(initiated);
    }
  }

  static void received_message(String id, String s) {
    Map<String, String> token = Map();
    token["type"] = "message";
    token["id"] = user_id;
    token["to"] = id;
    token["data"] = s;

    socket.write(json.encode(token));

    User? temp = User.get_user(id);
    if (temp != null) {
      temp.messages.add(Message(s, Message_Type.Received));
    } else {
      User initiated = User(id);
      initiated.messages.add(Message(s, Message_Type.Received));
      users.add(initiated);
    }
  }

  static User? get_user(String id) {
    for (User i in users) {
      if (i.id == id) {
        return i;
      }
    }

    return null;
  }

  @override
  String toString() {
    return "id $id\n\n" + messages.toString();
  }
}

enum Message_Type { Send, Received }

class Message {
  late String message;
  late Message_Type type;

  Message(this.message, this.type);

  @override
  String toString() {
    return type == Message_Type.Send
        ? "Send : $message"
        : "Received : $message";
  }
}

class Chat_selection extends State<Chat_Page> {
  late ListView users_list;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Connected ',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                backgroundColor: Colors.green[300],
                actions: [
                  // Navigate to the Search Screen
                  IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SearchPage())),
                      icon: Icon(Icons.message))
                ],
              ),
              body: users_list,
            )));
  }

  @override
  void initState() {
    super.initState();
    user_list_creator();
  }

  // CREATING USER LIST
  Future<void> user_list_creator() async {
    while (true) {
      List<Widget> temp = [];
      for (User i in users) {
        temp.add(GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => Indivisual_Chat_Page(id: i.id)));
            },
            child: Container(
              padding: const EdgeInsets.only(
                  left: 20, top: 13, bottom: 10, right: 20),
              height: 50,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.blueGrey,
              ),
              // constraints: BoxConstraints(maxWidth: 140),
              child: Text(
                i.id,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            )));
        temp.add(const SizedBox(
          height: 30,
        ));
      }
      setState(() {
        users_list = ListView(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
          children: temp,
        );
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return Search_Resutls();
  }
}

class Search_Resutls extends State<SearchPage> {
  TextEditingController search_editor = TextEditingController();
  String name = "";

  @override
  void initState() {
    search_editor.addListener(() async {
      fond_user = false;
      if (search_editor.text.isNotEmpty) {
        Map<String, String> token = Map();
        token["type"] = "find";
        token["id"] = search_editor.text;
        socket.write(json.encode(token));
      }
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        name = search_editor.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[300],
          // The search area here
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        /* Clear the search field */
                      },
                    ),
                    hintText: 'Search User',
                    border: InputBorder.none),
                controller: search_editor,
              ),
            ),
          )),
      body: fond_user
          ? SafeArea(
              child: SizedBox(
              width: double.infinity,
              child: TextButton(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text('Chat with $name?',
                        style: const TextStyle(
                            fontSize: 19, color: Colors.black))),
                onPressed: () {
                  fond_user = false;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Indivisual_Chat_Page(id: name)));
                },
              ),
            ))
          : null,
    );
  }
}

class Indivisual_Chat_Page extends StatefulWidget {
  late String id;

  Indivisual_Chat_Page({Key? key, this.id = "error"}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return Indivisual_Chat_Page_Creator(this.id);
  }
}

class Indivisual_Chat_Page_Creator extends State<Indivisual_Chat_Page> {
  bool alive = true;
  late String id;
  late TextField send_message_input;
  late var drawer;
  late ScrollController scroll_controller;

  Indivisual_Chat_Page_Creator(String id) {
    this.id = id;
    scroll_controller = ScrollController();
  }

  @override
  void initState() {
    drawer = updater();
    super.initState();
    alive = true;
    var sendMessageInputController = TextEditingController();

    send_message_input = TextField(
      controller: sendMessageInputController,
      decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(width: 3, color: Colors.green)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(width: 3, color: Colors.purple)),
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              User.received_message(id, sendMessageInputController.value.text);
              sendMessageInputController.clear();
              scroll_controller
                  .jumpTo(scroll_controller.position.maxScrollExtent);
            },
          ),
          hintText: 'Type here...',
          border: InputBorder.none),
      // controller: ,
    );

    update_start();
  }

  Future<void> update_start() async {
    while (true) {
      setState(() {
        drawer = updater();
      });

      await Future.delayed(Duration(seconds: 1));
      if (!alive) return;
      scroll_controller.jumpTo(scroll_controller.position.maxScrollExtent);
    }
  }

  dynamic updater() {
    List<Widget> messages = [SizedBox(height: 50)];

    for (User i in users) {
      if (i.id == id) {
        for (Message j in i.messages) {
          messages.add(Align(
              alignment: j.type == Message_Type.Received
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: Container(
                padding:
                    EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black12,
                ),
                constraints: BoxConstraints(maxWidth: 140),
                child: Text(
                  j.message,
                  style: TextStyle(fontSize: 17),
                ),
              )));
          messages.add(SizedBox(
            height: 10,
          ));
        }
      }
    }
    messages.add(SizedBox(height: 50));
    return ListView(
      padding: EdgeInsets.only(left: 5, bottom: 30, right: 5),
      controller: scroll_controller,
      //shrinkWrap: true,
      children: messages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.green[300],
            title: Text("$id"),
          ),
          body: drawer,
          bottomSheet: SizedBox(
            child: send_message_input,
          ),
        ));
  }

  @override
  void dispose() {
    alive = false;
    super.dispose();
  }
}

