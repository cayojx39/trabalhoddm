import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'feriado.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final ApiService instance = ApiService();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Feriado>> buscarFeriados({required int ano}) async {
    try {
      final List<List<Feriado>> feriadosPorAno = await Future.wait(
        <Future<List<Feriado>>>[
          _buscarFeriadosDoAno(ano),
          _buscarFeriadosDoAno(ano + 1),
        ],
      );
      final Map<String, Feriado> feriadosUnicos = <String, Feriado>{};
      for (final List<Feriado> lista in feriadosPorAno) {
        for (final Feriado feriado in lista) {
          if (feriado.global) {
            feriadosUnicos[_dateOnly(feriado.date)] = feriado;
          }
        }
      }
      return feriadosUnicos.values.toList()
        ..sort((Feriado a, Feriado b) => a.date.compareTo(b.date));
    } on ApiException {
      rethrow;
    } on http.ClientException catch (error) {
      throw ApiException('Não foi possível conectar à API de feriados: $error');
    } on TimeoutException {
      throw const ApiException('A API de feriados demorou para responder.');
    } on FormatException catch (error) {
      throw ApiException('A API retornou dados inválidos: ${error.message}');
    }
  }

  Future<List<Feriado>> _buscarFeriadosDoAno(int ano) async {
    final Uri uri = Uri.https(
      'date.nager.at',
      '/api/v3/PublicHolidays/$ano/BR',
    );
    final http.Response response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) {
      throw ApiException(
        'A API de feriados respondeu com status ${response.statusCode}.',
      );
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! List<dynamic>) {
      throw const FormatException('A resposta de feriados não é uma lista.');
    }

    return decoded.map((Object? item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Feriado com formato inválido.');
      }
      return Feriado.fromJson(item);
    }).toList();
  }

  static String _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day)
        .toIso8601String()
        .substring(0, 10);
  }
}
