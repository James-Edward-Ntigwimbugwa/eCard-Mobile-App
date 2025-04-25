import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/custom_widgets.dart';
import '../utils/resources/strings/strings.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ForgetPasswordPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
        backgroundColor: Theme.of(context).highlightColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            HeaderBoldWidget(
                                text: "We got you Covered",
                                color: Theme.of(context).primaryColor,
                                size: '32'),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: HeaderCenterWidget(
                                  text: Texts.forgetBanner,
                                  color: Theme.of(context).hintColor,
                                  size: '16'),
                            ),
                            SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Stack(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12.0, bottom: 24),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            height: 00,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: const BorderRadius
                                                    .only(
                                                    topLeft:
                                                        Radius.circular(200),
                                                    bottomLeft:
                                                        Radius.circular(200))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Form(
                                      key: _formKey,
                                      autovalidateMode: AutovalidateMode
                                          .onUserInteraction, // Auto-validate on user interaction
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                'valid email',
                                                style: GoogleFonts.aBeeZee(
                                                    textStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              )),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 12.0, bottom: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                    onTap: () =>
                                                        Navigator.pushNamed(
                                                            context, '/login'),
                                                    child: HeaderCenterWidget(
                                                        text: " Back to login?",
                                                        color: Theme.of(context)
                                                            .canvasColor,
                                                        size: '14')),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/dashboard');
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0, bottom: 50),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 50),
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4.0),
                                                            child: Icon(
                                                              CupertinoIcons
                                                                  .mail_solid,
                                                              color: Theme.of(
                                                                      context)
                                                                  .highlightColor,
                                                              size: 22,
                                                            ),
                                                          ),
                                                          HeaderCenterWidget(
                                                              text: 'Send to Email'
                                                                  .toUpperCase(),
                                                              color: Theme.of(
                                                                      context)
                                                                  .highlightColor,
                                                              size: '14')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ]),
                    ),
                  ))),
        ));
  }
}
