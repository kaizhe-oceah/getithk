// Project imports:
import '../imports.dart';

double parseCurrency(dynamic currency) {
  // Remove any commas from the currency string
  String cleanedCurrency = currency.toString().replaceAll(',', '');

  // Convert the cleaned string to a double
  double value = double.parse(cleanedCurrency);

  return value;
}

dynamic myEncode(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}

Size? getWidgetSize(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  return renderBox?.size;
}

int parseTimeToSeconds(String timeString) {
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int seconds = int.parse(parts[2]);
  return seconds + minutes * 60 + hours * 3600;
}

DateTime parseFromTimeOfDay(
    {required TimeOfDay timeOfDay, DateTime? dateTime}) {
  DateTime selectedDate = dateTime ?? DateTime.now().toLocal();
  return DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
      timeOfDay.hour, timeOfDay.minute);
}

String durationToString(Duration duration) {
  return "${duration.inHours}:${duration.inMinutes}";
}

Duration durationFromString(String value) {
  Duration duration = Duration(
      hours: int.parse(value.split(":").first),
      minutes: int.parse(value.split(":").last));
  return duration;
}

DateTime? timeFromJson(dynamic ts) {
  // ignore: unnecessary_cast
  switch (ts?.runtimeType as Type?) {
    // case Timestamp:
    //   return (ts as Timestamp).toDate();
    case const (DateTime):
      return (ts as DateTime).toLocal();
    case const (String):
      return DateTime.parse(ts as String).toLocal();
    case const (int):
      return DateTime.fromMillisecondsSinceEpoch(ts as int).toLocal();
    default:
      return DateTime.now().toLocal();
  }
}

bool parseBool(dynamic v, [bool d = false]) => v is bool ? v : d;

DateTime parseDate(dynamic ts, [DateTime? d]) {
  final def = (d ?? DateTime.now()).toLocal();
  if (ts == null) return def;
  switch (ts.runtimeType) {
    case const (DateTime):
      return (ts as DateTime).toLocal();
    case const (String):
      return DateTime.parse(ts as String).toLocal();
    case const (int):
      return DateTime.fromMillisecondsSinceEpoch(ts as int).toLocal();
    default:
      return def;
  }
}

double parseDouble(dynamic v, [double d = 0]) {
  if (v == null) {
    return d;
  } else if (v is double) {
    return v;
  } else if (v is num) {
    return v.toDouble();
  } else {
    return double.tryParse('${v ?? '0'}') ?? d;
  }
}

int parseInt(dynamic v, [int d = 0]) {
  if (v == null) {
    return d;
  } else if (v is String) {
    return int.tryParse(v.replaceAll(".", "").replaceAll(",", "")) ?? d;
  } else if (v is int) {
    return v;
  } else if (v is double) {
    return v.toInt();
  } else {
    return int.tryParse('${v ?? '0'}') ?? d;
  }
}

List<int> parseListInt(dynamic v) {
  if (v == null) {
    return [];
  } else if (v is List<int>) {
    return v;
  } else if (v is int) {
    return [];
  } else if (v is double) {
    return [];
  } else if (v is String) {
    return [];
  } else {
    return List<int>.from(v as List? ?? []);
  }
}

String parseSubstring(String text, int limit, {String? replace}) {
  if (text.length > limit) {
    return '${text.substring(0, limit)}${replace ?? ".."}';
  } else {
    return text;
  }
}

String parseString(dynamic v, [String? d]) => v is String ? v : '${v ?? d}';

List<String> parseListString(dynamic v) {
  if (v == null) {
    return [];
  } else if (v is List<String>) {
    return v;
  } else if (v is List<int>) {
    List<String> list = [];
    for (var element in v) {
      list.add(element.toString());
    }
    return list;
  } else if (v is int) {
    return [];
  } else if (v is double) {
    return [];
  } else if (v is String) {
    return [];
  } else {
    //  return List<String>.from(v as List? ?? []);
    List<String> list = [];
    v.forEach((element) {
      list.add(element.toString());
    });
    return list;
  }
}

String parsePrice(dynamic v, [String d = "0"]) {
  if (v == null) return d;

  String str = v.toString().replaceAll(",", "");

  return RegExp(r'^\d+(\.\d+)?$').hasMatch(str) ? str : d;
}
