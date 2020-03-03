import 'package:acs_upb_mobile/authentication/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/navigation/routes.dart';
import 'package:acs_upb_mobile/resources/banner.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/form/form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignUpView extends StatefulWidget {
  static const String routeName = '/signup';

  SignUpView();

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  List<FormItem> formItems;

  List<FormItem> _buildFormItems() {
    // Only build them once to avoid the cursor staying everywhere
    if (formItems != null) {
      return formItems;
    }

    TextEditingController passwordController = TextEditingController();
    AuthProvider authProvider = Provider.of(context);

    formItems = <FormItem>[
      FormItem(
        label: S.of(context).labelEmail,
        hint: S.of(context).hintEmail,
        check: (email) => authProvider.canSignUpWithEmail(email: email),
      ),
      FormItem(
        label: S.of(context).labelPassword,
        hint: S.of(context).hintPassword,
        controller: passwordController,
        obscureText: true,
        check: (password) =>
            authProvider.isStrongPassword(password: password),
      ),
      FormItem(
        label: S.of(context).labelConfirmPassword,
        hint: S.of(context).hintPassword,
        obscureText: true,
        check: (password) async {
          return password == passwordController.text;
        },
      ),
      FormItem(
        label: S.of(context).labelFirstName,
        hint: S.of(context).hintFirstName,
      ),
      FormItem(
        label: S.of(context).labelLastName,
        hint: S.of(context).hintLastName,
      ),
      FormItem(
        label: S.of(context).labelGroup,
        hint: S.of(context).hintGroup,
        check: (group) async {
          return group.length == 5 && group[0] == '3';
        },
      ),
    ];
    return formItems;
  }


  AppForm _buildForm(BuildContext context) {
    AuthProvider authProvider = Provider.of(context);

    return AppForm(
      title: S.of(context).actionSignUp,
      items: _buildFormItems(),
      onSubmitted: (Map<String, String> fields) async {
        var user = await authProvider.signUp(
          info: fields,
          context: context,
        );
        if (user != null) {
          // Remove all routes below and push home page
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 750, height: 1334, allowFontScaling: false);
    AppForm signUpForm = _buildForm(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: FractionalOffset.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 5.0, right: 10.0),
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 1.4,
                    maxHeight: MediaQuery.of(context).size.height -
                        ScreenUtil().setHeight(380),
                  ),
                  child: Image.asset(
                      "assets/illustrations/undraw_personal_information.png")),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, bottom: 8.0),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil.screenWidth > ScreenUtil.screenHeight
                          ? MediaQuery.of(context).size.height / 2
                          : MediaQuery.of(context).size.width / 1.62,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          UniBanner(),
                        ],
                      ),
                    ),
                    Expanded(child: signUpForm),
                    SizedBox(height: ScreenUtil().setHeight(40)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: AppButton(
                            text: S.of(context).buttonCancel,
                            onTap: () async {
                              return Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(30)),
                        Expanded(
                          child: AppButton(
                            color: Theme.of(context).accentColor,
                            text: S.of(context).actionSignUp,
                            onTap: () => signUpForm.submit(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(50),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}