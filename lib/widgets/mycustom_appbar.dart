import 'package:oilapp/Screens/cart_screen.dart';
import 'package:oilapp/Screens/products/product_search.dart';
import 'package:oilapp/config/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyCustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget? bottom;

  const MyCustomAppBar({Key? key, this.bottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black),
      title: const Text(
        "GlobalOil",
        style: TextStyle(
          fontSize: 20,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
          fontFamily: "Brand-Regular",
        ),
      ),
      centerTitle: true,
      bottom: bottom,
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
                Navigator.push(context, route);
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AutoParts.collectionUser)
                  .doc(AutoParts.sharedPreferences!.getString(AutoParts.userUID))
                  .collection('carts')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Container();
                return Positioned(
                  top: 3,
                  left: 3,
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                            border: Border.all(color: Colors.orangeAccent)),
                      ),
                      (snapshot.data!.docs.length < 10)
                          ? Positioned(
                              top: 2,
                              bottom: 4,
                              left: 6,
                              child: Text(
                                snapshot.data!.docs.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Positioned(
                              top: 3,
                              bottom: 2,
                              left: 3,
                              child: Text(
                                snapshot.data!.docs.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
            // Positioned(
            //   top: 3,
            //   left: 3,
            //   child: Stack(
            //     children: [
            //       Container(
            //         height: 20,
            //         width: 20,
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(20),
            //             color: Colors.red,
            //             border: Border.all(color: Colors.orangeAccent)),
            //       ),
            //       ((AutoParts.sharedPreferences
            //                       .getStringList(AutoParts.userCartList)
            //                       .length -
            //                   1) <
            //               10)
            //           ? Positioned(
            //               top: 2,
            //               bottom: 4,
            //               left: 6,
            //               child: Consumer<CartItemCounter>(
            //                 builder: (context, counter, _) {
            //                   return Text(
            //                     (AutoParts.sharedPreferences
            //                                 .getStringList(
            //                                     AutoParts.userCartList)
            //                                 .length -
            //                             1)
            //                         .toString(),
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontWeight: FontWeight.w500,
            //                     ),
            //                   );
            //                 },
            //               ),
            //             )
            //           : Positioned(
            //               top: 3,
            //               bottom: 2,
            //               left: 3,
            //               child: Consumer<CartItemCounter>(
            //                 builder: (context, counter, _) {
            //                   return Text(
            //                     (AutoParts.sharedPreferences
            //                                 .getStringList(
            //                                     AutoParts.userCartList)
            //                                 .length -
            //                             1)
            //                         .toString(),
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontSize: 12.0,
            //                     ),
            //                   );
            //                 },
            //               ),
            //             ),
            //     ],
            //   ),
            // ),
          ],
        ),
        IconButton(
          icon: const Icon(
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

  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
