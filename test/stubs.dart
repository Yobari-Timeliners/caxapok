import 'package:meta/meta.dart';

@immutable
class EqualStub {
  final int id;
  final String name;

  const EqualStub({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EqualStub) return false;

    return id == other.id && name == other.name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
