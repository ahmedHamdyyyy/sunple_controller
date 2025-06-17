import 'package:controlapp/pages/order_pages/order_list_page.dart';
import 'package:controlapp/utils/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class UserOrderList extends StatefulWidget {
  final String userUid;
  const UserOrderList({Key? key, required this.userUid}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _UserOrderListState createState() => _UserOrderListState();
}

class _UserOrderListState extends State<UserOrderList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "userOrders".tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppThemes.lightGreyColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: OrderListPage(
        userUid: widget.userUid,
      ),
    );
  }
}
