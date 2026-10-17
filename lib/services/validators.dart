class Validators {
  static String? requiredText(String? value, {int max = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }
    if (value.trim().length > max) return 'Usa como máximo $max caracteres.';
    return null;
  }

  static String? email(String? value) {
    if (requiredText(value, max: 254) case final String error) return error;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (requiredText(value, max: 25) case final String error) return error;
    if (!RegExp(r'^\+?[\d\s()\-]{7,25}$').hasMatch(value!.trim()) ||
        value.replaceAll(RegExp(r'\D'), '').length < 7) {
      return 'Ingresa un teléfono válido (mínimo 7 dígitos).';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length < 8) return 'Usa al menos 8 caracteres.';
    if (value.length > 128) return 'Usa como máximo 128 caracteres.';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña.';
    return value == password ? null : 'Las contraseñas no coinciden.';
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa un precio.';
    if (!RegExp(r'^\d{1,7}([.,]\d{1,2})?$').hasMatch(value.trim())) {
      return 'Usa un precio entre 0 y 9999999.99, con hasta 2 decimales.';
    }
    return null;
  }

  static int priceToCents(String value) {
    final parts = value.trim().replaceAll(',', '.').split('.');
    return int.parse(parts.first) * 100 +
        (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  }

  static String? stock(String? value) {
    if (value == null || !RegExp(r'^\d{1,7}$').hasMatch(value.trim())) {
      return 'Usa un entero entre 0 y 9999999.';
    }
    return null;
  }
}
