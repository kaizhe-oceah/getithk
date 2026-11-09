// Dart imports:
import "dart:convert";

// Package imports:
import "package:crypto/crypto.dart";

// Project imports:
import "api_constants.dart";

/// /player/login → /{playerPathKey}/login; other endpoints are left as is.
String signEndPoint(String endPoint, {DateTime? at}) {
  if (!endPoint.startsWith("$kPlayerSegment/")) return endPoint;
  return "/${playerPathKey(at: at)}${endPoint.substring(kPlayerSegment.length)}";
}

/// HMAC-SHA256 of the UTC time as mYdiH (month, year, day, minute, hour),
/// e.g. 2026-11-09 16:33 → "112026093316".
String playerPathKey({DateTime? at}) {
  final t = (at ?? DateTime.now()).toUtc();
  String two(int n) => n.toString().padLeft(2, "0");
  final message =
      "${two(t.month)}${t.year}${two(t.day)}${two(t.minute)}${two(t.hour)}";

  return Hmac(
    sha256,
    utf8.encode(kApiPathSecret),
  ).convert(utf8.encode(message)).toString();
}
