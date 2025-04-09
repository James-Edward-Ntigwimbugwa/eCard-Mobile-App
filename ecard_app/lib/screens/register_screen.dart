import 'package:ecard_app/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../components/custom_widgets.dart';
import '../utils/resources/images/images.dart';
import '../utils/resources/strings/strings.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final TextEditingController _firstNameController = TextEditingController();
  // final TextEditingController _middleNameController = TextEditingController();
  // final TextEditingController _lastNameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _phoneNumberController = TextEditingController();
  // final TextEditingController _bioController = TextEditingController();
  // final TextEditingController _companyTitleController = TextEditingController();
  // final TextEditingController _jobTitleController = TextEditingController();
  // final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool obscure = true;
  String? _password;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: double.maxFinite,
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(50))),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 2.8,
                  width: double.infinity,
                  child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 50.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              HeaderBoldWidget(
                                  text: Headlines.registerHeader,
                                  color: Theme.of(context).highlightColor,
                                  size: "24.0"),
                              const SizedBox(
                                width: 100,
                              ),
                              ClipOval(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          left: -10,
                                          child: Image.asset(
                                            Images.splashImage,
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 0.0, top: 20.0),
                            child: NormalHeaderWidget(
                                text: Headlines.registerDesc,
                                color: Theme.of(context).highlightColor,
                                size: "18.0"),
                          ),
                        ],
                      )),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 1.9,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _firstNameController,
                                icon: Icon(Icons.person),
                                hintText: "First Name",
                                field: 'firstName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _middleNameController,
                                icon: Icon(Icons.person),
                                hintText: "Second Name",
                                field: 'secondName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _lastNameController,
                                icon: Icon(Icons.person),
                                hintText: "Last Name",
                                field: 'lastName',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _emailController,
                                icon: Icon(Icons.email),
                                hintText: "Email",
                                field: 'email',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _phoneNumberController,
                                icon: Icon(Icons.phone),
                                hintText: "Phone number",
                                field: 'phoneNumber',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _bioController,
                                icon: Icon(FontAwesomeIcons.borderNone),
                                hintText: "Your bio (Optional)",
                                field: 'bio',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _companyTitleController,
                                icon: Icon(CupertinoIcons.house_alt_fill),
                                hintText: "Company Title",
                                field: 'companyTitle',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _jobTitleController,
                                icon: Icon(FontAwesomeIcons.mailchimp),
                                hintText: "job Title",
                                field: 'jobTitle',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                // controller: _usernameController,
                                icon: Icon(Icons.contact_mail),
                                hintText: "username",
                                field: 'username',
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                onSaved: (value) => _password = value,
                                autofocus: false,
                                controller: _passwordController,
                                validator: (value) => value!.isEmpty
                                    ? "Please Enter password"
                                    : null,
                                obscureText: obscure,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                  fontWeight: FontWeight.w500,
                                  backgroundColor: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(CupertinoIcons.padlock_solid),
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      // Update state for icon and password visibility
                                      setState(() {
                                        obscure = !obscure;
                                      });
                                    },
                                    icon: Icon(obscure
                                        ? CupertinoIcons.eye_slash_fill
                                        : CupertinoIcons.eye_fill),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    NormalHeaderWidget(
                                        text: Texts.haveAccount,
                                        color: Theme.of(context).primaryColor,
                                        size: '18.0'),
                                    TextButton(
                                        onPressed: () => authProvider
                                            .navigateToLoginScreen(),
                                        child: Text(Texts.login))
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .primaryColor, // Set the background color to green
                  minimumSize: Size(MediaQuery.of(context).size.width / 4,
                      48.0), // Set width to half of the screen width and height to 48.0
                  padding: EdgeInsets.symmetric(
                      vertical: 12.0), // Adjust padding for better appearance
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.rectangle,
                  ),
                  child: SizedBox(
                    height: 30.0,
                    width: MediaQuery.of(context).size.width /
                        4.9, // Reduce width further if needed
                    child: Center(
                      // Center the child widget
                      child: HeaderBoldWidget(
                        text: Texts.register,
                        color: Theme.of(context).highlightColor,
                        size: '24.0',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
