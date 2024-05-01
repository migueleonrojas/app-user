import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oil_app/Screens/Vehicles/create_car.dart';
import 'package:oil_app/Screens/Vehicles/create_motorcycle.dart';
class CreateVehicleScreen extends StatefulWidget {

  

  const CreateVehicleScreen({super.key});

  @override
  State<CreateVehicleScreen> createState() => _CreateVehicleScreenState();
}

class _CreateVehicleScreenState extends State<CreateVehicleScreen> with SingleTickerProviderStateMixin  {
  TabController? _tabController;
  ScrollController? _scrollController;


  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
 
        title: AutoSizeText(
          "Agregar Vehiculo",
          style: TextStyle(
            fontSize: size.height * 0.024,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
            
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          unselectedLabelColor: Colors.black12,
          labelColor: Colors.black,
          controller: _tabController,
          indicatorColor: Colors.black,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_repair_rounded),
                  SizedBox(width: 5),
                  Text(
                    "Agregar Carro",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.motorcycle_outlined),
                  SizedBox(width: 5),
                  Text(
                    "Agregar Moto",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CreateCarScreen(automaticallyImplyLeading: false),
          CreateMotorcycleScreen(automaticallyImplyLeading: false,),
        ],
      ),
    );
  }
}