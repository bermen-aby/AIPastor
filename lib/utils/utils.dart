
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class Utils {
  static void showMessage(
    BuildContext context,
    String title,
    String message,
    String buttonText,
    Function onPressed, {
    bool isConfirmationDialog = false,
    String buttonText2 = "",
    Function? onPressed2,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
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
            Visibility(
              visible: isConfirmationDialog,
              child: TextButton(
                onPressed: () {
                  //return
                  onPressed2!();
                },
                child: Text(buttonText2.toUpperCase()),
              ),
            )
          ],
        );
      },
    );
  }

  static String removeDiacritics(String str) {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }

    return str;
  }
}
