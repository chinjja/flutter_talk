import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

import '../profile_edit.dart';

class ProfileEditPage extends StatelessWidget {
  final User user;
  const ProfileEditPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileEditBloc(
        context.read<UserRepository>(),
        user: user,
      )..add(const ProfileEditStarted()),
      child: BlocListener<ProfileEditBloc, ProfileEditState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isSubmissionSuccess) {
            context.pop();
          } else if (state.status.isSubmissionFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Error occur!')));
          }
        },
        child: const ProfileEditView(),
      ),
    );
  }
}

class ProfileEditView extends StatelessWidget {
  const ProfileEditView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: const [
          _SubmitButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            _ProfilePhoto(),
            SizedBox(height: 10),
            _PickingPhotoButton(),
            _NameField(),
            _StateField(),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: BlocBuilder<ProfileEditBloc, ProfileEditState>(
        builder: (context, state) {
          final photo = state.photo;
          if (photo == null) {
            return UserAvatar(state.user);
          }
          return CircleAvatar(backgroundImage: MemoryImage(photo));
        },
      ),
    );
  }
}

class _PickingPhotoButton extends StatelessWidget {
  const _PickingPhotoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('profileEditView_photo_button'),
      onPressed: () async {
        context.read<ProfileEditBloc>().add(const ProfileEditPickingPhoto());
      },
      child: const Text('Picks A Photo'),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditBloc, ProfileEditState>(
      builder: (context, state) {
        return TextFormField(
          key: const Key('profileEditView_name_textField'),
          initialValue: state.name,
          decoration: const InputDecoration(
            labelText: '이름',
          ),
          onChanged: (value) {
            context.read<ProfileEditBloc>().add(ProfileEditNameChanged(value));
          },
        );
      },
    );
  }
}

class _StateField extends StatelessWidget {
  const _StateField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditBloc, ProfileEditState>(
      builder: (context, state) {
        return TextFormField(
          key: const Key('profileEditView_state_textField'),
          initialValue: state.state,
          decoration: const InputDecoration(
            labelText: '상태',
          ),
          onChanged: (value) {
            context.read<ProfileEditBloc>().add(ProfileEditStateChanged(value));
          },
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileEditBloc, ProfileEditState>(
      builder: (context, state) {
        return TextButton(
            key: const Key('profileEditView_submit_button'),
            onPressed: () {
              context.read<ProfileEditBloc>().add(const ProfileEditSubmitted());
            },
            child: const Text('완료'));
      },
    );
  }
}
