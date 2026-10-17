import 'package:flutter_test/flutter_test.dart';
import 'package:inventi/services/validators.dart';

void main() {
  test('Campos obligatorios y límites de texto', () {
    expect(Validators.requiredText('  '), isNotNull);
    expect(Validators.requiredText('Ana'), isNull);
    expect(Validators.requiredText('abcdef', max: 5), isNotNull);
  });
  test('Formato de correo y teléfono', () {
    for (final value in ['', 'ana', 'ana@', 'ana@correo', 'a b@example.com']) {
      expect(Validators.email(value), isNotNull);
    }
    expect(Validators.email(' Ana@Example.com '), isNull);
    expect(Validators.phone('+51 999 888 777'), isNull);
    for (final value in ['', '123', 'abcdefgh', '+(---)()']) {
      expect(Validators.phone(value), isNotNull);
    }
  });
  test('Contraseñas y confirmación', () {
    expect(Validators.password('1234567'), isNotNull);
    expect(Validators.password('12345678'), isNull);
    expect(Validators.confirmPassword('12345678', '87654321'), isNotNull);
    expect(Validators.confirmPassword('', ''), isNotNull);
    expect(Validators.confirmPassword('12345678', '12345678'), isNull);
  });
  test('Precio: cero, céntimos exactos, coma y punto', () {
    for (final value in ['0', '0.01', '3500', '19,90', '9999999.99']) {
      expect(Validators.price(value), isNull);
    }
    expect(Validators.priceToCents('0.29'), 29);
    expect(Validators.priceToCents('19,9'), 1990);
    expect(Validators.priceToCents('3500'), 350000);
  });
  test('Rechaza precios negativos, no finitos y no numéricos', () {
    for (final value in [
      '',
      '-1',
      'NaN',
      'Infinity',
      '1e4',
      '2.999',
      'abc',
      '10000000',
      '1,2.3',
    ]) {
      expect(Validators.price(value), isNotNull, reason: value);
    }
  });
  test('Stock: solo enteros no negativos dentro del rango', () {
    for (final value in ['0', '10', '9999999']) {
      expect(Validators.stock(value), isNull);
    }
    for (final value in ['', '-1', '1.5', '1e2', 'abc', '10000000']) {
      expect(Validators.stock(value), isNotNull);
    }
  });
}
