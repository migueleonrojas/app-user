import 'package:oilapp/Model/product_model.dart';
import 'package:oilapp/Screens/products/product_details.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/service/cart_service.dart';
import 'package:oilapp/service/wishlist_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';

class ProductSearch extends StatefulWidget {
  @override
  _ProductSearchState createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  final searchProductController = TextEditingController();

  List _allProductResults = [];
  List _productResultList = [];
  Future? productResultsLoaded;
  @override
  void initState() {
    searchProductController.addListener(_onProductSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    searchProductController.removeListener(_onProductSearchChanged);
    searchProductController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    productResultsLoaded = getAllSearchProductsData();
  }

  _onProductSearchChanged() {
    searchProductsResultsList();
  }

  searchProductsResultsList() {
    var showResult = [];
    if (searchProductController.text != "") {
      for (var productfromjson in _allProductResults) {
        var productName =
            ProductModel.fromSnaphot(productfromjson).productName!.toLowerCase();
        if (productName.contains(searchProductController.text.toLowerCase())) {
          showResult.add(productfromjson);
        }
      }
    } else {
      showResult = List.from(_allProductResults);
    }
    _productResultList = showResult;
  }

  getAllSearchProductsData() async {
    var data = await FirebaseFirestore.instance
        .collection('products')
        .orderBy("publishedDate", descending: true)
        .get();
    setState(() {
      _allProductResults = data.docs;
    });
    searchProductsResultsList();
    return "Completo";
  }

  Future <List<Map<String,dynamic>>> getProducts() async {

    List <Map<String,dynamic>> listProducts = [];

    QuerySnapshot<Map<String, dynamic>> products = await FirebaseFirestore.instance
        .collection('products')
        .orderBy("publishedDate", descending: true)
        .get();

    for(final product in products.docs) {

      listProducts.add(product.data());

    }

    return listProducts;

  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    int quantity = 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          onChanged: (searchProductController) {
            setState(() {
              searchProductController;
            });
          },
          style: TextStyle(
            color: Colors.black,
            fontSize: size.height * 0.022,
            fontWeight: FontWeight.w600,
          ),
          controller: searchProductController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: size.width * 0.10,
              horizontal: 0,
            ),
            hintText: 'Buscar productos...',
            hintStyle: TextStyle(
              color: Colors.blueGrey,
              fontSize: size.height * 0.022/* 18 */,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.black,
            ),
            onPressed: () {
              searchProductController.text = "";
            },
          ),
        ],
      ),

      body:  FutureBuilder(
        future: getProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
              return circularProgress();
          }
          if(snapshot.data!.isEmpty) {
            return const EmptyCardMessage(
              listTitle: 'No hay notas de productos',
              message: 'No hay productos disponibles',
            );
          }

          return SearchProductGridCard(
            productResultList: _productResultList,
            quantity: quantity,
          );

        },

      )
      /* body: SearchProductGridCard(
        productResultList: _productResultList,
        quantity: quantity,
      ), */
    );
  }
}

class SearchProductGridCard extends StatelessWidget {
  const SearchProductGridCard({
    Key? key,
    required List productResultList,
    required this.quantity,
  })  : _productResultList = productResultList,
        super(key: key);

  final List _productResultList;
  final int quantity;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _productResultList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (BuildContext context, int index) {
            ProductModel productModel =
                ProductModel.fromSnaphot(_productResultList[index]);
            return GestureDetector(
              onTap: () {
                Route route = MaterialPageRoute(
                    builder: (c) => ProductDetails(
                          productModel: productModel,
                        ));
                Navigator.push(context, route);
              },
              child: Stack(
                children: [
                  Card(
                    elevation: 2,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            productModel.productImgUrl!,
                            width: size.width * 0.3,
                            height: size.height * 0.11/* 100 */,
                          ),
                          SizedBox(height: size.height * 0.008),
                          Padding(
                            padding: EdgeInsets.all(size.height * 0.006),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productModel.productName!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: "Brand-Regular",
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.branding_watermark_outlined),
                                    SizedBox(width: size.width * 0.02),
                                    Flexible(
                                      child: Text(
                                        productModel.brandName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: "Brand-Regular",
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                (productModel.offervalue! < 1)
                                    ? Padding(
                                        padding:
                                             EdgeInsets.only(bottom: size.height * 0.015),
                                        child: Text(
                                          "\$${productModel.orginalprice}",
                                          style: TextStyle(
                                            fontFamily: "Brand-Regular",
                                            fontSize: size.height * 0.020,
                                            color: Colors.deepOrangeAccent,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "\$${productModel.newprice}",
                                            style: TextStyle(
                                              fontFamily: "Brand-Regular",
                                              fontSize: size.height * 0.020,
                                              color: Colors.deepOrangeAccent,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "\$${productModel.orginalprice}",
                                                style: TextStyle(
                                                  fontFamily: "Brand-Regular",
                                                  fontSize: size.height * 0.020,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: size.width * 0.02),
                                              Text(
                                                '- ${productModel.offervalue}%',
                                                style: TextStyle(
                                                  fontFamily: "Brand-Regular",
                                                  fontSize: size.height * 0.020,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: size.height * 0.048/* 40 */,
                      width: size.width * 0.115/* 40 */,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow:  const [
                           BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            spreadRadius: -2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(size.height * 0.058),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(AutoParts.collectionUser)
                              .doc(AutoParts.sharedPreferences!
                                  .getString(AutoParts.userUID))
                              .collection('wishLists')
                              .where("productId",
                                  isEqualTo: productModel.productId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            return Center(
                              child: IconButton(
                                icon: (snapshot.data!.docs.length == 1)
                                    ? const Icon(
                                        Icons.favorite,
                                        color: Colors.deepOrangeAccent,
                                      )
                                    : const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.deepOrangeAccent,
                                      ),
                                onPressed: () {
                                  WishListService().addWish(
                                    productModel.productId!,
                                    productModel.productName!,
                                    productModel.brandName!,
                                    productModel.productImgUrl!,
                                    productModel.newprice!,
                                  );
                                  Fluttertoast.showToast(
                                    msg: "Artículo añadido a la lista de favoritos con éxito.",
                                  );
                                },
                              ),
                            );
                          }),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.004,
                    right: size.width * 0.012,
                    child: Container(
                      height: size.height * 0.060,
                      decoration: BoxDecoration(
                        color: Colors.deepOrangeAccent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(size.width * 0.05/* 10 */),
                          bottomRight: Radius.circular(size.width * 0.015),
                        ),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(AutoParts.collectionUser)
                              .doc(AutoParts.sharedPreferences!
                                  .getString(AutoParts.userUID))
                              .collection('carts')
                              .where("productId",
                                  isEqualTo: productModel.productId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container();
                            return IconButton(
                              icon: (snapshot.data!.docs.length == 1)
                                  ? Icon(
                                      Icons.shopping_bag,
                                      size: size.height * 0.030,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.add_shopping_cart_outlined,
                                      size: size.height * 0.030,
                                      color: Colors.white,
                                    ),
                              onPressed: () {
                                CartService().checkItemInCart(
                                  productModel.productId!,
                                  productModel.productName!,
                                  productModel.productImgUrl!,
                                  productModel.newprice!,
                                  productModel.newprice =
                                      productModel.newprice! * quantity,
                                  quantity,
                                  context,
                                );
                              },
                            );
                          }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
