import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_color_picker/easy_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide Trans;
import 'package:ionicons/ionicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:controlapp/models/slider_model.dart';
import 'package:controlapp/utils/app_helper.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:controlapp/utils/app_widgets.dart';
import 'package:validators/validators.dart';
import 'dart:convert';
import 'package:image_picker_web/image_picker_web.dart';

class EditSliderPage extends StatefulWidget {
  final SliderModel slider;
  const EditSliderPage({super.key, required this.slider});

  @override
  // ignore: library_private_types_in_public_api
  _EditSliderPageState createState() => _EditSliderPageState();
}

class _EditSliderPageState extends State<EditSliderPage> {
  TextEditingController sliderTitleCont = TextEditingController();
  TextEditingController sliderSubtitleCont = TextEditingController();
  TextEditingController sliderImageCont = TextEditingController();
  TextEditingController sliderColorCont = TextEditingController();

  bool isLoading = true;
  late String sliderTitleValue = widget.slider.title;
  late String sliderSubtitleValue = widget.slider.subtitle;
  late String sliderImageValue = "${widget.slider.image}";
  late String sliderColorValue = "${widget.slider.color}";
  late bool showToUser = widget.slider.showToUser == 1;

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
        sliderImageValue = base64Encode(imageBytes);
        sliderImageCont.text = sliderImageValue;
      });
    }
  }

  // Widget to display image properly
  Widget _buildImageWidget(String imageValue) {
    if (_pickedImage != null) {
      // Show newly picked image
      return Image.memory(
        _pickedImage!,
        fit: BoxFit.cover,
      );
    } else if (_isBase64(imageValue)) {
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
  void initState() {
    sliderTitleCont.text = widget.slider.title;
    sliderSubtitleCont.text = widget.slider.subtitle;
    sliderImageCont.text = "${widget.slider.image}";
    sliderColorCont.text = "${widget.slider.color}";

    isLoading = false;
    super.initState();
  }

  final List<Color> _colors = [
    Colors.white,
    ...Colors.primaries,
    ...Colors.accents
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "editSlider".tr(),
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
            bool useTwoColumns =
                constraints.maxWidth > 600; // Threshold for switching layout

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
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white),
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 2,
                          child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: !isHexColor(sliderColorValue)
                                    ? const Color(0xffffffff)
                                    : Color(int.parse("0xff$sliderColorValue")),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildImageWidget(sliderImageValue),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3)),
                                  ),
                                  Center(
                                    child: ListTile(
                                      title: Text(
                                        sliderTitleValue,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      subtitle: Text(
                                        sliderSubtitleValue,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white, size: 20),
                                        onPressed: startWebFilePicker,
                                        constraints: const BoxConstraints(
                                            minWidth: 40, minHeight: 40),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
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
                    controller: sliderTitleCont,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "sliderTitle".tr(),
                      filled: true,
                    ),
                    onChanged: (v) {
                      setState(() {
                        sliderTitleValue = v;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: sliderSubtitleCont,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "sliderSubtitle".tr(),
                      filled: true,
                    ),
                    onChanged: (v) {
                      setState(() {
                        sliderSubtitleValue = v;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: sliderImageCont,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "sliderImage".tr(),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: startWebFilePicker,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        sliderImageValue = v;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[a-fA-F0-9]+$')),
                    ],
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: "sliderColor".tr(),
                        filled: true,
                        counterText: ''),
                    maxLength: 6,
                    controller: sliderColorCont,
                    onChanged: (v) {
                      setState(() {
                        sliderColorValue = v;
                        if (isHexColor(v) && v.length > 3) {
                          _colors.add(Color(int.parse("0xff$v")));
                        }
                      });
                    },
                  ),
                  EasyColorPicker(
                      selected: !isHexColor(sliderColorValue)
                          ? const Color(0xffffffff)
                          : Color(int.parse("0xff$sliderColorValue")),
                      colors: _colors.toSet().toList(),
                      onChanged: (color) => setState(() {
                            sliderColorValue =
                                color.value.toRadixString(16).substring(2, 8);
                            sliderColorCont.text = sliderColorValue;
                          })),
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
                      if (sliderTitleValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("يرجى إدخال عنوان السلايدر")),
                        );
                        return;
                      }
                      if (sliderSubtitleValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text("يرجى إدخال العنوان الفرعي للسلايدر")),
                        );
                        return;
                      }
                      if (sliderImageValue.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("يرجى إضافة صورة للسلايدر")),
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
                          .editSlider(
                              slider: SliderModel(
                        id: widget.slider.id,
                        title: sliderTitleValue,
                        subtitle: sliderSubtitleValue,
                        color: sliderColorValue,
                        image: sliderImageValue,
                        showToUser: showToUser ? 1 : 0,
                      ))
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
                              title: "sliderUpdated".tr(),
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
                              title: "sliderNotUpdated".tr(),
                              confirm: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text("back".tr())));
                        }
                      });
                    },
                    child: Text("editSlider".tr()),
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
                  // Mimic ColScreen sizes with Flexible
                  Flexible(
                      flex: 4,
                      child: designSectionWidget), // Approx lg:5, xl:4, xxl:3
                  Flexible(
                      flex: 3,
                      child:
                          informationSectionWidget), // Approx lg:4, xl:4, xxl:3
                ],
              );
            } else {
              // Single column layout for smaller screens
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
