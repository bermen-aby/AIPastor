import 'package:flutter/material.dart';

class LoaderProvider with ChangeNotifier {
  bool _isApiCallProcess = false;
  bool get isApiCallProcess => _isApiCallProcess;

  // ignore: avoid_positional_boolean_parameters
  void setLoadingStatus(bool status) {
    _isApiCallProcess = status;
    notifyListeners();
  }
}
