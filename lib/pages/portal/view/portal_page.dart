import 'dart:math';

import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/portal/model/website.dart';
import 'package:acs_upb_mobile/pages/portal/service/website_provider.dart';
import 'package:acs_upb_mobile/resources/storage_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/circle_image.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/spoiler/view/spoiler.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PortalPage extends StatefulWidget {
  @override
  _PortalPageState createState() => _PortalPageState();
}

class _PortalPageState extends State<PortalPage> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      AppToast.show(S.of(context).errorCouldNotLaunchURL(url));
    }
  }

  Widget listCategory(String category, List<Website> websites) {
    if (websites == null || websites.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Spoiler(
        isOpened: true,
        leadingArrow: true,
        header: Text(
          category,
          style: Theme.of(context).textTheme.headline6,
        ),
        child: Container(
          height: min(MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height) /
                  5 + // circle
              8 + // padding
              ScreenUtil().setHeight(80), // text
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: websites
                .map((website) => Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    child: FutureBuilder<ImageProvider<dynamic>>(
                      future: Storage.getImageFromPath(website.iconPath),
                      builder: (context, snapshot) {
                        var image;
                        if (snapshot.hasData) {
                          image = snapshot.data;
                        } else {
                          image = AssetImage('assets/images/white.png');
                        }
                        return CircleImage(
                          label: website.label,
                          tooltip:
                              website.infoByLocale[Utils.getLocale(context)],
                          image: image,
                          onTap: () => _launchURL(website.link),
                        );
                      },
                    )))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<Widget> listWebsitesByCategory(List<Website> websites) {
    if (websites == null || websites.isEmpty) {
      return <Widget>[];
    }

    Map<WebsiteCategory, List<Website>> map = Map();
    websites.forEach((website) {
      var category = website.category;
      map.putIfAbsent(category, () => List<Website>());
      map[category].add(website);
    });

    return [
      WebsiteCategory.learning,
      WebsiteCategory.administrative,
      WebsiteCategory.association,
      WebsiteCategory.resource,
      WebsiteCategory.other
    ]
        .map((category) =>
            listCategory(category.toLocalizedString(context), map[category]))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    WebsiteProvider websiteProvider = Provider.of<WebsiteProvider>(context);

    return AppScaffold(
      title: S.of(context).navigationPortal,
      body: StreamBuilder<List<Website>>(
          stream: websiteProvider.getWebsites(),
          builder: (context, AsyncSnapshot<List<Website>> snapshot) {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.done) {
              var websites = snapshot.data;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: listWebsitesByCategory(websites),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }
}