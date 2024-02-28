import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ci.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Membership extends StatelessWidget {
  const Membership({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: ListTile(
            leading: SizedBox(
                width: 64,
                height: 64,
                child: Center(
                    child: Iconify(
                  Ci.sketch,
                  size: 32,
                  color: Theme.of(context).colorScheme.onBackground,
                ))),
            title: Text(AppLocalizations.of(context)!.becomeAMember),
            subtitle: Text(AppLocalizations.of(context)!.memberSubtitle),
          ),
        ),
      ),
    );
  }
}
