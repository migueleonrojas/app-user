import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:oil_app/Screens/products/category_products.dart';
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String imageUrl, categoryName;
  CategoryTile({
    required this.imageUrl,
    required this.categoryName,
  });
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        var connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult != ConnectivityResult.mobile &&
            connectivityResult != ConnectivityResult.wifi) {
          return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: AutoSizeText(
                  "No Internet Connection",
                ),
                content: Text("Check your network settings and try again."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProducts(category: categoryName),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(right: size.width * 0.015),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                imageUrl,
                width: size.width * 0.33,
                height: size.height * 0.20,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: size.width * 0.33,
              height: size.height * 0.20,
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(size.height * 0.01),
              ),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.height * 0.020,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
