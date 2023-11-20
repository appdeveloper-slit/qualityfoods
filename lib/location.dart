import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:qf/values/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'contact_us.dart';
import 'globalurls.dart';
import 'home_page.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';

String? sLocation, sLatitude, sLongitude;
String? sUserid, lat,lng;
late BuildContext ctx;

class MyLocation extends StatefulWidget {
  final Gmapkey;
  final Stype;
  final skey;

  const MyLocation({super.key, this.Stype, this.skey, this.Gmapkey});


  @override
  State<MyLocation> createState() {
    return MyLocationState();
  }
}

class MyLocationState extends State<MyLocation> {
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  late StreamSubscription<Position> positionStream;
  bool click = false;
  AwesomeDialog? dialog;
 var mapkey;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sUserid = sp.getString('userid') ?? "";

      // widget.Stype == 'home'
      //     ? sLocation = null
      //     : sLocation != null
      //     ? updateLocation(sLatitude, sLongitude)
      //     : null;
    });
  }

  @override
  void initState() {
    Geolocator.requestPermission();
    print('${mapkey}+Mapkey');
    getGMapKey();
    // getLocations();
    getSession();
    super.initState();
  }

  void getGMapKey() async {

    var dio = Dio();
    var formData = FormData.fromMap({
      // 'user_id' : '2'
    });
    final response = await dio.post(GMapDataPageUrl(), data: formData);
    var res = json.decode(response.data);
    mapkey = res['google_map_key'];
    print(res);
    print(mapkey);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('Gmapkey', res["google_map_key"].toString());
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(Dim().d32),
        child: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 70,
                ),
                SvgPicture.asset('assets/img/location2.svg',height: 230),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Location permission is off',
                  style: Sty().largeText.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xff065197),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Dim().d12,),
                Text(
                  'We need your location to find the nearest store & provide you a seamless delivery experience.',textAlign: TextAlign.center,
                  style: Sty().largeText.copyWith(
                      color: Clr().black,
                      fontWeight: FontWeight.w400,
                      fontSize: 14),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: Text(
                //     "We'll need your location to give you the best possible eye contact matching experience",
                //     textAlign: TextAlign.center,
                //     style: Sty().smallText.copyWith(
                //         height: 1.5, fontSize: 14, fontWeight: FontWeight.w400),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 45,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        end: Alignment(0.0, 0.4),
                        begin: Alignment(0.0, -1),
                        colors: [Color(0xFF065197), Color(0xFF337ec4)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.transparent,
                        onSurface: Colors.transparent,
                        shadowColor: Colors.transparent,
                        //make color or elevated button transparent
                      ),
                      onPressed: ()  {
                        permissionHandle();
                      },
                      child: Center(
                        child: Text(
                          'Enable Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    )),
                SizedBox(
                  height: Dim().d28,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 45,
                  child: ElevatedButton(
                      onPressed: () {
                        STM().redirect2page(ctx, CustomSearchScaffold(mapkey, 'home'));
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Clr().white,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Clr().primaryColor),
                              borderRadius: BorderRadius.circular(45))),
                      child: Text(
                        'Enter Location Manually',
                        style: Sty().largeText.copyWith(
                            color: Clr().black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      )),
                ),
                SizedBox(height: 28,),
                // Container(
                //     width: MediaQuery.of(context).size.width * 0.6,
                //     height: 45,
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         end: Alignment(0.0, 0.4),
                //         begin: Alignment(0.0, -1),
                //         colors: [Color(0xFF065197), Color(0xFF337ec4)],
                //       ),
                //       borderRadius: BorderRadius.circular(25),
                //     ),
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         elevation: 0,
                //         primary: Colors.transparent,
                //         onSurface: Colors.transparent,
                //         shadowColor: Colors.transparent,
                //         //make color or elevated button transparent
                //       ),
                //       onPressed: ()  {
                //         STM().redirect2page(context, LocationNotFound());
                //       },
                //       child: Center(
                //         child: Text(
                //           'Location Not Found',
                //           style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 17,
                //               fontWeight: FontWeight.w400),
                //         ),
                //       ),
                //     )),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> permissionHandle() async {
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      getLocation();
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      STM().displayToast('Location permission is required');
      await Geolocator.openAppSettings();
    }
  }

  // getLocation
  getLocation() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.requestPermission();
    dialog = STM().loadingDialog(ctx, 'Fetch location');
    dialog!.show();
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position)  {
      setState(()  {
        STM().displayToast('Current location is selected');
        sp.setString('lat', position.latitude.toString());
        sp.setString('lng', position.longitude.toString());
        dialog!.dismiss();
        STM().finishAffinity(ctx, HomeScreen());
      });
    }).catchError((e){
      dialog!.dismiss();
    });
  }

}

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  final String sMapKey;
  final stype;

  CustomSearchScaffold(this.sMapKey, this.stype, {Key? key})
      : super(
    key: key,
    apiKey: sMapKey,
    sessionToken: const Uuid().v4(),
    language: 'en',
    //components: [Component(Component.country, 'in')],

  );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffF16624),
        title: AppBarPlacesAutoCompleteTextField(
          cursorColor: Clr().primaryColor,
          textStyle: Sty().mediumText,
          textDecoration: null,
        ),
      ),
      body: PlacesAutocompleteResult(
        onTap: (p) async {
          SharedPreferences sp = await SharedPreferences.getInstance();
          if (p == null) {
            return;
          }
          final _places = GoogleMapsPlaces(
            apiKey: widget.apiKey,
            apiHeaders: await const GoogleApiHeaders().getHeaders(),
          );
          final detail = await _places.getDetailsByPlaceId(p.placeId!);
          final geometry = detail.result.geometry!;
          setState(() {
            sLocation = p.description;
            sLatitude = geometry.location.lat.toString();
            sLongitude = geometry.location.lng.toString();
            sp.setString('lat', geometry.location.lat.toString());
            sp.setString('lng', geometry.location.lng.toString());
            // sp.setString('addresslocation', sLocation!);
            STM().finishAffinity(ctx, const HomeScreen());
          });
          STM().displayToast('Location is selected');
        },
        logo: null,
      ),
    );
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage ?? 'Unknown error')),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
    if (response.predictions.isNotEmpty) {
      setState(() {
        sLocation = response.status;
      });
    }
  }

}

