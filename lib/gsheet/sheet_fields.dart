// ignore_for_file: avoid_classes_with_only_static_members

class DataSheetFields {
  static const String pastorUpdate = "pastorUpdate";

  static List<String> getFields() => [pastorUpdate];
}

class DataSheet {
  DataSheet({
    this.pastorUpdate,
  });

  double? pastorUpdate;

  DataSheet.fromJson(Map<String, dynamic> json)
      : pastorUpdate =
            double.tryParse(json[DataSheetFields.pastorUpdate] as String);
}

class SliderSheetFields {
  static const String id = 'ID';
  static const String title = 'Title';
  static const String imgURL = 'ImgURL';
  static const String type = 'Type';
  static const String linkFR = 'LinkFR';
  static const String linkEN = 'LinkEN';

  static List<String> getFields() => [id, imgURL, type, linkFR, linkEN];
}

class HomeSlider {
  const HomeSlider({
    this.id,
    this.title,
    this.imgURL,
    this.type,
    this.linkFR,
    this.linkEN,
  });

  final String? id;
  final String? title;
  final String? imgURL;
  final String? type;
  final String? linkFR;
  final String? linkEN;

  Map<String, dynamic> toJson() => {
        SliderSheetFields.id: id,
        SliderSheetFields.title: title,
        SliderSheetFields.imgURL: imgURL,
        SliderSheetFields.type: type,
        SliderSheetFields.linkFR: linkFR,
        SliderSheetFields.linkEN: linkEN,
      };

  HomeSlider.fromJson(Map<String, dynamic> json)
      : id = json[SliderSheetFields.id] as String? ?? '',
        title = json[SliderSheetFields.title] as String? ?? '',
        imgURL = json[SliderSheetFields.imgURL] as String? ?? '',
        type = json[SliderSheetFields.type] as String? ?? '',
        linkFR = json[SliderSheetFields.linkFR] as String? ?? '',
        linkEN = json[SliderSheetFields.linkEN] as String? ?? '';
}
