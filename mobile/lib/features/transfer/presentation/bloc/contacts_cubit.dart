import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../wallet/domain/entities/public_user.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

/// Строка списка контактов: имя и номер с устройства, плюс пользователь
/// Nur Pay за этим номером, если он там есть.
class ContactEntry {
  const ContactEntry({
    required this.displayName,
    required this.number,
    this.user,
  });

  final String displayName;
  final String number;
  final PublicUser? user;

  bool get isNurPayUser => user != null;
}

enum ContactsStatus { loading, permissionDenied, error, loaded }

class ContactsState {
  const ContactsState({
    this.status = ContactsStatus.loading,
    this.nurPayContacts = const [],
    this.otherContacts = const [],
  });

  final ContactsStatus status;

  /// Сверху — те, кто уже в Nur Pay.
  final List<ContactEntry> nurPayContacts;

  /// Снизу — остальные, им пока некуда переводить.
  final List<ContactEntry> otherContacts;

  ContactsState copyWith({
    ContactsStatus? status,
    List<ContactEntry>? nurPayContacts,
    List<ContactEntry>? otherContacts,
  }) => ContactsState(
    status: status ?? this.status,
    nurPayContacts: nurPayContacts ?? this.nurPayContacts,
    otherContacts: otherContacts ?? this.otherContacts,
  );
}

/// Список контактов устройства, размеченный по тому, кто из них уже
/// пользуется Nur Pay — бэкенд сверяет номера, само устройство этого не
/// знает.
class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit(this._wallet) : super(const ContactsState());

  final WalletRepository _wallet;

  Future<void> load() async {
    emit(state.copyWith(status: ContactsStatus.loading));

    final permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      emit(state.copyWith(status: ContactsStatus.permissionDenied));
      return;
    }

    try {
      final device = await FastContacts.getAllContacts();

      final byNumber = <String, ContactEntry>{};
      for (final contact in device) {
        final name = contact.displayName.trim();
        if (name.isEmpty) continue;
        for (final phone in contact.phones) {
          final normalized = _localDigits(phone.number);
          if (normalized == null) continue;
          // Один и тот же номер может повторяться в нескольких
          // контактах — оставляем первый.
          byNumber.putIfAbsent(
            normalized,
            () => ContactEntry(displayName: name, number: phone.number),
          );
        }
      }

      if (byNumber.isEmpty) {
        emit(
          state.copyWith(
            status: ContactsStatus.loaded,
            nurPayContacts: const [],
            otherContacts: const [],
          ),
        );
        return;
      }

      final matches = await _wallet.lookupPhones(byNumber.keys.toList());
      final userByNumber = {
        for (final user in matches)
          if (user.phone != null) _localDigits(user.phone!): user,
      };

      final nurPay = <ContactEntry>[];
      final others = <ContactEntry>[];
      for (final entry in byNumber.entries) {
        final user = userByNumber[entry.key];
        final row = user == null
            ? entry.value
            : ContactEntry(
                displayName: entry.value.displayName,
                number: entry.value.number,
                user: user,
              );
        (user == null ? others : nurPay).add(row);
      }

      int byName(ContactEntry a, ContactEntry b) =>
          a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      nurPay.sort(byName);
      others.sort(byName);

      emit(
        state.copyWith(
          status: ContactsStatus.loaded,
          nurPayContacts: nurPay,
          otherContacts: others,
        ),
      );
    } catch (_) {
      emit(state.copyWith(status: ContactsStatus.error));
    }
  }

  /// Последние 8 цифр номера — локальный абонентский номер без кода
  /// страны. Ровно так же его сравнивает бэкенд: код страны в
  /// приложении всегда +993, а в контактах телефона он то есть, то нет.
  static String? _localDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return null;
    return digits.substring(digits.length - 8);
  }
}
