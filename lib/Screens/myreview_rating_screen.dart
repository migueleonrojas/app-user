import 'package:oilapp/Model/rating_review_model.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyReviewAndRating extends StatefulWidget {
  @override
  _MyReviewAndRatingState createState() => _MyReviewAndRatingState();
}

class _MyReviewAndRatingState extends State<MyReviewAndRating> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        false,
        "Mis opiniónes y valoraciones",
        context
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AutoParts.collectionUser)
            .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
            .collection('ratingandreviews')
            .orderBy("publishedDate", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return (snapshot.data!.docs.length == 0)
              ? EmptyCardMessage(
                  listTitle: 'Sin opiniones',
                  message: 'Empezar a dar opiniones!',
                )
              : SingleChildScrollView(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.blueGrey,
                        height: 2,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      RatingAndReviewModel ratingAndReviewModel =
                          RatingAndReviewModel.formJson(
                        (snapshot.data!.docs[index] as dynamic).data(),
                      );

                      return ListTile(
                        leading: Image.network(
                          ratingAndReviewModel.productImage!,
                          width: 80,
                          height: 80,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ratingAndReviewModel.productName!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
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
                                    i < ratingAndReviewModel.rating!;
                                    i++)
                                  Text('⭐'),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Text(ratingAndReviewModel.reviewMessage!),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
