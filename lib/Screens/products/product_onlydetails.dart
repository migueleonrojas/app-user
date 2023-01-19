import 'package:oilapp/Model/product_model.dart';
import 'package:oilapp/widgets/simpleAppbar.dart';
import 'package:flutter/material.dart';

class ProductOnlyDetails extends StatelessWidget {
  final ProductModel productModel;

  const ProductOnlyDetails({Key? key, required this.productModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: simpleAppBar(
        false,
        "Detalles de producto",
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Especificaciones del producto",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Brand-Bold",
                ),
              ),
              SizedBox(height: 4),
              Text(
                productModel.shortInfo!.replaceAll("\\n", "\n"),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Brand-Regular",
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Detalles del producto",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Brand-Bold",
                ),
              ),
              SizedBox(height: 4),
              Text(
                productModel.description!.replaceAll("\\n", "\n"),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Brand-Regular",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
