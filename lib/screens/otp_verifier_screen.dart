import 'package:ecard_app/components/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../utils/resources/strings/strings.dart';

class OtpVerifier extends StatefulWidget {
  const OtpVerifier({super.key});

  @override
  State<StatefulWidget> createState() => OtpVerifierState();
}

class OtpVerifierState extends State<OtpVerifier> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Container(
            color: Theme.of(context).highlightColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeaderBoldWidget(
                    text: Headlines.verifyOtp,
                    color: Theme.of(context).indicatorColor,
                    size: '24.0'),
                const SizedBox(height: 30,),
                OtpTextField(
                  numberOfFields: 6,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  showFieldAsBox: true,
                  borderColor: Theme.of(context).primaryColor,
                  onCodeChanged: (String code) {},
                  onSubmit: (String verificationCode) {},
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
