import 'package:flutter/material.dart';
import '../../../../core/native/native_bridge.dart';

class NativeDemoPage extends StatefulWidget {
  const NativeDemoPage({super.key});

  @override
  State<NativeDemoPage> createState() => _NativeDemoPageState();
}

class _NativeDemoPageState extends State<NativeDemoPage> {
  String _deviceInfo = 'Unknown';
  String _cellTowerInfo = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native Integrations Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: () async {
              final info = await NativeBridge.getDeviceInfo();
              setState(() => _deviceInfo = info ?? 'Failed');
            },
            child: const Text('Get Device Info'),
          ),
          Text('Device Info: $_deviceInfo', textAlign: TextAlign.center),
          const Divider(height: 32),
          ElevatedButton(
            onPressed: () async {
              final info = await NativeBridge.getCellTowerLocation();
              setState(() => _cellTowerInfo = info ?? 'Failed');
            },
            child: const Text('Get Cell Tower Location'),
          ),
          Text('Cell Tower: $_cellTowerInfo', textAlign: TextAlign.center),
          const Divider(height: 32),
          ElevatedButton(
            onPressed: () => NativeBridge.showNativeDatePicker(),
            child: const Text('Show Native Date Picker'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => NativeBridge.showNativeBottomSheet(),
            child: const Text('Show Native Bottom Sheet'),
          ),
        ],
      ),
    );
  }
}
