import 'package:bird_cam/loading_animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Visualization extends StatelessWidget {
  Map<String, dynamic> urls;
 
  Visualization({required this.urls, Key? key }) : super(key: key);

  Widget PhotoCard(int index, String imgurl) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Map for your image", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400)),
          Container(
            child: Image.network(imgurl))
        ]
      ),
    );
  }


  Future get_data() async {
    await Future.delayed(Duration(seconds: 5));
    return;

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Feature",
                style: TextStyle(color: Colors.brown.shade600, fontSize: 55, fontWeight: FontWeight.w700),
                ),
                Text("Maps",
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.brown.shade600, fontSize: 62, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20,),
                Expanded(
                            child: ListView.builder(
                              itemCount: 5,
                              itemBuilder: (context, index) {
                              return PhotoCard(1, urls["map"+(index+1).toString()]);
                            }),
                          )
              ],
            ),
        ),
      ),
    );
  }
}