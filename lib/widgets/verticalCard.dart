import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Model/product_model.dart';
import 'package:oil_app/Screens/products/product_details.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/service/cart_service.dart';
import 'package:oil_app/service/wishlist_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerticalCard extends StatelessWidget {
  final String? cardTitle;
  final Stream? stream;
  const VerticalCard({
    Key? key,
    this.cardTitle,
    this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int quantity = 1;
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(
              horizontal: size.width * 0.030,
              vertical: size.height * 0.010,
            ),
            child: AutoSizeText(
              cardTitle!,
              style:  TextStyle(
                fontSize: size.height * 0.020,
                fontFamily: "Brand-Bold",
                letterSpacing: 0.5,
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: stream as dynamic,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return AutoSizeText('');
              }
              return Container(
                height: size.height * 0.350,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    ProductModel productModel =
                        ProductModel.fromJson((snapshot.data!.docs[index] as dynamic ).data());
                    return GestureDetector(
                      onTap: () {
                        Route route = MaterialPageRoute(
                          builder: (_) =>
                              ProductDetails(productModel: productModel),
                        );
                        Navigator.push(context, route);
                      },
                      child: Stack(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(size.height * 0.010),
                            ),
                            // margin: EdgeInsets.all(8),
                            child: Container(
                              height: size.height * 0.350,
                              width: size.width * 0.500,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Image.network(
                                    productModel.productImgUrl!,
                                    width: size.width * 0.350,
                                    height: size.height * 0.200,
                                    fit: BoxFit.contain,
                                  ),
                                  Padding(
                                    padding:  EdgeInsets.all(size.height * 0.0050),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          productModel.productName!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: size.height * 0.020,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.005),
                                        (productModel.offervalue! < 1)
                                            ? Padding(
                                                padding:
                                                    EdgeInsets.symmetric(
                                                  vertical: size.height * 0.005,
                                                ),
                                                child: AutoSizeText(
                                                  "\$${productModel.orginalprice}",
                                                  style: TextStyle(
                                                    fontFamily: "Brand-Regular",
                                                    fontSize: size.height * 0.020,
                                                    color:
                                                        Colors.deepOrangeAccent,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AutoSizeText(
                                                    "\$${productModel.newprice}",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "Brand-Regular",
                                                      fontSize: size.height * 0.020,
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          AutoSizeText(
                                                            "\$${productModel.orginalprice}",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Brand-Regular",
                                                              fontSize: size.height * 0.020,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(width: size.width * 0.005),
                                                          AutoSizeText(
                                                            '- ${productModel.offervalue}%',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "Brand-Regular",
                                                              fontSize: size.height * 0.020,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: size.height * 0.050,
                              width: size.width * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    spreadRadius: -2,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(AutoParts.collectionUser)
                                      .doc(AutoParts.sharedPreferences!
                                          .getString(AutoParts.userUID))
                                      .collection('wishLists')
                                      .where("productId",
                                          isEqualTo: productModel.productId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Container();
                                    return Center(
                                      child: IconButton(
                                        icon: (snapshot.data!.docs.length == 1)
                                            ? Icon(
                                                Icons.favorite,
                                                color: Colors.deepOrangeAccent,
                                              )
                                            : Icon(
                                                Icons.favorite_border_rounded,
                                                color: Colors.deepOrangeAccent,
                                              ),
                                        onPressed: () {
                                          WishListService().addWish(
                                            productModel.productId!,
                                            productModel.productName!,
                                            productModel.brandName!,
                                            productModel.productImgUrl!,
                                            productModel.newprice!,
                                          );
                                          Fluttertoast.showToast(
                                            msg:
                                                "Item Added to WishList Successfully.",
                                          );
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            right: 3,
                            child: Container(
                              height: size.height * 0.050,
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(size.width * 0.035),
                                  bottomRight: Radius.circular(size.width * 0.035),
                                ),
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection(AutoParts.collectionUser)
                                      .doc(AutoParts.sharedPreferences!
                                          .getString(AutoParts.userUID))
                                      .collection('carts')
                                      .where("productId",
                                          isEqualTo: productModel.productId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return Container();
                                    return IconButton(
                                      icon: (snapshot.data!.docs.length == 1)
                                          ? Icon(
                                              Icons.shopping_bag,
                                              size: size.height * 0.030,
                                              color: Colors.white,
                                            )
                                          : Icon(
                                              Icons.add_shopping_cart_outlined,
                                              size: size.height * 0.030,
                                              color: Colors.white,
                                            ),
                                      onPressed: () {
                                        (productModel.status == 'Available')
                                            ? CartService().checkItemInCart(
                                                productModel.productId!,
                                                productModel.productName!,
                                                productModel.productImgUrl!,
                                                productModel.newprice!,
                                                productModel.newprice =
                                                    productModel.newprice! *
                                                        quantity,
                                                quantity,
                                                context,
                                              )
                                            : Fluttertoast.showToast(
                                                msg:
                                                    "This Product is now not available",
                                              );
                                      },
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
