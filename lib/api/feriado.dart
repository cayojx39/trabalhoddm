import 'dart:convert';

class Feriado {
  final DateTime date;
  final String localName;
  final String name;
  final String countryCode;
  final bool global;
  final List<String>? counties;
  final List<String> types;

  const Feriado({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    required this.global,
    this.counties,
    this.types = const <String>[],
  });

  factory Feriado.fromJson(Map<String, dynamic> json) {
    final Object? rawDate = json['date'];
    if (rawDate is! String || DateTime.tryParse(rawDate) == null) {
      throw const FormatException('Data de feriado inválida.');
    }

    return Feriado(
      date: DateTime.parse(rawDate),
      localName: json['localName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      countryCode: json['countryCode'] as String? ?? '',
      global: json['global'] as bool? ?? false,
      counties: (json['counties'] as List<dynamic>?)?.cast<String>(),
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
    );
  }

  factory Feriado.fromMap(Map<String, Object?> map) {
    return Feriado(
      date: DateTime.parse(map['date']! as String),
      localName: map['local_name']! as String,
      name: map['name']! as String,
      countryCode: map['country_code']! as String,
      global: map['global'] == 1,
      counties: map['counties'] == null
          ? null
          : (jsonDecode(map['counties']! as String) as List<dynamic>).cast<String>(),
      types: (jsonDecode(map['types']! as String) as List<dynamic>).cast<String>(),
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'date': _dateOnly(date),
      'local_name': localName,
      'name': name,
      'country_code': countryCode,
      'global': global ? 1 : 0,
      'counties': counties == null ? null : jsonEncode(counties),
      'types': jsonEncode(types),
    };
  }

  static String _dateOnly(DateTime value) {
    final DateTime dateOnly = DateTime(value.year, value.month, value.day);
    return dateOnly.toIso8601String().substring(0, 10);
  }
}

Feriado? feriadoProximo(
  DateTime? data,
  Iterable<Feriado> feriados, {
  int distanciaMaximaDias = 2,
}) {
  if (data == null) {
    return null;
  }

  final DateTime dataSemHora = DateTime(data.year, data.month, data.day);
  Feriado? maisProximo;
  int? menorDistancia;

  for (final Feriado feriado in feriados) {
    final DateTime dataFeriado = DateTime(
      feriado.date.year,
      feriado.date.month,
      feriado.date.day,
    );
    final int distancia = dataSemHora.difference(dataFeriado).inDays.abs();
    if (distancia <= distanciaMaximaDias &&
        (menorDistancia == null || distancia < menorDistancia)) {
      maisProximo = feriado;
      menorDistancia = distancia;
    }
  }
  return maisProximo;
}
