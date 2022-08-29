import 'package:etrade/components/constants.dart';
import 'package:etrade/screen/AboutUs/WebView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class About {
  About({required this.title, required this.subtitle, required this.icon});
  String title;
  String subtitle;
  Icon icon;
}

class AboutScreen extends StatefulWidget {
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<About> aboutList = [
    About(
      title: "Support Mail",
      subtitle: "support@exapp.pk",
      icon: Icon(
        Icons.mail,
        color: etradeMainColor,
      ),
    ),
    About(
      title: "Contact Us",
      subtitle: "+923040636454",
      icon: Icon(
        Icons.phone,
        color: etradeMainColor,
      ),
    ),
    About(
      title: "Follow us on Facebook",
      subtitle: "facebook.com/automatingbiz",
      icon: Icon(
        Icons.facebook,
        color: etradeMainColor,
      ),
    ),
    About(
      title: "Follow us on Twitter",
      subtitle: "twitter.com/e_xapp",
      icon: Icon(
        Icons.business_center_outlined,
        color: etradeMainColor,
      ),
    ),
    About(
        title: "Follow us on LinkedIn",
        subtitle: "https://www.linkedin.com/company/exapp-pvt-ltd",
        icon: Icon(
          Icons.linked_camera_outlined,
          color: etradeMainColor,
        )),
    About(
      title: "Official Website",
      subtitle: "www.exapp.pk",
      icon: Icon(
        Icons.web,
        color: etradeMainColor,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: etradeMainColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  "images/exapp.png",
                  fit: BoxFit.fitWidth,
                  width: 180,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return MaterialButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (index > 1)
                        Get.to(WebViewScreen(link: aboutList[index].subtitle),
                            transition: Transition.rightToLeft);
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(aboutList[index].title),
                        subtitle: Text(aboutList[index].subtitle),
                        leading: aboutList[index].icon,
                      ),
                    ),
                  );
                },
                itemCount: aboutList.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(5),
                scrollDirection: Axis.vertical,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
