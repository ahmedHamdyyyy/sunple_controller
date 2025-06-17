import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/slider_model.dart';
import 'package:controlapp/pages/slider_pages/add_slider_page.dart';
import 'package:controlapp/pages/slider_pages/edit_slider_page.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'package:validators/validators.dart';
import 'dart:convert';

class SliderListPage extends StatefulWidget {
  const SliderListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SliderListPageState createState() => _SliderListPageState();
}

class _SliderListPageState extends State<SliderListPage> {
  bool isLoading = true;
  late List<SliderModel> sliders;
  late List<SliderModel> filterSlider;

  getAllSlider() async {
    setState(() {
      isLoading = true;
      isFilter = false;
      showToUser = "All";
    });
    sliders = [];
    await AppData().getAllSliders().then((value) {
      sliders = value;
      setState(() {
        isLoading = false;
      });
    });
  }

  bool isFilter = false;
  String searchValue = "";

  filterResult({required String type}) {
    if (type == "Visible") {
      setState(() {
        filterSlider = [];
        filterSlider =
            sliders.where((element) => element.showToUser == 1).toList();

        isFilter = true;
      });
    } else if (type == "Invisible") {
      setState(() {
        filterSlider = [];
        filterSlider =
            sliders.where((element) => element.showToUser == 0).toList();

        isFilter = true;
      });
    } else {
      setState(() {
        isFilter = false;
      });
    }
  }

  String showToUser = "All";

  @override
  void initState() {
    getAllSlider();
    super.initState();
  }

  // Function to check if image is base64
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Widget to display image properly
  Widget _buildImageWidget(String imageValue) {
    if (_isBase64(imageValue)) {
      // Show base64 image
      try {
        return Image.memory(
          base64Decode(imageValue),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          color: Colors.transparent,
          child: const Center(
            child:
                Icon(Icons.image_not_supported, color: Colors.white, size: 48),
          ),
        );
      }
    } else if (imageValue.isNotEmpty) {
      // Show network image
      return CachedNetworkImage(
        imageUrl: imageValue,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Container(
          color: Colors.transparent,
          child: const Center(
            child:
                Icon(Icons.image_not_supported, color: Colors.white, size: 48),
          ),
        ),
        fit: BoxFit.cover,
      );
    } else {
      // Show placeholder
      return Container(
        color: Colors.transparent,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.white, size: 48),
        ),
      );
    }
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
                  //   crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  //     alignment: WrapAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "sliderSearch".tr(),
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
                          showToUser = "All";
                          filterResult(type: "All");
                        });
                      },
                      selected: showToUser == "All",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: showToUser == "All"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                    FilterChip(
                      label: Text("visible".tr()),
                      onSelected: (bool value) {
                        setState(() {
                          showToUser = "Visible";
                          filterResult(type: "Visible");
                        });
                      },
                      selected: showToUser == "Visible",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: showToUser == "Visible"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                    FilterChip(
                      label: Text("invisible".tr()),
                      onSelected: (bool value) {
                        setState(() {
                          showToUser = "Invisible";
                          filterResult(type: "Invisible");
                        });
                      },
                      selected: showToUser == "Invisible",
                      backgroundColor: AppThemes.lightGreyColor,
                      selectedColor: AppThemes.primaryColor,
                      checkmarkColor: AppThemes.lightGreyColor,
                      labelStyle: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(
                              color: showToUser == "Invisible"
                                  ? AppThemes.lightGreyColor
                                  : AppThemes.darkColor),
                    ),
                  ],
                ), // End of filter chips Wrap
                LayoutBuilder(builder: (context, constraints) {
                  final double availableWidth = constraints.maxWidth;
                  int numColumns;

                  // Determine number of columns based on available width
                  // Original BsCol sizes: xs/sm:12 (1 item), md/lg/xl:6 (2 items), xxl:4 (3 items)
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
                  List<Widget> sliderWidgets = [];
                  List<SliderModel> currentList =
                      isFilter ? filterSlider : sliders;

                  for (var slider in currentList) {
                    bool matchesSearch = searchValue == "" ||
                        slider.title
                            .toLowerCase()
                            .contains(searchValue.toLowerCase()) ||
                        slider.subtitle
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());

                    if (matchesSearch) {
                      Widget sliderContent = Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: slider.showToUser == 1
                                  ? Colors.white
                                  : Colors.red.shade50,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: 2,
                                  child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: !isHexColor(slider.color!)
                                            ? const Color(0xffffffff)
                                            : Color(int.parse(
                                                "0xff${slider.color!}")),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          _buildImageWidget(slider.image!),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.3)),
                                          ),
                                          Center(
                                            child: ListTile(
                                              title: Text(
                                                slider.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              subtitle: Text(
                                                slider.subtitle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                                const Divider(),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: [
                                    ActionChip(
                                      onPressed: () async {
                                        var result = await Get.to(() =>
                                            EditSliderPage(slider: slider));
                                        if (result != null) {
                                          setState(() {
                                            getAllSlider();
                                          });
                                        }
                                      },
                                      label: Text(
                                        "edit".tr(),
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                      avatar: Icon(Ionicons.create_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                    ActionChip(
                                      onPressed: () {
                                        AppWidgets().MyDialog(
                                          context: context,
                                          background: Colors.blue,
                                          title: "delete".tr(),
                                          subtitle: "deleteSlider".tr(),
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
                                                  .deleteSlider(
                                                      sliderId: "${slider.id}")
                                                  .then((value) async {
                                                Get.back();
                                                if (value['type'] ==
                                                    "success") {
                                                  setState(() {
                                                    getAllSlider();
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
                                                          child:
                                                              Text("ok".tr())));
                                                }
                                              });
                                            },
                                            style: Get.theme.elevatedButtonTheme
                                                .style!
                                                .copyWith(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red)),
                                            child: Text("yes".tr()),
                                          ),
                                          cancel: ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            style: Get.theme.elevatedButtonTheme
                                                .style!
                                                .copyWith(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .blueGrey)),
                                            child: Text("no".tr()),
                                          ),
                                        );
                                      },
                                      label: Text(
                                        "delete".tr(),
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      avatar: const Icon(
                                        Ionicons.close_circle,
                                        color: Colors.red,
                                      ),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                      sliderWidgets.add(
                        SizedBox(
                          width: columnWidth > 0 ? columnWidth : null,
                          child: Padding(
                            // This was the BsCol padding
                            padding: const EdgeInsets.all(5.0),
                            child: sliderContent,
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
                    children: sliderWidgets,
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var result = await Get.to(() => const AddSliderPage());
          if (result != null) {
            setState(() {
              getAllSlider();
            });
          }
        },
        label: Text("addSlider".tr()),
        icon: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
