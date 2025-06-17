import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/category_model.dart';
import 'package:controlapp/pages/category_pages/add_category_page.dart';
import 'package:controlapp/pages/category_pages/edit_category_page.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'dart:convert';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  bool isLoading = true;
  late List<CategoryModel> categories;
  late List<CategoryModel> filterCategory;

  getAllCategory() async {
    setState(() {
      isLoading = true;
      isFilter = false;
      showToUser = "All";
    });
    categories = [];
    await AppData().getAllCategories().then((value) {
      categories = value;
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
        filterCategory = [];
        filterCategory =
            categories.where((element) => element.showToUser == 1).toList();

        isFilter = true;
      });
    } else if (type == "Invisible") {
      setState(() {
        filterCategory = [];
        filterCategory =
            categories.where((element) => element.showToUser == 0).toList();

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
    getAllCategory();
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
  Widget _buildImageWidget(String imageValue, {double? width, double? height}) {
    if (_isBase64(imageValue)) {
      // Show base64 image
      try {
        return Image.memory(
          base64Decode(imageValue),
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey,
          child: const Icon(Icons.image, color: Colors.white),
        );
      }
    } else if (imageValue.isNotEmpty) {
      // Show network image
      return CachedNetworkImage(
        imageUrl: imageValue,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: Colors.grey,
          child: const Icon(Icons.image, color: Colors.white),
        ),
      );
    } else {
      // Show placeholder
      return Container(
        width: width,
        height: height,
        color: Colors.grey,
        child: const Icon(Icons.image, color: Colors.white),
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
                            labelText: "searchByTitle".tr(),
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
                  const double spacing = 8.0;
                  int numColumns;

                  // Determine number of columns based on available width
                  // Original BsCol sizes: xs:6 (2 items), sm/md/lg/xl:3 (4 items), xxl:2 (6 items)
                  if (availableWidth >= 1400) {
                    // approx xxl
                    numColumns = 6;
                  } else if (availableWidth >= 600) {
                    // approx sm and up
                    numColumns = 4;
                  } else {
                    // approx xs
                    numColumns = 2;
                  }

                  // Calculate item width
                  final double itemWidth =
                      (availableWidth - (numColumns - 1) * spacing) /
                          numColumns;

                  List<Widget> categoryItems = [];
                  List<CategoryModel> currentList =
                      isFilter ? filterCategory : categories;

                  for (var category in currentList) {
                    bool matchesSearch = searchValue == "" ||
                        category.title
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());

                    if (matchesSearch) {
                      categoryItems.add(
                        SizedBox(
                          width: itemWidth > 0
                              ? itemWidth
                              : null, // Ensure positive width
                          child: Padding(
                            // This was the BsCol padding
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: category.showToUser == 1
                                        ? Colors.white
                                        : Colors.red.shade50,
                                  ),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.white),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 2,
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    child: _buildImageWidget(
                                                        category.image,
                                                        width: 140,
                                                        height: 85),
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: Colors.black
                                                            .withOpacity(0.5)),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      category.title,
                                                      maxLines: 2,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const Divider(),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: [
                                          ActionChip(
                                            onPressed: () async {
                                              var result = await Get.to(() =>
                                                  EditCategoryPage(
                                                      category: category));
                                              if (result != null) {
                                                setState(() {
                                                  getAllCategory();
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
                                            avatar: Icon(
                                                Ionicons.create_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                          ),
                                          ActionChip(
                                            onPressed: () {
                                              AppWidgets().MyDialog(
                                                context: context,
                                                background: Colors.blue,
                                                title: "delete".tr(),
                                                subtitle:
                                                    "deleteCategoryDescription"
                                                        .tr(),
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
                                                                color: Colors
                                                                    .white));
                                                    await AppData()
                                                        .deleteCategory(
                                                            categoryId:
                                                                "${category.id}")
                                                        .then((value) async {
                                                      Get.back();
                                                      if (value['type'] ==
                                                          "success") {
                                                        setState(() {
                                                          getAllCategory();
                                                        });
                                                      } else {
                                                        AppWidgets().MyDialog(
                                                            context: context,
                                                            title: "error".tr(),
                                                            background:
                                                                Colors.red,
                                                            asset: const Icon(
                                                              Ionicons
                                                                  .close_circle,
                                                              size: 80,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            confirm: TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                child: Text("ok"
                                                                    .tr())));
                                                      }
                                                    });
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
                                                  child: Text("yes".tr()),
                                                ),
                                                cancel: ElevatedButton(
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
                                                                      .blueGrey)),
                                                  child: Text("no".tr()),
                                                ),
                                              );
                                            },
                                            label: Text(
                                              "delete".tr(),
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                            avatar: const Icon(
                                              Ionicons.close_circle,
                                              color: Colors.red,
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade200,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: categoryItems,
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var result = await Get.to(() => const AddCategoryPage());
          if (result != null) {
            setState(() {
              getAllCategory();
            });
          }
        },
        label: Text("addCategory".tr()),
        icon: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
