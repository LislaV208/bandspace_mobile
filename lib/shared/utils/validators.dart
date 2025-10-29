String? validateEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'Pole jest wymagane';
  }
  return null;
}

String? validateEmail(String? value) {
  final isEmpty = validateEmpty(value);
  if (isEmpty != null) {
    return isEmpty;
  }

  if (!value!.contains('@')) {
    return 'Podany adres email jest niepoprawny';
  }
  return null;
}

String? validatePassword(String? value, {int min = 6}) {
  final isEmpty = validateEmpty(value);
  if (isEmpty != null) {
    return isEmpty;
  }

  if (value == null || value.length < min) {
    return 'Hasło musi mieć co najmniej $min znaków';
  }
  return null;
}

String? validateConfirmPassword(String? value, String? password) {
  final isEmpty = validateEmpty(value);
  if (isEmpty != null) {
    return isEmpty;
  }

  if (value == null || value != password) {
    return 'Hasła różną sie od siebie';
  }
  return null;
}
