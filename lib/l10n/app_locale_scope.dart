import 'package:flutter/material.dart';

import 'app_locale.dart';

/// The current [AppLocale] plus the ability to change it, as handed out by
/// [AppLocaleScope.of]. Changing [setLocale] rebuilds every widget that
/// read `.locale` and persists the new choice.
abstract class AppLocaleController {
  AppLocale get locale;
  Future<void> setLocale(AppLocale locale);
}

/// Makes the current [AppLocale] available to the whole widget tree and
/// lets any screen change it — wraps [MaterialApp] in main.dart. Loads the
/// persisted choice once at startup.
class AppLocaleScope extends StatefulWidget {
  const AppLocaleScope({super.key, required this.child});

  final Widget child;

  static AppLocaleController of(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<_AppLocaleInherited>()
        ?.state;
    assert(state != null, 'AppLocaleScope.of() called outside an AppLocaleScope');
    return state!;
  }

  @override
  State<AppLocaleScope> createState() => _AppLocaleScopeState();
}

class _AppLocaleScopeState extends State<AppLocaleScope>
    implements AppLocaleController {
  AppLocale _locale = AppLocale.english;

  @override
  AppLocale get locale => _locale;

  @override
  void initState() {
    super.initState();
    AppLocale.load().then((loaded) {
      if (mounted) setState(() => _locale = loaded);
    });
  }

  @override
  Future<void> setLocale(AppLocale locale) async {
    setState(() => _locale = locale);
    await AppLocale.save(locale);
  }

  @override
  Widget build(BuildContext context) {
    return _AppLocaleInherited(
      state: this,
      locale: _locale,
      child: widget.child,
    );
  }
}

class _AppLocaleInherited extends InheritedWidget {
  const _AppLocaleInherited({
    required this.state,
    required this.locale,
    required super.child,
  });

  final _AppLocaleScopeState state;
  final AppLocale locale;

  @override
  bool updateShouldNotify(_AppLocaleInherited oldWidget) =>
      oldWidget.locale != locale;
}
