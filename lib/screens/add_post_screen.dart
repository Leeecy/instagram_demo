import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import '../models/storage_methods.dart';
import '../providers/provider_manager.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  
  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }
  _selectImage(BuildContext parentContext) async {
    return showDialog(context: parentContext, builder: (BuildContext context){
      return SimpleDialog(
        title: const Text('Create a Post'),
        children: [
          SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take a photo'),
              onPressed: () async {
                Navigator.pop(context);
                Uint8List file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              }),
          SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              }),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      );
    });
  }
  void clearImage() {
    setState(() {
      _file = null;
    });
  }
  Future<void> postImage(String uid, String username, String photoUrl) async {
    setState(() {
      isLoading = true;
    });

    try{
      // upload to storage and db
      String res = await StorageMethods().uploadPost(
        _descriptionController.text,
        _file!,
        uid,
        username,
        photoUrl,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        showSnackBar(
          context,
          'Posted!',
        );
        clearImage();
      }else {
        showSnackBar(context, res);
      }

    }catch(err){
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
              ),
              onPressed: () => _selectImage(context),
            ),
          )
        : Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            AsyncValue<model.User> user  = ref.watch(userInfoProvider);
            return Scaffold(
              appBar: AppBar(
                backgroundColor: mobileBackgroundColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: clearImage,
                ),
                title: const Text(
                  'Post to',
                ),
                centerTitle: false,
                actions: <Widget>[
                  user.when(
                        data: (model.User user) => TextButton(
                              onPressed: () {
                                postImage(
                                  user.uid,
                                  user.username,
                                  user.photoUrl,
                                );
                              },
                              child: const Text(
                                "Post",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0),
                              ),
                            ),
                        error: (error, stack) =>
                            const Text('Oops, something unexpected happened'),
                        loading: () => CircularProgressIndicator()),
                  ],
              ),
              body:Column(
                    children: <Widget>[
                      isLoading?const LinearProgressIndicator():const Padding(padding: EdgeInsets.only(top: 0.0)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:<Widget> [
                          user.when(
                              data: (model.User user) => CircleAvatar(
                                backgroundImage: NetworkImage(
                                  user.photoUrl,
                                ),
                              ),
                              error: (error, stack) =>
                              const Text('Oops, something unexpected happened'),
                              loading: () => CircularProgressIndicator()),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                  hintText: "Write a caption...",
                                  border: InputBorder.none),
                              maxLines: 8,
                            ),
                          ),
                          SizedBox(
                            height: 45.0,
                            width: 45.0,
                            child: AspectRatio(
                              aspectRatio: 487 / 451,
                              child: Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      alignment: FractionalOffset.topCenter,
                                      image: MemoryImage(_file!),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                    ],
                  ),
            );
          },
        );
  }


}
