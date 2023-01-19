import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oilapp/config/config.dart';


class AddModel extends StatefulWidget {
  int? selectedIndex;
  String? modelName;
  int? brandId;
  bool holdIndex = false;
  late int previousSelectedIndex = 0;
  late String previousModelName;
  late int previousModelId;
  AddModel({super.key, this.selectedIndex, this.modelName, this.brandId});

  @override
  State<AddModel> createState() => _AddModelState();
}

class _AddModelState extends State<AddModel> {

  late ScrollController scrollController = ScrollController(
    initialScrollOffset:(widget.selectedIndex == null)? 0 : (widget.selectedIndex!.toDouble() * 40) - 80
  );
  
  
  @override
  void initState() {
    super.initState();
    widget.holdIndex = (widget.selectedIndex == null) ? false: true;
    widget.previousSelectedIndex = (widget.selectedIndex == null) ? 0: widget.selectedIndex!;
    widget.previousModelName = (widget.modelName == null)? "": widget.modelName!;
    widget.previousModelId = (widget.brandId == null)? 0: widget.brandId!;
  }
  void changeIndex(int index, String brandNameSnapshot) {
   setState(() {
    widget.selectedIndex = index;
    widget.modelName = brandNameSnapshot;
   });
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Center(child: Text('Models')),
      content:
        Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: AutoParts.firestore!
            .collection(AutoParts.modelsVehicle)
            .where('id_brand', isEqualTo: widget.brandId)
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
                          changeIndex(index, (snapshot.data!.docs[index] as dynamic).data()["name"]);
                        }, 
                        child: Material(
                          color: widget.modelName == (snapshot.data!.docs[index] as dynamic).data()["name"] ? Colors.blue:Colors.transparent,
                          /* color: widget.selectedIndex == index ? Colors.blue : Colors.transparent, */
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 120,
                            child: Center(child: Text((snapshot.data!.docs[index] as dynamic).data()["name"],style: const TextStyle(fontSize: 15)),),
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
            
            Navigator.of(context).pop([widget.selectedIndex, widget.modelName, widget.brandId]);
          },
        ),
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            final returnedIndexBrand = (widget.holdIndex) ? widget.previousSelectedIndex : '';
            final returnedBrandName = (widget.holdIndex) ? widget.previousModelName : '';
            
            Navigator.of(context).pop([returnedIndexBrand,returnedBrandName]);
          },
        ),
      ],
    );
    
  }
  
}