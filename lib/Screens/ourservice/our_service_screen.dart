import 'package:auto_size_text/auto_size_text.dart';
import 'package:oilapp/Model/vehicle_model.dart';
import 'package:oilapp/Screens/orders/myservice_order_by_vehicle_screen.dart';
import 'package:oilapp/Screens/ourservice/coustomServicebody.dart';
import 'package:flutter/material.dart';

class OurService extends StatefulWidget {

  final List<VehicleModel> vehicleModel;

  const OurService({required this.vehicleModel});

  @override
  _OurServiceState createState() => _OurServiceState();
}

class _OurServiceState extends State<OurService> {
  int selectedIndex = 0;
  double width = 50;
  double height = 30;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        
        title:  AutoSizeText(
          "Servicios MetaOil",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        /* actions: [
          IconButton(
            icon: Image.asset(
              "assets/icons/service.png",
              color: Colors.white,
            ),
            onPressed: () {
              /* Navigator.push(context,
                  MaterialPageRoute(builder: (_) => MyServiceOrderScreen())); */
            },
          ),
        ], */
      ),
      body: Row(
        children: [
          LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(                
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: NavigationRail(                    
                    elevation: 30,
                    backgroundColor: Colors.black,
                    selectedIndex: selectedIndex,
                    labelType: NavigationRailLabelType.selected,
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    destinations: [
                      /* modifique el codigo de este widget NavigationRailDestination, el destinations.length >= 1 */
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_oilchange.png",
                          width: size.width * 0.1,
                          height: size.height * 0.038,
                          color: (selectedIndex == 0)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: const Text(""),
                      ),
                      
                      /* NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_wash.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 1)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ),
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_repair.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 2)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ),
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_maintance.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 3)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ),
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_paint.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 4)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ),
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_tyre.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 5)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ),
                      NavigationRailDestination(
                        icon: Image.asset(
                          "assets/icons/car_windshield.png",
                          width: width,
                          height: height,
                          color: (selectedIndex == 6)
                              ? Colors.white
                              : Colors.white70,
                        ),
                        label: AutoSizeText(""),
                      ), */
                    ],
                  ),
                ),
              ),
            );
          }),
          Expanded(
            child: PageView(
              controller: pageController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              children:  [
                CoustomServiceBody(
                  isEqualTo: "Cambio de Aceite",
                  vehicleModel: widget.vehicleModel,
                ),
                /* CoustomServiceBody(
                  isEqualTo: "Car Wash",
                  vehicleModel: widget.vehicleModel,
                ),
                CoustomServiceBody(
                  isEqualTo: "Car Repair",
                  vehicleModel: widget.vehicleModel,
                ),
                CoustomServiceBody(
                  isEqualTo: "Car Maintance",
                  vehicleModel: widget.vehicleModel,
                ),
                CoustomServiceBody(
                  isEqualTo: "Car Denting and Painting",
                  vehicleModel: widget.vehicleModel,
                ),
                CoustomServiceBody(
                  isEqualTo: "Car Tyre Replacment",
                  vehicleModel: widget.vehicleModel,
                ),
                CoustomServiceBody(
                  isEqualTo: "Car windshield Replacment",
                  vehicleModel: widget.vehicleModel,
                ), */
              ],
            ),
          )
        ],
      ),
    );
  }
}
