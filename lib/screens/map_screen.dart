// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:snapp_sample/constants/dimens.dart';
import 'package:snapp_sample/constants/text_styles.dart';
import 'package:snapp_sample/gen/assets.gen.dart';
import 'package:snapp_sample/widgets/back_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class ButtonState {
  ButtonState._();

  static const selectOrigin = 0;
  static const selectDest = 1;
  static const reqDriver = 2;
}

GeoPoint initGeoPoint =
    GeoPoint(latitude: 35.77268811234567, longitude: 51.39465428431657);

Widget originMarker = SvgPicture.asset(
  Assets.icons.origin,
  height: 100,
  width: 40,
);
Widget destMarker = SvgPicture.asset(
  Assets.icons.destination,
  height: 100,
  width: 40,
);

class _MapScreenState extends State<MapScreen> {
  List states = [ButtonState.selectOrigin];
  List<GeoPoint> geoPoints = [];
  String distance = 'در حال محاسبه فاصله...';
  String originAddress = 'آدرس مبدأ...';
  String destAddress = 'آدرس مقصد...';
  Widget markerIcon = originMarker;
  bool isBackButtonVisible = false;

  MapController mapController = MapController.withPosition(
    initPosition: initGeoPoint,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          // M A P
          SizedBox.expand(
            child: OSMFlutter(
              controller: mapController,
              osmOption: OSMOption(
                isPicker: true,
                markerOption: MarkerOption(
                  advancedPickerMarker: MarkerIcon(
                    iconWidget: markerIcon,
                  ),
                ),
                zoomOption: ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 8,
                  maxZoomLevel: 18,
                  stepZoom: 1,
                ),
              ),
              mapIsLoading: SpinKitCircle(color: Colors.black),
              // onMapIsReady: (ready) {
              //   _addCustomMarker();
              // },
            ),
          ),

          // B U T T O N
          currentButton(),

          // B A C K   B U T T O N
          Visibility(
            visible: isBackButtonVisible,
            child: SnappBackButton(
              onPressed: () {
                setState(() {
                  switch (states.last) {
                    case ButtonState.selectOrigin:
                      break;
                    case ButtonState.selectDest:
                      isBackButtonVisible = false;

                      mapController.removeMarker(geoPoints.first);
                      geoPoints.removeLast();
                      markerIcon = originMarker;
                      break;
                    case ButtonState.reqDriver:
                      isBackButtonVisible = true;

                      mapController.advancedPositionPicker();
                      mapController.removeMarker(geoPoints.last);
                      geoPoints.removeLast();
                      markerIcon = destMarker;
                      break;
                  }

                  mapController.init();

                  if (states.length > 1) {
                    states.removeLast();
                  }
                });
              },
            ),
          ),
        ],
      ),
    ));
  }

  Widget currentButton() {
    Widget currentButton = origin();

    switch (states.last) {
      case ButtonState.selectOrigin:
        currentButton = origin();
        break;
      case ButtonState.selectDest:
        currentButton = dest();
        break;
      case ButtonState.reqDriver:
        currentButton = reqDriver();
        break;
    }

    return currentButton;
  }

  Widget origin() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: () async {
            GeoPoint originGeoPoint =
                await mapController.getCurrentPositionAdvancedPositionPicker();
            geoPoints.add(originGeoPoint);

            //TODO: Delete
            log(geoPoints.length.toString(), name: 'Origin Selected');

            await mapController.addMarker(
              geoPoints.first,
              markerIcon: MarkerIcon(
                iconWidget: SvgPicture.asset(
                  Assets.icons.origin,
                  height: 40,
                ),
              ),
            );

            log(originGeoPoint.latitude.toString(), name: 'latitude');
            log(originGeoPoint.longitude.toString(), name: 'longitude');

            setState(() {
              isBackButtonVisible = true;
              states.add(ButtonState.selectDest);
              markerIcon = destMarker;
            });

            mapController.init();
          },
          child: Text(
            'انتخاب مبدأ',
            style: SnappTextStyles.button,
          ),
        ),
      ),
    );
  }

  Widget dest() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: ElevatedButton(
          onPressed: () async {
            await mapController.getCurrentPositionAdvancedPositionPicker().then(
              (destGeoPoint) {
                geoPoints.add(destGeoPoint);

                //TODO: Delete
                log(geoPoints.length.toString(), name: 'Destination Selected');
              },
            );

            mapController.cancelAdvancedPositionPicker();

            await mapController.addMarker(
              geoPoints.last,
              markerIcon: MarkerIcon(
                iconWidget: SvgPicture.asset(
                  Assets.icons.destination,
                  height: 40,
                ),
              ),
            );

            setState(() {
              states.add(ButtonState.reqDriver);
            });

            distance2point(geoPoints.first, geoPoints.last).then((distance) {
              setState(() {
                if (distance < 1000) {
                  this.distance =
                      'فاصله مبدأ تا مقصد: ${distance.toInt().toString()} متر';
                } else {
                  this.distance =
                      'فاصله مبدأ تا مقصد: ${(distance.toInt() / 1000).toStringAsFixed(1)} کلیومتر';
                }
              });
            });

            //TODO: Bug
            // getAddress();

            mapController.zoomOut();
          },
          child: Text(
            'انتخاب مقصد',
            style: SnappTextStyles.button,
          ),
        ),
      ),
    );
  }

  Widget reqDriver() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.large),
        child: Column(
          children: [
            // Origin Address
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(Dimens.medium),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.medium),
                  child: Text(
                    textDirection: TextDirection.rtl,
                    originAddress,
                    style: SnappTextStyles.details,
                  ),
                ),
              ),
            ),

            SizedBox(height: Dimens.small),

            // Dest Address
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(Dimens.medium),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.medium),
                  child: Text(
                    textDirection: TextDirection.rtl,
                    destAddress,
                    style: SnappTextStyles.details,
                  ),
                ),
              ),
            ),

            SizedBox(height: Dimens.small),

            // Distance
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(Dimens.medium),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.medium),
                  child: Text(
                    textDirection: TextDirection.rtl,
                    distance,
                    style: SnappTextStyles.details,
                  ),
                ),
              ),
            ),
            SizedBox(height: Dimens.small),

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {},
                child: Text(
                  'درخواست راننده',
                  style: SnappTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO: There is PlatformException
  getAddress() async {
    try {
      await placemarkFromCoordinates(
        geoPoints.last.latitude,
        geoPoints.last.longitude,
        localeIdentifier: 'fa',
      ).then((List<Placemark> marksList) {
        setState(() {
          originAddress =
              '${marksList.first.locality} ,${marksList.first.thoroughfare}, ${marksList[2].name}';
        });
      });

      await placemarkFromCoordinates(
        geoPoints.first.latitude,
        geoPoints.first.longitude,
        localeIdentifier: 'fa',
      ).then((List<Placemark> marksList) {
        setState(() {
          originAddress =
              '${marksList.first.locality} ,${marksList.first.thoroughfare}, ${marksList[2].name}';
        });
      });
    } catch (e) {
      setState(() {
        originAddress = 'آدرس یافت نشد';
        destAddress = 'آدرس یافت نشد';
      });
    }
  }
}
