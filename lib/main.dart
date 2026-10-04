import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const AyOSApp());
}

class AyOSApp extends StatelessWidget {
  const AyOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AyOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'monospace',
      ),
      home: const XMBHomeScreen(),
    );
  }
}

class XMBHomeScreen extends StatefulWidget {
  const XMBHomeScreen({super.key});

  @override
  State<XMBHomeScreen> createState() => _XMBHomeScreenState();
}

class _XMBHomeScreenState extends State<XMBHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  // XMB Kategorileri (Yatay Eksen)
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'KULLANICI',
      'icon': Icons.person_outline,
      'items': ['Aybars Reis (Master)', 'Yeni Profil Ekle', 'Güç / Kapat']
    },
    {
      'title': 'AYARLAR',
      'icon': Icons.settings_outlined,
      'items': ['Sistem Ayarları', 'Ekran & Çözünürlük', 'Gamepad / Kol Eşle', 'Ağ Ayarları', 'AyOS Bilgisi']
    },
    {
      'title': 'OYUNLAR',
      'icon': Icons.sports_esports_outlined,
      'items': ['God of War', 'GTA: San Andreas', 'Minecraft', 'Need for Speed', 'Tüm Android Oyunları']
    },
    {
      'title': 'EMÜLATÖR',
      'icon': Icons.memory,
      'items': ['PPSSPP (PSP)', 'AetherSX2 (PS2)', 'RetroArch (Retro Hub)', 'Dolphin (GameCube/Wii)']
    },
    {
      'title': 'MEDYA',
      'icon': Icons.play_circle_outline,
      'items': ['Galeri / Fotoğraflar', 'Müzik Çalar', 'Video Oynatıcı', 'YouTube']
    },
    {
      'title': 'JARVIS',
      'icon': Icons.terminal,
      'items': ['Terminal Konsolu', 'Sistem Teşhisi', 'Yapay Zeka Asistanı']
    },
  ];

  int _selectedCategoryIndex = 2; // Başlangıç: Oyunlar
  int _selectedItemIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Gamepad / Klavye Yön Kontrolleri
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (_selectedCategoryIndex > 0) {
          setState(() {
            _selectedCategoryIndex--;
            _selectedItemIndex = 0;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (_selectedCategoryIndex < _categories.length - 1) {
          setState(() {
            _selectedCategoryIndex++;
            _selectedItemIndex = 0;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (_selectedItemIndex > 0) {
          setState(() {
            _selectedItemIndex--;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        final currentItems = _categories[_selectedCategoryIndex]['items'] as List<String>;
        if (_selectedItemIndex < currentItems.length - 1) {
          setState(() {
            _selectedItemIndex++;
          });
        }
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.gameButtonA ||
          event.logicalKey == LogicalKeyboardKey.gameButtonX) {
        _launchSelectedItem();
      }
    }
  }

  void _launchSelectedItem() {
    final category = _categories[_selectedCategoryIndex]['title'];
    final item = _categories[_selectedCategoryIndex]['items'][_selectedItemIndex];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('[$category] -> $item Başlatılıyor...'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItems = _categories[_selectedCategoryIndex]['items'] as List<String>;

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Canlı PS3 Dalga Arka Planı (Dynamic Wave)
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: PS3WavePainter(_waveController.value),
                );
              },
            ),

            // Üst Sağ Bilgi Çubuğu (Saat & Sistem)
            Positioned(
              top: 24,
              right: 32,
              child: Row(
                children: [
                  const Icon(Icons.wifi, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  const Icon(Icons.battery_charging_full, color: Colors.white70, size: 20),
                  const SizedBox(width: 16),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
                      return Text(
                        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Sol Üst Logo
            Positioned(
              top: 24,
              left: 32,
              child: Row(
                children: const [
                  Text(
                    'AyOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '4.91 CELL',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // XMB Menü İskeleti
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  // 1. Yatay Kategori Çubuğu
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _selectedCategoryIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedItemIndex = 0;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _categories[index]['icon'],
                                  size: isSelected ? 44 : 28,
                                  color: isSelected ? Colors.cyanAccent : Colors.white38,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _categories[index]['title'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white38,
                                    fontSize: isSelected ? 13 : 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 2. Dikey Seçenekler Listesi (XMB Stili)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 60, top: 10),
                      child: ListView.builder(
                        itemCount: currentItems.length,
                        itemBuilder: (context, index) {
                          final isSelectedItem = index == _selectedItemIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedItemIndex = index;
                              });
                              _launchSelectedItem();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelectedItem
                                    ? Colors.cyanAccent.withOpacity(0.15)
                                    : Colors.transparent,
                                border: isSelectedItem
                                    ? const Border(
                                        left: BorderSide(color: Colors.cyanAccent, width: 4),
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelectedItem
                                        ? Icons.play_arrow_rounded
                                        : Icons.chevron_right,
                                    color: isSelectedItem ? Colors.cyanAccent : Colors.white30,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    currentItems[index],
                                    style: TextStyle(
                                      color: isSelectedItem ? Colors.white : Colors.white70,
                                      fontSize: isSelectedItem ? 18 : 15,
                                      fontWeight: isSelectedItem ? FontWeight.bold : FontWeight.w400,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Alt Kısım: Gamepad Rehberi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildButtonLegend('D-Pad', 'Dolaş'),
                        const SizedBox(width: 24),
                        _buildButtonLegend('X / Ent', 'Başlat'),
                        const SizedBox(width: 24),
                        _buildButtonLegend('O / Esc', 'Geri'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonLegend(String button, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            button,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// PS3 Orijinal Akışkan Dinamik Dalga Efekti Çizicisi
class PS3WavePainter extends CustomPainter {
  final double animationValue;

  PS3WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.cyan.withOpacity(0.2),
          Colors.blueAccent.withOpacity(0.05),
          Colors.purple.withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.35)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    final path2 = Path();

    path.moveTo(0, size.height * 0.6);
    path2.moveTo(0, size.height * 0.55);

    for (double x = 0; x <= size.width; x += 10) {
      double y = sin((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * 35 +
          sin((x / size.width * 4 * pi) + (animationValue * 4 * pi)) * 15 +
          size.height * 0.6;

      double y2 = cos((x / size.width * 2 * pi) + (animationValue * 2 * pi)) * 25 +
          size.height * 0.55;

      path.lineTo(x, y);
      path2.lineTo(x, y2);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint1);
    canvas.drawPath(path, paintLine);
    canvas.drawPath(path2, paintLine);
  }

  @override
  bool shouldRepaint(covariant PS3WavePainter oldDelegate) => true;
}
