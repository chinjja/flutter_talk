import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:talk/common/converter/image_resizer.dart';
import 'package:talk/repos/repos.dart';

part 'profile_edit_event.dart';
part 'profile_edit_state.dart';

part 'profile_edit_bloc.g.dart';

class ProfileEditBloc extends Bloc<ProfileEditEvent, ProfileEditState> {
  final UserRepository _userRepository;
  final ImageResizer _imageResizer;

  ProfileEditBloc(
    this._userRepository, {
    required User user,
    ImageResizer? imageResizer,
  })  : _imageResizer = imageResizer ?? ImageResizer(),
        super(
            ProfileEditState(user: user, name: user.name, state: user.state)) {
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
        var photo = state.photo;
        if (photo != null) {
          photo = await _imageResizer.resize(photo, width: 256);
          if (photo == null) {
            emit(state.copyWith(
              status: FormzStatus.submissionFailure,
              error: 'cannot decode',
            ));
            return;
          }
        }
        await _userRepository.update(
          name: state.name,
          state: state.state,
          photo: photo,
        );
        emit(state.copyWith.status(FormzStatus.submissionSuccess));
      } catch (e) {
        emit(state.copyWith(
          status: FormzStatus.submissionFailure,
          error: e,
        ));
      }
    });
  }
}
