import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_flutter/models/login_model.dart';

import '../utils/colors.dart';
import '../utils/global_variable.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String username = '';
  @override
  void initState(){
    super.initState();
    getUsername();
  }

  void getUsername() async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    print(snap.data());

    setState((){
      username = (snap.data() as Map<String,dynamic>)['username'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
      width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.messenger_outline,
              color: primaryColor,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          TextButton(onPressed: () async {
            Dio dio = Dio(BaseOptions(responseType: ResponseType.plain));
            Response response =
                await dio.get('http://www.weather.com.cn/data/sk/101010100.html');
            var json1 = json.decode(response.data);
            print(json1);
            
            FirebaseFirestore.instance.collection('/datas').doc().set(json1);
          }, child: Text('上传')),
          TextButton(onPressed: ()  {
            AuthMethods().signOut();
          }, child: Text('注销')),
          Text(username),
        ],
      ),
    );
  }
}
