import 'package:oilapp/Helper/product_details_helper.dart';
import 'package:oilapp/Model/product_model.dart';
import 'package:oilapp/Model/rating_review_model.dart';
import 'package:oilapp/Screens/products/product_reviews.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/rating_review_service.dart';
import 'package:oilapp/service/wishlist_service.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/mycustom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rating_dialog/rating_dialog.dart';

class ProductDetails extends StatefulWidget {
  final ProductModel productModel;
  const ProductDetails({
    Key? key,
   required this.productModel,
  }) : super(key: key);
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;
  TextEditingController reviewController = TextEditingController();

  double totalrating = 0;
  ratingcalculation() {}
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    Stream stream = FirebaseFirestore.instance
        .collection(AutoParts.collectionUser)
        .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
        .collection('carts')
        .where('productId', isEqualTo: widget.productModel.productId)
        .snapshots();
    return SafeArea(
      child: Scaffold(
        appBar: MyCustomAppBar(),
        bottomNavigationBar:
            ProductDetailsHelper(productModel: widget.productModel)
                .bottomNavigationBar(quantity),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductDetailsHelper(productModel: widget.productModel)
                  .productCoverImage(context),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.014,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductDetailsHelper(productModel: widget.productModel)
                        .productName(),
                    SizedBox(height: size.height * 0.010),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProductDetailsHelper(productModel: widget.productModel)
                            .productPrice(),
                        StreamBuilder<QuerySnapshot>(
                          stream: stream as dynamic,
                          builder: (context, snapshot) {
                            if (snapshot.data == null)
                              return Center(
                                child: circularProgress(),
                              );
                            return (snapshot.data!.docs.length == 1)
                                ? ElevatedButton.icon(
                                    /* shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ), */
                                    icon: const Icon(
                                      Icons.favorite_border_outlined,
                                      color: Colors.white,
                                    ),
                                    label:  Text(
                                      "Agregar a Favoritos",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Brand-Bold",
                                        letterSpacing: .5,
                                        fontSize: size.height * 0.020,
                                      ),
                                    ),
                                    /* color: Colors.blueAccent[200], */
                                    onPressed: () {
                                      WishListService().addWish(
                                        widget.productModel.productId!,
                                        widget.productModel.productName!,
                                        widget.productModel.brandName!,
                                        widget.productModel.productImgUrl!,
                                        widget.productModel.newprice!,
                                      );
                                      Fluttertoast.showToast(
                                        msg:
                                            "Artículo añadido a la lista de favoritos con éxito.",
                                      );
                                    },
                                  )
                                : Row(
                                    children: [
                                      SizedBox(
                                        width: size.width * 0.15,
                                        child: OutlinedButton(
                                          child: const Icon(Icons.remove),
                                          onPressed: () {
                                            if (quantity > 1) {
                                              setState(() {
                                                quantity--;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:  EdgeInsets.symmetric(
                                          horizontal: size.width * 0.05,
                                        ),
                                        child: Text(
                                          quantity.toString(),
                                          style: TextStyle(
                                            fontFamily: "Brand-Regular",
                                            fontSize: size.height * 0.020,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.15,
                                        child: OutlinedButton(
                                          child: Icon(Icons.add),
                                          onPressed: () {
                                            setState(() {
                                              quantity++;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ProductDetailsHelper(productModel: widget.productModel).divider(),
              ProductDetailsHelper(productModel: widget.productModel)
                  .detailsproduct(context),
              ProductDetailsHelper(productModel: widget.productModel).divider(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.025,
                  vertical: size.height * 0.013,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Valoración y comentarios",
                      style: TextStyle(
                        fontSize: size.height * 0.024,
                        fontFamily: "Brand-Bold",
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: size.height * 0.014),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('ratingandreviews')
                                  .where("productId",
                                      isEqualTo: widget.productModel.productId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Container();
                                }
                                double userrating = 0;
                                for (int i = 0;
                                    i < snapshot.data!.docs.length;
                                    i++) {
                                  userrating = userrating +
                                      (snapshot.data!.docs[i] as dynamic).data()['rating'] as dynamic;
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          (snapshot.data!.docs.length == 0)
                                              ? "0.0"
                                              : "${(userrating / snapshot.data!.docs.length).toStringAsFixed(1)}",
                                          style: TextStyle(
                                            fontSize: size.height *0.064,
                                          ),
                                        ),
                                        Icon(
                                          Icons.star_half,
                                          size: size.height * 0.046,
                                          color: Colors.deepOrangeAccent[200],
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('${userrating.toString()}/'),
                                        Text(
                                          "${snapshot.data!.docs.length.toString()} Clasificaciones",
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              }),
                        ),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return RatingDialog(
                                    commentHint: 'Díganos sus comentarios',
                                    /* icon: Image.asset(
                                      "assets/authenticaiton/logo.png",
                                      width: 100,
                                      height: 100,
                                    ), */
                                    title: Text("Dar su calificación"),
                                    /* description:
                                        "Tap a star to set your rating. Add more description here if you want.", */
                                    onSubmitted: (rating) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(size.height * 0.035),
                                            ),
                                            title: const Text(
                                              "Dé su opinión",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  "Escriba su valiosa opinión sobre este servicio. Nos ayudará a mejorar nuestro servicio.",
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: size.height *0.008),
                                                TextFormField(
                                                  maxLines: 3,
                                                  controller: reviewController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "¡escribe lo que quieras!",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.height *0.007),
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                     await RatingAndReviewService()
                                                        .addRatingandReviewForuser(
                                                      AutoParts
                                                          .sharedPreferences!
                                                          .getString(AutoParts
                                                              .userAvatarUrl)!,
                                                      AutoParts
                                                          .sharedPreferences!
                                                          .getString(AutoParts
                                                              .userName)!,
                                                      AutoParts
                                                          .sharedPreferences!
                                                          .getString(AutoParts
                                                              .userUID)!,
                                                      widget.productModel
                                                          .productId!,
                                                      widget.productModel
                                                          .productName!,
                                                      widget.productModel
                                                          .productImgUrl!,
                                                      rating.rating,
                                                      reviewController.text,
                                                    );
                                                    setState(() {
                                                      reviewController.text =
                                                          "";
                                                    });

                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Gracias por darnos su valiosa calificación y reseña");
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Enviar",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: size.height *0.018,
                                                      color: Colors
                                                          .deepOrangeAccent,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    submitButtonText: "Opine",
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: size.height * 0.115,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(size.height * 0.008),
                                border: Border.all(
                                  width: size.width *0.01,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Califique y opine...",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ratingandreviews')
                          .where("productId",
                              isEqualTo: widget.productModel.productId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return (snapshot.data!.docs.length == 0)
                            ? Container()
                            : (snapshot.data!.docs.length > 5)
                                ? Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: 5,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          RatingAndReviewModel
                                              ratingAndReviewModel =
                                              RatingAndReviewModel.formJson(
                                            (snapshot.data!.docs[index] as dynamic).data(),
                                          );
                                          return ListTile(
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(size.height * 0.055),
                                              child: Image.network(
                                                ratingAndReviewModel.userAvatar!,
                                                fit: BoxFit.cover,
                                                width: size.width * 0.13,
                                                height: size.height * 0.055,
                                              ),
                                            ),
                                            title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ratingAndReviewModel.userName!,
                                                  style: TextStyle(
                                                    fontSize: size.height * 0.022,
                                                    letterSpacing: 0.5,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: "Brand-Regular",
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${ratingAndReviewModel.rating} ',
                                                    ),
                                                    for (int i = 0;
                                                        i <
                                                            ratingAndReviewModel
                                                                .rating!;
                                                        i++)
                                                      Text('⭐'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            subtitle: Text(ratingAndReviewModel
                                                .reviewMessage!),
                                          );
                                        },
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ProductReviews(
                                                  productId: widget
                                                      .productModel.productId!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Mas Opiniones....",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "Brand-Regular",
                                              letterSpacing: 0.5,
                                              color:
                                                  Colors.deepOrangeAccent[200],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      RatingAndReviewModel
                                          ratingAndReviewModel =
                                          RatingAndReviewModel.formJson(
                                        (snapshot.data!.docs[index] as dynamic).data(),
                                      );
                                      return ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(size.height * 0.055),
                                          child: Image.network(
                                            ratingAndReviewModel.userAvatar!,
                                            fit: BoxFit.cover,
                                            width: size.width * 0.1,
                                            height: size.height * 0.055,
                                          ),
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ratingAndReviewModel.userName!,
                                              style:  TextStyle(
                                                fontSize: size.height * 0.021,
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "Brand-Regular",
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    '${ratingAndReviewModel.rating}'),
                                                for (int i = 0;
                                                    i <
                                                        ratingAndReviewModel
                                                            .rating!;
                                                    i++)
                                                  Text('⭐'),
                                              ],
                                            )
                                          ],
                                        ),
                                        subtitle: Text(
                                            ratingAndReviewModel.reviewMessage!),
                                      );
                                    },
                                  );
                      },
                    ),
                  ],
                ),
              ),
              ProductDetailsHelper(productModel: widget.productModel).divider(),
              ProductDetailsHelper(productModel: widget.productModel)
                  .relatedProduct(),
            ],
          ),
        ),
      ),
    );
  }
}
