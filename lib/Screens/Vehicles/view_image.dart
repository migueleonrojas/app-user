import 'dart:io';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ViewImage extends StatefulWidget {

  final dynamic pathImage;
  

  const ViewImage({super.key, required this.pathImage});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        
        title: AutoSizeText(
          "Vista de Imagen",
          style: TextStyle(
            fontSize: size.height * 0.028,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontFamily: "Brand-Regular",
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
              
                bool confirm =  await _onBackPressed("De que quieres eliminar este adjunto");
                if(!confirm) return;
                if(!mounted) return;
                Navigator.of(context).pop(widget.pathImage);
                
              },  
            ),
        ],
       
      ),
      
      body: InteractiveViewer(
      
        minScale: 0.5,
        maxScale: 5,
        child:(widget.pathImage is XFile || widget.pathImage is PlatformFile)
          ?Image.file(
            File(widget.pathImage.path),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
            fit: BoxFit.contain,
          )
          :Image.network(
            widget.pathImage,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - AppBar().preferredSize.height,
            fit: BoxFit.contain,
          )
      ),
    );
    
  }



  Future<bool> _onBackPressed(String msg) async {
    return await showDialog(
      context: context,
      builder: (context) =>  AlertDialog(
        title:  Text('Estas seguro?'),
        content:  Container(
          height: MediaQuery.of(context).size.height * 0.04,
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(msg)
        ),
        actions: <Widget>[
           GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
              child: Text("YES"),
            ),
          ),
           SizedBox(height: MediaQuery.of(context).size.height * 0.016),
           GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child:  Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
              child: Text("NO"),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),
        ],
      ),
    ) ?? false;
  }
}