import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Model/product_model.dart';
import 'package:oil_app/Screens/cart_screen.dart';
import 'package:oil_app/Screens/products/product_onlydetails.dart';
import 'package:oil_app/config/config.dart';
import 'package:oil_app/service/cart_service.dart';

import 'package:oil_app/widgets/loading_widget.dart';
import 'package:oil_app/widgets/horizontalCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailsHelper {
  ProductDetailsHelper({required this.productModel});
  final ProductModel productModel;

  final _db = FirebaseFirestore.instance.collection('products').limit(15);

  bottomNavigationBar(int quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: BottomAppBar(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(AutoParts.collectionUser)
              .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
              .collection('carts')
              .where('productId', isEqualTo: productModel.productId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Center(
                child: circularProgress(),
              );
            return (snapshot.data!.docs.length == 1)
                ? SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      child: AutoSizeText(
                        "Ir a la carro de compras".toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Brand-Bold",
                          letterSpacing: 1.5,
                          fontSize: 18,
                        ),
                      ),
                      /* color: Colors.blueAccent[200], */
                      onPressed: () {
                        Route route =
                            MaterialPageRoute(builder: (_) => CartScreen());
                        Navigator.pushReplacement(context, route);
                      },
                    ),
                  )
                : SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black
                      ),
                      child: AutoSizeText(
                        "Añadir al carro de compras".toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          
                          color: Colors.white,
                          fontFamily: "Brand-Bold",
                          letterSpacing: 1.5,
                          fontSize: 18,
                        ),
                      ),
                      /* color: Theme.of(context).accentColor, */
                      onPressed: () {
                        (productModel.status == 'Disponible')
                            ? CartService().checkItemInCart(
                                productModel.productId!,
                                productModel.productName!,
                                productModel.productImgUrl!,
                                productModel.newprice!,
                                productModel.newprice =
                                    productModel.newprice! * quantity,
                                quantity,
                                context,
                              )
                            : Fluttertoast.showToast(
                                msg: "Este producto ya no está disponible");
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }

  productCoverImage(BuildContext context) {
    return Image.network(
      productModel.productImgUrl!,
      fit: BoxFit.contain,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
    );
  }

  productName() {
    return AutoSizeText(
      productModel.productName!,
      style: TextStyle(
        fontFamily: "Brand-Regular",
        fontSize: 18,
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  productPrice() {
    return Row(
      children: [
        (productModel.offervalue!.toInt() < 1)
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: AutoSizeText(
                  "\$${productModel.orginalprice}",
                  style: TextStyle(
                    fontFamily: "Brand-Regular",
                    fontSize: 16,
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "\$${productModel.newprice}",
                    style:const TextStyle(
                      fontFamily: "Brand-Regular",
                      fontSize: 16,
                      color: Colors.deepOrangeAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      AutoSizeText(
                        "\$${productModel.orginalprice}",
                        style: const TextStyle(
                          fontFamily: "Brand-Regular",
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      AutoSizeText(
                        '- ${productModel.offervalue}%',
                        style: const TextStyle(
                          fontFamily: "Brand-Regular",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ],
              ),
      ],
    );
  }

  wishButton(BuildContext context) {
    return ElevatedButton.icon(
      /* shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), */
      icon: const Icon(
        Icons.favorite_border_outlined,
        color: Colors.white,
      ),
      label: const AutoSizeText(
        "Agregar a Favoritos",
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Brand-Bold",
          letterSpacing: 1.5,
          fontSize: 18,
        ),
      ),
      /* color: Colors.blueAccent[200], */
      onPressed: () {
        // WishListService().checkItemInWishList(
        //   productId,
        //   pName,
        //   pBrand,
        //   pImage,
        //   newPrice,
        //   context,
        // );
      },
    );
  }

  divider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 10,
        color: Colors.blueGrey[50],
      ),
    );
  }

  detailsproduct(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AutoSizeText(
                "Detalles",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Brand-Bold",
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductOnlyDetails(
                        productModel: productModel,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          AutoSizeText(
            productModel.description!.replaceAll("\\n", "\n"),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: "Brand-Regular",
            ),
          ),
        ],
      ),
    );
  }

  relatedProduct() {
    return HorizontalCard(
      cardTitle: 'Producto relacionado',
      stream: _db
          .where("categoryName", isEqualTo: productModel.categoryName)
          .snapshots(),
    );
  }
}
