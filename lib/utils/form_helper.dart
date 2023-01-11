import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class FormHelper {
  static Widget textInput(
    BuildContext context,
    Object? initialValue,
    Function onChanged, {
    bool isTextArea = false,
    bool isNumberInput = false,
    bool obscureText = false,
    Function? onValidate,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return TextFormField(
      initialValue: initialValue != null ? initialValue.toString() : "",
      decoration: fieldDecoration(
        context,
        "",
        "",
        suffixIcon: suffixIcon,
      ),
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: !isTextArea ? 1 : 3,
      keyboardType: isNumberInput ? TextInputType.number : TextInputType.text,
      onChanged: (String value) {
        // ignore: void_checks
        return onChanged(value);
      },
      validator: (value) {
        return onValidate!(value) as String;
      },
    );
  }

  static InputDecoration fieldDecoration(
    BuildContext context,
    String hintText,
    String helperText, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(6),
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  static Widget fieldLabel(String labelName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
      child: Text(
        labelName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15.0,
        ),
      ),
    );
  }

  static Widget fieldLabelValue(BuildContext context, String labelName) {
    return FormHelper.textInput(
      context,
      labelName,
      (value) => {},
      onValidate: (value) {
        return null;
      },
      //readOnly: true,
    );
  }

  static Widget saveButton(
    String buttonText,
    Function onTap, {
    String? color,
    String? textColor,
    bool? fullWidth,
  }) {
    return SizedBox(
      height: 50.0,
      width: 150,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.green,
            ),
            color: Colors.green,
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showMessage(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    Function onPressed, {
    String? button2Text,
    Function? onPressed2,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              //color: PremStyle.primary.shade900,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                //return
                onPressed();
              },
              child: Text(buttonText.toUpperCase()),
            ),
            if (button2Text != null)
              TextButton(
                onPressed: () {
                  //return
                  if (onPressed2 != null) {
                    onPressed2();
                  }
                },
                child: Text(button2Text.toUpperCase()),
              )
          ],
        );
      },
    );
  }
}
