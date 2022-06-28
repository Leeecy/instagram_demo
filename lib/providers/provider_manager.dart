import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/models/user.dart' as model;

import '../models/login_model.dart';

final userProvider = FutureProvider((ref) => UserInfoProvider());

final FutureProvider<model.User> userInfoProvider = FutureProvider((ref) => AuthMethods().getUserDetails());

// final counterProvider = Provider((ref){
//   final wsClient =  ref.watch(cityProvider);
//   return wsClient;
// });

final websocketClientProvider = FutureProvider((ref) async{
  final ws =  await AuthMethods().getUserDetails();
  return ws;
});

// final Provider<model.User> weatherProvider = Provider((ref){
//   final ws1111111 =  ref.watch(websocketClientProvider);
//   return ws1111111;
// });