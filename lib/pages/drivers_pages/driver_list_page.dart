// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/driver_model.dart';
import 'package:controlapp/pages/drivers_pages/add_driver_page.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';

class DriverListPage extends StatefulWidget {
  const DriverListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DriverListPageState createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  bool isLoading = true;
  late List<DriverModel> drivers;
  late List<DriverModel> filterDriver;

  String isAvailable = "All";

  getAllDriver() async {
    setState(() {
      isLoading = true;
      isFilter = false;
      isAvailable = "All";
    });
    drivers = [];
    await AppData().getDrivers().then((value) {
      drivers = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  bool isFilter = false;
  String searchValue = "";

  filterResult({required String type}) {
    if (type == "Available") {
      setState(() {
        filterDriver = [];
        filterDriver =
            drivers.where((element) => element.available == 1).toList();

        isFilter = true;
      });
    } else if (type == "Not Available") {
      setState(() {
        filterDriver = [];
        filterDriver =
            drivers.where((element) => element.available == 0).toList();

        isFilter = true;
      });
    } else {
      setState(() {
        isFilter = false;
      });
    }
  }

  @override
  void initState() {
    getAllDriver();
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
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "searchByPhone".tr(),
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
                    FilterChip(
                      label: Text("all".tr()),
                      onSelected: (bool value) {
                        setState(() {
                          isAvailable = "All";
                          filterResult(type: "All");
                        });
                      },
                      selected: isAvailable == "All",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: isAvailable == "All"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                    FilterChip(
                      label: Text("available".tr()),
                      onSelected: (bool value) {
                        setState(() {
                          isAvailable = "Available";
                          filterResult(type: "Available");
                        });
                      },
                      selected: isAvailable == "Available",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: isAvailable == "Available"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                    FilterChip(
                      label: Text("notAvailable".tr()),
                      onSelected: (bool value) {
                        setState(() {
                          isAvailable = "Not Available";
                          filterResult(type: "Not Available");
                        });
                      },
                      selected: isAvailable == "Not Available",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: isAvailable == "Not Available"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                  ],
                ), // End of filter chips Wrap
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
                  List<Widget> driverWidgets = [];
                  List<DriverModel> currentList =
                      isFilter ? filterDriver : drivers;

                  for (var driver in currentList) {
                    bool matchesSearch = searchValue == "" ||
                        driver.name
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        driver.phone
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());

                    if (matchesSearch) {
                      bool isDriverAvailable = driver.available == 1;
                      Widget driverContent = ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          tileColor: Colors.white,
                          title: Text(driver.name,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                driver.phone,
                              ),
                              isDriverAvailable
                                  ? Chip(
                                      backgroundColor: Colors.green,
                                      label: Text(
                                        "available".tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      avatar: const Icon(
                                        Ionicons.checkmark_circle,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Chip(
                                      backgroundColor: Colors.red,
                                      label: Text(
                                        "notAvailable".tr(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      avatar: const Icon(
                                        Ionicons.close_circle,
                                        color: Colors.white,
                                      ),
                                    )
                            ],
                          ),
                          minLeadingWidth: 0,
                          leading: const Icon(Ionicons.bicycle),
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
                                          Ionicons.call,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Text("callDriver".tr())),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 1,
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
                                    value: 2,
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
                                    value: 3,
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
                                            child: Text("deleteDriver".tr())),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              onSelected: (value) async {
                                switch (value) {
                                  case 0:
                                    js.context.callMethod(
                                        'open', ['tel:${driver.phone}']);
                                    break;
                                  case 1:
                                    Clipboard.setData(
                                            ClipboardData(text: driver.phone))
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
                                  case 2:
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
                                                                  "${driver.id}",
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
                                  case 3:
                                    AppWidgets().MyDialog(
                                      context: context,
                                      background: Colors.blue,
                                      title: "delete".tr(),
                                      subtitle: "deleteDriverDescription".tr(),
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
                                              .deleteDriver(
                                                  driverId: "${driver.id}")
                                              .then((value) async {
                                            Get.back();
                                            if (value['type'] == "success") {
                                              setState(() {
                                                getAllDriver();
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

                      driverWidgets.add(
                        SizedBox(
                          width: columnWidth > 0 ? columnWidth : null,
                          child: Padding(
                            // This was the BsCol padding
                            padding: const EdgeInsets.all(5.0),
                            child: driverContent,
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
                    children: driverWidgets,
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var result = await Get.to(() => const AddDriverPage());
          if (result != null) {
            setState(() {
              getAllDriver();
            });
          }
        },
        label: Text("addDriver".tr()),
        icon: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
