import 'package:flutter/material.dart';
import 'package:talk/providers/providers.dart';

import '../common.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  const UserAvatar(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
      );
    }
    final photoId = user?.photoId;
    if (photoId == null) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }
    return CircleAvatar(
      backgroundImage: StorageImage(photoId).provider,
    );
  }
}
