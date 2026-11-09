// Dart imports:
import "dart:convert";

// Package imports:
import "package:crypto/crypto.dart";
import "package:flutter_test/flutter_test.dart";

// Project imports:
import "package:getithk/utils/api_constants.dart";
import "package:getithk/utils/api_path_signer.dart";

void main() {
  final at = DateTime.utc(2026, 11, 9, 16, 33, 59);

  test("signs the UTC time as mYdiH", () {
    final expected = Hmac(
      sha256,
      utf8.encode(kApiPathSecret),
    ).convert(utf8.encode("112026093316")).toString();

    expect(playerPathKey(at: at), expected);
    expect(playerPathKey(at: at.toLocal()), expected);
  });

  test(
    "matches the backend's example",
    () => expect(
      playerPathKey(at: at),
      "9122281de408a1f235fe8475c20bff0fdbe4631f089466f05a5f3202f3bed1f6",
    ),
    skip: kApiPathSecret.isEmpty ? "kApiPathSecret not set" : false,
  );

  test("swaps only the /player segment", () {
    final key = playerPathKey(at: at);

    expect(signEndPoint(kLogin, at: at), "/$key/login");
    expect(
      signEndPoint(kPlayerSocialAccountsLink, at: at),
      "/$key/social-accounts/link",
    );
    expect(signEndPoint(kBanner, at: at), kBanner);
    expect(signEndPoint(kProductTagListing, at: at), kProductTagListing);
  });
}
