import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

export 'fetch_status.dart';
export 'forms/forms.dart';
export 'widgets/widgets.dart';
export 'converter/converter.dart';

void showSnackbar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message ?? ''),
      ),
    );
}

void showError(BuildContext context, dynamic error) {
  String message;
  if (error is DioError) {
    message = error.message;
  } else {
    message = error.toString();
  }
  showSnackbar(context, message);
}
