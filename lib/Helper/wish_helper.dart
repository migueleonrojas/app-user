import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/wish_model.dart';
import 'package:oilapp/Screens/cart_screen.dart';
import 'package:oilapp/Screens/products/product_search.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/counter/cart_item_counter.dart';
import 'package:oilapp/service/cart_service.dart';
import 'package:oilapp/service/wishlist_service.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class WishHelper {
  Widget wishAppBar(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return AppBar(

      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            "Favoritos",
            style: TextStyle(
              fontSize: size.height * 0.024,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              fontFamily: "Brand-Regular",
              color: Colors.black
            ),
          ),
          SizedBox(width: size.width * 0.01),
          AutoSizeText(
            "(",
            style: TextStyle(
              fontSize: size.height * 0.024,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(AutoParts.collectionUser)
                .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                .collection('wishLists')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return AutoSizeText('');
              }
              return AutoSizeText(
                snapshot.data!.docs.length.toString(),
                style: TextStyle(
                  fontSize: size.height * 0.024,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              );
            },
          ),
          AutoSizeText(
            ")",
            style: TextStyle(
              fontSize: size.height * 0.024,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.black,
              ),
              onPressed: () {
                Route route = MaterialPageRoute(builder: (_) => CartScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
            Positioned(
              top: size.height * 0.002,
              left: size.width * 0.008,
              child: Stack(
                children: [
                  Container(
                    height: size.height * 0.024,
                    width: size.width *0.053,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.height * 0.24),
                        color: Colors.red,
                        border: Border.all(color: Colors.orangeAccent)),
                  ),
                  ((AutoParts.sharedPreferences!
                                  .getStringList(AutoParts.userCartList)!
                                  .length -
                              1) <
                          10)
                      ? Positioned(
                          top: size.height * 0.0007 /* 2 */,
                          bottom: size.height * 0.0014,
                          left: size.width * 0.016/* 6 */,
                          child: Consumer<CartItemCounter>(
                            builder: (context, counter, _) {
                              return AutoSizeText(
                                (AutoParts.sharedPreferences!
                                            .getStringList(
                                                AutoParts.userCartList)!
                                            .length -
                                        1)
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        )
                      : Positioned(
                          top: size.height * 0.002,
                          bottom: size.height * 0.002,
                          left: size.width * 0.008,
                          child: Consumer<CartItemCounter>(
                            builder: (context, counter, _) {
                              return AutoSizeText(
                                (AutoParts.sharedPreferences!
                                            .getStringList(
                                                AutoParts.userCartList)!
                                            .length -
                                        1)
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.height * 0.016,
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.search_outlined,
          ),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (_) => ProductSearch());
            Navigator.push(context, route);
          },
        ),
      ],
    );
  }

  Widget wishlistItems(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    int quantity = 1;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(AutoParts.collectionUser)
          .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
          .collection('wishLists')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        return (snapshot.data!.docs.length == 0)
            ? const EmptyCardMessage(
                listTitle: "La lista de favoritos esta vacia",
                message: "Empieza a añadir artículos a tu lista de favoritos",
              )
            : Expanded(
              child: SingleChildScrollView(
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        WishModel wishModel = WishModel.fromJson(
                          (snapshot.data!.docs[index] as dynamic).data(),
                        );
                        return Stack(
                          children: [
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: size.height * 0.021/* 15 */,
                                  bottom: size.height * 0.021,
                                  left: size.width * 0.02/* 10 */,
                                  right: size.width * 0.02/* 10 */,
                                ),
                                child: ListTile(
                                  leading: Image.network(
                                    wishModel.pImage!,
                                  ),
                                  title: Column(
                                    children: [
                                      AutoSizeText(
                                        wishModel.pName!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: size.height * 0.021,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.008),
                                      Row(
                                        children: [
                                          Icon(Icons.branding_watermark_outlined),
                                          SizedBox(width: size.width *  0.01),
                                          Flexible(
                                            child: AutoSizeText(
                                              wishModel.pBrand!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: size.height * 0.021,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(
                                        top: size.height * 0.014, bottom: size.width *0.03),
                                    child: AutoSizeText(
                                      '\$${wishModel.newPrice}',
                                      style: TextStyle(
                                        fontSize: size.height * 0.020,
                                        color: Colors.deepOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.deepOrangeAccent,
                                ),
                                onPressed: () {
                                  WishListService().deleteWish(
                                    wishModel.productId!,
                                    // context,
                                  );
                                  Fluttertoast.showToast(
                                      msg: "Artículo eliminado con éxito.");
                                },
                              ),
                            ),
                            Positioned(
                              bottom: size.height * 0.002/* 2 */,
                              right:  size.width * 0.01/* 2 */,
                              child: Container(
                                height: size.height * 0.042,
                                width: size.width * 0.22,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrangeAccent,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection(AutoParts.collectionUser)
                                        .doc(AutoParts.sharedPreferences!
                                            .getString(AutoParts.userUID))
                                        .collection('carts')
                                        .where("productId",
                                            isEqualTo: wishModel.productId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return Container();
                                      return IconButton(
                                        icon: (snapshot.data!.docs.length == 1)
                                            ? Icon(
                                                Icons.shopping_bag,
                                                size: size.height * 0.024,
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.add_shopping_cart_outlined,
                                                size: size.height * 0.024,
                                                color: Colors.white,
                                              ),
                                        onPressed: () {
                                          CartService().checkItemInCart(
                                            wishModel.productId!,
                                            wishModel.pName!,
                                            wishModel.pImage!,
                                            wishModel.newPrice!,
                                            wishModel.newPrice =
                                                wishModel.newPrice! * quantity,
                                            quantity,
                                            context,
                                          );
                                        },
                                      );
                                    }),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ),
            );
      },
    );
  }
}
