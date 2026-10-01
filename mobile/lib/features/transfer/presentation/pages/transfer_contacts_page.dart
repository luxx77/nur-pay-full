import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/ui_kit/ui_kit.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../bloc/contacts_cubit.dart';
import '../bloc/transfer_cubit.dart';

/// 4.1 · Kontaktlar — кому из телефонной книги можно перевести напрямую,
/// без нового скана его QR.
class TransferContactsPage extends StatelessWidget {
  const TransferContactsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => ContactsCubit(context.read<WalletRepository>())
      ..load(),
    child: const _TransferContactsView(),
  );
}

class _TransferContactsView extends StatefulWidget {
  const _TransferContactsView();

  @override
  State<_TransferContactsView> createState() => _TransferContactsViewState();
}

class _TransferContactsViewState extends State<_TransferContactsView> {
  bool _resolving = false;

  Future<void> _select(ContactEntry entry) async {
    final user = entry.user;
    if (user == null || _resolving) return;

    setState(() => _resolving = true);
    final cubit = context.read<TransferCubit>();
    final resolved = await cubit.resolve(StaticQr(publicQrUuid: user.publicQrUuid));
    if (!mounted) return;

    if (!resolved) {
      setState(() => _resolving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(cubit.state.error?.userMessage ?? 'Ýalňyşlyk ýüze çykdy'),
          ),
        );
      return;
    }
    context.push(AppRoutes.transferAmount);
  }

  @override
  Widget build(BuildContext context) => RoleTheme.dark(
    role: AppRole.customer,
    child: Builder(
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Column(
              children: [
                const AppTopBar(title: 'Kontaktlar'),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _resolving,
                    child: BlocBuilder<ContactsCubit, ContactsState>(
                      builder: (context, state) => _Body(
                        state: state,
                        resolving: _resolving,
                        onTap: _select,
                        onRetry: () => context.read<ContactsCubit>().load(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.resolving,
    required this.onTap,
    required this.onRetry,
  });

  final ContactsState state;
  final bool resolving;
  final ValueChanged<ContactEntry> onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    switch (state.status) {
      case ContactsStatus.loading:
        return Center(
          child: CircularProgressIndicator(color: cs.primary),
        );

      case ContactsStatus.permissionDenied:
        return EmptyState(
          icon: Icon(Icons.contacts_outlined, size: 40.r, color: cs.outline),
          title: 'Kontaktlara rugsat gerek',
          message:
              'Kimiň Nur Pay ulanýandygyny görkezmek üçin telefon '
              'kitapçasyna rugsat beriň.',
          actions: [
            AppButton.outlined(label: 'Gaýtadan synanyş', onPressed: onRetry),
          ],
        );

      case ContactsStatus.error:
        return EmptyState(
          icon: Icon(
            Icons.error_outline,
            size: 40.r,
            color: cs.error,
          ),
          title: 'Ýüklenip bilmedi',
          message: 'Internet baglanyşygyny barlaň we gaýtadan synanyşyň.',
          actions: [
            AppButton.outlined(label: 'Gaýtadan synanyş', onPressed: onRetry),
          ],
        );

      case ContactsStatus.loaded:
        if (state.nurPayContacts.isEmpty && state.otherContacts.isEmpty) {
          return const EmptyState(
            title: 'Kontakt tapylmady',
            message: 'Telefon kitapçaňyzda belgili kontakt ýok.',
          );
        }
        return ListView(
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            if (state.nurPayContacts.isNotEmpty) ...[
              SectionLabel('Nur Pay-da bar'),
              AppListGroup(
                children: [
                  for (final entry in state.nurPayContacts)
                    _ContactTile(entry: entry, onTap: () => onTap(entry)),
                ],
              ),
            ],
            if (state.otherContacts.isNotEmpty) ...[
              SectionLabel('Nur Pay-da ýok'),
              AppListGroup(
                children: [
                  for (final entry in state.otherContacts)
                    _ContactTile(entry: entry, onTap: null),
                ],
              ),
            ],
          ],
        );
    }
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.entry, required this.onTap});

  final ContactEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      leading: AppAvatar.fromName(
        entry.displayName,
        tone: entry.isNurPayUser ? AppAvatarTone.brand : AppAvatarTone.neutral,
      ),
      title: Text(
        entry.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        entry.number,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: entry.isNurPayUser
          ? Icon(Icons.chevron_right, color: cs.outline)
          : null,
    );
  }
}
