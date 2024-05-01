
import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Model/rating_review_model.dart';
import 'package:oil_app/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductReviews extends StatefulWidget {
  final String productId;

  const ProductReviews({
    Key? key,
    required this.productId,
  }) : super(key: key);
  @override
  _ProductReviewsState createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        false,
        "Rating & Reviews",
        context
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ratingandreviews')
            .where("productId", isEqualTo: widget.productId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return (snapshot.data!.docs.length == 0)
              ? Container()
              : SingleChildScrollView(
                  child: Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        RatingAndReviewModel ratingAndReviewModel =
                            RatingAndReviewModel.formJson(
                          (snapshot.data!.docs[index] as dynamic).data(),
                        );
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              ratingAndReviewModel.userAvatar!,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                ratingAndReviewModel.userName!,
                                style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Brand-Regular",
                                ),
                              ),
                              Row(
                                children: [
                                  AutoSizeText('${ratingAndReviewModel.rating}'),
                                  for (int i = 0;
                                      i < ratingAndReviewModel.rating!;
                                      i++)
                                    AutoSizeText('⭐'),
                                ],
                              )
                            ],
                          ),
                          subtitle: AutoSizeText(ratingAndReviewModel.reviewMessage!),
                        );
                      },
                    ),
                  ),
                );
        },
      ),
    );
  }
}
