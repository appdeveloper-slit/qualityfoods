import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:qf/appbar_gradientlook.dart';
import 'package:qf/colors.dart';

class ImageViewScreen extends StatefulWidget {
  List<String> imagesList;
  String title;

  ImageViewScreen({required this.imagesList, required this.title});

  @override
  State<ImageViewScreen> createState() =>
      ImageViewScreenState(images: imagesList, title: title);
}

List<String> imgListView = [];

List<Widget> imageSliders = [];

class ImageViewScreenState extends State<ImageViewScreen> {
  List<String> images;
  String title;

  ImageViewScreenState({required this.images, required this.title});

  int selected = 0;
  final CarouselController _controller = CarouselController();

  Widget sliderwidget() {
    return CarouselSlider(
      items: imageSliders,
      carouselController: _controller,
      options: CarouselOptions(
          autoPlay: false,
          enlargeCenterPage: false,
          // aspectRatio: 1.2,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {
              selected = index;
            });
          }),
    );
  }

  Widget dots() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 12,
      ),
      child: Wrap(
        children: imgListView.asMap().entries.map((entry) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(
              horizontal: 2,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected == entry.key ? primary() : Colors.white,
              border: Border.all(width: 2, color: primary()),
            ),
          );
        }).toList(),
      ),
    );
  }

  void setImages() {
    imgListView = [];
    for (int i = 0; i < images.length; i++) {
      imgListView.add(images[i]);
    }
    imgListView = imgListView;
    print(imgListView);

    setState(() {
      imgListView = imgListView;
      // print(imgListView);
      imageSliders = imgListView
          .map((item) => Container(
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      child: Stack(
                        children: <Widget>[
                          item.isNotEmpty
                              ? CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Image.asset("assets/img/logo (6).png"),
                                  imageUrl: item,
                                  // imageErrorBuilder:
                                  //     (context, exception, stackTrace) {
                                  //   return Container(child: Text("Failed to load the image"));
                                  // },
                                )
                              : Image.asset("assets/img/logo (6).png"),
                          Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child: Container(
                              // decoration: BoxDecoration(
                              //   gradient: LinearGradient(
                              //     colors: [
                              //       Color.fromARGB(0, 0, 0, 0),
                              //       Color.fromARGB(0, 0, 0, 0)
                              //     ],
                              //     begin: Alignment.bottomCenter,
                              //     end: Alignment.topCenter,
                              //   ),
                              // ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10.0),
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ))
          .toList();
    });

  }

  @override
  void initState() {
    setImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                color: Color(0xff00182E),
                fontWeight: FontWeight.w500,
                fontSize: 18)),
        flexibleSpace: barGredient(),
        elevation: 0.2,
        leading: BackButton(color: Color(0xff244D73)),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: sliderwidget()),
          dots(),
          SizedBox(
            height: 10,
          )
        ],
      )),
    );
  }
}
