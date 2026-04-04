class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните поле';
    }
    return null;
  }

  static String? email(String? value) {
    if (requiredField(value) != null) return 'Введите email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value!.trim())) {
      return 'Введите корректный email';
    }
    return null;
  }

  static String? password(String? value) {
    if (requiredField(value) != null) return 'Введите пароль';
    if (value!.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  static String? year(String? value) {
    if (requiredField(value) != null) return 'Введите год';
    final parsed = int.tryParse(value!);
    final maxYear = DateTime.now().year + 1;
    if (parsed == null || parsed < 1900 || parsed > maxYear) {
      return 'Введите год от 1900 до $maxYear';
    }
    return null;
  }
}