class LocationNotFound extends StatefulWidget {
  const LocationNotFound({Key? key}) : super(key: key);

  @override
  State<LocationNotFound> createState() => _LocationNotFoundState();
}

class _LocationNotFoundState extends State<LocationNotFound> {
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        STM().finishAffinity(ctx, MyLocation());
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().background,
          leading: InkWell(
            onTap: () {
              STM().finishAffinity(ctx, MyLocation());
            },
            child: Icon(
              Icons.arrow_back_rounded,
              color: Clr().black,
            ),
          ),

        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(Dim().d32),
          child: Center(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 70,
                  ),
                  SvgPicture.asset('assets/img/locationNotFound.svg',height: 230),
                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                   " Sit Tight! We're Coming Soon!",
                    style: Sty().largeText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xff065197),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Dim().d12,),
                  Text(
                    ' Our team is working tirelessly to bring 15 minute deliveries to your location',textAlign: TextAlign.center,
                    style: Sty().largeText.copyWith(
                        color: Clr().black,
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16),
                  //   child: Text(
                  //     "We'll need your location to give you the best possible eye contact matching experience",
                  //     textAlign: TextAlign.center,
                  //     style: Sty().smallText.copyWith(
                  //         height: 1.5, fontSize: 14, fontWeight: FontWeight.w400),
                  //   ),
                  // ),

                  const SizedBox(
                    height: 20,
                  ),
                  Divider(),
                  SizedBox(height: 24,),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          end: Alignment(0.0, 0.4),
                          begin: Alignment(0.0, -1),
                          colors: [Color(0xFF065197), Color(0xFF337ec4)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.transparent,
                          onSurface: Colors.transparent,
                          shadowColor: Colors.transparent,
                          //make color or elevated button transparent
                        ),
                        onPressed: ()  {
                          STM().redirect2page(context, ContactUsScreen());
                        },
                        child: Center(
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
