import 'package:oil_app/Helper/wish_helper.dart';
import 'package:flutter/material.dart';

class WishListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize:  Size.fromHeight(size.height *0.115),
          child: WishHelper().wishAppBar(context),
        ),
      body: Container(
        child: Column(
          children: [
            WishHelper().wishlistItems(context),
          ],
        ),
      ),
    );
  }
}
