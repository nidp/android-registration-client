import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:registration_client/model/process.dart';
import 'package:registration_client/pigeon/biometrics_pigeon.dart';
import 'package:registration_client/pigeon/common_details_pigeon.dart';
import 'package:registration_client/platform_android/machine_key_impl.dart';
import 'package:registration_client/platform_spi/machine_key.dart';
import 'package:registration_client/platform_spi/packet_service.dart';
import 'package:registration_client/ui/process_ui/new_process.dart';

class GlobalProvider with ChangeNotifier {
  final MachineKey machineKey = MachineKey();

  final PacketService packetService = PacketService();

  //Variables
  int _currentIndex = 0;
  String _name = "";
  String _centerId = "";
  String _centerName = "";
  String _machineName = "";
  final formKey = GlobalKey<FormState>();

  Process? _currentProcess;
  Map<String?, String?> _machineDetails = {};

  int _newProcessTabIndex = 0;
  int _htmlBoxTabIndex = 0;

  List<String> _chosenLang = ["English"];
  Map<String, bool> _languageMap = {
    'English': true,
    'Arabic': false,
    'French': false,
  };
  Map<String, String> _thresholdValuesMap = {
    'mosip.registration.leftslap_fingerprint_threshold': '0',
    'mosip.registration.rightslap_fingerprint_threshold': '0',
    'mosip.registration.thumbs_fingerprint_threshold': '0',
    'mosip.registration.iris_threshold': '0',
    'mosip.registration.face_threshold': '0',
  };
  Map<String, dynamic> _fieldDisplayValues = {};

  Map<String, dynamic> _fieldInputValue = {};

  Map<String, bool> _mvelValues = {};

  Map<int, String> _hierarchyValues = {};
  Map<String, List<Uint8List?>> _scannedPages = {};

  String _regId = "";
  String _ageGroup = "";

  //GettersSetters
  setScannedPages(String field, List<Uint8List?> value) {
    _scannedPages[field] = value;

    notifyListeners();
  }

  Map<String, List<Uint8List?>> get scannedPages => _scannedPages;

  String get ageGroup => this._ageGroup;

  set ageGroup(String value) {
    this._ageGroup = value;
    notifyListeners();
  }

  int get currentIndex => _currentIndex;
  String get name => _name;
  String get centerId => _centerId;
  String get centerName => _centerName;
  String get machineName => _machineName;
  Map<String?, String?> get machineDetails => _machineDetails;
  String get regId => _regId;

  Map<String, bool> get mvelValues => _mvelValues;
  Map<int, String> get hierarchyValues => _hierarchyValues;

  setRegId(String value) {
    _regId = value;
    notifyListeners();
  }

  setMvelValues(String field, bool value) {
    _mvelValues[field] = value;
    notifyListeners();
  }

  setHierarchyValues(int hierarchyLevel, String value) {
    _hierarchyValues[hierarchyLevel] = value;
    notifyListeners();
  }

  removeKeysFromHierarchy(int hierarchyLevel) {
    hierarchyValues.removeWhere((key, value) => key > hierarchyLevel);
    notifyListeners();
  }

  Process? get currentProcess => _currentProcess;

  Map<String, bool> get languageMap => _languageMap;
  Map<String, String> get thresholdValuesMap => _thresholdValuesMap;
  List<String> get chosenLang => _chosenLang;

  set chosenLang(List<String> value) => _chosenLang = value;

  set languageMap(Map<String, bool> value) => _languageMap = value;
  set thresholdValuesMap(Map<String, String> value) =>
      _thresholdValuesMap = value;

  set currentProcess(Process? value) {
    _currentProcess = value;
    notifyListeners();
  }

  int get newProcessTabIndex => _newProcessTabIndex;

  set newProcessTabIndex(int value) {
    _newProcessTabIndex = value;
    notifyListeners();
  }

  int get htmlBoxTabIndex => _htmlBoxTabIndex;

  set htmlBoxTabIndex(int value) {
    _htmlBoxTabIndex = value;
    notifyListeners();
  }

  Map<String, dynamic> get fieldDisplayValues => _fieldDisplayValues;

  set fieldDisplayValues(Map<String, dynamic> value) {
    _fieldDisplayValues = value;
    notifyListeners();
  }

