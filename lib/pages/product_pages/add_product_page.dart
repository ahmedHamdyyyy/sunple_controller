import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as Carousel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
// ignore: avoid_web_libraries_in_flutter
import 'package:image_picker_web/image_picker_web.dart';
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/category_model.dart';
import 'package:controlapp/models/product_model.dart';
import 'package:controlapp/utils/app_const.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  bool isLoading = true;
  String productTitleValue = "";
  String productPriceValue = "";
  String productUnitValue = "";
  String productUnitSizeValue = "";
  String productDescriptionValue = "";
  bool showToUser = true;
  CategoryModel? productCategory;
  final _carouselcontroller = Carousel.CarouselSliderController();
  late List<CategoryModel> categories;
  List<Map<String, dynamic>> _pickedproductimages = [];
  int _currentIndex = 0;

  startWebFilePicker() async {
    List<Uint8List>? imagelist = await ImagePickerWeb.getMultiImagesAsBytes();
    if (imagelist != null && imagelist.isNotEmpty) {
      for (var imageBytes in imagelist) {
        String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        _pickedproductimages.add({
          'bytes': imageBytes,
          'name': fileName,
        });
      }
      setState(() {});
    }
  }

  Future<bool> uploadProduct() async {
    try {
      var uri = Uri.parse('${AppConst.url}/api.php');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['action'] = 'addProduct';
      request.fields['title'] = productTitleValue;
      request.fields['description'] = productDescriptionValue;
      request.fields['price'] = productPriceValue;
      request.fields['unit'] = productUnitValue;
      request.fields['unitSize'] = productUnitSizeValue;
      request.fields['categoryId'] = productCategory!.id.toString();
      request.fields['showToUser'] = showToUser ? '1' : '0';

      // Add image files
      for (var i = 0; i < _pickedproductimages.length; i++) {
        var imageData = _pickedproductimages[i];
        var multipartFile = http.MultipartFile.fromBytes(
          'images[]',
          imageData['bytes'],
          filename: imageData['name'],
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      return jsonResponse['type'] == 'success';
    } catch (e) {
      print('Error uploading product: $e');
      return false;
    }
  }

  getCategories() async {
    await AppData().getAllCategories().then((value) {
      setState(() {
        categories = value;
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "addProduct".tr(),
          style: const TextStyle(
              color: AppThemes.lightGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
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
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "design".tr(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: _pickedproductimages.isNotEmpty
                                      ? SizedBox(
                                          width: 140,
                                          height: 85,
                                          child: Stack(
                                            children: [
                                              Carousel.CarouselSlider(
                                                carouselController:
                                                    _carouselcontroller,
                                                options:
                                                    Carousel.CarouselOptions(
                                                  height: 85.0,
                                                  enableInfiniteScroll: false,
                                                  reverse: true,
                                                  onPageChanged:
                                                      (index, reason) {
                                                    _currentIndex = index;
                                                    setState(() {});
                                                  },
                                                ),
                                                items: [
                                                  for (var item
                                                      in _pickedproductimages)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      child: Image.memory(
                                                          item['bytes'],
                                                          width: 140,
                                                          height: 85,
                                                          fit: BoxFit.cover),
                                                    )
                                                ],
                                              ),
                                              (_pickedproductimages.length > 1)
                                                  ? SizedBox(
                                                      height: 85,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .arrow_back,
                                                                  size: 20,
                                                                  color: Colors.white,
                                                                  shadows: [
                                                                    Shadow(
                                                                        color: Colors
                                                                            .black,
                                                                        blurRadius:
                                                                            5)
                                                                  ]),
                                                              onPressed: () {
                                                                _carouselcontroller
                                                                    .previousPage();
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_forward,
                                                                size: 20,
                                                                color: Colors
                                                                    .white,
                                                                shadows: [
                                                                  Shadow(
                                                                      color: Colors
                                                                          .black,
                                                                      blurRadius:
                                                                          5)
                                                                ],
                                                              ),
                                                              onPressed: () {
                                                                _carouselcontroller
                                                                    .nextPage();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          color: Colors.grey,
                                          width: 140,
                                          height: 85,
                                          child: IconButton(
                                            icon: const Icon(Icons.add_a_photo,
                                                size: 48, color: Colors.white),
                                            onPressed: () {
                                              startWebFilePicker();
                                            },
                                          ),
                                        ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: ButtonBar(
                                    alignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            startWebFilePicker();
                                          },
                                          icon: const Icon(
                                            Icons.add_to_photos_outlined,
                                            size: 16,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            if (_pickedproductimages
                                                    .isNotEmpty &&
                                                _currentIndex <
                                                    _pickedproductimages
                                                        .length) {
                                              _pickedproductimages
                                                  .removeAt(_currentIndex);
                                              if (_currentIndex >=
                                                      _pickedproductimages
                                                          .length &&
                                                  _pickedproductimages
                                                      .isNotEmpty) {
                                                _currentIndex =
                                                    _pickedproductimages
                                                            .length -
                                                        1;
                                              }
                                              setState(() {});
                                            }
                                          },
                                          icon: const Icon(
                                            Icons
                                                .remove_circle_outline_outlined,
                                            size: 16,
                                          )),
                                    ],
                                  ),
                                ),
                                Text(
                                  productTitleValue,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$productPriceValue ${AppConst.appCurrency}",
                                  maxLines: 1,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "$productUnitSizeValue $productUnitValue",
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  label: Text("add".tr()),
                                  icon: const Icon(Ionicons.bag_add_outline),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                color: Colors.white),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  child: _pickedproductimages.isNotEmpty
                                      ? Image.memory(
                                          _pickedproductimages.first['bytes'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.grey,
                                          width: 60,
                                          height: 60,
                                          child: const Icon(
                                            Icons.image,
                                            size: 24,
                                            color: Colors.white,
                                          )),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productTitleValue,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "$productPriceValue ${AppConst.appCurrency}",
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "$productUnitSizeValue $productUnitValue",
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Ionicons.bag_add,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "information".tr(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          FormField(
                            builder: (FormFieldState state) {
                              return InputDecorator(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: "productCategory".tr(),
                                    filled: true),
                                isEmpty: productCategory == null,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    value: productCategory,
                                    isDense: true,
                                    onChanged: (newValue) {
                                      setState(() {
                                        productCategory =
                                            newValue as CategoryModel;
                                        state.didChange(newValue);
                                      });
                                    },
                                    items: categories
                                        .map((CategoryModel category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              child: CachedNetworkImage(
                                                imageUrl: category.image,
                                                fit: BoxFit.cover,
                                                width: 40,
                                                height: 40,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(category.title),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "productTitle".tr(),
                              filled: true,
                            ),
                            onChanged: (v) {
                              setState(() {
                                productTitleValue = v;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "productPrice".tr(),
                              filled: true,
                            ),
                            onChanged: (v) {
                              setState(() {
                                productPriceValue = v;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "productDescription".tr(),
                              filled: true,
                            ),
                            minLines: 5,
                            maxLines: 7,
                            onChanged: (v) {
                              setState(() {
                                productDescriptionValue = v;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "productUnit".tr(),
                              filled: true,
                            ),
                            onChanged: (v) {
                              setState(() {
                                productUnitValue = v;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "productUnitSize".tr(),
                              filled: true,
                            ),
                            onChanged: (v) {
                              setState(() {
                                productUnitSizeValue = v;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          CheckboxListTile(
                            tileColor: const Color(0xffeaecf5),
                            title: Text("showToUsers".tr()),
                            value: showToUser,
                            onChanged: (bool? value) {
                              setState(() {
                                showToUser = !showToUser;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (productTitleValue.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("يرجى إدخال اسم المنتج")),
                                );
                                return;
                              }
                              if (productPriceValue.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("يرجى إدخال سعر المنتج")),
                                );
                                return;
                              }
                              if (productCategory == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("يرجى اختيار فئة المنتج")),
                                );
                                return;
                              }
                              if (_pickedproductimages.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("يرجى إضافة صورة للمنتج")),
                                );
                                return;
                              }

                              AppWidgets().MyDialog(
                                  context: context,
                                  title: "loading".tr(),
                                  background: Colors.blue,
                                  asset: const CircularProgressIndicator(
                                      color: Colors.white));

                              bool success = await uploadProduct();
                              Get.back(); // Close loading dialog

                              if (success) {
                                AppWidgets().MyDialog(
                                    context: context,
                                    asset: const Icon(
                                      Ionicons.checkmark_circle,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    background:
                                        Theme.of(context).colorScheme.primary,
                                    title: "productCreated".tr(),
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
                                    title: "productNotCreated".tr(),
                                    confirm: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        child: Text("back".tr())));
                              }
                            },
                            child: Text("addProduct".tr()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
    );
  }
}
