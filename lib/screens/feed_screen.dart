import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_flutter/models/login_model.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:instagram_flutter/providers/provider_manager.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String username = '';

  @override
  void initState() {
    super.initState();
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
      body:  StreamBuilder(
        stream:FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0,
                  ),
                  child: PostCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                );
              });
        },
      ),
    );
  }

  Future<Consumer> buildConsumer() async {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        AsyncValue<model.User> user = ref.watch(userInfoProvider);
        // final model.User user = ref.watch(weatherProvider);
        return Column(
          children: [
            TextButton(
                onPressed: () async {
                  Dio dio =
                      Dio(BaseOptions(responseType: ResponseType.plain));
                  Response response = await dio.get(
                      'http://www.weather.com.cn/data/sk/101010100.html');
                  var json1 = json.decode(response.data);
                  print(json1);

                  FirebaseFirestore.instance
                      .collection('/datas')
                      .doc()
                      .set(json1);
                },
                child: Text('上传')),
            TextButton(
                onPressed: () {
                  AuthMethods().signOut();
                },
                child: Text('注销')),
            user.when(
                data: (model.User value) => Text(value.email),
                error: (error, stack) =>
                    Text('Oops, something unexpected happened'),
                loading: () => CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
