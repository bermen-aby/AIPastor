class ServerData {
  //final String title;
  final bool mandatoryUpdate;
  final String? storeVersion;
  final String? title;
  final String? text;
  final String? image;

  ServerData({
    required this.mandatoryUpdate,
    this.storeVersion,
    this.title,
    this.text,
    this.image,
  });

  factory ServerData.fromJson(Map<String, dynamic> json) {
    return ServerData(
      title: json['title']['rendered'],
      text: json['content']['rendered'],
      mandatoryUpdate: json['acf']['maj_importante'],
      storeVersion: json['acf']['store_version'],
      //image: ,
    );
  }
}
