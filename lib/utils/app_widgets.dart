import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppWidgets {
  // ignore: non_constant_identifier_names
  MyDialog(
          {required BuildContext context,
          String? title,
          String? subtitle,
          Color? background,
          Widget? confirm,
          Widget? cancel,
          required Widget asset}) =>
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: background,
                      child: Center(child: asset),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          title != null
                              ? Text(title,
                                  style: Theme.of(context).textTheme.titleLarge)
                              : const SizedBox(),
                          subtitle != null
                              ? Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          confirm ?? const SizedBox(),
                          const SizedBox(
                            width: 10,
                          ),
                          cancel ?? const SizedBox(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });

  // ignore: non_constant_identifier_names
  EmptyDataWidget({
    required String title,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: Get.size.width / 2,
        ),
        Text(
          title,
          //  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey),
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
