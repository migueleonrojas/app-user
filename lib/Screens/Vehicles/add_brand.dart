import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/config/config.dart';
import 'package:oilapp/widgets/emptycardmessage.dart';
import 'package:oilapp/widgets/loading_widget.dart';


class AddBrand extends StatefulWidget {
  int? selectedIndex;
  String? brandName;
  int? brandId;
  String? logoBrand;
  bool holdIndex = false;
  late int previousSelectedIndex = 0;
  late String previousBrandName;
  late int previousBrandId;
  late String previousLogoBrand;
  AddBrand({super.key, this.selectedIndex, this.brandName, this.brandId, this.logoBrand});

  @override
  State<AddBrand> createState() => _AddBrandState();
}

class _AddBrandState extends State<AddBrand> {

  /* late ScrollController scrollController = ScrollController(
    initialScrollOffset:(widget.selectedIndex == null)? 0 : (widget.selectedIndex!.toDouble() * 40) - 80
  ); */
  late FixedExtentScrollController scrollController;
  
  
  @override
  void initState() {
   
    super.initState();
    
    scrollController = FixedExtentScrollController(
      initialItem: widget.selectedIndex ?? 0
    );
    

    widget.holdIndex = (widget.selectedIndex == null) ? false: true;
    widget.previousSelectedIndex = (widget.selectedIndex == null) ? 0: widget.selectedIndex!;
    widget.previousBrandName = (widget.brandName == null)? "": widget.brandName!;
    widget.previousLogoBrand = (widget.logoBrand == null)? "": widget.logoBrand!;
    widget.previousBrandId = (widget.brandId == null)? 0: widget.brandId!;
  }
  void changeIndex(int index, String brandNameSnapshot, int id, String logo ) {
   setState(() {
    widget.selectedIndex = index;
    widget.brandName = brandNameSnapshot;
    widget.brandId = id;
    widget.logoBrand = logo;
   });
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Center(child: Text('Marca')),
      content:
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          child: StreamBuilder<QuerySnapshot>(
            stream: AutoParts.firestore!
            .collection(AutoParts.brandsVehicle)
            .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return circularProgress();
              }

              if(snapshot.data!.docs.isEmpty) {
                return const EmptyCardMessage(
                  listTitle: 'No hay marcas',
                  message: 'No hay marcas disponibles',
                );
              }

              return ListWheelScrollView.useDelegate(
                physics: FixedExtentScrollPhysics(),
                controller: scrollController,
                perspective: 0.010,
                diameterRatio: 1.5,
                squeeze: 0.8,
                itemExtent: size.width * 0.1,
                onSelectedItemChanged: (value) {
                
                  changeIndex(
                    value, 
                    (snapshot.data!.docs[value] as dynamic).data()["name"],
                    (snapshot.data!.docs[value] as dynamic).data()["id"],
                    (snapshot.data!.docs[value] as dynamic).data()["logo"],
                  );
                },
                
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: snapshot.data!.docs.length,
                  builder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          (snapshot.data!.docs[index] as dynamic).data()["logo"],
                          fit: BoxFit.scaleDown,
                          width: size.width * 0.1,
                          height: size.height * 0.35,
                        ),
                        GestureDetector(
                          onTap: () {
                            changeIndex(
                              index, 
                              (snapshot.data!.docs[index] as dynamic).data()["name"],
                              (snapshot.data!.docs[index] as dynamic).data()["id"],
                              (snapshot.data!.docs[index] as dynamic).data()["logo"],
                            );
                          }, 
                          child: Material(
                            color: widget.brandName == (snapshot.data!.docs[index] as dynamic).data()["name"] ? Colors.blue:Colors.transparent,
                            
                            borderRadius: BorderRadius.circular(size.height * 0.035),
                            child: Container(
                              width: size.width * 0.35,
                              child: Center(child: Text((snapshot.data!.docs[index] as dynamic).data()["name"],style: TextStyle(fontSize: size.height * 0.020)),),
                            ),
                          ),
                        ),
                      ],
                    );
                
                  },
                ),
              );

             
                       
              /* return ListWheelScrollView(
                itemExtent: 40, 
                children: [
                Container(
                  
                )
              ]); */
              /* return ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemExtent:40,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {

                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        (snapshot.data!.docs[index] as dynamic).data()["logo"],
                        fit: BoxFit.scaleDown,
                        width: 40,
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          changeIndex(
                            index, 
                            (snapshot.data!.docs[index] as dynamic).data()["name"],
                            (snapshot.data!.docs[index] as dynamic).data()["id"],
                            (snapshot.data!.docs[index] as dynamic).data()["logo"],
                          );
                        }, 
                        child: Material(
                          color: widget.brandName == (snapshot.data!.docs[index] as dynamic).data()["name"] ? Colors.blue:Colors.transparent,
                          /* color: widget.selectedIndex == index  ? Colors.blue : Colors.transparent, */
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 120,
                            child: Center(child: Text((snapshot.data!.docs[index] as dynamic).data()["name"],style: TextStyle(fontSize: 15)),),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ); */
            },
          ),
        ),
      actions: [
        TextButton(
          child: const Text('Agregar'),
          onPressed: () {
            
            Navigator.of(context).pop([widget.selectedIndex, widget.brandName, widget.brandId, widget.logoBrand, true]);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            final returnedIndexBrand = (widget.holdIndex) ? widget.previousSelectedIndex : '';
            final returnedBrandName = (widget.holdIndex) ? widget.previousBrandName : '';
            final returnedLogoBrand = (widget.holdIndex) ? widget.previousLogoBrand : '';
            final returnedBrandId = (widget.holdIndex) ? widget.previousBrandId : '';
            Navigator.of(context).pop([returnedIndexBrand,returnedBrandName,returnedBrandId, returnedLogoBrand, false]);
          },
        ),
      ],
    );
    
  }
  
}