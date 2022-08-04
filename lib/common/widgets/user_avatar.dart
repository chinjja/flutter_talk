import 'package:flutter/material.dart';
import 'package:talk/providers/providers.dart';

import '../common.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  const UserAvatar(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final photoId = user?.photoId;
    return CircleAvatar(
      backgroundImage: photoId == null ? null : StorageImage(photoId).provider,
    );
  }
}
