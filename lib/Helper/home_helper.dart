
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:oil_app/Screens/Vehicles/create_vehicle.dart';
import 'package:oil_app/Screens/Vehicles/vehicles.dart';
import 'package:oil_app/Screens/products/product_search.dart';
import 'package:oil_app/service/category_data.dart';
import 'package:oil_app/widgets/category_tile.dart';
import 'package:oil_app/widgets/loading_widget.dart';
import 'package:oil_app/widgets/verticalCard.dart';
import 'package:oil_app/widgets/horizontalCard.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeHelper {
  final _db = FirebaseFirestore.instance.collection('products');
  List<String> imageslider = [];
  Widget categoriesCard(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.height * 0.020,
              vertical: size.height * 0.020 ,
            ),
            child: AutoSizeText(
              'Categories',
              style: TextStyle(
                fontSize: size.height * 0.025,
                fontFamily: "Brand-Bold",
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            height: size.height * 0.1,
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

    Size size = MediaQuery.of(context).size;

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
          height:  size.height * 0.25,
          width: double.infinity,
          child: CarouselSlider(
            options: CarouselOptions(height: size.height * 0.50),
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

    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        
        
        
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Route route = MaterialPageRoute(builder: (_) => Vehicles());
                Navigator.push(context, route);
              },
              child: Container(
                padding: EdgeInsets.all(size.height * 0.0010),
                /* decoration: BoxDecoration(  
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blueAccent)
                ), */
                width: MediaQuery.of(context).size.width * 0.30,
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.21,
                      height: size.height * 0.100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.height * 0.015),
                        color: const Color.fromARGB(255, 27, 93, 179),
                      ),
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
                    
                    
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.010,),
            AutoSizeText(
              'Mis Vehiculos',
              style: TextStyle(fontSize: size.height * 0.018,color: Colors.black),
            )
          ],
        ),
        SizedBox(width: size.width * 0.010,),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                Route route = MaterialPageRoute(builder: (_) => ProductSearch());
                Navigator.push(context, route);
              },
              child: Container(
                padding: EdgeInsets.all(size.height * 0.0010),
                /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.blueAccent)
                ), */
                width: MediaQuery.of(context).size.width * 0.30,
                child: Column(
                  children: [
                    Container(
                      width: size.width * 0.21,
                      height: size.height * 0.100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.height * 0.015),
                        color: Colors.amber,
                      ),
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
                    
                    
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.010,),
            AutoSizeText(
              'Tienda GO',
              style: TextStyle(fontSize: size.height * 0.018, color: Colors.black),
            )
          ],
        ),
        
        
      ],
    );
  }


  Widget buttonCreateVehicle(Color color, BuildContext context) {

    Size size = MediaQuery.of(context).size;

    

    return Container(
      width: size.width *0.7,
      height: size.height * 0.065,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.height *0.015),
        boxShadow: [
          for(double i = 1; i < 5; i++)
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3 * i,
              
            ),
          for(double i = 1; i < 5; i++)
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3 * i,
              offset: Offset.zero,
              blurStyle: BlurStyle.outer
            ),
        ]

      ),
      child: TextButton(
        onPressed: () {
          Route route = MaterialPageRoute(builder: (_) => CreateVehicleScreen());
          Navigator.push(context, route);
        },
        style: TextButton.styleFrom(
          side: BorderSide(color: color, width: size.width *0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.height *0.015)
          )
        ),
        child: Text(
          'Registre su vehículo aqui',
          style: TextStyle(
            color: color,
            shadows: [
              for(double i = 1; i < 4; i++)
                Shadow(
                  color: Colors.grey.shade300,
                  blurRadius: 3 * i
      
                )
            ]
          ),
        ),
      ),
    );

  }

}
