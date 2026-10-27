import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:trabalhoddm/api/api_service.dart';
import 'package:trabalhoddm/api/feriado.dart';

void main() {
  group('Feriado', () {
    test('converte entre JSON e mapa SQLite', () {
      final Feriado feriado = Feriado.fromJson(<String, dynamic>{
        'date': '2026-01-01',
        'localName': 'Confraternização Universal',
        'name': 'New Year',
        'countryCode': 'BR',
        'global': true,
        'counties': null,
        'types': <String>['Public'],
      });

      final Feriado recuperado = Feriado.fromMap(feriado.toMap());
      expect(recuperado.date, DateTime(2026, 1, 1));
      expect(recuperado.localName, 'Confraternização Universal');
      expect(recuperado.global, isTrue);
      expect(recuperado.types, <String>['Public']);
    });

    test('identifica feriado em até dois dias da entrega', () {
      final Feriado feriado = Feriado(
        date: DateTime(2026, 4, 21),
        localName: 'Tiradentes',
        name: 'Tiradentes',
        countryCode: 'BR',
        global: true,
      );

      expect(
        feriadoProximo(DateTime(2026, 4, 23), <Feriado>[feriado]),
        same(feriado),
      );
      expect(feriadoProximo(DateTime(2026, 4, 24), <Feriado>[feriado]), isNull);
    });
  });

  test('consulta dois anos e descarta feriados não nacionais', () async {
    final ApiService api = ApiService(
      client: MockClient((http.Request request) async {
        final bool anoAtual = request.url.path.contains('/2026/');
        return http.Response(
          jsonEncode(<Map<String, Object>>[
            <String, Object>{
              'date': anoAtual ? '2026-04-21' : '2027-04-21',
              'localName': 'Feriado nacional',
              'name': 'National holiday',
              'countryCode': 'BR',
              'global': true,
              'counties': <String>[],
              'types': <String>['Public'],
            },
            <String, Object>{
              'date': anoAtual ? '2026-07-09' : '2027-07-09',
              'localName': 'Feriado estadual',
              'name': 'State holiday',
              'countryCode': 'BR',
              'global': false,
              'counties': <String>['BR-SP'],
              'types': <String>['Public'],
            },
          ]),
          200,
        );
      }),
    );

    final List<Feriado> feriados = await api.buscarFeriados(ano: 2026);
    expect(feriados, hasLength(2));
    expect(feriados.every((Feriado feriado) => feriado.global), isTrue);
    expect(feriados.map((Feriado feriado) => feriado.date.year), <int>[
      2026,
      2027,
    ]);
  });
}
