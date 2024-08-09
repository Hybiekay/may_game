import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttergame/extention.dart';
import 'package:fluttergame/main.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: Container(),
        leadingWidth: 1,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(child: LogInDialog());
                });
          },
          child: const Card(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Log In"),
          )),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.all(8),
                height: 180,
                width: MediaQuery.sizeOf(context).width / 2.5,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8),
                height: 180,
                width: MediaQuery.sizeOf(context).width / 2.5,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(
                  "1000",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          child: Container(
                            height: 500,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                const TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Enter the name of the user",
                                      suffixIcon: Icon(Icons.search_rounded)),
                                ),
                                Expanded(
                                    child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    return Container();
                                  },
                                ))
                              ],
                            ),
                          ),
                        ));
              },
              child: Text(
                "Play With Other",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => GamePage()));
              },
              child: Text(
                "Play With Computer",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              "Best Player",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                var data = snapshot.data!.docs;

                return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var user = data[index].data();

                      return ListTile(
                        leading: CircleAvatar(),
                        title: Text(user["username"]),
                      );
                    });
              } else {
                return const Center(
                  child: Text("Check Your internet Connection"),
                );
              }
            },
          ))

          // Expanded(
          //     child: ListView.builder(
          //         itemCount: 10,
          //         itemBuilder: (context, index) {
          //           return ListTile(
          //             leading: CircleAvatar(
          //               radius: 25,
          //             ),
          //             title: Text(
          //               "Ademola",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //                 fontSize: 18,
          //               ),
          //             ),
          //             trailing: Text(
          //               "1000 Coin",
          //               style: TextStyle(fontSize: 14),
          //             ),
          //           );
          //         }))
        ],
      ),
    );
  }
}

class LogInDialog extends StatefulWidget {
  const LogInDialog({
    super.key,
  });

  @override
  State<LogInDialog> createState() => _LogInDialogState();
}

class _LogInDialogState extends State<LogInDialog> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;
  bool forgetPassword = false;
  bool isLogin = true;
  bool isLoading = false;

  Future login(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login Succesfully"),
        backgroundColor: Colors.green,
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
      print(e.message);
    }
  }

  Future register(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      var cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      setState(() {
        isLoading = false;
      });
      // hybiekay@gmail.com

      // hybiekay  //age

      var userData = {
        'email': email.trim(),
        "coin": 0,
        "username": email.toUserName()
      };
      firebaseFirestore.collection("users").doc(cred.user?.uid).set(userData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Regiser Successfully"),
        backgroundColor: Colors.green,
      ));

      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        emailController.clear();
                        passwordController.clear();
                        setState(() {
                          isLogin = true;
                        });
                      },
                      child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isLogin ? Colors.green : Colors.white60,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18,
                                color: isLogin ? Colors.white : Colors.black),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        emailController.clear();
                        passwordController.clear();
                        setState(() {
                          isLogin = false;
                        });
                      },
                      child: Container(
                          height: 30,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isLogin ? Colors.white60 : Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 18,
                              color: isLogin ? Colors.black : Colors.white,
                            ),
                          )),
                    ),
                  ],
                ),

                ///Register
                ///
                ///
                ///
                forgetPassword
                    ? Container(
                        height: 250,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                  hintText: "Enter your Email",
                                  border: OutlineInputBorder()),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await login(emailController.text,
                                    passwordController.text);
                              },
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Forget Password",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      )
                    : isLogin
                        ? Container(
                            height: 250,
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(),
                            child: Column(
                              children: [
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      hintText: "Enter your Email",
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: passwordController,
                                  obscureText: isObscure,
                                  decoration: const InputDecoration(
                                    hintText: "Enter your Password",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await login(emailController.text,
                                        passwordController.text);
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          forgetPassword = true;
                                        });
                                      },
                                      child: Text("Forgot Password")),
                                )
                              ],
                            ),
                          )
                        : Container(
                            height: 250,
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(),
                            child: Column(
                              children: [
                                const TextField(
                                  decoration: InputDecoration(
                                      hintText: "Enter your Email",
                                      border: OutlineInputBorder()),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: passwordController,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    hintText: "Enter your Password",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    register(emailController.text,
                                        passwordController.text);
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Register",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
              ],
            ),
    );
  }
}
