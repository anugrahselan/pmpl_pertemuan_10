import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Platform Channel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PlatformChannelPage(),
    );
  }
}

class PlatformChannelPage extends StatefulWidget {
  const PlatformChannelPage({super.key});

  @override
  State<PlatformChannelPage> createState() => _PlatformChannelPageState();
}

class _PlatformChannelPageState extends State<PlatformChannelPage> {
  // Nama MethodChannel harus identik dengan yang di MainActivity (case-sensitive)
  static const platform = MethodChannel(
    'com.example.pmpl_pertemuan_10/battery',
  );

  String _batteryLevel = 'Belum diketahui';
  final TextEditingController _toastController = TextEditingController();
  bool _isLong = true; // Default true untuk Toast.LENGTH_LONG

  // Mengambil data baterai dari native Android
  Future<void> _getBatteryLevel() async {
    String batteryStatus;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryStatus = 'Level baterai saat ini: $result%';
    } on PlatformException catch (e) {
      batteryStatus = "Gagal mengambil level baterai: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryStatus;
    });
  }

  // Mengirim data teks dan durasi ke native Android untuk ditampilkan sebagai Toast
  Future<void> _showNativeToast() async {
    final String textToSend = _toastController.text.trim().isEmpty
        ? '2411500039 - Anugrah Akbar' // Ganti dengan NIM dan Nama Anda
        : _toastController.text.trim();

    try {
      await platform.invokeMethod('showToast', {
        'message': textToSend,
        'isLong': _isLong,
      });
    } on PlatformException catch (e) {
      debugPrint("Gagal menampilkan Toast: ${e.message}");
    }
  }

  @override
  void dispose() {
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertemuan 10: Platform Channel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian 1: Native -> Flutter (Battery Level)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.battery_charging_full,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _batteryLevel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _getBatteryLevel,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cek Level Baterai (Native)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bagian 2: Flutter -> Native (Toast dengan Parameter)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Kirim Pesan ke Native Toast',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _toastController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Tulis pesan Toast',
                        hintText:
                            'Contoh: 2411500039 - Anugrah Akbar',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLong
                                    ? 'Aktif (Toast.LENGTH_LONG)'
                                    : 'Nonaktif (Toast.LENGTH_SHORT)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: _isLong,
                          onChanged: (bool value) {
                            setState(() {
                              _isLong = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: _showNativeToast,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Tampilkan Native Toast'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
