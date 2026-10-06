// Project imports:
import 'package:getithk/imports.dart';

class ApiResponseModel {
  int? status;
  String? message;
  dynamic data;
  dynamic mapResponse;

  ApiResponseModel.fromJson(Map<String, dynamic> _json) {
    status = _json["status"];

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
