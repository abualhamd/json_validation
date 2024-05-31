import 'package:dartz/dartz.dart';

typedef Schema = Map<String, Either<Type, Map<String, dynamic>>>;

bool validateJson(Map<String, dynamic> schema, Map<String, dynamic> json) {
  bool isValid = true;

  MapEntry<String, Either<Type, Map<String, dynamic>>> toSchemaEntry(
      MapEntry entry) {
    return switch (entry.value) {
      Left<Type, Map<String, dynamic>> l => MapEntry(entry.key, l),
      Right<Type, Map<String, dynamic>> r => MapEntry(entry.key, r),
      Type _ => MapEntry(entry.key, Left(entry.value)),
      Map<String, dynamic> map => MapEntry(entry.key, Right(map)),
      _ => throw Exception("No matching type"),
    };
  }

  Schema toSchema(Map map) {
    try {
      final updatedEntries = map.entries.map(toSchemaEntry);
      return {}..addEntries(updatedEntries.toList());
    } catch (e) {
      rethrow;
//       return false;
    }
  }

  final actualSchema = toSchema(schema);

  for (final key in actualSchema.keys) {
    isValid = actualSchema[key]?.fold((type) {
          // print("key: $key, json value: ${json[key]}, schema value: ${type}");
          return type == json[key].runtimeType;
        }, (map) {
          try {
            Schema updatedSchema = toSchema(map);
            return validateJson(updatedSchema, json[key]);
          } catch (e) {
            // print("error: $e");
            return false;
          }
        }) ??
        false;

    if (!isValid) {
      return false;
    }
  }
  return isValid;
}

final Map<String, dynamic> cSchema = {
  'x': int,
  'y': int,
  'z': {
    "a": int,
    "b": {"e": double}
  }
};

void main() {
  final cJson = {
    'x': 10,
    'y': 5,
    'z': {
      'a': 0,
      'b': {'e': 1.3}
    },
  };

  final isCValid = validateJson(cSchema, cJson);

  print("is c valid: $isCValid");
}
