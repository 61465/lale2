import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ مضاف
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ حذف path_provider غير المستخدم

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlaaAppHome(),
    ));

// ================ تعريف الحالات النفسية لآلاء ================
enum AlaaMood {
  warrior, // مولان - حالة القوة والإصرار
  cute, // هالو كيتي - حالة الدلال واللطف
  peaceful, // الطبيعة والعصافير - حالة الهدوء
  romantic, // صور الحب - حالة العاطفة
  pensive, // ديزني برنس - حالة التأمل والعمق
  exhausted // بليز/هالو كيتي حمام - حالة الرغبة في الراحة
}

// ================ نماذج البيانات ================
class Task {
  String title;
  bool isDone;
  Task(this.title, {this.isDone = false});
}

class Novel {
  String name;
  String path;
  String note;
  String type;
  Novel(this.name, this.path, this.type, {this.note = ""});
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'note': note,
    'type': type,
  };
  
  factory Novel.fromJson(Map<String, dynamic> json) => Novel(
    json['name'],
    json['path'],
    json['type'],
    note: json['note'] ?? '',
  );
}

class StarModel {
  double x, y;
  double floatOffset;
  StarModel(this.x, this.y, {this.floatOffset = 0});
}

class MemoryImage {
  String path;
  MemoryImage(this.path);
}

class Game {
  String name;
  String path;
  Game(this.name, this.path);
}

class Song {
  String name;
  String path;
  Song(this.name, this.path);
}

// ================ الصفحة الرئيسية ================
class AlaaAppHome extends StatefulWidget {
  const AlaaAppHome({super.key});

  @override
  State<AlaaAppHome> createState() => _AlaaAppHomeState();
}

