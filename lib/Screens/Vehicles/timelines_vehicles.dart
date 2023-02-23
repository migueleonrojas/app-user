import 'package:flutter/material.dart';
import 'package:oilapp/Screens/Vehicles/time_line_car.dart';
import 'package:oilapp/Screens/Vehicles/time_line_motorcycle.dart';

class TimelinesVehicles extends StatefulWidget {
  const TimelinesVehicles({super.key});

  @override
  State<TimelinesVehicles> createState() => _TimelinesVehiclesState();
}

class _TimelinesVehiclesState extends State<TimelinesVehicles>  {

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    
    return Column(
      children: [
        Text(
          'Próximos servicios de cambio de aceite',
          style:  TextStyle(
            fontSize: size.height * 0.023,
            color: Colors.black

          ),
        ),
        DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: const TabBar(
                  labelColor: Colors.black,
                  dividerColor: Colors.blue,
                  indicatorColor: Colors.blue,
                  unselectedLabelColor: Colors.black12,
                  
                  tabs:   [

                    Tab(
                      
                      text: 'Carros',
                      icon: Icon(
                        Icons.car_repair,
                        color: Colors.black,
                      )
                    ),
                    Tab(
                      text: 'Motos',
                      icon: Icon(
                        Icons.motorcycle,
                        color: Colors.black,
                      ),

                    )
                  ],
                ),
              ),
              Container(
                width: size.width * 0.85,
                height: size.height * 0.4,
                child: TabBarView(
                  children: [
                    TimeLineCars(),
                    TimeLineMotorCycles()
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );

  }
}