import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void success(
      BuildContext context,
      String title,
      String description,
      ) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      description: Text(description),
      alignment: Alignment.topCenter,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }

  static void error(
      BuildContext context,
      String title,
      String description,
      ) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      description: Text(description),
      alignment: Alignment.topCenter,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }

  static void warning(
      BuildContext context,
      String title,
      String description,
      ) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      description: Text(description),
      alignment: Alignment.topCenter,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }

  static void info(
      BuildContext context,
      String title,
      String description,
      ) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(title),
      description: Text(description),
      alignment: Alignment.topCenter,
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }
}