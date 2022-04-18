import 'package:flutter/material.dart';
import 'package:flutwest/cust_widget/background_image.dart';
import 'package:flutwest/cust_widget/standard_padding.dart';

import '../model/vars.dart';

enum TextFieldFocus { none, customID, password }

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _customIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _showPasswordCancel = false;
  bool _showIDCancel = false;

  String _errorMsg = "";

  TextFieldFocus _textFieldFocus = TextFieldFocus.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const BackgroundImage(),
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
            child: StandardPadding(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StandardPadding(child: Icon(Icons.share)),
                      _getInputArea(),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _getErrorMsg() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets / 2),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: const BoxDecoration(
            color: Color.fromARGB(20, 244, 67, 54),
            border: Border(
                bottom: BorderSide(width: 1.0, color: Colors.red),
                top: BorderSide(width: 1.0, color: Colors.red))),
        child: Text(_errorMsg,
            style: const TextStyle(color: Colors.white, fontSize: 14.0)));
  }

  Widget _getInputArea() {
    return Container(
      margin: const EdgeInsets.only(top: 25.0, bottom: 65),
      padding: const EdgeInsets.symmetric(
          vertical: Vars.topBotPaddingSize,
          horizontal: Vars.standardPaddingSize),
      decoration: BoxDecoration(
          color: const Color.fromARGB(167, 27, 1, 31),
          borderRadius: BorderRadius.circular(3.0),
          border: Border.all(width: 1.0, color: Colors.grey)),
      child: Column(
        children: [
          _errorMsg.isNotEmpty ? _getErrorMsg() : const SizedBox(),
          _getTextFields(),
          _getForgotPassword(),
          _getSignInButton(),
          _getRegisterButton(),
        ],
      ),
    );
  }

  Widget _getTextFields() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize),
          child: TextField(
            maxLength: 8,
            keyboardType: TextInputType.number,
            controller: _customIDController,
            onTap: () {
              if (_textFieldFocus != TextFieldFocus.customID) {
                setState(() {
                  _textFieldFocus = TextFieldFocus.customID;
                });
              }
            },
            onChanged: (value) {
              if (_textFieldFocus == TextFieldFocus.customID) {
                if (value.isNotEmpty) {
                  if (!_showIDCancel) {
                    setState(() {
                      _showIDCancel = true;
                    });
                  }
                } else {
                  if (_showIDCancel) {
                    setState(() {
                      _showIDCancel = false;
                    });
                  }
                }
              }
            },
            decoration: InputDecoration(
                counterText: "",
                labelText: "Customer ID",
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0)),
                suffixIcon:
                    _textFieldFocus == TextFieldFocus.customID && _showIDCancel
                        ? IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            onPressed: () {
                              _customIDController.clear();
                              setState(() {
                                _showIDCancel = false;
                              });
                            },
                          )
                        : const SizedBox()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Vars.topBotPaddingSize),
          child: TextField(
            controller: _passwordController,
            obscureText: true,
            onTap: () {
              if (_textFieldFocus != TextFieldFocus.password) {
                setState(() {
                  _textFieldFocus = TextFieldFocus.password;
                });
              }

              if (_customIDController.text.length < 8) {
                if (_errorMsg.isEmpty) {
                  setState(() {
                    _errorMsg = "Customer ID is too short. Enter 8 digits.";
                  });
                }
              } else {
                if (_errorMsg.isNotEmpty) {
                  _errorMsg = "";
                }
              }
            },
            onChanged: (value) {
              if (_textFieldFocus == TextFieldFocus.password) {
                if (value.isNotEmpty) {
                  if (!_showPasswordCancel) {
                    setState(() {
                      _showPasswordCancel = true;
                    });
                  }
                } else {
                  if (_showPasswordCancel) {
                    setState(() {
                      _showPasswordCancel = false;
                    });
                  }
                }
              }
            },
            decoration: InputDecoration(
                labelText: "Customer ID",
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0)),
                suffixIcon: _textFieldFocus == TextFieldFocus.password &&
                        _showPasswordCancel
                    ? IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: () {
                          _passwordController.clear();
                          setState(() {
                            _showPasswordCancel = false;
                          });
                        },
                      )
                    : const SizedBox()),
          ),
        )
      ],
    );
  }

  Widget _getForgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Vars.heightGapBetweenWidgets * 1.5),
      child: GestureDetector(
        onTap: () {},
        child: Row(children: const [
          Text(
            "Forgot customer ID or password",
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          SizedBox(width: 3.0),
          Icon(
            Icons.arrow_right_outlined,
            color: Colors.white,
          )
        ]),
      ),
    );
  }

  Widget _getSignInButton() {
    return InkWell(
      onTap: () {
        String errMsg = "";

        if (_customIDController.text.length < 8) {
          errMsg = "Enter 8 digits";
        } else if (_passwordController.text.isEmpty) {
          errMsg = "No password entered";
        } else if (_passwordController.text.length < 6) {
          errMsg = "Your password does no meet requirements. Please try again.";
          _passwordController.clear();
        }

        if (errMsg != "") {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(errMsg),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Ok"))
                  ],
                );
              });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets / 4),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: BoxDecoration(
            color: Colors.red[700], borderRadius: BorderRadius.circular(3)),
        child: const Center(
            child: Text("Sign in",
                style: TextStyle(color: Colors.white, fontSize: 18.0))),
      ),
    );
  }

  Widget _getRegisterButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: Vars.heightGapBetweenWidgets / 4),
        padding: const EdgeInsets.symmetric(
            vertical: Vars.topBotPaddingSize,
            horizontal: Vars.standardPaddingSize),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(width: 1.0, color: Colors.red)),
        child: const Center(
          child: Text(
            "Register for online banking",
            style: TextStyle(color: Colors.black, fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
