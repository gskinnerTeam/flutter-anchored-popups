import 'package:anchored_popups/anchored_popup_region.dart';
import 'package:anchored_popups/anchored_popups.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnchoredPopups(
      child: MaterialApp(
        home: PopupTests(),
      ),
    );
  }
}

class PopupTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: AnchoredPopUpRegion(
                anchor: Alignment.centerLeft,
                popAnchor: Alignment.centerRight,
                popChild: Card(child: Text("centerLeft to centerRight")),
                child: Container(width: 50, height: 50, child: Placeholder())),
          ),
          Center(
            child: SeparatedColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              separatorBuilder: () => SizedBox(height: 10),
              children: [
                Text("Hover over the boxes to show different behaviors."),
                AnchoredPopUpRegion(
                  anchor: Alignment.bottomLeft,
                  popAnchor: Alignment.bottomRight,
                  popChild: Card(child: Text("BottomLeft to BottomRight")),
                  child: Container(width: 50, height: 50, child: Placeholder()),
                ),

                AnchoredPopUpRegion(
                    anchor: Alignment.center,
                    popAnchor: Alignment.center,
                    popChild: Card(child: Text("Center to Center")),
                    child: Container(width: 50, height: 50, child: Placeholder())),

                /// Example of a card that, when clicked shows a form.
                AnchoredPopUpRegion(
                  mode: PopUpMode.clickToToggle,
                  anchor: Alignment.centerRight,
                  popAnchor: Alignment.centerLeft,
                  // This is what is shown when the popup is opened:
                  popChild: Card(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("CenterRight to CenterLeft"),
                      TextButton(
                          onPressed: () {
                            AnchoredPopups.of(context).hide();
                          },
                          child: Text("Close Popup"))
                    ],
                  )),
                  // The region that will activate the popup
                  child: Container(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Click me for more info..."),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
