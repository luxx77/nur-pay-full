/// Чужой счёт, каким его можно показать: без баланса и секретов.
class PublicUser {
  const PublicUser({
    required this.userId,
    required this.isMerchant,
    required this.publicQrUuid,
    this.displayName,
    this.phone,
  });

  final String userId;
  final bool isMerchant;

  /// Постоянный QR получателя — им переводят без нового скана.
  final String publicQrUuid;
  final String? displayName;
  final String? phone;

  String get title => displayName ?? phone ?? 'Nur Pay';
}
