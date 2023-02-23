import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/Screens/Vehicles/cars.dart';
import 'package:oilapp/Screens/Vehicles/create_car.dart';
import 'package:oilapp/Screens/Vehicles/create_motorcycle.dart';
import 'package:oilapp/Screens/Vehicles/motorcycles.dart';
class Vehicles extends StatefulWidget {
  const Vehicles({super.key});

  @override
  State<Vehicles> createState() => _VehiclesState();
}

class _VehiclesState extends State<Vehicles> with SingleTickerProviderStateMixin  {
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
          "Garage",
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
                    "Ver Carros",
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
                    "Ver Motos",
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
          Cars(),
          Motocycles()
        ],
      ),
    );
  }
}