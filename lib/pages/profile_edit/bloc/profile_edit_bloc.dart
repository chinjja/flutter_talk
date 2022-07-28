import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:talk/repos/repos.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

part 'profile_edit_bloc.g.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final UserRepository _userRepository;
  final StorageRepository _storageRepository;

  ProfileEditBloc(
    this._userRepository,
    this._storageRepository, {
    required User user,
  }) : super(ProfileEditState(user: user, name: user.name, state: user.state)) {
    on<ProfileEditStarted>((event, emit) async {
      if (state.status.isPure) {
        final photo = user.photoId == null
            ? null
            : await _storageRepository.get(id: user.photoId!);
        emit(state.copyWith.photo(photo));
      }
    });

    on<ProfileEditPickingPhoto>((event, emit) async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null) return;
      add(ProfileEditPhotoChanged(result.files.first.bytes!));
    });
    on<ProfileEditPhotoChanged>((event, emit) {
      emit(state.copyWith.photo(event.photo));
    });

    on<ProfileEditNameChanged>((event, emit) {
      emit(state.copyWith.name(event.name));
    });

    on<ProfileEditStateChanged>((event, emit) {
      emit(state.copyWith.state(event.state));
    });

    on<ProfileEditSubmitted>((event, emit) async {
      try {
        emit(state.copyWith.status(FormzStatus.submissionInProgress));
        await _userRepository.update(
          name: state.name,
          state: state.state,
          photo: state.photo,
        );
        emit(state.copyWith.status(FormzStatus.submissionSuccess));
      } catch (_) {
        emit(state.copyWith.status(FormzStatus.submissionFailure));
      }
    });
  }
}
