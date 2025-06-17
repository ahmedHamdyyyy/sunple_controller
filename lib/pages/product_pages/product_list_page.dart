import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as Carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/product_model.dart';
import 'package:controlapp/pages/product_pages/add_product_page.dart';
import 'package:controlapp/pages/product_pages/edit_product_page.dart';
import 'package:controlapp/utils/app_const.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'dart:convert';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  bool isLoading = true;
  late List<ProductModel> products;
  late List<ProductModel> filterProduct;
  final _carouselcontroller = Carousel.CarouselSliderController();

  // Function to get list of image paths from comma-separated string
  List<String> _getImagePaths(String imageValue) {
    if (imageValue.isEmpty) return [];
    return imageValue
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Function to construct proper image URL
  String _constructImageUrl(String imagePath) {
    // Remove any leading slash
    imagePath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;

    // If path already contains 'uploads/', don't add it again
    if (imagePath.startsWith('uploads/')) {
      return "${AppConst.url}/$imagePath";
    } else {
      return "${AppConst.url}/uploads/$imagePath";
    }
  }

  // Widget to display image properly
  Widget _buildImageWidget(String imageValue, {double? width, double? height}) {
    List<String> imagePaths = _getImagePaths(imageValue);

    if (imagePaths.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey,
        child: const Icon(Icons.image, color: Colors.white),
      );
    }

    if (imagePaths.length == 1) {
      String fullUrl = _constructImageUrl(imagePaths.first);
      print("Single image URL: $fullUrl");

      return CachedNetworkImage(
        imageUrl: fullUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          print("Error loading image: $url - $error");
          return Container(
            width: width,
            height: height,
            color: Colors.grey,
            child: const Icon(Icons.image, color: Colors.white),
          );
        },
      );
    }

    // Multiple images - use carousel
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Carousel.CarouselSlider(
            carouselController: _carouselcontroller,
            options: Carousel.CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: imagePaths.map((image) {
              String fullUrl = _constructImageUrl(image);
              print("Carousel image URL: $fullUrl");

              return CachedNetworkImage(
                imageUrl: fullUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) {
                  print("Error loading carousel image: $url - $error");
                  return Container(
                    width: width,
                    height: height,
                    color: Colors.grey,
                    child: const Icon(Icons.image, color: Colors.white),
                  );
                },
              );
            }).toList(),
          ),
          if (imagePaths.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black26,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imagePaths.asMap().entries.map((entry) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  getAllProduct() async {
    setState(() {
      isLoading = true;
      isFilter = false;
      showToUser = "All";
    });
    products = [];
    await AppData().getAllProducts().then((value) {
      products = value;
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
        filterProduct = [];
        filterProduct =
            products.where((element) => element.showToUser == 1).toList();

        isFilter = true;
      });
    } else if (type == "Invisible") {
      setState(() {
        filterProduct = [];
        filterProduct =
            products.where((element) => element.showToUser == 0).toList();

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
    getAllProduct();
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
                            labelText: "productSearch".tr(),
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
                ),
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: List.generate(
                        isFilter ? filterProduct.length : products.length,
                        (index) {
                      ProductModel product =
                          isFilter ? filterProduct[index] : products[index];
                      if (searchValue == "") {
                        return Container(
                          padding: const EdgeInsets.all(5.0),
                          width: MediaQuery.of(context).size.width >= 1200
                              ? MediaQuery.of(context).size.width / 6
                              : MediaQuery.of(context).size.width >= 992
                                  ? MediaQuery.of(context).size.width / 4
                                  : MediaQuery.of(context).size.width / 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: product.showToUser == 1
                                      ? Colors.white
                                      : Colors.red.shade50,
                                ),
                                clipBehavior: Clip.antiAlias,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: _buildImageWidget(product.image,
                                          width: 140, height: 85),
                                    ),
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${product.price} ${AppConst.appCurrency}",
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${product.unitSize} ${product.unit}",
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        ActionChip(
                                          onPressed: () async {
                                            var result = await Get.to(() =>
                                                EditProductPage(
                                                    product: product));
                                            if (result != null) {
                                              setState(() {
                                                getAllProduct();
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
                                              subtitle: "deleteProduct".tr(),
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
                                                      .deleteProduct(
                                                          productId:
                                                              "${product.id}")
                                                      .then((value) async {
                                                    Get.back();
                                                    if (value['type'] ==
                                                        "success") {
                                                      setState(() {
                                                        getAllProduct();
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
                                                            color: Colors.white,
                                                          ),
                                                          confirm: TextButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: Text(
                                                                  "ok".tr())));
                                                    }
                                                  });
                                                },
                                                style: Get.theme
                                                    .elevatedButtonTheme.style!
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
                                                style: Get.theme
                                                    .elevatedButtonTheme.style!
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
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (searchValue != "" &&
                          (product.title
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              product.price
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              product.unit
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()) ||
                              product.unitSize
                                  .toString()
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase()))) {
                        return Container(
                          padding: const EdgeInsets.all(5.0),
                          width: MediaQuery.of(context).size.width >= 1200
                              ? MediaQuery.of(context).size.width / 6
                              : MediaQuery.of(context).size.width >= 992
                                  ? MediaQuery.of(context).size.width / 4
                                  : MediaQuery.of(context).size.width / 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: product.showToUser == 1
                                      ? Colors.white
                                      : Colors.red.shade50,
                                ),
                                clipBehavior: Clip.antiAlias,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      child: _buildImageWidget(product.image,
                                          width: 140, height: 85),
                                    ),
                                    Text(
                                      product.title,
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${product.price} ${AppConst.appCurrency}",
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${product.unitSize} ${product.unit}",
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        ActionChip(
                                          onPressed: () async {
                                            var result = await Get.to(() =>
                                                EditProductPage(
                                                    product: product));
                                            if (result != null) {
                                              setState(() {
                                                getAllProduct();
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
                                              subtitle: "deleteProduct".tr(),
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
                                                      .deleteProduct(
                                                          productId:
                                                              "${product.id}")
                                                      .then((value) async {
                                                    Get.back();
                                                    if (value['type'] ==
                                                        "success") {
                                                      setState(() {
                                                        getAllProduct();
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
                                                            color: Colors.white,
                                                          ),
                                                          confirm: TextButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: Text(
                                                                  "ok".tr())));
                                                    }
                                                  });
                                                },
                                                style: Get.theme
                                                    .elevatedButtonTheme.style!
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
                                                style: Get.theme
                                                    .elevatedButtonTheme.style!
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
                                          backgroundColor: Colors.grey.shade200,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                    })),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var result = await Get.to(() => const AddProductPage());
          if (result != null) {
            setState(() {
              getAllProduct();
            });
          }
        },
        label: Text("addProduct".tr()),
        icon: const Icon(Ionicons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
