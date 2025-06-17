import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/category_model.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'dart:convert';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:flutter/services.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  String categoryTitleValue = "";
  String categoryImageValue = "";
  bool showToUser = true;

  // Add image picker functionality
  Uint8List? _pickedImage;

  // Function to check if image is base64
  bool _isBase64(String str) {
    try {
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Function to pick new image
  startWebFilePicker() async {
    Uint8List? imageBytes = await ImagePickerWeb.getImageAsBytes();
    if (imageBytes != null) {
      setState(() {
        _pickedImage = imageBytes;
        categoryImageValue = base64Encode(imageBytes);
      });
    }
  }

  // Widget to display image properly
  Widget _buildImageWidget(String imageValue, {double? width, double? height}) {
    if (_pickedImage != null) {
      // Show newly picked image
      return Image.memory(
        _pickedImage!,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (_isBase64(imageValue)) {
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
      // Show placeholder with upload button
      return Container(
        width: width,
        height: height,
        color: Colors.grey,
        child: IconButton(
          icon: const Icon(Icons.add_a_photo, size: 48, color: Colors.white),
          onPressed: startWebFilePicker,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "addCategory".tr(),
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
            // Use a threshold to switch between single column and two columns
            bool useTwoColumns = constraints.maxWidth > 600;

            Widget designSectionWidget = Padding(
              padding: const EdgeInsets.all(20.0), // Original BsCol padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "design".tr(),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    width: 140,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 2,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildImageWidget(categoryImageValue),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3)),
                                    ),
                                    Center(
                                      child: Text(
                                        categoryTitleValue,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                      ),
                                    ),
                                    if (categoryImageValue.isNotEmpty)
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.white, size: 16),
                                            onPressed: startWebFilePicker,
                                            constraints: const BoxConstraints(
                                                minWidth: 30, minHeight: 30),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );

            Widget informationSectionWidget = Padding(
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
                      labelText: "categoryTitle".tr(),
                      filled: true,
                    ),
                    onChanged: (v) {
                      setState(() {
                        categoryTitleValue = v;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "categoryImage".tr(),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: startWebFilePicker,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        categoryImageValue = v;
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
                      // Validation
                      if (categoryTitleValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("يرجى إدخال اسم الفئة")),
                        );
                        return;
                      }
                      if (categoryImageValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("يرجى إضافة صورة للفئة")),
                        );
                        return;
                      }

                      AppWidgets().MyDialog(
                          context: context,
                          title: "loading".tr(),
                          background: Colors.blue,
                          asset: const CircularProgressIndicator(
                              color: Colors.white));
                      await AppData()
                          .addCategory(
                              category: CategoryModel(
                                  title: categoryTitleValue,
                                  image: categoryImageValue,
                                  showToUser: showToUser ? 1 : 0))
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
                              title: "categoryCreated".tr(),
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
                              title: "categoryNotCreated".tr(),
                              confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("back".tr())));
                        }
                      });
                    },
                    child: Text("addCategory".tr()),
                  ),
                ],
              ),
            );

            if (useTwoColumns) {
              return Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Mimics BsRow alignment: Alignment.center
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: designSectionWidget),
                  Flexible(child: informationSectionWidget),
                ],
              );
            } else {
              return Column(
                children: [
                  designSectionWidget,
                  informationSectionWidget,
                ],
              );
            }
          }),
        ],
      ),
    );
  }
}