class _AlaaAppHomeState extends State<AlaaAppHome> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _skyAnimationController;
  
  // متغيرات الحالة المزاجية
  AlaaMood currentMood = AlaaMood.peaceful;
  String? lastAnalysisResult;
  
  // متغيرات نجوم التأمل
  List<StarModel> stars = [];
  bool isNightMode = true;
  
  // متغيرات المهام
  List<Task> alaaTasks = [];
  
  // متغيرات المهام المشتركة مع الزوج
  List<String> coupleTasks = [];
  
  // متغيرات المحراب الأدبي
  List<String> proseWritings = [];
  List<String> poetryWritings = [];
  
  // متغيرات الروايات (مع دعم PDF/Word)
  List<Novel> novels = [];
  
  // متغيرات الموسيقى
  List<Song> songs = [];
  String? currentSongName;
  
  // متغيرات الذكريات
  List<MemoryImage> memories = [];
  
  // متغيرات الألعاب
  List<Game> games = [];
  
  // حكمة اليوم
  List<String> dailyQuotes = [
    "الجمال في التفاصيل الصغيرة يا آلاء",
    "اليوم فرصة جديدة لتكوني أفضل نسخة من نفسك",
    "القوة الحقيقية تأتي من الداخل",
    "كل لحظة هدوء هي هدية لنفسك",
    "الإبداع هو أن تتركي بصمتكِ الخاصة في كل شيء",
  ];
  
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _proseController = TextEditingController();
  final TextEditingController _poetryController = TextEditingController();
  final TextEditingController _feelingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skyAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _loadSavedData();
    _initDefaultData();
    
    // إضافة بعض النجوم الافتراضية
    for (int i = 0; i < 10; i++) {
      stars.add(StarModel(
        Random().nextDouble() * 300,
        Random().nextDouble() * 500,
        floatOffset: Random().nextDouble() * 2 * pi,
      ));
    }
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // تحميل المهام
    List<String>? savedTasks = prefs.getStringList('tasks');
    if (savedTasks != null) {
      setState(() {
        alaaTasks = savedTasks.map((t) => Task(t)).toList();
      });
    }
    
    // تحميل المهام المشتركة
    List<String>? savedCoupleTasks = prefs.getStringList('coupleTasks');
    if (savedCoupleTasks != null) {
      setState(() {
        coupleTasks = savedCoupleTasks;
      });
    }
    
    // تحميل الكتابات
    List<String>? savedProse = prefs.getStringList('proseWritings');
    if (savedProse != null) {
      setState(() {
        proseWritings = savedProse;
      });
    }
    
    List<String>? savedPoetry = prefs.getStringList('poetryWritings');
    if (savedPoetry != null) {
      setState(() {
        poetryWritings = savedPoetry;
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', alaaTasks.map((t) => t.title).toList());
    await prefs.setStringList('coupleTasks', coupleTasks);
    await prefs.setStringList('proseWritings', proseWritings);
    await prefs.setStringList('poetryWritings', poetryWritings);
  }

  void _initDefaultData() {
    if (alaaTasks.isEmpty) {
      alaaTasks = [
        Task("📝 كتابة صفحة في المحراب"),
        Task("🧘 تأمل 10 دقائق"),
        Task("📖 قراءة رواية"),
        Task("💝 وقت مع زوجي"),
      ];
    }
    
    if (coupleTasks.isEmpty) {
      coupleTasks = [
        "🎬 مشاهدة فيلم معاً",
        "🍽️ عشاء رومانسي",
        "📞 مكالمة مسائية",
      ];
    }
    
    if (proseWritings.isEmpty) {
      proseWritings = [
        "خاطرة الصباح - ٢٠٢٤/٠٣/١٥",
        "تأملات المساء - ٢٠٢٤/٠٣/١٤",
      ];
    }
    
    if (poetryWritings.isEmpty) {
      poetryWritings = [
        "قصيدة الحب - ٢٠٢٤/٠٣/١٣",
        "شعر عن الطبيعة - ٢٠٢٤/٠٣/١٢",
      ];
    }
  }

  // دوال الصور والحالات
  String getMoodProfileImage(AlaaMood mood) {
    switch (mood) {
      case AlaaMood.warrior: return 'assets/molan.jpg';
      case AlaaMood.cute: return 'assets/hello kity katkot.jpg';
      case AlaaMood.peaceful: return 'assets/lely.jpg';
      case AlaaMood.romantic: return 'assets/love.jpg';
      case AlaaMood.pensive: return 'assets/disney mulan.jpg';
      case AlaaMood.exhausted: return 'assets/please.jpg';
    }
  }

  String _getMoodAnalysisTitle(AlaaMood mood) {
    switch (mood) {
      case AlaaMood.warrior: return "🛡️ محاربة - روح مولان";
      case AlaaMood.cute: return "🎀 دلال - هالو كيتي";
      case AlaaMood.peaceful: return "🕊️ هادئة - عصافير";
      case AlaaMood.romantic: return "❤️ رومانسية - حب";
      case AlaaMood.pensive: return "📚 متأملة - عمق";
      case AlaaMood.exhausted: return "🛏️ متعبة - استرخاء";
    }
  }

  // ================ محرك التحليل النفسي الذكي ================
  String _performProfessionalAnalysis(String text) {
    if (text.isEmpty) {
      return "اكتبي شيئاً لأحلل حالتك يا آلاء 💭";
    }

    bool isCreative = text.contains("خيال") || 
                      text.contains("نجم") || 
                      text.contains("بحر") || 
                      text.contains("شوق") ||
                      text.contains("قمر") ||
                      text.contains("ورد") ||
                      text.contains("سماء");

    if (text.contains("تعب") || text.contains("مرهقة") || text.contains("ضغط") || text.contains("نوم")) {
      setState(() => currentMood = AlaaMood.exhausted);
      String result = "تحليل الطبيب: آلاء، كلماتكِ تشير إلى حمل ثقيل تضعينه على عاتقكِ. أنتِ في مرحلة 'استنزاف عاطفي'. نصيحتي لكِ: التوقف الآن ليس فشلاً، بل هو استجماع للقوة. خذي استراحة 'بليز' فوراً.";
      if (isCreative) {
        _showCreativeSuggestion("أرى في كلماتكِ رغبة في الراحة مع لمسة إبداعية.. هل تودين كتابة شعر عن الهدوء والاسترخاء؟");
      }
      return result;
    } 
    else if (text.contains("قوة") || text.contains("تحدي") || text.contains("سأفعل") || text.contains("إنجاز")) {
      setState(() => currentMood = AlaaMood.warrior);
      String result = "تحليل الطبيب: مذهل! يظهر من كلماتكِ بزوغ روح 'المحاربة'. أنتِ في حالة 'تدفق ذهني عالي'. استغلي هذه الطاقة لإنهاء أصعب مهامكِ اليوم، فالمستحيل مجرد كلمة في قاموسكِ الآن.";
      if (isCreative) {
        _showCreativeSuggestion("روح مولان فيكِ ملهمة! لمَ لا تكتبين قصيدة عن القوة والتحدي؟");
      }
      return result;
    } 
    else if (text.contains("حب") || text.contains("سعادة") || text.contains("جميل") || text.contains("فرح")) {
      setState(() => currentMood = AlaaMood.cute);
      String result = "تحليل الطبيب: روحكِ ترفرف في فضاء من اللطف. أنتِ في حالة 'توازن وجداني'. انشري هذا الجمال حولكِ، فالعالم يحتاج لابتسامة آلاء اليوم.";
      if (isCreative) {
        _showCreativeSuggestion("هذه المشاعر الجميلة تستحق أن تخلديها في قصيدة رقيقة!");
      }
      return result;
    }
    else if (text.contains("حزن") || text.contains("بكاء") || text.contains("ألم")) {
      setState(() => currentMood = AlaaMood.pensive);
      String result = "تحليل الطبيب: أشعر ببعض الحزن في كلماتكِ، وهذا طبيعي جداً. المشاعر السلبية جزء من رحلتنا. تنفسي بعمق، وتذكري أن الغيوم تمطر ثم تنجلي.";
      if (isCreative) {
        _showCreativeSuggestion("أحياناً الكتابة هي أفضل دواء.. هل تودين التعبير عن مشاعركِ في قصيدة؟");
      }
      return result;
    }
    else {
      setState(() => currentMood = AlaaMood.peaceful);
      String result = "تحليل الطبيب: هدوءكِ الحالي هو أرض خصبة للإبداع. أنتِ في حالة 'تأمل واعي'. هذا هو الوقت المثالي لزيارة 'ركن التأمل' أو كتابة الشعر في المحراب.";
      if (isCreative) {
        _showCreativeSuggestion("كلماتكِ تحمل نسمات إبداعية.. لمَ لا تنتقلين لمحراب الشعر الآن؟");
      }
      return result;
    }
  }

  void _showCreativeSuggestion(String message) {
    if (!mounted) return; // ✅ إصلاح: التحقق من mounted قبل استخدام context
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "✨ اقتراح الطبيب النفسي الأدبي",
          style: TextStyle(color: Colors.purple),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ليس الآن"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 4;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text("✍️ إلى محراب الشعر"),
          ),
        ],
      ),
    );
  }

  void _showAnalysisResultDialog(String result) {
    setState(() {
      lastAnalysisResult = result;
    });
    
    if (!mounted) return; // ✅ إصلاح: التحقق من mounted
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🧠 نتيجة التحليل النفسي"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  // ================ دوال ركن التأمل ================
  void _addStar() {
    setState(() {
      stars.add(StarModel(
        Random().nextDouble() * 300,
        Random().nextDouble() * 500,
        floatOffset: Random().nextDouble() * 2 * pi,
      ));
    });
  }

  // ================ دوال المهام ================
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        alaaTasks.add(Task("📌 ${_taskController.text}"));
        _taskController.clear();
      });
      _saveTasks();
    }
  }

  void _toggleTask(int index) {
    setState(() {
      alaaTasks[index].isDone = !alaaTasks[index].isDone;
    });
    _saveTasks();
  }

  void _removeTask(int index) {
    setState(() {
      alaaTasks.removeAt(index);
    });
    _saveTasks();
  }

  void _addCoupleTask() {
    if (!mounted) return; // ✅ إصلاح
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text("❤️ إضافة مهمة مشتركة"),
          content: TextField(controller: controller),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
            TextButton(
              onPressed: () {
                setState(() {
                  coupleTasks.add("❤️ ${controller.text}");
                });
                _saveTasks();
                Navigator.pop(context);
              },
              child: const Text("إضافة"),
            ),
          ],
        );
      },
    );
  }

  // ================ دوال المحراب الأدبي ================
  void _addProseWriting() {
    if (_proseController.text.isNotEmpty) {
      setState(() {
        proseWritings.insert(0, "📝 ${_proseController.text.substring(0, min(20, _proseController.text.length))}...");
        _proseController.clear();
      });
      _saveTasks();
    }
  }

  void _addPoetryWriting() {
    if (_poetryController.text.isNotEmpty) {
      setState(() {
        poetryWritings.insert(0, "📜 ${_poetryController.text.substring(0, min(20, _poetryController.text.length))}...");
        _poetryController.clear();
      });
      _saveTasks();
    }
  }

  // ================ دوال مكتبة الروايات (دعم PDF/Word) ================
  Future<void> _pickNovel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (await file.exists()) {
          if (!mounted) return; // ✅ إصلاح: التحقق من mounted بعد await
          setState(() {
            novels.add(Novel(
              result.files.single.name,
              file.path,
              result.files.single.extension ?? 'pdf',
            ));
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ تمت إضافة: ${result.files.single.name}")),
          );
        } else {
          if (!mounted) return; // ✅ إصلاح
          _showWindowsPermissionDialog();
        }
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      _showWindowsPermissionDialog();
    }
  }

  void _showWindowsPermissionDialog() {
    if (!mounted) return; // ✅ إصلاح
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ مشكلة في الوصول للملفات"),
        content: const Text(
          "على ويندوز، قد تحتاجين إلى:\n\n"
          "1. تفعيل 'Developer Mode' من إعدادات النظام\n"
          "2. تشغيل التطبيق كـ Administrator\n"
          "3. التأكد من أن مسار الملف غير محمي"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  void _openNotePaper(int index) {
    if (!mounted) return; // ✅ إصلاح
    TextEditingController noteController = TextEditingController(text: novels[index].note);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("📝 ملاحظات: ${novels[index].name}"),
        content: TextField(
          controller: noteController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: "اكتبي خاطرتكِ عن هذه الرواية هنا يا آلاء...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                novels[index].note = noteController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم حفظ الملاحظة")),
              );
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  Future<void> _viewFile(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        final Uri uri = Uri.file(path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (!mounted) return; // ✅ إصلاح
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لا يمكن فتح هذا النوع من الملفات")),
          );
        }
      } else {
        if (!mounted) return; // ✅ إصلاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الملف غير موجود")),
        );
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في فتح الملف: $e")),
      );
    }
  }

  // ================ دوال الألعاب ================
  Future<void> _addGame() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['exe', 'lnk', 'bat'],
      );

      if (result != null) {
        if (!mounted) return; // ✅ إصلاح
        setState(() {
          games.add(Game(
            result.files.single.name.replaceAll('.exe', '').replaceAll('.lnk', ''),
            result.files.single.path!,
          ));
        });
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      _showWindowsPermissionDialog();
    }
  }

  Future<void> _launchGame(String path) async {
    try {
      File file = File(path);
      if (await file.exists()) {
        final Uri uri = Uri.file(path);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (!mounted) return; // ✅ إصلاح
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لا يمكن تشغيل اللعبة")),
          );
        }
      } else {
        if (!mounted) return; // ✅ إصلاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ملف اللعبة غير موجود")),
        );
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تشغيل اللعبة: $e")),
      );
    }
  }

  // ================ دوال الموسيقى ================
  Future<void> _pickAndPlayMusic() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        if (await file.exists()) {
          await _player.play(DeviceFileSource(filePath));
          if (!mounted) return; // ✅ إصلاح
          setState(() {
            currentSongName = result.files.single.name;
            songs.add(Song(result.files.single.name, filePath));
          });
        } else {
          if (!mounted) return; // ✅ إصلاح
          _showWindowsPermissionDialog();
        }
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      _showWindowsPermissionDialog();
    }
  }

  // ================ دوال معرض الذكريات ================
  Future<void> _addMemoryImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (await file.exists()) {
          if (!mounted) return; // ✅ إصلاح
          setState(() {
            memories.add(MemoryImage(result.files.first.path!));
          });
        } else {
          if (!mounted) return; // ✅ إصلاح
          _showWindowsPermissionDialog();
        }
      }
    } catch (e) {
      if (!mounted) return; // ✅ إصلاح
      _showWindowsPermissionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientForIndex(),
                ),
              ),
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientForIndex() {
    switch (_selectedIndex) {
      case 2: return isNightMode 
          ? [const Color(0xFF0B0B2B), const Color(0xFF1B1B4B)]
          : [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)];
      case 3: return [const Color(0xFF957DAD), const Color(0xFFD291BC)];
      case 4: return [const Color(0xFFE2D1C3), const Color(0xFFF9F3E6)];
      case 5: return [const Color(0xFFFBC2C2), const Color(0xFFFFE6E6)];
      default: return [const Color(0xFFFDEEF2), const Color(0xFFFFF0F5)];
    }
  }

  Widget _buildSidebar() {
    int completedTasks = alaaTasks.where((t) => t.isDone).length;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFFFDEEF2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildProfileHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("✨ أنجزتِ $completedTasks مهام اليوم", 
              style: const TextStyle(fontSize: 12, color: Colors.pink)),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _sidebarItem(0, "الرئيسية", Icons.dashboard),
                _sidebarItem(1, "قائمة المهام", Icons.checklist),
                _sidebarItem(2, "لحظة تأمل", Icons.self_improvement),
                _sidebarItem(3, "الطبيب النفسي", Icons.psychology),
                _sidebarItem(4, "المحراب الأدبي", Icons.edit_note),
                _sidebarItem(5, "قائمة مع زوجي", Icons.favorite),
                _sidebarItem(6, "مكتبة الروايات", Icons.menu_book),
                _sidebarItem(7, "معرض الذكريات", Icons.photo_library),
                _sidebarItem(8, "ألعابي", Icons.videogame_asset),
                _sidebarItem(9, "الموسيقى", Icons.music_note),
              ],
            ),
          ),
          _buildCassetteButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.pink.shade100,
            backgroundImage: AssetImage(getMoodProfileImage(currentMood)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("آلاء", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_getMoodAnalysisTitle(currentMood), 
                  style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String title, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.pink.shade50,
      leading: Icon(icon, color: isSelected ? Colors.pink : Colors.black54),
      title: Text(title, style: TextStyle(color: isSelected ? Colors.pink : Colors.black87)),
      onTap: () => setState(() => _selectedIndex = index),
    );
  }

  Widget _buildCassetteButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _showMusicMenu,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.album, color: Colors.pink, size: 20),
              SizedBox(width: 8),
              Text("كاسيت آلاء", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildDashboard();
      case 1: return _buildTasksPage();
      case 2: return _buildLivingSky();
      case 3: return _buildPsychologySection();
      case 4: return _buildLiteraryShrine();
      case 5: return _buildCoupleList();
      case 6: return _buildNovelLibrary();
      case 7: return _buildMemoryGallery();
      case 8: return _buildGamesPage();
      case 9: return _buildMusicPage();
      default: return _buildComingSoon();
    }
  }

  // ================ الصفحات المختلفة ================
  
  Widget _buildDashboard() {
    int completedTasks = alaaTasks.where((t) => t.isDone).length;
    String dailyQuote = dailyQuotes[DateTime.now().day % dailyQuotes.length];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVibeCard("🧠 حالتك النفسية", _getMoodAnalysisTitle(currentMood)),
          const SizedBox(height: 15),
          _buildAchievementCard("📊 إنجازات اليوم", "$completedTasks مهام مكتملة"),
          const SizedBox(height: 15),
          _buildDailyQuote(dailyQuote),
          if (lastAnalysisResult != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("آخر تحليل:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(lastAnalysisResult!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVibeCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // ✅ إصلاح: withValues → withOpacity
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_emotions, color: Colors.pink.shade300),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title), Text(value, style: const TextStyle(fontSize: 12))],
          )),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3), // ✅ إصلاح: withValues → withOpacity
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber.shade700),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title), Text(value, style: const TextStyle(fontSize: 12))],
          )),
        ],
      ),
    );
  }

  Widget _buildDailyQuote(String quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.purple.shade200]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text("💫 $quote", style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
    );
  }

  Widget _buildTasksPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("📋 مهام آلاء (${alaaTasks.where((t) => t.isDone).length}/${alaaTasks.length})",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: "مهمة جديدة...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            )),
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: Colors.pink,
              child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: _addTask),
            ),
          ]),
          const SizedBox(height: 20),
          Expanded(child: ListView.builder(
            itemCount: alaaTasks.length,
            itemBuilder: (context, index) => Dismissible(
              key: Key(alaaTasks[index].title),
              background: Container(color: Colors.red),
              onDismissed: (direction) => _removeTask(index),
              child: Card(
                child: ListTile(
                  leading: Checkbox(
                    value: alaaTasks[index].isDone,
                    onChanged: (_) => _toggleTask(index),
                  ),
                  title: Text(alaaTasks[index].title,
                    style: TextStyle(decoration: alaaTasks[index].isDone ? TextDecoration.lineThrough : null)),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeTask(index)),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLivingSky() {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isNightMode 
              ? [Colors.black, Colors.indigo.shade900]
              : [Colors.blue.shade300, Colors.orange.shade200],
        ),
      ),
      child: Stack(
        children: [
          ...stars.asMap().entries.map((entry) {
            int idx = entry.key;
            StarModel star = entry.value;
            return Positioned(
              left: star.x,
              top: star.y,
              child: AnimatedBuilder(
                animation: _skyAnimationController,
                builder: (context, child) {
                  double floatY = sin(_skyAnimationController.value * 2 * pi + star.floatOffset) * 5;
                  return Transform.translate(
                    offset: Offset(0, floatY),
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          star.x += details.delta.dx;
                          star.y += details.delta.dy;
                        });
                      },
                      child: Icon(Icons.star, color: isNightMode ? Colors.yellow : Colors.orange,
                        size: 15 + (idx % 3) * 5),
                    ),
                  );
                },
              ),
            );
          }),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addStar,
                      icon: const Icon(Icons.star),
                      label: const Text("✨ نجمة جديدة"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => isNightMode = !isNightMode),
                      icon: Icon(isNightMode ? Icons.wb_sunny : Icons.nights_stay),
                      label: Text(isNightMode ? "شروق الشمس" : "سماء النجوم"),
                    ),
                  ],
                ),
                const Text("اسحبي النجوم لتشكيل اسمكِ في السماء ⭐",
                  style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologySection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("🧘‍♀️ فضفضي للطبيب النفسي الذكي",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _feelingController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: "اكتبي ما يحزنكِ أو يبهجكِ يا آلاء.. نحن نسمعكِ..",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
              ),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              String result = _performProfessionalAnalysis(_feelingController.text);
              _showAnalysisResultDialog(result);
            },
            icon: const Icon(Icons.analytics_outlined),
            label: const Text("🔮 بدء التحليل النفسي"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiteraryShrine() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [Tab(text: "📝 نثر"), Tab(text: "📜 شعر")],
            indicatorColor: Colors.brown,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWritingTab(_proseController, _addProseWriting, proseWritings),
                _buildWritingTab(_poetryController, _addPoetryWriting, poetryWritings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingTab(TextEditingController controller, VoidCallback onSave, List<String> writings) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "اكتبي جديدك...",
              filled: true,
              fillColor: Colors.white.withOpacity(0.3), // ✅ إصلاح: withValues → withOpacity
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(onPressed: onSave, icon: const Icon(Icons.save), label: const Text("حفظ")),
          const SizedBox(height: 15),
          Expanded(child: ListView.builder(
            itemCount: writings.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(writings[index]),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCoupleList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink, size: 40),
              SizedBox(width: 10),
              Text("❤️ مهامنا المشتركة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: ListView.builder(
            itemCount: coupleTasks.length,
            itemBuilder: (context, index) => Card(
              color: Colors.pink.shade50,
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pink),
                title: Text(coupleTasks[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => coupleTasks.removeAt(index)),
                ),
              ),
            ),
          )),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton.icon(
              onPressed: _addCoupleTask,
              icon: const Icon(Icons.add),
              label: const Text("إضافة مهمة"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelLibrary() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("📚 مكتبة الروايات", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickNovel,
            icon: const Icon(Icons.add),
            label: const Text("إضافة رواية (PDF/Word)"),
          ),
          const SizedBox(height: 20),
          Expanded(child: novels.isEmpty
            ? const Center(child: Text("أضيفي روايتكِ الأولى!"))
            : ListView.builder(
                itemCount: novels.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Icon(
                      novels[index].type == 'pdf' ? Icons.picture_as_pdf : Icons.description,
                      color: novels[index].type == 'pdf' ? Colors.red : Colors.blue,
                    ),
                    title: Text(novels[index].name),
                    subtitle: novels[index].note.isNotEmpty ? Text(novels[index].note) : null,
                    onTap: () => _viewFile(novels[index].path),
                    trailing: IconButton(
                      icon: const Icon(Icons.note_add),
                      onPressed: () => _openNotePaper(index),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMemoryGallery() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("📸 معرض الذكريات", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addMemoryImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("إضافة صورة"),
          ),
          const SizedBox(height: 20),
          Expanded(child: memories.isEmpty
            ? const Center(child: Text("أضيفي ذكرياتكِ!"))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: memories.length,
                itemBuilder: (context, index) => _buildMemoryFrame(memories[index].path),
              )),
        ],
      ),
    );
  }

  Widget _buildMemoryFrame(String imagePath) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37), width: 8),
        boxShadow: const [BoxShadow(blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.file(File(imagePath), fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => 
            Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  Widget _buildGamesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("🎮 ألعاب آلاء", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addGame,
            icon: const Icon(Icons.add),
            label: const Text("إضافة لعبة"),
          ),
          const SizedBox(height: 20),
          Expanded(child: games.isEmpty
            ? const Center(child: Text("أضيفي ألعابكِ المفضلة!"))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) => _gameSticker(
                  games[index].name,
                  () => _launchGame(games[index].path),
                ),
              )),
        ],
      ),
    );
  }

  Widget _gameSticker(String name, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.3), blurRadius: 8)], // ✅ إصلاح
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports, color: Colors.pink, size: 40),
            const SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("🎵 مكتبة الموسيقى", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          if (currentSongName != null)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.pink.shade50,
              child: Text("🎵 الآن: $currentSongName"),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickAndPlayMusic,
            icon: const Icon(Icons.library_music),
            label: const Text("اختيار وتشغيل موسيقى"),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return const Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.construction, size: 80),
        SizedBox(height: 20),
        Text("قريباً...", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  void _showMusicMenu() {
    if (!mounted) return; // ✅ إصلاح
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎵 كاسيت آلاء", style: TextStyle(color: Colors.white, fontSize: 20)),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.amber),
              title: const Text("لحن التأمل", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.library_music, color: Colors.green),
              title: const Text("إضافة موسيقى من الجهاز", style: TextStyle(color: Colors.green)),
              onTap: () {
                Navigator.pop(context);
                _pickAndPlayMusic();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _skyAnimationController.dispose();
    _taskController.dispose();
    _proseController.dispose();
    _poetryController.dispose();
    _feelingController.dispose();
    _player.dispose();
    super.dispose();
  }

  // ================ منطقة ألعاب الهاتف ================
  Widget _buildMobileGameZone() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_android, size: 100, color: Colors.pink),
          const SizedBox(height: 20),
          const Text(
            "ألعاب الهاتف 📱",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _openMobileApp("com.tencent.ig"),
            icon: const Icon(Icons.sports_esports),
            label: const Text("فتح ببجي موبايل 🎮"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "ملاحظة: هذه الميزة تعمل على الهاتف فقط",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // دالة فتح تطبيقات الهاتف (مثل ببجي)
  void _openMobileApp(String packageName) async {
    try {
      final Uri url = Uri.parse("intent://#Intent;package=$packageName;scheme=package;end");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("لا يمكن فتح التطبيق: $packageName")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: \$e")),
      );
    }
  }
}