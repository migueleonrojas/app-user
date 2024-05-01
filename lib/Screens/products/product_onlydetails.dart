import 'package:auto_size_text/auto_size_text.dart';
import 'package:oil_app/Model/product_model.dart';
import 'package:oil_app/widgets/simpleAppbar.dart';
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
        context
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
              AutoSizeText(
                "Especificaciones del producto",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Brand-Bold",
                ),
              ),
              SizedBox(height: 4),
              AutoSizeText(
                productModel.shortInfo!.replaceAll("\\n", "\n"),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Brand-Regular",
                ),
              ),
              SizedBox(height: 8),
              AutoSizeText(
                "Detalles del producto",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "Brand-Bold",
                ),
              ),
              SizedBox(height: 4),
              AutoSizeText(
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
