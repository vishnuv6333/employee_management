import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection_container.dart' as di;
import 'notification_service.dart';

class NotificationPermissionGate extends StatefulWidget {
  final Widget child;

  const NotificationPermissionGate({super.key, required this.child});

  @override
  State<NotificationPermissionGate> createState() =>
      _NotificationPermissionGateState();
}

class _NotificationPermissionGateState
    extends State<NotificationPermissionGate>
    with WidgetsBindingObserver {
  static const String _keyInitialPromptShown =
      'initial_notification_prompt_shown';

  bool _isLoading = true;
  bool _isGranted = false;
  bool _proceededWithoutPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_proceededWithoutPermission) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = di.sl<SharedPreferences>();
    final bool initialPromptShown =
        prefs.getBool(_keyInitialPromptShown) ?? false;
    final notificationService = di.sl<NotificationService>();
    final isGranted = await notificationService.checkPermission();

    if (mounted) {
      setState(() {
        _isGranted = isGranted;
        _proceededWithoutPermission = initialPromptShown;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    final notificationService = di.sl<NotificationService>();
    final isGranted = await notificationService.requestPermission();
    await di.sl<SharedPreferences>().setBool(_keyInitialPromptShown, true);

    if (mounted) {
      setState(() {
        _isGranted = isGranted;
        _proceededWithoutPermission = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedAnyway() async {
    await di.sl<SharedPreferences>().setBool(_keyInitialPromptShown, true);
    if (mounted) {
      setState(() {
        _proceededWithoutPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isGranted || _proceededWithoutPermission) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Enable Notifications',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Smart Workspace works best with notifications enabled for Note Notifications and Daily Workspace Reminders. Enable permissions now, or proceed to the app.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Feature Highlights Card
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.note_alt_rounded,
                            color: colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Note Notifications',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Timely alerts for your scheduled notes and tasks',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            color: colorScheme.secondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Workspace Reminder',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Daily sync reminder to review workspace goals',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Primary Enable Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _requestPermission,
                  icon: const Icon(Icons.notifications_none_rounded),
                  label: const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Proceed Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: _proceedAnyway,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Proceed Without Notifications'),
                ),
              ),
              const SizedBox(height: 8),

              // Check Status Text Button
              TextButton.icon(
                onPressed: _checkPermission,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Check Permission Status'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
