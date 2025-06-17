import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/driver_model.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';

class AddDriverPage extends StatefulWidget {
  const AddDriverPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddDriverPageState createState() => _AddDriverPageState();
}

class _AddDriverPageState extends State<AddDriverPage> {
  String driverNameValue = "";
  String driverPhoneValue = "";
  String driverPasswordValue = "";
  PhoneNumber number = PhoneNumber(isoCode: 'DZ');

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "addDriver".tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppThemes.lightGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(16.0),
        shrinkWrap: true,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            Widget formContent = Padding(
              padding: const EdgeInsets.all(20.0), // Original BsCol padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "information".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "driverName".tr(),
                      filled: true,
                    ),
                    onChanged: (v) {
                      setState(() {
                        driverNameValue = v;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        driverPhoneValue = "${number.phoneNumber}";
                      });
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                      useEmoji: true,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: number,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputDecoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "driverPhone".tr(),
                      filled: true,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      AppWidgets().MyDialog(
                          context: context,
                          title: "loading".tr(),
                          background: Colors.blue,
                          asset: const CircularProgressIndicator(
                              color: Colors.white));
                      await AppData()
                          .addDriver(
                              driver: DriverModel(
                                  name: driverNameValue,
                                  phone: driverPhoneValue,
                                  available: 1))
                          .then((value) {
                        Get.back();
                        if (value['type'] == "success") {
                          AppWidgets().MyDialog(
                              context: context,
                              asset: const Icon(
                                Ionicons.checkmark_circle,
                                size: 80,
                                color: Colors.white,
                              ),
                              background: Theme.of(context).colorScheme.primary,
                              title: "driverCreated".tr(),
                              confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.back(result: true);
                                  },
                                  child: Text("back".tr())));
                        } else {
                          AppWidgets().MyDialog(
                              context: context,
                              asset: const Icon(
                                Ionicons.close_circle,
                                size: 80,
                                color: Colors.white,
                              ),
                              background: const Color(0xffDF2E2E),
                              title: "driverNotCreated".tr(),
                              confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("back".tr())));
                        }
                      });
                    },
                    child: Text("addDriver".tr()),
                  ),
                ],
              ),
            );

            // Mimic BsCol sizes: xs:12, sm:6, md:6, lg:4, xl:4, xxl:3
            // and BsRow alignment: Alignment.center
            if (constraints.maxWidth < 576) {
              // xs screens
              return formContent; // Full width within ListView item
            } else {
              double fraction;
              if (constraints.maxWidth >= 1400) {
                // xxl (col-3)
                fraction = 3.0 / 12.0;
              } else if (constraints.maxWidth >= 1200) {
                // xl (col-4)
                fraction = 4.0 / 12.0;
              } else if (constraints.maxWidth >= 992) {
                // lg (col-4)
                fraction = 4.0 / 12.0;
              } else if (constraints.maxWidth >= 768) {
                // md (col-6)
                fraction = 6.0 / 12.0;
              } else {
                // sm (col-6)
                fraction = 6.0 / 12.0;
              }

              return Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the content
                children: [
                  SizedBox(
                    width: constraints.maxWidth * fraction,
                    child: formContent,
                  ),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}
