import 'dart:convert';
import 'dart:io';
import 'package:bird_cam/loading_animation.dart';
import 'package:bird_cam/visualization.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:bird_cam/bird.dart';
import 'package:bird_cam/database.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;

String url = "http://b962-34-123-250-26.ngrok.io/classify";

void main() {
  runApp(BirdCam());
}

class BirdCam extends StatelessWidget {
  const BirdCam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BirdCam',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        fontFamily: "SF-Pro-Display"
      ),
      home: Scaffold(body:  HomeCamera()),
    );
  }
}

class HomeCamera extends StatefulWidget {
  const HomeCamera({Key? key}) : super(key: key);

  @override
  State<HomeCamera> createState() => _HomeCameraState();
}

class _HomeCameraState extends State<HomeCamera> {
  @override
  Widget build(BuildContext context) {
    return CameraCamera(onFile: (file) {
      showBarModalBottomSheet(
        context: context,
        builder: (context) => Results(
          file: file,
        ),
      );
    });
  }
}

class Results extends StatelessWidget {
  // final Bird bird;
  Results({Key? key, required this.file}) : super(key: key);
  File file;
  Bird? b;
  bool loading = true;

  final List<String> titles = [
    "Habitat",
    "Diet",
    "Lifespan",
    "Family",
    "Interesting Fact"
  ];
  final List<IconData> leadingIcons = [
    Icons.home_rounded,
    Icons.food_bank,
    Icons.health_and_safety,
    Icons.groups,
    Icons.favorite
  ];

  Widget loadingWidget() {
    return Center(
      child: SizedBox(
        // height: 300,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: [
            LoadingAnimation(isPaused: false),
            const SizedBox(
              height: 10,
            ),
            const Text("Please wait. Running our CNN model...",
                style: TextStyle(fontSize: 16))
          ],
        ),
      ),
    );
  }

  Widget resultContent(double screenHeight, List<String?> bDetails, context, Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4), BlendMode.dstATop),
                fit: BoxFit.cover,
                image: AssetImage(
                  b!.image,
                ),
              )),
          height: screenHeight * 0.3,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b?.name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(b?.scientificName ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ),
        ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Details",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Visualization(urls: result,)));
                },
                child: Text("More info for geeks",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54)),
              ),
                      
            ],
          ),
        ),
        //       SizedBox(height: 15),
        Expanded(
            child: ListTileTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          iconColor: Colors.red,
          textColor: Colors.brown.shade800,
          tileColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          style: ListTileStyle.list,
          dense: true,
          child: ListView.builder(
            itemCount: 5,
            itemBuilder: (_, index) => Card(
              color: Colors.white,
              elevation: 1.0,
              margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade700,
                  child: IconButton(
                    icon: Icon(leadingIcons[index], color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                title: Text(
                  titles[index],
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle:
                    Text(bDetails[index] ?? "", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ))
      ],
    );
  }


  Future<Map<String,dynamic>?> getData(File file) async {
    Map<String,dynamic>? _result;
    print('uploading data');
      var uri = Uri.parse(url);
      var request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      try{
      var res = await request.send();
      _result= jsonDecode(await res.stream.bytesToString());
      print(_result);
      }catch(e){
        print(e);
        return null;
      }
      return _result;
    //   return response.data['result'] as int;
    // } catch (e) {
    //   print(e);
    //   return -3;
    // }
  }

  @override
   Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return FutureBuilder(
        future: getData(
            file), // the function to get your data from firebase or firestore
        builder: (BuildContext context, AsyncSnapshot snap) {
          if (!snap.hasData) {
            return loadingWidget();
          } else {
            int result =int.parse( snap.data["result"] as String);
            if (result < 0) {
              return const Center(
                child: Text("No bird found", style: TextStyle(fontSize: 20)),
              );
            } else {
              b = birds.firstWhere((element) => element.id == result);
              final List<String?> bDetails = [
                b?.habitat,
                b?.diet,
                b?.lifespan,
                b?.lifespan,
                b?.other
              ];
              return resultContent(screenHeight, bDetails, context, snap.data);
            }
          }
        });
  }
}