  Map<String, dynamic> get fieldInputValue => _fieldInputValue;

  set fieldInputValue(Map<String, dynamic> value) {
    _fieldInputValue = value;
    notifyListeners();
  }

  set mvelValues(Map<String, bool> value) {
    _mvelValues = value;
    notifyListeners();
  }

  set hierarchyValues(Map<int, String> value) {
    _hierarchyValues = value;
    notifyListeners();
  }

  //Functions

  setCurrentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  setName(String value) {
    _name = value;
    notifyListeners();
  }

  setCenterId(String value) {
    _centerId = value;
    notifyListeners();
  }

  setCenterName(String value) {
    _centerName = value;
    notifyListeners();
  }

  setMachineName(String value) {
    _machineName = value;

    notifyListeners();
  }

  setMachineDetails() async {
    final machine = await machineKey.getMachineKeys();

    if (machine.errorCode != null) {
      _machineDetails.addAll({});
    } else {
      _machineDetails = machine.map;
      _machineName = _machineDetails["name"]!;
    }

    notifyListeners();
  }

  addRemoveLang(String key, bool value) {
    for (int i = 0; i < languageMap.length; i++) {
      if (languageMap.entries.elementAt(i).key == key) {
        languageMap["${key}"] = value;

        if (value == true) {
          chosenLang.add(key);
        } else {
          for (var e in chosenLang) {
            if (e == key) {
              chosenLang.remove(e);
              break;
            }
          }
        }

        notifyListeners();
        break;
      }
    }
  }

  setInputMapValue(String key, dynamic value, Map<String, dynamic> commonMap) {
    commonMap[key] = value;
    notifyListeners();
  }

  setLanguageSpecificValue(String key, String value, String language,
      Map<String, dynamic> commonMap) {
    if (!commonMap.containsKey(key)) {
      commonMap[key] = <String, String>{language: value};
    } else {
      commonMap[key][language] = value;
    }

    notifyListeners();
  }

  removeFieldFromMap(String key, Map<String, dynamic> commonMap) {
    commonMap.remove(key);
    notifyListeners();
  }

  clearMapValue(Map<String, dynamic> commonMap) {
    commonMap = {};
    notifyListeners();
  }

  getThresholdValues() async {
    for (var e in thresholdValuesMap.keys) {
      thresholdValuesMap[e] = await BiometricsApi().getThresholdValue(e);
    }
  }

  chooseLanguage(Map<String, String> label) {
    String x = '';
    for (var i in chosenLang) {
      if (i == "English") {
        x = x + label["eng"]! + "/";
      }
      if (i == "Arabic") {
        x = x + label["ara"]! + "/";
      }
      if (i == "French") {
        x = x + label["fra"]! + "/";
      }
    }
    x = x.substring(0, x.length - 1);
    return x;
  }

  langToCode(String lang) {
    if (lang == "English") {
      return "eng";
    }
    if (lang == "Arabic") {
      return "ara";
    }
    if (lang == "French") {
      return "fra";
    }
  }

  fieldValues(Process process) {
    process.screens!.forEach((screen) {
      screen!.fields!.forEach((field) async {
        if (field!.fieldType == "dynamic") {
          fieldDisplayValues[field.id!] =
              await CommonDetailsApi().getFieldValues(field.id!, "eng");
        }
        if (field.templateName != null) {
          List values = List.empty(growable: true);
          chosenLang.forEach((lang) async {
            values.add(
              await CommonDetailsApi().getTemplateContent(
                field.templateName!,
                langToCode(lang),
              ),
            );
          });
          fieldDisplayValues[field.id!] = values;
        }
      });
    });
  }

  getRegCenterName(String regCenterId, String langCode) async {
    String regCenterName =
        await machineKey.getCenterName(regCenterId, langCode);

    _centerName = regCenterName;
    notifyListeners();
  }

  syncPacket(String packetId) async {
    await packetService.packetSync(packetId);
    log("provider sync packet Sucess");
  }

  uploadPacket(String packetId) async {
    await packetService.packetUpload(packetId);
    log("provider upload packet Sucess");
  }

  clearMap() {
    _fieldInputValue = {};
    _fieldInputValue = {};
    _fieldInputValue = {};
    _fieldDisplayValues = {};
    log(_fieldInputValue.toString());
    notifyListeners();
  }
}
