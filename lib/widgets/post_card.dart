import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_flutter/models/storage_methods.dart';
import 'package:instagram_flutter/models/user.dart' as model;
import 'package:intl/intl.dart';
import '../providers/provider_manager.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import 'comment_card.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({Key? key, this.snap}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          AsyncValue<model.User> user = ref.watch(userInfoProvider);
          return Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ).copyWith(right: 0),
                child: Row(
                  children:<Widget> [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        widget.snap['profImage'].toString(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.snap['username'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    user.when(
                        data: (model.User user) => widget.snap['uid'].toString() == user.uid?IconButton(onPressed:(){
                          showDialog(context: context, builder: (context){
                            return Dialog(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shrinkWrap: true,

                              ),
                            );
                          });
                        }, icon: const Icon(Icons.more_vert)):Container(),
                        error: (error, stack) =>
                            Text('Oops, something unexpected happened'),
                        loading: () => CircularProgressIndicator()),

                  ],
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Image.network(
                  widget.snap['postUrl'].toString(),
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: <Widget>[
                  user.when(
                      data: (model.User user) =>IconButton(
                        onPressed: () {
                          StorageMethods().likePost(widget.snap['postId'].toString(), user.uid, widget.snap['likes']);
                        },
                        icon: widget.snap['likes'].contains(user.uid)
                            ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                            : const Icon(
                          Icons.favorite_border,
                        ),),
                      error: (error, stack) =>
                          Text('Oops, something unexpected happened'),
                      loading: () => CircularProgressIndicator()),

                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: widget.snap['postId'].toString(),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.send,
                      ),
                      onPressed: () {}),
                  Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                            icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                      ))

                ],
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DefaultTextStyle(
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontWeight: FontWeight.w800),
                        child: Text(
                          '${widget.snap['likes'].length} likes',
                          style: Theme.of(context).textTheme.bodyText2,
                        )),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: RichText(text: TextSpan(
                        style: TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' ${widget.snap['description']}',
                          ),
                        ],
                      )),
                    ),

                    InkWell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          'View all $commentLen comments',
                          style: const TextStyle(
                            fontSize: 16,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(
                            postId: widget.snap['postId'].toString(),
                          ),
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat.yMMMd()
                            .format(widget.snap['datePublished'].toDate()),
                        style: const TextStyle(
                          color: secondaryColor,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          );
        },

      ),
    );
  }
}
