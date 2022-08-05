part of 'profile_bloc.dart';

@CopyWith()
class ProfileState extends Equatable {
  final FetchStatus status;
  final FormzStatus directChatStatus;
  final Chat? directChat;
  final User? user;
  final dynamic error;

  const ProfileState({
    this.status = FetchStatus.initial,
    this.directChatStatus = FormzStatus.pure,
    this.directChat,
    this.user,
    this.error,
  });

  @override
  List<Object?> get props => [
        status,
        directChatStatus,
        directChat,
        user,
        error,
      ];
}
