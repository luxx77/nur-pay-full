/// Чужой счёт, каким его можно показать: без баланса и секретов.
class PublicUser {
  const PublicUser({
    required this.userId,
    required this.isMerchant,
    this.displayName,
    this.phone,
  });

  final String userId;
  final bool isMerchant;
  final String? displayName;
  final String? phone;

  String get title => displayName ?? phone ?? 'Nur Pay';
}
