import 'package:flutter/material.dart';

void main() {
  runApp(const HomeNetworkApp());
}

class HomeNetworkApp extends StatelessWidget {
  const HomeNetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة شبكة المنزل',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NetworkControlScreen(),
    );
  }
}

class NetworkControlScreen extends StatefulWidget {
  const NetworkControlScreen({super.key});

  @override
  State<NetworkControlScreen> createState() => _NetworkControlScreenState();
}

class DeviceItem {
  final String name;
  final String ip;
  bool isBlocked;
  String blockTime;
  final bool isProtected; // للاستثناء (موبايلك أو My TV)

  DeviceItem({
    required this.name,
    required this.ip,
    required this.isBlocked,
    required this.blockTime,
    this.isProtected = false,
  });
}

class _NetworkControlScreenState extends State<NetworkControlScreen> {
  bool isGlobalInternetBlocked = false;

  // قائمة الأجهزة المتصلة في المنزل مع الاستثناءات المطلوبة
  final List<DeviceItem> devices = [
    DeviceItem(name: 'موبايل الأستاذ عامر (استثناء)', ip: '192.168.1.10', isBlocked: false, blockTime: '00:00 - 00:00', isProtected: true),
    DeviceItem(name: 'جهاز ماي تي في (My TV - استثناء)', ip: '192.168.1.15', isBlocked: false, blockTime: '00:00 - 00:00', isProtected: true),
    DeviceItem(name: 'هاتف الصالة', ip: '192.168.1.20', isBlocked: false, blockTime: '14:00 - 16:00'),
    DeviceItem(name: 'جهاز اللابتوب', ip: '192.168.1.25', isBlocked: false, blockTime: '22:00 - 06:00'),
    DeviceItem(name: 'جهاز الشاشة الذكية', ip: '192.168.1.30', isBlocked: false, blockTime: '01:00 - 05:00'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحكم بالإنترنت المنزلي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // المفتاحان الكبيران في أعلى الشاشة
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isGlobalInternetBlocked = true;
                        // تطبيق الحظر على الكل ما عدا المستثناءات
                        for (var d in devices) {
                          if (!d.isProtected) d.isBlocked = true;
                        }
                      });
                    },
                    icon: const Icon(Icons.block, size: 28),
                    label: const Text('حظر الإنترنت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGlobalInternetBlocked ? Colors.red : Colors.red.shade100,
                      foregroundColor: isGlobalInternetBlocked ? Colors.white : Colors.red.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isGlobalInternetBlocked = false;
                        for (var d in devices) {
                          d.isBlocked = false;
                        }
                      });
                    },
                    icon: const Icon(Icons.wifi, size: 28),
                    label: const Text('الاتصال بالإنترنت', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isGlobalInternetBlocked ? Colors.green : Colors.green.shade100,
                      foregroundColor: !isGlobalInternetBlocked ? Colors.white : Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // عنوان القائمة
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الأجهزة المتصلة بالشبكة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
            const SizedBox(height: 10),

            // قائمة اظهار جميع الاجهزة
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    device.isProtected ? Icons.admin_panel_settings : Icons.devices,
                                    color: device.isProtected ? Colors.amber.shade800 : Colors.indigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: device.isProtected ? Colors.green.shade800 : Colors.black87,
                                        ),
                                      ),
                                      Text(device.ip, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              // مفتاح تشغيل وايقاف الحظر لكل جهاز (مع منع حظر المستثناءات)
                              Switch(
                                value: device.isBlocked,
                                onChanged: device.isProtected
                                    ? null // منع التعديل على الأجهزة المستستناة
                                    : (value) {
                                        setState(() {
                                          device.isBlocked = value;
                                        });
                                      },
                                activeColor: Colors.red,
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                device.isProtected ? 'محمي دائماً (لا يمكن حظره)' : 'وقت الحظر: ${device.blockTime}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: device.isProtected ? Colors.green : Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (!device.isProtected)
                                TextButton.icon(
                                  onPressed: () {
                                    // نافذة أو دالة لتعديل وقت الحظر خلال 24 ساعة
                                    _showTimePickerDialog(context, device);
                                  },
                                  icon: const Icon(Icons.access_time, size: 16),
                                  label: const Text('تعديل التوقيت', style: TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // نافذة اختيار توقيت الحظر خلال 24 ساعة
  void _showTimePickerDialog(BuildContext context, DeviceItem device) {
    showDialog(
      context: dialogContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('تحديد وقت الحظر لـ ${device.name}'),
          content: const Text('اختر فترة الحظر المطلوبة خلال الـ 24 ساعة (مثال: من 12 ليلاً إلى 6 صباحاً).'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  device.blockTime = '01:00 - 05:00'; // مثال على التحديث
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
