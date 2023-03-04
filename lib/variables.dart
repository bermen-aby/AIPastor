import 'package:ai_pastor/models/server_data.dart';
import 'package:isar/isar.dart';

bool isDarkModeVar = false;
bool maj = true; // True if there is a new version available in the store
bool isPopupActive = false; // Not used
bool firstVisitVar =
    true; // Show the tutorial for the first time opening the app
bool donationPopUpOnce = false; // turn to true after showing the popup once
late Isar isar;
ServerData serverData = ServerData(mandatoryUpdate: false);
int prompts = 0;
