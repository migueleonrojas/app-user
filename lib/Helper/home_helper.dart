
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oilapp/Screens/Vehicles/vehicles.dart';
import 'package:oilapp/Screens/products/product_search.dart';
import 'package:oilapp/service/category_data.dart';
import 'package:oilapp/widgets/category_tile.dart';
import 'package:oilapp/widgets/loading_widget.dart';
import 'package:oilapp/widgets/verticalCard.dart';
import 'package:oilapp/widgets/horizontalCard.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeHelper {
  final _db = FirebaseFirestore.instance.collection('products');
  List<String> imageslider = [];
  Widget categoriesCard(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Brand-Bold",
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            height: 80,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (BuildContext context, int index) {
                return CategoryTile(
                  categoryName: categories[index].categoryName!,
                  imageUrl: categories[index].imageUrl!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget homeCarousel(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Carousels")
          .orderBy("publishedDate", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<String> sliderImage = [];
        for (int i = 0; i < snapshot.data!.docs.length; i++) {
          DocumentSnapshot snap = snapshot.data!.docs[i];
          sliderImage.add(
            (snap.data() as dynamic)["carouselImgUrl"],
          );
        }

        return Container(
          height: 200,
          width: double.infinity,
          child: CarouselSlider(
            options: CarouselOptions(height: 400.0),
            items: sliderImage
                .map(
                  (e) => Container(
                    child: Image.network(
                      e,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget uptoFiftyPercentOFFCard() {
    return VerticalCard(
      cardTitle: 'Up to 50% off',
      stream: _db.where("offer", isGreaterThanOrEqualTo: 50).snapshots(),
    );
  }

  Widget newArrivalCard() {
    return VerticalCard(
      cardTitle: 'New Arrival',
      stream: _db.orderBy('publishedDate', descending: true).snapshots(),
    );
  }

  Widget vacuumsCard() {
    return HorizontalCard(
      cardTitle: 'Vacuums',
      stream: _db.where("categoryName", isEqualTo: 'Vacuums').snapshots(),
    );
  }

  Widget helmetCard() {
    return VerticalCard(
      cardTitle: 'Helmet',
      stream: _db.where("categoryName", isEqualTo: 'Helmet').snapshots(),
    );
  }
  Widget airfresnersCard() {
    return HorizontalCard(
      cardTitle: 'Air Fresheners',
      stream: _db.where("categoryName", isEqualTo: 'Air Fresheners').snapshots(),
    );
  }

  Widget mainButtons (BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Route route = MaterialPageRoute(builder: (_) => ProductSearch());
                Navigator.push(context, route);
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blueAccent)
                ),
                width: MediaQuery.of(context).size.width * 0.30,
                child: Column(
                  children: [
                    Container(
                      
                      color: Colors.amber,
                      child: IconButton(
                        icon: const Icon(
                          Icons.search_outlined,
                        ),
                        onPressed: () {
                            Route route = MaterialPageRoute(builder: (_) => ProductSearch());
                            Navigator.push(context, route);
                        },
                      ),
                    ),
                    const SizedBox(height: 5,),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5,),
            const Text(
              'Tienda GO',
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
        const SizedBox(width: 10,),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Route route = MaterialPageRoute(builder: (_) => Vehicles());
                Navigator.push(context, route);
              },
              child: Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(  
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blueAccent)
                ),
                width: MediaQuery.of(context).size.width * 0.30,
                child: Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(255, 27, 93, 179),
                      child: IconButton(
                        icon: const Icon(
                          Icons.garage,
                        ),
                        onPressed: () {
                          Route route = MaterialPageRoute(builder: (_) => Vehicles());
                          Navigator.push(context, route);
                        },
                      ),
                    ),
                    const SizedBox(height: 5,),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5,),
            const Text(
              'Mis Vehiculos',
              style: TextStyle(fontSize: 14),
            )
          ],
        ),
        
        
      ],
    );
  }

}
