// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/user_model.dart';
import 'package:controlapp/pages/users_pages/user_order_list.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_widgets.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  bool isLoading = true;
  late List<UserModel> users;

  getAllUser() async {
    setState(() {
      isLoading = true;
    });
    users = [];
    await AppData().getUsers().then((value) {
      users = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  String searchValue = "";

  @override
  void initState() {
    getAllUser();
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
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 420,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: "userSearch".tr(),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Ionicons.search)),
                      onChanged: (v) {
                        setState(() {
                          searchValue = v;
                        });
                      },
                    ),
                  ),
                ),
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
                  List<Widget> userWidgets = [];

                  for (var user in users) {
                    bool matchesSearch = searchValue == "" ||
                        (user.phone
                            .toLowerCase()
                            .contains(searchValue.toLowerCase())) ||
                        (user.firstname
                            .toLowerCase()
                            .contains(searchValue.toLowerCase())) ||
                        (user.lastname
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()));

                    if (matchesSearch) {
                      Widget userContent = ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          tileColor: Colors.white,
                          title: SelectableText(user.phone,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.ltr,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${user.firstname} ${user.lastname}',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          minLeadingWidth: 0,
                          leading: const Icon(Ionicons.person),
                          trailing: PopupMenuButton(
                              offset: const Offset(0, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem<int>(
                                    value: 0,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.bag_handle,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Text("userOrders".tr())),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.call,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Text("callUser".tr())),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 2,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.copy,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child:
                                                Text("copyPhoneNumber".tr())),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 3,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.notifications,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child:
                                                Text("sendNotification".tr())),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 4,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Ionicons.close_circle,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Text("deleteUser".tr())),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              onSelected: (value) async {
                                switch (value) {
                                  case 0:
                                    var result =
                                        await Get.to(() => UserOrderList(
                                              userUid: user.phone,
                                            ));
                                    if (result != null) {
                                      setState(() {
                                        getAllUser();
                                      });
                                    }
                                    break;
                                  case 1:
                                    js.context.callMethod(
                                        'open', ['tel:${user.phone}']);
                                    break;
                                  case 2:
                                    Clipboard.setData(
                                            ClipboardData(text: user.phone))
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                        "phoneCopied".tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )));
                                    });
                                    break;
                                  case 3:
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          String title = "";
                                          String description = "";
                                          return StatefulBuilder(
                                              builder: (context, ssNotify) {
                                            return AlertDialog(
                                              title:
                                                  Text("sendNotification".tr()),
                                              clipBehavior: Clip.antiAlias,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0)),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
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
                                                      hintText:
                                                          "description".tr(),
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
                                                            AppData()
                                                                .sendNotificationToUser(
                                                              toUser:
                                                                  user.phone,
                                                              title: title,
                                                              body: description,
                                                            );
                                                          },
                                                          child: Text(
                                                              "send".tr())),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        style: Get
                                                            .theme
                                                            .elevatedButtonTheme
                                                            .style!
                                                            .copyWith(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(Colors
                                                                            .red)),
                                                        child:
                                                            Text("cancel".tr()),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          });
                                        });
                                    break;
                                  case 4:
                                    AppWidgets().MyDialog(
                                      context: context,
                                      background: Colors.blue,
                                      title: "delete".tr(),
                                      subtitle: "deleteUserConfirmation".tr(),
                                      asset: const Icon(
                                        Ionicons.information_circle,
                                        size: 80,
                                        color: Colors.white,
                                      ),
                                      confirm: ElevatedButton(
                                        onPressed: () async {
                                          Get.back();
                                          AppWidgets().MyDialog(
                                              context: context,
                                              title: "loading".tr(),
                                              background: Colors.blue,
                                              asset:
                                                  const CircularProgressIndicator(
                                                      color: Colors.white));
                                          await AppData()
                                              .deleteUser(userUid: user.phone)
                                              .then((value) async {
                                            Get.back();
                                            if (value['type'] == "success") {
                                              Get.back();
                                              setState(() {
                                                users.removeWhere((element) =>
                                                    element.phone ==
                                                    user.phone);
                                              });
                                            } else {
                                              AppWidgets().MyDialog(
                                                  context: context,
                                                  title: "error".tr(),
                                                  background: Colors.red,
                                                  asset: const Icon(
                                                    Ionicons.close_circle,
                                                    size: 80,
                                                    color: Colors.white,
                                                  ),
                                                  confirm: TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child: Text("ok".tr())));
                                            }
                                          });
                                        },
                                        style: Get
                                            .theme.elevatedButtonTheme.style!
                                            .copyWith(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.red)),
                                        child: Text("yes".tr()),
                                      ),
                                      cancel: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        style: Get
                                            .theme.elevatedButtonTheme.style!
                                            .copyWith(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blueGrey)),
                                        child: Text("no".tr()),
                                      ),
                                    );
                                    break;
                                  default:
                                    break;
                                }
                              }));
                      userWidgets.add(
                        SizedBox(
                          width: columnWidth > 0 ? columnWidth : null,
                          child: Padding(
                            // This was the BsCol padding
                            padding: const EdgeInsets.all(5.0),
                            child: userContent,
                          ),
                        ),
                      );
                    }
                  }
                  return Wrap(
                    spacing:
                        0, // Space between columns is handled by item padding
                    runSpacing:
                        0, // Space between rows is handled by item padding
                    children: userWidgets,
                  );
                }),
              ],
            ),
    );
  }
}
