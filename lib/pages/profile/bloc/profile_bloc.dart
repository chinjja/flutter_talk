import 'dart:developer';
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
  final StorageRepository _storageRepository;
  final ListenRepository _listenRepository;

  Unsubscribe? _unsubscribe;

  ProfileBloc(
    this._userRepository,
    this._storageRepository,
    this._listenRepository,
  ) : super(const ProfileState()) {
    on<ProfileStarted>((event, emit) async {
      if (state.status != FetchStatus.initial) return;

      try {
        emit(state.copyWith.status(FetchStatus.loading));
        final user = await _userRepository.get(username: event.username);
        emit(state.copyWith(
          status: FetchStatus.success,
          user: user,
          name: user.name ?? user.username,
          state: user.state,
        ));
        final photoId = user.photoId;
        if (photoId != null) {
          emit(state.copyWith.photo(await _storageRepository.get(id: photoId)));
        }
      } catch (e) {
        log(e.toString());
        emit(state.copyWith.status(FetchStatus.failure));
      }
      _unsubscribe = _listenRepository.subscribeToUser((event) async {
        add(ProfileUpdated(event.user));
      });
    });

    on<ProfileUpdated>((event, emit) async {
      Uint8List? photo;
      final user = event.user;
      if (user.photoId != null) {
        photo = await _storageRepository.get(id: user.photoId!);
      }
      emit(state.copyWith(
        status: FetchStatus.success,
        user: user,
        name: user.name ?? user.username,
        state: user.state,
        photo: photo,
      ));
    });
  }

  @override
  Future<void> close() {
    _unsubscribe?.call();
    return super.close();
  }
}
