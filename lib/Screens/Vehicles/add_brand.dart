import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/config/config.dart';


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

  late ScrollController scrollController = ScrollController(
    initialScrollOffset:(widget.selectedIndex == null)? 0 : (widget.selectedIndex!.toDouble() * 40) - 80
  );
  
  
  @override
  void initState() {
    super.initState();
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

    return AlertDialog(
      title: const Center(child: Text('Marca')),
      content:
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: AutoParts.firestore!
            .collection(AutoParts.brandsVehicle)
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
              );
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