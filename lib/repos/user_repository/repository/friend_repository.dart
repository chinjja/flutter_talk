import 'package:rxdart/rxdart.dart';
import 'package:talk/repos/repos.dart';

class FriendRepository {
  final FriendProvider _friendProvider;
  final ListenRepository _listenRepository;
  Unsubscribe? _unsubscribe;

  FriendRepository(this._friendProvider, this._listenRepository) {
    _listenRepository.onConnectedUser.listen((user) async {
      if (user == null) {
        _unsubscribe?.call();
        _unsubscribe = null;
      } else {
        await fetchFriends();
        _unsubscribe = _listenRepository.subscribeToFriend((event) async {
          final old = await _friendsChanged.first;
          if (event.isAdded) {
            _friendsChanged.add([...old, event.friend]);
          } else if (event.isRemoved) {
            _friendsChanged.add(old
                .where((e) => e.user.username != event.friend.user.username)
                .toList());
          }
        });
      }
    });
  }

  final _friendsChanged = BehaviorSubject<List<Friend>>();
  late final onFriends = _friendsChanged.stream;

  Future<List<Friend>> getFriends() async {
    return _friendProvider.getFriends();
  }

  Future<void> fetchFriends() async {
    final friends = await getFriends();
    _friendsChanged.add(friends);
  }

  Future<void> addFriend({
    required String username,
  }) async {
    await _friendProvider.addFriend(username: username);
  }

  Future<void> removeFriend({
    required User friend,
  }) async {
    await _friendProvider.removeFriend(friend: friend);
  }
}
