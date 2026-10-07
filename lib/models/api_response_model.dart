// Project imports:
import 'package:getithk/imports.dart';

class ApiResponseModel {
  int? status;
  String? message;
  dynamic data;
  dynamic mapResponse;

  ApiResponseModel.fromJson(Map<String, dynamic> _json) {
    // The player API sends a bool (`"status": false`); map it onto the
    // kSuccess / kFail ints the rest of the app uses.
    final rawStatus = _json["status"];
    status = rawStatus is bool ? (rawStatus ? kSuccess : kFail) : rawStatus;

    // Normalize message (handle List<String> or String)
    final rawMessage = _json["message"];
    if (rawMessage is List) {
      message = rawMessage.join(", ");
    } else if (rawMessage is String) {
      message = rawMessage;
    }

    if (_json["data"] != null) data = _json["data"];
    mapResponse = _json;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["status"] = status;
    data["message"] = message;
    if (this.data != null) {
      data["data"] = this.data;
    }
    data["map_response"] = mapResponse;
    return data;
  }

  void showMessage() {
    if (message != null) {
      ToastHelper.showToast(message!);
    }
  }
}
