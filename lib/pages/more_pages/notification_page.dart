import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = true;
  late List<Map<String, dynamic>> notifications;

  getAllNotification() async {
    setState(() {
      isLoading = true;
    });
    notifications = [];
    await AppData().getNotifications().then((value) {
      notifications = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getAllNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: SizedBox(
                width: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: const LinearProgressIndicator(
                    minHeight: 10,
                  ),
                ),
              ),
            )
          : ListView(
              controller: ScrollController(),
              padding: const EdgeInsets.all(10.0),
              shrinkWrap: true,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  int numColumns;

                  // Determine number of columns based on available width
                  // Original BsCol sizes:
                  // xs: Col.col_12 (1 item)
                  // sm: Col.col_12 (1 item)
                  // md: Col.col_6  (2 items)
                  // lg: Col.col_6  (2 items)
                  // xl: Col.col_6  (2 items)
                  // xxl: Col.col_4 (3 items)
                  if (availableWidth >= 1400) {
                    // approx xxl
                    numColumns = 3;
                  } else if (availableWidth >= 768) {
                    // approx md, lg, xl
                    numColumns = 2;
                  } else {
                    // approx xs, sm
                    numColumns = 1;
                  }

                  final double columnWidth = availableWidth / numColumns;
                  List<Widget> notificationWidgets = [];

                  for (var notification in notifications) {
                    Widget notificationContent = ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      tileColor: Colors.white,
                      title: SelectableText(notification['title'],
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: SelectableText(
                        notification['description'],
                      ),
                      minLeadingWidth: 0,
                      leading: Card(
                          color: notification['toUser'] == "user"
                              ? Colors.blue
                              : notification['toUser'] == "driver"
                                  ? Colors.orange
                                  : Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              notification['toUser'] == "user"
                                  ? Ionicons.people
                                  : notification['toUser'] == "driver"
                                      ? Ionicons.bicycle
                                      : Ionicons.notifications,
                              color: Colors.white,
                            ),
                          )),
                    );
                    notificationWidgets.add(SizedBox(
                      width: columnWidth > 0 ? columnWidth : null,
                      child: Padding(
                        // This was the BsCol padding
                        padding: const EdgeInsets.all(5.0),
                        child: notificationContent,
                      ),
                    ));
                  }
                  return Wrap(
                    spacing:
                        0, // Space between columns is handled by item padding
                    runSpacing:
                        0, // Space between rows is handled by item padding
                    children: notificationWidgets,
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (context) {
                String toUser = "all";
                String title = "";
                String description = "";
                return StatefulBuilder(builder: (context, ssNotify) {
                  return AlertDialog(
                    title: Text("sendNotification".tr()),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("sendTo".tr()),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            FilterChip(
                              label: Text("all".tr()),
                              selected: toUser == "all",
                              backgroundColor: AppThemes.lightGreyColor,
                              selectedColor: AppThemes.primaryColor,
                              onSelected: (v) {
                                ssNotify(() {
                                  toUser = "all";
                                });
                              },
                              checkmarkColor: AppThemes.lightGreyColor,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: toUser == "all"
                                          ? AppThemes.lightGreyColor
                                          : AppThemes.darkColor),
                            ),
                            FilterChip(
                              label: Text("users".tr()),
                              selected: toUser == "user",
                              backgroundColor: AppThemes.lightGreyColor,
                              selectedColor: AppThemes.primaryColor,
                              onSelected: (v) {
                                ssNotify(() {
                                  toUser = "user";
                                });
                              },
                              checkmarkColor: AppThemes.lightGreyColor,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: toUser == "user"
                                          ? AppThemes.lightGreyColor
                                          : AppThemes.darkColor),
                            ),
                            FilterChip(
                              label: Text("drivers".tr()),
                              selected: toUser == "driver",
                              backgroundColor: AppThemes.lightGreyColor,
                              selectedColor: AppThemes.primaryColor,
                              onSelected: (v) {
                                ssNotify(() {
                                  toUser = "driver";
                                });
                              },
                              checkmarkColor: AppThemes.lightGreyColor,
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      color: toUser == "driver"
                                          ? AppThemes.lightGreyColor
                                          : AppThemes.darkColor),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "title".tr(),
                            filled: true,
                          ),
                          onChanged: (v) {
                            ssNotify(() {
                              title = v;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "description".tr(),
                            filled: true,
                          ),
                          maxLines: 5,
                          minLines: 4,
                          onChanged: (v) {
                            ssNotify(() {
                              description = v;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                  AppWidgets().MyDialog(
                                      context: context,
                                      title: "loading".tr(),
                                      background: Colors.blue,
                                      asset: const CircularProgressIndicator(
                                          color: Colors.white));
                                  AppData()
                                      .sendNotification(
                                    toUser: toUser,
                                    title: title,
                                    body: description,
                                  )
                                      .then((value) {
                                    var data = jsonDecode(value.body);
                                    if (data['id'] != null &&
                                        data['id'] != '') {
                                      AppData()
                                          .addNotification(
                                        toUser: toUser,
                                        title: title,
                                        description: description,
                                      )
                                          .then((value) {
                                        getAllNotification();
                                      });
                                      Get.back();
                                    } else {
                                      Get.back();
                                      AppWidgets().MyDialog(
                                          context: context,
                                          asset: const Icon(
                                            Ionicons.close_circle,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                          background: const Color(0xffDF2E2E),
                                          title: "notificationNotSent".tr(),
                                          confirm: ElevatedButton(
                                              onPressed: () {
                                                Get.back();
                                              },
                                              child: Text("back".tr())));
                                    }
                                  });
                                },
                                child: Text("send".tr())),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              style: Get.theme.elevatedButtonTheme.style!
                                  .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.red)),
                              child: Text("cancel".tr()),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                });
              });
        },
        label: Text("newNotification".tr()),
        icon: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
