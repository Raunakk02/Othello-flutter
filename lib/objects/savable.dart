abstract class Savable {
  Map<String, dynamic> toMap();
}

extension convertToMaps<T extends Savable> on List<T> {
  List<Map<String, dynamic>> toMaps() {
    List<Map<String, dynamic>> res = [];
    for (var elem in this) res.add(elem.toMap());
    return res;
  }
}