import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/config/config.dart';


class AddYear extends StatefulWidget {
  int? selectedIndex;
  
  int? year;
  bool holdIndex = false;
  late int previousSelectedIndex = 0;
  late int previousYear;
  AddYear({super.key, this.selectedIndex, this.year});

  @override
  State<AddYear> createState() => _AddYearState();
}

class _AddYearState extends State<AddYear> {

  late ScrollController scrollController = ScrollController(
    initialScrollOffset:(widget.selectedIndex == null)? 0 : (widget.selectedIndex!.toDouble() * 40) - 80
  );
  
  
  @override
  void initState() {
    super.initState();
    widget.holdIndex = (widget.selectedIndex == null) ? false: true;
    widget.previousSelectedIndex = (widget.selectedIndex == null) ? 0: widget.selectedIndex!;
    widget.previousYear = (widget.year == null)? 0: widget.year!;
  }
  void changeIndex(int index, int yry) {
   setState(() {
    widget.selectedIndex = index;
    widget.year = yry;
   });
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Center(child: Text('Años')),
      content:
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: AutoParts.firestore!
            .collection(AutoParts.yearsVehicle)
            .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(height: 120,);
              }
              return ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemExtent:40,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      GestureDetector(
                        onTap: () {
                          changeIndex(index, (snapshot.data!.docs[index] as dynamic).data()["year"]);
                        }, 
                        child: Material(
                          color: widget.year == (snapshot.data!.docs[index] as dynamic).data()["year"] ? Colors.blue: Colors.transparent,
                          /* color: widget.selectedIndex == index ? Colors.blue : Colors.transparent, */
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 120,
                            child: Center(child: Text((snapshot.data!.docs[index] as dynamic).data()["year"].toString(),style: TextStyle(fontSize: 15)),),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      actions: [
        TextButton(
          child: const Text('Agregar'),
          onPressed: () {
            
            Navigator.of(context).pop([widget.selectedIndex, widget.year]);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            final returnedIndexBrand = (widget.holdIndex) ? widget.previousSelectedIndex : '';
            final returnedBrandId = (widget.holdIndex) ? widget.previousYear : '';
            Navigator.of(context).pop([returnedIndexBrand,returnedBrandId]);
          },
        ),
      ],
    );
    
    /* return AlertDialog(
      title: const Center(child: Text('Brand')),
      content: Container(
        height: 200,
        child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          itemExtent:40,
          itemCount: 1000,
          itemBuilder: (BuildContext context, int index) {

            return GestureDetector(

              onTap: () {
                changeIndex(index);
              }, 
              child: Material(
                color: widget.selectedIndex == index ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  child: Center(child: Text(index.toString(),style: TextStyle(fontSize: 15)),),
                ),
              ),
            );
            
            
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            
            Navigator.of(context).pop(widget.selectedIndex);
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            final returnedBrand = (widget.holdIndex) ? widget.previousSelectedIndex : '';
            Navigator.of(context).pop(returnedBrand);
          },
        ),
      ],
    ); */
  }
  
}