class Data {

  final String id;
  final String input;
  final String output;


  const Data( {
    required  this.id,
    required  this.input,
    required  this.output,

  });

  factory Data.fromJson1(Map<String, dynamic> json) {
    return Data(
      id: json["id"] as String? ?? "",
      input: json["input"] as String? ?? "",
      output: json["input"] as String? ?? "",

    );
  }

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    id : json["id"] as String,
    input :  json["input"] as String,
    output :  json["output"] as String,

  );

  factory Data.fromJson(Map<String, dynamic> json) {
    return switch (json) {
    {
      "id": String id,
    "input" : String input,
    'output' : String output,

    } =>
    Data(
    id : id,
    input :  input,
    output :  output,

    ),
    _ => throw const FormatException('Failed to load data.'),
  };
  }



}