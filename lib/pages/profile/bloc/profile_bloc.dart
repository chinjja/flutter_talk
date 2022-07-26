import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:talk/common/common.dart';
import 'package:talk/repos/repos.dart';

part 'profile_event.dart';
part 'profile_state.dart';

part 'profile_bloc.g.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  ProfileBloc(this._userRepository) : super(const ProfileState()) {
    on<ProfileStarted>((event, emit) async {
      if (state.status != FetchStatus.initial) return;

      try {
        emit(state.copyWith.status(FetchStatus.loading));
        final user = await _userRepository.get(username: event.username);
        emit(state.copyWith(
          status: FetchStatus.success,
          user: user,
        ));
      } catch (_) {
        emit(state.copyWith.status(FetchStatus.failure));
      }
    });
  }
}
