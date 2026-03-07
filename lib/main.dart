import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:open_file/open_file.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AlaaSplashScreen(),
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

// ================================================================
// ================ شاشة التحميل الدرامية ========================
// ================================================================
class AlaaSplashScreen extends StatefulWidget {
  const AlaaSplashScreen({super.key});
  @override
  State<AlaaSplashScreen> createState() => _AlaaSplashScreenState();
}

class _AlaaSplashScreenState extends State<AlaaSplashScreen>
    with TickerProviderStateMixin {
  // الأحرف التي ستُكتب
  final String _fullName = "Alaa";
  int _visibleChars = 0;
  bool _showCursor = true;
  bool _showSubtitle = false;
  bool _showGlow = false;
  Timer? _typingTimer;
  Timer? _cursorTimer;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
    _scaleController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scaleAnim = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _fadeController.forward();

    // كتابة الأحرف واحداً بعد الآخر
    int delay = 0;
    for (int i = 1; i <= _fullName.length; i++) {
      final charIndex = i;
      Future.delayed(Duration(milliseconds: 500 + delay), () {
        if (mounted) setState(() => _visibleChars = charIndex);
        if (charIndex == _fullName.length) {
          // بعد اكتمال الاسم
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              setState(() { _showGlow = true; _scaleController.forward(); });
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) setState(() => _showSubtitle = true);
                // الانتقال للتطبيق بعد ثانيتين
                Future.delayed(const Duration(milliseconds: 2200), () {
                  if (mounted) {
                    Navigator.pushReplacement(context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const AlaaAppHome(),
                        transitionDuration: const Duration(milliseconds: 800),
                        transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  }
                });
              });
            }
          });
        }
      });
      delay += 280; // تأخير بين كل حرف
    }

    // وميض المؤشر
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0a0a1a), Color(0xFF1a0a2e), Color(0xFF0a1a2e)],
            ),
          ),
          child: Stack(
            children: [
              // نجوم خلفية
              ...List.generate(30, (i) {
                final rand = Random(i * 7 + 3);
                return Positioned(
                  left: rand.nextDouble() * 400,
                  top: rand.nextDouble() * 900,
                  child: AnimatedOpacity(
                    opacity: _showGlow ? 0.8 : 0.3,
                    duration: Duration(milliseconds: 500 + i * 30),
                    child: Text("✦",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: rand.nextDouble() * 8 + 4,
                      )),
                  ),
                );
              }),

              // المحتوى المركزي
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الاسم يُكتب
                    ScaleTransition(
                      scale: _visibleChars == _fullName.length ? _scaleAnim
                        : const AlwaysStoppedAnimation(1.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ...List.generate(_visibleChars, (i) => AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              _fullName[i],
                              style: TextStyle(
                                fontSize: 82,
                                fontWeight: FontWeight.w100,
                                color: Colors.white,
                                letterSpacing: 8,
                                shadows: _showGlow ? [
                                  Shadow(color: Colors.pink.shade300, blurRadius: 30),
                                  Shadow(color: Colors.purple.shade300, blurRadius: 60),
                                ] : [],
                              ),
                            ),
                          )),
                          // مؤشر الكتابة
                          if (_visibleChars < _fullName.length)
                            AnimatedOpacity(
                              opacity: _showCursor ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                width: 3,
                                height: 70,
                                margin: const EdgeInsets.only(left: 4, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // خط تحت الاسم
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: _showGlow ? 120.0 : 0.0,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent,
                            Colors.pink.shade300, Colors.transparent]),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // العبارة تحت الاسم
                    AnimatedOpacity(
                      opacity: _showSubtitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Column(
                        children: [
                          Text("عالمكِ الخاص ✨",
                            style: TextStyle(
                              color: Colors.pink.shade200,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            )),
                          const SizedBox(height: 8),
                          Text("يُحمَّل بكل الحب 💕",
                            style: TextStyle(color: Colors.white30, fontSize: 13)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // مؤشر التحميل
                    AnimatedOpacity(
                      opacity: _showSubtitle ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 600),
                      child: SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  bool _isSidebarOpen = false; // مغلقة عند الفتح
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  bool _isPlaying = false;
  List<String> _cinemaVideos = [];          // صفحة السينما
  Timer? _timeOfDayTimer;                   // تحديث وقت اليوم
  String _timeOfDay = "morning";            // morning/afternoon/sunset/night

  // ================ متغيرات الورد اليومي ================
  int _currentDailyMessageIndex = 0;
  final List<Map<String, String>> _husbandMessages = [
    {"msg": "أحبكِ زوجتي 💕", "sub": "من أحب الناس إلى قلبك"},
    {"msg": "أعشقكِ أميرتي 👑", "sub": "أنتِ تاج فوق رأسي"},
    {"msg": "يوم جيد دلوعتي 🌸", "sub": "أتمنى يومكِ مليء بالسعادة"},
    {"msg": "نورتِ يومي يا آلاء ☀️", "sub": "ابتسامتكِ أجمل شيء"},
    {"msg": "فخور بكِ كل يوم 🌟", "sub": "ستكوني ممرضة رائعة"},
    {"msg": "أنتِ قوتي يا حياتي 💪", "sub": "معكِ أستطيع كل شيء"},
    {"msg": "اشتقت إليكِ 💌", "sub": "ما أجمل أن تكوني في حياتي"},
  ];

  // ================ متغيرات البومودورو ================
  Timer? _pomodoroTimer;
  int _pomodoroSeconds = 25 * 60;
  bool _pomodoroRunning = false;
  bool _isBreakTime = false;
  int _pomodoroCount = 0;

  // ================ متغيرات عداد الأيام ================
  DateTime? _specialDate;
  String _specialDateLabel = "تاريخ الزواج 💍";

  // ================ متغيرات الرسائل المقفلة ================
  List<Map<String, String>> _lockedMessages = [];

  // ================ متغيرات صفحة التمريض ================
  List<Map<String, String>> _nursingSchedule = [];
  List<String> _nursingNotes = [];
  List<String> _nursingFiles = [];
  final TextEditingController _nursingNoteController = TextEditingController();
  List<Map<String, String>> _alaaPersonalities = [
    {"name": "آلاء عفاش", "desc": "فنانة تشكيلية رائعة"},
    {"name": "آلاء حسانين", "desc": "أديبة وشاعرة موهوبة"},
    {"name": "آلاء المستقبل 🌸", "desc": "ممرضة ستغيّر حياة الكثيرين"},
  ];
  List<Map<String, String>> _alaaGoals = [
    {"goal": "التخرج من كلية التمريض 🎓", "done": "false"},
    {"goal": "أكون ممرضة محترفة 👩‍⚕️", "done": "false"},
  ];
  List<String> _alaaQuotes = [
    "النجاح ليس نهاية الطريق، بل بداية رحلة أجمل 🌟",
    "أنتِ أقوى مما تتخيلين 💪",
  ];
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
    _updateTimeOfDay();
    _timeOfDayTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTimeOfDay());
    // ساعة حقيقية
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    
    // إضافة بعض النجوم الافتراضية
    for (int i = 0; i < 10; i++) {
      stars.add(StarModel(
        Random().nextDouble() * 300,
        Random().nextDouble() * 500,
        floatOffset: Random().nextDouble() * 2 * pi,
      ));
    }
  }

  // ============================================================
  // حفظ وتحميل جميع البيانات
  // ============================================================
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final tasks = prefs.getStringList('tasks');
      if (tasks != null) alaaTasks = tasks.map((t) => Task(t)).toList();
      final couple = prefs.getStringList('coupleTasks');
      if (couple != null) coupleTasks = couple;
      final prose = prefs.getStringList('proseWritings');
      if (prose != null) proseWritings = prose;
      final poetry = prefs.getStringList('poetryWritings');
      if (poetry != null) poetryWritings = poetry;
      // الأغاني
      final songNames = prefs.getStringList('songNames') ?? [];
      final songPaths = prefs.getStringList('songPaths') ?? [];
      if (songNames.length == songPaths.length && songNames.isNotEmpty) {
        songs = List.generate(songNames.length, (i) => Song(songNames[i], songPaths[i]));
      }
      // الروايات
      final novelNames = prefs.getStringList('novelNames') ?? [];
      final novelPaths = prefs.getStringList('novelPaths') ?? [];
      final novelTypes = prefs.getStringList('novelTypes') ?? [];
      final novelNotes = prefs.getStringList('novelNotes') ?? [];
      if (novelNames.length == novelPaths.length && novelNames.isNotEmpty) {
        novels = List.generate(novelNames.length, (i) => Novel(
          novelNames[i], novelPaths[i],
          i < novelTypes.length ? novelTypes[i] : 'pdf',
          note: i < novelNotes.length ? novelNotes[i] : '',
        ));
      }
      // الألعاب
      final gameNames = prefs.getStringList('gameNames') ?? [];
      final gamePaths = prefs.getStringList('gamePaths') ?? [];
      if (gameNames.length == gamePaths.length && gameNames.isNotEmpty) {
        games = List.generate(gameNames.length, (i) => Game(gameNames[i], gamePaths[i]));
      }
      // الذكريات
      final memPaths = prefs.getStringList('memories') ?? [];
      if (memPaths.isNotEmpty) memories = memPaths.map((p) => MemoryImage(p)).toList();
      // السينما
      final cinema = prefs.getStringList('cinemaVideos');
      if (cinema != null) _cinemaVideos = cinema;
      // التمريض
      final nFiles = prefs.getStringList('nursingFiles');
      if (nFiles != null) _nursingFiles = nFiles;
      final nNotes = prefs.getStringList('nursingNotes');
      if (nNotes != null) _nursingNotes = nNotes;
      final schedSubj = prefs.getStringList('schedSubjects') ?? [];
      final schedTime = prefs.getStringList('schedTimes') ?? [];
      if (schedSubj.isNotEmpty) {
        _nursingSchedule = List.generate(schedSubj.length, (i) => {
          'subject': schedSubj[i],
          'time': i < schedTime.length ? schedTime[i] : '',
        });
      }
      // الرسائل المقفلة
      final lmTitles   = prefs.getStringList('lmTitles')   ?? [];
      final lmContents = prefs.getStringList('lmContents') ?? [];
      final lmDates    = prefs.getStringList('lmDates')    ?? [];
      final lmCreated  = prefs.getStringList('lmCreated')  ?? [];
      if (lmTitles.isNotEmpty) {
        _lockedMessages = List.generate(lmTitles.length, (i) => {
          'title':     lmTitles[i],
          'content':   i < lmContents.length ? lmContents[i] : '',
          'openDate':  i < lmDates.length    ? lmDates[i]    : '',
          'createdAt': i < lmCreated.length  ? lmCreated[i]  : '',
        });
      }
      // ركن آلاء
      final persNames = prefs.getStringList('persNames') ?? [];
      final persDescs = prefs.getStringList('persDescs') ?? [];
      if (persNames.isNotEmpty) {
        _alaaPersonalities = List.generate(persNames.length, (i) => {
          'name': persNames[i],
          'desc': i < persDescs.length ? persDescs[i] : '',
        });
      }
      final goalTexts = prefs.getStringList('goalTexts') ?? [];
      final goalDones = prefs.getStringList('goalDones') ?? [];
      if (goalTexts.isNotEmpty) {
        _alaaGoals = List.generate(goalTexts.length, (i) => {
          'goal': goalTexts[i],
          'done': i < goalDones.length ? goalDones[i] : 'false',
        });
      }
      final alaaQ = prefs.getStringList('alaaQuotes');
      if (alaaQ != null) _alaaQuotes = alaaQ;
      // عداد الأيام
      final dateStr = prefs.getString('specialDate');
      if (dateStr != null) _specialDate = DateTime.tryParse(dateStr);
      final dateLabel = prefs.getString('specialDateLabel');
      if (dateLabel != null) _specialDateLabel = dateLabel;
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', alaaTasks.map((t) => t.title).toList());
    await prefs.setStringList('coupleTasks', coupleTasks);
    await prefs.setStringList('proseWritings', proseWritings);
    await prefs.setStringList('poetryWritings', poetryWritings);
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('songNames',  songs.map((s) => s.name).toList());
    await prefs.setStringList('songPaths',  songs.map((s) => s.path).toList());
    await prefs.setStringList('novelNames', novels.map((n) => n.name).toList());
    await prefs.setStringList('novelPaths', novels.map((n) => n.path).toList());
    await prefs.setStringList('novelTypes', novels.map((n) => n.type).toList());
    await prefs.setStringList('novelNotes', novels.map((n) => n.note).toList());
    await prefs.setStringList('gameNames',  games.map((g) => g.name).toList());
    await prefs.setStringList('gamePaths',  games.map((g) => g.path).toList());
    await prefs.setStringList('memories',   memories.map((m) => m.path).toList());
    await prefs.setStringList('cinemaVideos', _cinemaVideos);
    await prefs.setStringList('nursingFiles', _nursingFiles);
    await prefs.setStringList('nursingNotes', _nursingNotes);
    await prefs.setStringList('schedSubjects', _nursingSchedule.map((e) => e['subject'] ?? '').toList());
    await prefs.setStringList('schedTimes',    _nursingSchedule.map((e) => e['time']    ?? '').toList());
    await prefs.setStringList('lmTitles',   _lockedMessages.map((m) => m['title']     ?? '').toList());
    await prefs.setStringList('lmContents', _lockedMessages.map((m) => m['content']   ?? '').toList());
    await prefs.setStringList('lmDates',    _lockedMessages.map((m) => m['openDate']  ?? '').toList());
    await prefs.setStringList('lmCreated',  _lockedMessages.map((m) => m['createdAt'] ?? '').toList());
    await prefs.setStringList('persNames', _alaaPersonalities.map((p) => p['name'] ?? '').toList());
    await prefs.setStringList('persDescs', _alaaPersonalities.map((p) => p['desc'] ?? '').toList());
    await prefs.setStringList('goalTexts', _alaaGoals.map((g) => g['goal'] ?? '').toList());
    await prefs.setStringList('goalDones', _alaaGoals.map((g) => g['done'] ?? 'false').toList());
    await prefs.setStringList('alaaQuotes', _alaaQuotes);
    if (_specialDate != null) await prefs.setString('specialDate', _specialDate!.toIso8601String());
    await prefs.setString('specialDateLabel', _specialDateLabel);
    await _saveTasks();
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
          _saveAll();
          
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
    if (!mounted) return;
    try {
      final file = File(path);
      if (!await file.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الملف غير موجود على الجهاز")));
        return;
      }
      final ext = path.split('.').last.toLowerCase();

      // ===== الصور: داخل التطبيق =====
      if (['jpg','jpeg','png','gif','webp','bmp','heic'].contains(ext)) {
        if (!mounted) return;
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => _ImageViewerPage(imagePath: path),
        ));
        return;
      }

      // ===== الفيديو: مشغل داخلي =====
      if (['mp4','mkv','avi','mov','webm','3gp','m4v'].contains(ext)) {
        if (!mounted) return;
        final name = path.split(Platform.pathSeparator).last;
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => _VideoPlayerPage(videoPath: path, videoName: name),
        ));
        return;
      }

      // ===== PDF والملفات الأخرى: قائمة التطبيقات (مثل واتساب) =====
      final result = await OpenFile.open(path);
      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تعذّر الفتح: ${result.message}")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")));
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
        _saveAll();
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
            _isPlaying = true;
            songs.add(Song(result.files.single.name, filePath));
          });
          _saveAll();
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
            _saveAll();
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
          // ✅ القائمة الجانبية قابلة للإخفاء
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarOpen ? 260 : 0,
            child: _isSidebarOpen ? _buildSidebar() : const SizedBox.shrink(),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientForIndex(),
                ),
              ),
              child: Stack(
                children: [
                  _buildMainContent(),
                  // ✅ زر إظهار/إخفاء القائمة
                  Positioned(
                    top: 10,
                    left: 10,
                    child: AnimatedRotation(
                      turns: _isSidebarOpen ? 0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      child: FloatingActionButton.small(
                        heroTag: "sidebar_toggle",
                        backgroundColor: Colors.pink.shade100,
                        onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
                        child: Icon(
                          _isSidebarOpen ? Icons.menu_open : Icons.menu,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
      case 11: return [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)];
      case 12: return [const Color(0xFF1a1a2e), const Color(0xFF16213e)];
      case 13: return [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
      case 14: return [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)];
      case 15: return [const Color(0xFFFCE4EC), const Color(0xFFF8BBD9)];
      case 16: return [const Color(0xFF0a0a0a), const Color(0xFF1a1a1a)];
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
                _sidebarItem(11, "📚 التمريض", Icons.medical_services),
                _sidebarItem(16, "🎬 السينما", Icons.movie),
                const Divider(),
                _sidebarItem(12, "🌙 ورد يومي", Icons.favorite_border),
                _sidebarItem(13, "⏱️ بومودورو", Icons.timer),
                _sidebarItem(14, "📅 عداد الأيام", Icons.calendar_today),
                _sidebarItem(15, "💌 رسائل مقفلة", Icons.lock),
                const Divider(),
                _alaaCornerSidebarItem(),
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
          // ✅ زر إغلاق القائمة
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
            tooltip: "إغلاق القائمة",
            onPressed: () => setState(() => _isSidebarOpen = false),
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
      onTap: () {
        setState(() {
          _selectedIndex = index;
          // ✅ إغلاق القائمة تلقائياً على الشاشات الصغيرة
          if (MediaQuery.of(context).size.width < 800) {
            _isSidebarOpen = false;
          }
        });
      },
    );
  }

  Widget _buildCassetteButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        children: [
          // اسم الأغنية الحالية
          if (currentSongName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                "🎵 ${currentSongName!.length > 20 ? currentSongName!.substring(0, 20) + '...' : currentSongName!}",
                style: const TextStyle(fontSize: 10, color: Colors.pink),
                textAlign: TextAlign.center,
              ),
            ),
          // أزرار التحكم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // زر إضافة أغنية
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.pink, size: 20),
                tooltip: "إضافة أغنية",
                onPressed: _pickAndPlayMusic,
              ),
              // زر تشغيل/إيقاف
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _player.pause();
                    setState(() => _isPlaying = false);
                  } else {
                    await _player.resume();
                    setState(() => _isPlaying = true);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isPlaying ? Colors.pink : Colors.pink.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _isPlaying ? Colors.white : Colors.pink,
                    size: 24,
                  ),
                ),
              ),
              // زر فتح قائمة الموسيقى
              IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.pink, size: 20),
                tooltip: "قائمة الأغاني",
                onPressed: _showMusicMenu,
              ),
            ],
          ),
          const Text("كاسيت آلاء 🎀", style: TextStyle(fontSize: 10, color: Colors.pink)),
        ],
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
      case 10: return _buildAlaaCornerPage();
      case 11: return _buildNursingPage();
      case 12: return _buildDailyWirdPage();
      case 13: return _buildPomodoroPage();
      case 14: return _buildDayCounterPage();
      case 15: return _buildLockedMessagesPage();
      case 16: return _buildCinemaPage();
      default: return _buildComingSoon();
    }
  }

  // ================ الصفحات المختلفة ================
  
  Widget _buildDashboard() {
    int completedTasks = alaaTasks.where((t) => t.isDone).length;
    int totalTasks = alaaTasks.length;
    String dailyQuote = dailyQuotes[_now.day % dailyQuotes.length];

    // تحديد تحية الوقت
    int hour = _now.hour;
    String greeting;
    String greetEmoji;
    if (hour >= 5 && hour < 12) { greeting = "صباح النور يا آلاء"; greetEmoji = "🌅"; }
    else if (hour >= 12 && hour < 17) { greeting = "طاب مساؤكِ يا أميرة"; greetEmoji = "☀️"; }
    else if (hour >= 17 && hour < 20) { greeting = "غروب جميل مثلكِ"; greetEmoji = "🌇"; }
    else { greeting = "تصبحين على خير يا نجمتي"; greetEmoji = "🌙"; }

    // يوم الأسبوع عربي
    const arabicDays = ["الاثنين","الثلاثاء","الأربعاء","الخميس","الجمعة","السبت","الأحد"];
    const arabicMonths = ["يناير","فبراير","مارس","أبريل","مايو","يونيو",
      "يوليو","أغسطس","سبتمبر","أكتوبر","نوفمبر","ديسمبر"];
    String dayName = arabicDays[_now.weekday - 1];
    String monthName = arabicMonths[_now.month - 1];
    String fullDate = "$dayName، ${_now.day} $monthName ${_now.year}";

    // تنسيق الساعة
    int h = _now.hour % 12;
    if (h == 0) h = 12;
    String ampm = _now.hour < 12 ? "ص" : "م";
    String timeStr = "${h.toString().padLeft(2,'0')}:${_now.minute.toString().padLeft(2,'0')}:${_now.second.toString().padLeft(2,'0')}";

    // ألوان حسب الوقت
    List<Color> bgColors = _getSkyColors();

    return SingleChildScrollView(
      child: Column(
        children: [
          // ===== بطاقة الوقت الرئيسية =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // تحية + اسم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(greetEmoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(greeting,
                      style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 16),
                // الساعة الكبيرة
                Text(timeStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 58,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(ampm,
                  style: const TextStyle(color: Colors.white60, fontSize: 18)),
                const SizedBox(height: 10),
                // التاريخ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(fullDate,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                // شريط التقدم في اليوم
                Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("تقدم اليوم", style: TextStyle(color: Colors.white60, fontSize: 12)),
                      Text("${((_now.hour * 60 + _now.minute) / 1440 * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_now.hour * 60 + _now.minute) / 1440,
                        minHeight: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== الحالة المزاجية + الإنجازات =====
                Row(
                  children: [
                    // الحالة
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.pink.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("حالتكِ اليوم", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(_getMoodEmoji(currentMood), style: const TextStyle(fontSize: 28)),
                            Text(_getMoodAnalysisTitle(currentMood),
                              style: TextStyle(color: Colors.pink.shade700, fontSize: 12,
                                fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // الإنجازات
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("مهامكِ اليوم", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text("$completedTasks/$totalTasks",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700)),
                            const Text("مهمة منجزة ✅",
                              style: TextStyle(color: Colors.orange, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // البومودورو
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIndex = 13),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.purple.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("البومودورو", style: TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text("$_pomodoroCount", style: TextStyle(fontSize: 28,
                                fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                              const Text("جلسة تركيز 🍅",
                                style: TextStyle(color: Colors.purple, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ===== اقتباس اليوم =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.pink.shade50]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Row(
                    children: [
                      const Text("❝", style: TextStyle(fontSize: 30, color: Colors.pink)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(dailyQuote,
                          style: const TextStyle(fontSize: 14, height: 1.5,
                            fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ===== رسالة اليوم من الزوج =====
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1a1a2e), const Color(0xFF2d1b4e)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text("💌", style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("رسالة اليوم من زوجكِ",
                                style: TextStyle(color: Colors.white60, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(
                                _husbandMessages[_now.weekday % _husbandMessages.length]["msg"] ?? "",
                                style: const TextStyle(color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white30),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ===== اختصارات سريعة =====
                const Text("وصول سريع ⚡",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                  children: [
                    _quickAccessItem(1, "المهام", "✅", Colors.green),
                    _quickAccessItem(4, "الأدبي", "✍️", Colors.purple),
                    _quickAccessItem(9, "موسيقى", "🎵", Colors.pink),
                    _quickAccessItem(11, "تمريض", "🏥", Colors.blue),
                    _quickAccessItem(7, "ذكريات", "📸", Colors.orange),
                    _quickAccessItem(6, "روايات", "📚", Colors.teal),
                    _quickAccessItem(16, "سينما", "🎬", Colors.red),
                    _quickAccessItem(13, "تركيز", "⏱️", Colors.indigo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(AlaaMood mood) {
    switch (mood) {
      case AlaaMood.warrior: return "⚔️";
      case AlaaMood.cute: return "🌸";
      case AlaaMood.peaceful: return "🌿";
      case AlaaMood.romantic: return "💕";
      case AlaaMood.pensive: return "🌙";
      case AlaaMood.exhausted: return "😴";
    }
  }

  Widget _quickAccessItem(int index, String label, String emoji, Color color) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    String tod;
    if (hour >= 5 && hour < 10) tod = "morning";
    else if (hour >= 10 && hour < 16) tod = "afternoon";
    else if (hour >= 16 && hour < 19) tod = "sunset";
    else tod = "night";
    if (tod != _timeOfDay) setState(() => _timeOfDay = tod);
  }

  List<Color> _getSkyColors() {
    switch (_timeOfDay) {
      case "morning":  return [const Color(0xFFFFE0B2), const Color(0xFF87CEEB)];
      case "afternoon":return [const Color(0xFF1976D2), const Color(0xFF42A5F5)];
      case "sunset":   return [const Color(0xFFFF6F00), const Color(0xFFE91E63)];
      default:         return [const Color(0xFF0B0B2B), const Color(0xFF1B1B4B)];
    }
  }

  String _getSkyEmoji() {
    switch (_timeOfDay) {
      case "morning":   return "🌅 صباح الجمال يا آلاء";
      case "afternoon": return "☀️ نهار مشرق مثلكِ";
      case "sunset":    return "🌇 غروب ساحر يا أميرة";
      default:          return "🌙 ليل هادئ يا نجمتي";
    }
  }

  Widget _buildLivingSky() {
    return AnimatedContainer(
      duration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getSkyColors(),
        ),
      ),
      child: Stack(
        children: [
          // النجوم
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
                    child: Draggable<int>(
                      data: idx,
                      feedback: Text(
                        _timeOfDay == "night" ? "⭐" : _timeOfDay == "sunset" ? "✨" : "🌸",
                        style: TextStyle(fontSize: 15.0 + (idx % 3) * 5),
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      onDragEnd: (drag) => setState(() {
                        final box = context.findRenderObject() as RenderBox?;
                        if (box != null) {
                          final local = box.globalToLocal(drag.offset);
                          star.x = local.dx;
                          star.y = local.dy;
                        }
                      }),
                      child: GestureDetector(
                        onPanUpdate: (details) => setState(() {
                          star.x += details.delta.dx;
                          star.y += details.delta.dy;
                        }),
                        child: Text(
                          _timeOfDay == "night" ? "⭐" : _timeOfDay == "sunset" ? "✨" : "🌸",
                          style: TextStyle(fontSize: 15.0 + (idx % 3) * 5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // عنصر الوقت في الأعلى
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(_getSkyEmoji(),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ),

          // الأزرار في الأسفل
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // سلة المهملات للنجوم
                if (stars.isNotEmpty)
                  DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      setState(() => stars.removeAt(details.data));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🗑️ تم حذف النجمة"), duration: Duration(seconds: 1)),
                      );
                    },
                    builder: (ctx, candidateData, rejectedData) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty ? Colors.red : Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: candidateData.isNotEmpty ? Colors.red : Colors.white30,
                          width: 2,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.delete_outline,
                          color: candidateData.isNotEmpty ? Colors.white : Colors.white60, size: 20),
                        const SizedBox(width: 6),
                        Text("🗑️ اسحبي النجمة هنا لحذفها",
                          style: TextStyle(
                            color: candidateData.isNotEmpty ? Colors.white : Colors.white60,
                            fontSize: 12)),
                      ]),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addStar,
                      icon: const Text("⭐"),
                      label: const Text("نجمة جديدة"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        isNightMode = !isNightMode;
                        _timeOfDay = isNightMode ? "night" : "morning";
                      }),
                      icon: Icon(_timeOfDay == "night" ? Icons.wb_sunny : Icons.nights_stay),
                      label: Text(_timeOfDay == "night" ? "نهار" : "ليل"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text("اسحبي النجوم لتشكيل اسمكِ في السماء ⭐",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
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
            itemBuilder: (context, index) => Dismissible(
              key: Key('${writings[index]}_$index'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red.shade400,
                child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
              ),
              onDismissed: (_) {
                setState(() => writings.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🗑️ تم الحذف")),
                );
              },
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(writings[index]),
                ),
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
                itemBuilder: (context, index) => Dismissible(
                  key: Key(novels[index].path),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.shade400,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                        Text("حذف", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    setState(() => novels.removeAt(index));
            _saveAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🗑️ تم حذف الرواية")),
                    );
                  },
                  child: Card(
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
                itemBuilder: (context, index) => GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("🗑️ حذف الصورة"),
                        content: const Text("هل تريدين حذف هذه الذكرى؟"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              setState(() => memories.removeAt(index));
                              _saveAll();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("🗑️ تم حذف الصورة")),
                              );
                            },
                            child: const Text("حذف", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: _buildMemoryFrame(memories[index].path),
                ),
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
                itemBuilder: (context, index) => Stack(
                  children: [
                    _gameSticker(games[index].name, () => _launchGame(games[index].path)),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => games.removeAt(index));
                          _saveAll();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("🗑️ تم حذف اللعبة")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
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
          const SizedBox(height: 10),
          // مشغل الأغنية الحالية
          if (currentSongName != null)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.purple.shade200]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text("🎵 $currentSongName",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                        onPressed: () async => await _player.seek(Duration.zero),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_isPlaying) {
                            await _player.pause();
                            setState(() => _isPlaying = false);
                          } else {
                            await _player.resume();
                            setState(() => _isPlaying = true);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.pink,
                            size: 32,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop, color: Colors.white, size: 30),
                        onPressed: () async {
                          await _player.stop();
                          setState(() {
                            _isPlaying = false;
                            currentSongName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _pickAndPlayMusic,
            icon: const Icon(Icons.add),
            label: const Text("إضافة أغنية"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 15),
          // قائمة الأغاني مع السحب للحذف
          Expanded(
            child: songs.isEmpty
              ? const Center(child: Text("أضيفي أغانيكِ المفضلة! 🎵"))
              : ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) => Dismissible(
                    key: Key(songs[index].path),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                          Text("حذف", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    onDismissed: (_) {
                      setState(() => songs.removeAt(index));
                      _saveAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🗑️ تم حذف الأغنية")),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: const Icon(Icons.music_note, color: Colors.pink),
                        ),
                        title: Text(songs[index].name),
                        trailing: IconButton(
                          icon: Icon(
                            currentSongName == songs[index].name && _isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                            color: Colors.pink,
                            size: 30,
                          ),
                          onPressed: () async {
                            if (currentSongName == songs[index].name && _isPlaying) {
                              await _player.pause();
                              setState(() => _isPlaying = false);
                            } else {
                              await _player.play(DeviceFileSource(songs[index].path));
                              setState(() {
                                currentSongName = songs[index].name;
                                _isPlaying = true;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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
    _nursingNoteController.dispose();
    _pomodoroTimer?.cancel();
    _timeOfDayTimer?.cancel();
    _clockTimer?.cancel();
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
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }


  // ================ زر ركن آلاء في القائمة ================
  Widget _alaaCornerSidebarItem() {
    bool isSelected = _selectedIndex == 10;
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.pink.shade50,
      leading: Icon(Icons.auto_awesome, color: isSelected ? Colors.pinkAccent : Colors.black54),
      title: Text("✨ ركن آلاء الخاص",
        style: TextStyle(color: isSelected ? Colors.pinkAccent : Colors.black87,
          fontWeight: FontWeight.bold)),
      onTap: () {
        setState(() {
          _selectedIndex = 10;
          // ✅ إغلاق القائمة تلقائياً على الشاشات الصغيرة
          if (MediaQuery.of(context).size.width < 800) {
            _isSidebarOpen = false;
          }
        });
      },
    );
  }

  // ================ صفحة ركن آلاء ================
  Widget _buildAlaaCornerPage() {
    final List<String> nameStyles = [
      "آلاء ✨", "𝓐𝓵𝓪𝓪 🌸", "𝔸𝕝𝕒𝕒 👑", "คɭคค 🎀", "A L A A 💎", "آلاءُ الرحمن 🕊️"
    ];

    final TextEditingController customStyleController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade300, Colors.purple.shade300],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text("👑", style: TextStyle(fontSize: 50)),
                SizedBox(height: 8),
                Text("ركن آلاء الخاص",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text("كل ما يخصّكِ في مكان واحد ✨",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // معنى الاسم في القرآن
          _alaaSection("📖 اسمكِ في القرآن الكريم"),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade50, Colors.teal.shade50]),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Text("34", style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text("مرة ذُكرت كلمة آلاء في القرآن الكريم\nتعني النعم والعطايا الإلهية التي لا تُحصى",
                          style: TextStyle(fontSize: 14, height: 1.5)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    "فَبِأَيِّ آلَاءِ رَبِّكُمَا تُكَذِّبَانِ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                      color: Colors.green, fontFamily: 'serif'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text("— سورة الرحمن",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // معنى الاسم
          _alaaSection("📚 معنى اسمكِ في اللغة"),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                "آلاء هو اسم عربي أصيل يعني «النعم» التي لا تُحصى،\nذُكر في القرآن الكريم 34 مرة ليدل على عظمة عطايا الخالق.\n\nفي علم النفس، يرمز الاسم للشخصية المعطاءة والذكية والمبدعة،\nصاحبته تتميز بالعطف والذكاء العاطفي العميق.",
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // صفات اسم آلاء
          _alaaSection("💎 صفات تحملها صاحبة هذا الاسم"),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              "💕 محبوبة", "🌟 موهوبة", "🧠 ذكية", "🌸 رقيقة",
              "💪 قوية", "🎨 مبدعة", "📚 مثقفة", "🌙 حالمة",
              "❤️ عطوفة", "👑 قيادية",
            ].map((trait) => Chip(
              label: Text(trait, style: const TextStyle(fontSize: 13)),
              backgroundColor: Colors.pink.shade50,
              side: BorderSide(color: Colors.pink.shade200),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // الزخارف
          _alaaSection("✍️ اسمكِ بزخارف مختلفة (اضغطي للنسخ)"),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: nameStyles.map((style) => ActionChip(
              label: Text(style, style: const TextStyle(fontSize: 16)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: style));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("تم نسخ: $style ✅")),
                );
              },
              backgroundColor: Colors.pink.shade50,
            )).toList(),
          ),
          const SizedBox(height: 20),

          // شخصيات ملهمة - قابلة للتعديل
          _alaaSection("🌟 شخصيات ملهمة بهذا الاسم"),
          ..._alaaPersonalities.asMap().entries.map((e) => Dismissible(
            key: Key('personality_${e.key}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red.shade300,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => setState(() { _alaaPersonalities.removeAt(e.key); _saveAll(); }),
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Text("⭐", style: TextStyle(fontSize: 22)),
                title: Text(e.value["name"] ?? ""),
                subtitle: Text(e.value["desc"] ?? ""),
              ),
            ),
          )),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _addAlaaPersonality,
            icon: const Icon(Icons.add),
            label: const Text("إضافة شخصية ملهمة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
              foregroundColor: Colors.pink.shade800,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // إضافة بصمة خاصة
          _alaaSection("💝 أضيفي بصمتكِ الخاصة"),
          TextField(
            controller: customStyleController,
            decoration: InputDecoration(
              hintText: "اكتبي هنا ما تحبين إضافته لاسمكِ...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.pink),
                onPressed: () {
                  if (customStyleController.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: customStyleController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم نسخ بصمتكِ ✅")),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _addAlaaPersonality() {
    if (!mounted) return;
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⭐ إضافة شخصية ملهمة"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: "اسم الشخصية",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descCtrl,
            decoration: InputDecoration(
              hintText: "وصف مختصر (لماذا تلهمكِ؟)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.star),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() => _alaaPersonalities.add({
                  "name": nameCtrl.text,
                  "desc": descCtrl.text,
                }));
                _saveAll();
                Navigator.pop(ctx);
              }
            },
            child: const Text("إضافة ✨", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addAlaaGoal() {
    if (!mounted) return;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🎯 إضافة هدف أو حلم"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "مثل: أكون ممرضة محترفة...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() => _alaaGoals.add({"goal": ctrl.text, "done": "false"}));
                _saveAll();
                Navigator.pop(ctx);
              }
            },
            child: const Text("إضافة ✨", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addAlaaQuote() {
    if (!mounted) return;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("💬 إضافة اقتباس مفضل"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "اكتبي اقتباسكِ المفضل...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() => _alaaQuotes.add(ctrl.text));
                _saveAll();
                Navigator.pop(ctx);
              }
            },
            child: const Text("حفظ 💕", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _alaaSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink.shade800)),
    );
  }

  // ================================================================
  // ================ 1. صفحة التمريض ================================
  // ================================================================
  Widget _buildNursingPage() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade500]),
            ),
            child: const TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(icon: Icon(Icons.calendar_month), text: "الجدول الدراسي"),
                Tab(icon: Icon(Icons.note_alt), text: "مذكرة التمريض"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ======= تاب الجدول - أيام ثابتة + مواد قابلة للتعديل =======
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade800, Colors.blue.shade500]),
                        ),
                        child: const Text("📅 جدولكِ الدراسي — اضغطي على خانة لتعديلها",
                          style: TextStyle(color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Table(
                            border: TableBorder.all(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.3),
                              1: FlexColumnWidth(2.2),
                              2: FlexColumnWidth(1.3),
                            },
                            children: [
                              // رأس الجدول
                              TableRow(
                                decoration: BoxDecoration(color: Colors.blue.shade700),
                                children: const [
                                  Padding(padding: EdgeInsets.all(10),
                                    child: Text("اليوم", textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 13))),
                                  Padding(padding: EdgeInsets.all(10),
                                    child: Text("المادة", textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 13))),
                                  Padding(padding: EdgeInsets.all(10),
                                    child: Text("الوقت", textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold, fontSize: 13))),
                                ],
                              ),
                              // صفوف الأيام
                              ...List.generate(6, (idx) {
                                final days = ["السبت","الأحد","الاثنين","الثلاثاء","الأربعاء","الخميس"];
                                final day = days[idx];
                                final entry = _nursingSchedule.length > idx
                                  ? _nursingSchedule[idx] : <String,String>{};
                                final subject = entry["subject"] ?? "";
                                final time = entry["time"] ?? "";
                                final isEven = idx.isEven;
                                return TableRow(
                                  decoration: BoxDecoration(
                                    color: isEven ? Colors.white : Colors.blue.shade50),
                                  children: [
                                    // اليوم
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(day,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.blue.shade800,
                                          fontSize: 13)),
                                    ),
                                    // المادة - قابلة للنقر
                                    GestureDetector(
                                      onTap: () => _editNursingCell(idx, "subject"),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                subject.isEmpty ? "اضغطي للإضافة" : subject,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: subject.isEmpty
                                                    ? Colors.blue.shade300
                                                    : Colors.black87,
                                                  fontStyle: subject.isEmpty
                                                    ? FontStyle.italic : FontStyle.normal,
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.edit,
                                              size: 12,
                                              color: Colors.blue.shade200),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // الوقت - قابل للنقر
                                    GestureDetector(
                                      onTap: () => _editNursingCell(idx, "time"),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          time.isEmpty ? "—" : time,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: time.isEmpty
                                              ? Colors.blue.shade200 : Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextButton.icon(
                          onPressed: () { setState(() => _nursingSchedule.clear()); _saveAll(); },
                          icon: const Icon(Icons.refresh, color: Colors.red, size: 18),
                          label: const Text("مسح الجدول",
                            style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ======= تاب المذكرة =======
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // حقل كتابة الملاحظة
                      TextField(
                        controller: _nursingNoteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "اكتبي ملاحظاتك الدراسية هنا يا آلاء...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save, color: Colors.blue),
                            onPressed: () {
                              if (_nursingNoteController.text.isNotEmpty) {
                                setState(() {
                                  _nursingNotes.insert(0, _nursingNoteController.text);
                  _saveAll();
                                  _nursingNoteController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // أزرار إضافة الملفات
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _addNursingImage,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: const Text("إضافة صورة"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _addNursingPdf,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text("إضافة PDF"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // قائمة الملفات والملاحظات
                      Expanded(
                        child: ListView(
                          children: [
                            if (_nursingFiles.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("📎 الملفات المرفقة", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ),
                              ..._nursingFiles.asMap().entries.map((e) => Dismissible(
                                key: Key('nfile_${e.key}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) { setState(() => _nursingFiles.removeAt(e.key)); _saveAll(); },
                                child: Card(
                                  child: ListTile(
                                    leading: Icon(
                                      e.value.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.image,
                                      color: e.value.endsWith('.pdf') ? Colors.red : Colors.green,
                                    ),
                                    title: Text(e.value.split('/').last),
                                    onTap: () => _viewFile(e.value),
                                  ),
                                ),
                              )),
                            ],
                            if (_nursingNotes.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("📝 ملاحظاتي", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              ),
                              ..._nursingNotes.asMap().entries.map((e) => Dismissible(
                                key: Key('nnote_${e.key}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.red, alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) { setState(() => _nursingNotes.removeAt(e.key)); _saveAll(); },
                                child: Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.note, color: Colors.blue),
                                    title: Text(e.value),
                                  ),
                                ),
                              )),
                            ],
                            if (_nursingNotes.isEmpty && _nursingFiles.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Text("أضيفي ملاحظاتكِ وملفاتكِ الدراسية 📚",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addNursingScheduleItem() {
    if (!mounted) return;
    final dayCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("📅 إضافة مادة للجدول"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: subjectCtrl,
            decoration: InputDecoration(
              hintText: "اسم المادة (مثل: تشريح)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.book, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dayCtrl,
            decoration: InputDecoration(
              hintText: "اليوم (مثل: الأحد)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: timeCtrl,
            decoration: InputDecoration(
              hintText: "الوقت (مثل: 8:00 ص)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.access_time, color: Colors.blue),
            ),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            onPressed: () {
              if (subjectCtrl.text.isNotEmpty) {
                setState(() => _nursingSchedule.add({
                  "subject": subjectCtrl.text,
                  "day": dayCtrl.text,
                  "time": timeCtrl.text,
                }));
                _saveAll();
                Navigator.pop(ctx);
              }
            },
            child: const Text("إضافة ✅", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addNursingImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() => _nursingFiles.insert(0, result.files.single.path!));
        _saveAll();
      }
    } catch (e) { if (!mounted) return; }
  }

  Future<void> _addNursingPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() => _nursingFiles.insert(0, result.files.single.path!));
        _saveAll();
      }
    } catch (e) { if (!mounted) return; }
  }

  // ================================================================
  // ================ 2. صفحة الورد اليومي ==========================
  // ================================================================
  Widget _buildDailyWirdPage() {
    final msg = _husbandMessages[DateTime.now().weekday % _husbandMessages.length];
    final loving = _husbandMessages[_currentDailyMessageIndex];

    return SingleChildScrollView(
      child: Column(
        children: [
          // رسالة الزوج اليومية
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Colors.pink, size: 50),
                const SizedBox(height: 16),
                const Text("💌 رسالة من زوجكِ",
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 12),
                Text(loving["msg"]!,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(loving["sub"]!,
                  style: TextStyle(color: Colors.pink.shade200, fontSize: 14),
                  textAlign: TextAlign.center),
                const SizedBox(height: 20),
                // أزرار التنقل بين الرسائل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white60),
                      onPressed: () => setState(() =>
                        _currentDailyMessageIndex = (_currentDailyMessageIndex - 1 + _husbandMessages.length) % _husbandMessages.length),
                    ),
                    Text("${_currentDailyMessageIndex + 1}/${_husbandMessages.length}",
                      style: const TextStyle(color: Colors.white60)),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white60),
                      onPressed: () => setState(() =>
                        _currentDailyMessageIndex = (_currentDailyMessageIndex + 1) % _husbandMessages.length),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // الورد والأذكار
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🌙 ورد يومي مقترح",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 15),
                ...[
                  {"icon": "☀️", "text": "أذكار الصباح", "count": "10 دقائق"},
                  {"icon": "📖", "text": "قراءة ورد القرآن", "count": "ربع حزب"},
                  {"icon": "🌿", "text": "الاستغفار", "count": "100 مرة"},
                  {"icon": "💫", "text": "الصلاة على النبي", "count": "100 مرة"},
                  {"icon": "🌙", "text": "أذكار المساء", "count": "10 دقائق"},
                ].map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: const Color(0xFF1a1a2e).withOpacity(0.7),
                  child: ListTile(
                    leading: Text(item["icon"]!, style: const TextStyle(fontSize: 24)),
                    title: Text(item["text"]!, style: const TextStyle(color: Colors.white)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item["count"]!, style: const TextStyle(color: Colors.pink, fontSize: 12)),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ================ 3. صفحة البومودورو =============================
  // ================================================================
  Widget _buildPomodoroPage() {
    int minutes = _pomodoroSeconds ~/ 60;
    int seconds = _pomodoroSeconds % 60;
    double progress = _isBreakTime
      ? 1 - (_pomodoroSeconds / (5 * 60))
      : 1 - (_pomodoroSeconds / (25 * 60));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isBreakTime ? "☕ وقت الراحة" : "📚 وقت التركيز",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                color: _isBreakTime ? Colors.green : Colors.purple),
            ),
            const SizedBox(height: 10),
            Text("جلسات مكتملة: $_pomodoroCount 🌸",
              style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            // دائرة التايمر
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isBreakTime ? Colors.green : Colors.purple),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Text(_pomodoroRunning ? "جارٍ..." : "متوقف",
                        style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // إعادة تعيين
                IconButton(
                  icon: const Icon(Icons.refresh, size: 32, color: Colors.grey),
                  onPressed: () {
                    _pomodoroTimer?.cancel();
                    setState(() {
                      _pomodoroSeconds = 25 * 60;
                      _pomodoroRunning = false;
                      _isBreakTime = false;
                    });
                  },
                ),
                const SizedBox(width: 20),
                // تشغيل/إيقاف
                GestureDetector(
                  onTap: () {
                    if (_pomodoroRunning) {
                      _pomodoroTimer?.cancel();
                      setState(() => _pomodoroRunning = false);
                    } else {
                      setState(() => _pomodoroRunning = true);
                      _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (t) {
                        if (_pomodoroSeconds > 0) {
                          setState(() => _pomodoroSeconds--);
                        } else {
                          t.cancel();
                          setState(() {
                            _pomodoroRunning = false;
                            if (!_isBreakTime) {
                              _pomodoroCount++;
                              _isBreakTime = true;
                              _pomodoroSeconds = 5 * 60;
                            } else {
                              _isBreakTime = false;
                              _pomodoroSeconds = 25 * 60;
                            }
                          });
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isBreakTime ? Colors.green : Colors.purple,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: (_isBreakTime ? Colors.green : Colors.purple).withOpacity(0.4),
                        blurRadius: 20,
                      )],
                    ),
                    child: Icon(_pomodoroRunning ? Icons.pause : Icons.play_arrow,
                      color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                // تخطي
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 32, color: Colors.grey),
                  onPressed: () {
                    _pomodoroTimer?.cancel();
                    setState(() {
                      _pomodoroRunning = false;
                      _isBreakTime = !_isBreakTime;
                      _pomodoroSeconds = _isBreakTime ? 5 * 60 : 25 * 60;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "25 دقيقة تركيز ← 5 دقائق راحة\nبعد 4 جلسات خذي راحة طويلة 💜",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.purple, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ================ 4. صفحة عداد الأيام ===========================
  // ================================================================
  Widget _buildDayCounterPage() {
    int daysPassed = _specialDate != null
      ? DateTime.now().difference(_specialDate!).inDays
      : 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite, color: Colors.pink, size: 60),
          const SizedBox(height: 10),
          Text(_specialDateLabel,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          if (_specialDate != null) ...[
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade400, Colors.teal.shade400]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text("$daysPassed",
                    style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("يوم مضى 💕",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "منذ ${_specialDate!.day}/${_specialDate!.month}/${_specialDate!.year}",
              style: const TextStyle(color: Colors.grey),
            ),
          ] else
            const Text("اضغطي لتحديد التاريخ المميز 📅",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                if (!mounted) return;
                setState(() => _specialDate = picked); _saveAll();
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text("تحديد التاريخ"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              final ctrl = TextEditingController(text: _specialDateLabel);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("تسمية المناسبة"),
                  content: TextField(controller: ctrl),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _specialDateLabel = ctrl.text); _saveAll();
                        Navigator.pop(ctx);
                      },
                      child: const Text("حفظ"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("✏️ تغيير اسم المناسبة"),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ================ 5. صفحة الرسائل المقفلة =======================
  // ================================================================
  Widget _buildLockedMessagesPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text("💌 الرسائل المقفلة",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("اكتبي رسالة لنفسكِ في المستقبل",
            style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addLockedMessage,
            icon: const Icon(Icons.lock),
            label: const Text("رسالة جديدة مقفلة 💌"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _lockedMessages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 60, color: Colors.pink),
                      SizedBox(height: 10),
                      Text("لا توجد رسائل مقفلة بعد\nاكتبي أولى رسائلكِ للمستقبل 💌",
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _lockedMessages.length,
                  itemBuilder: (ctx, i) {
                    final msg = _lockedMessages[i];
                    final openDate = DateTime.tryParse(msg["openDate"] ?? "");
                    final canOpen = openDate == null || DateTime.now().isAfter(openDate);
                    return Dismissible(
                      key: Key('lmsg_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) { setState(() => _lockedMessages.removeAt(i)); _saveAll(); },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Icon(
                            canOpen ? Icons.lock_open : Icons.lock,
                            color: canOpen ? Colors.green : Colors.pink,
                          ),
                          title: Text(msg["title"] ?? "رسالة"),
                          subtitle: Text(openDate != null
                            ? "تُفتح في: ${openDate.day}/${openDate.month}/${openDate.year}"
                            : "متاحة الآن"),
                          trailing: canOpen
                            ? IconButton(
                                icon: const Icon(Icons.open_in_new, color: Colors.pink),
                                onPressed: () => _openLockedMessage(msg),
                              )
                            : const Icon(Icons.hourglass_empty, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void _addLockedMessage() {
    if (!mounted) return;
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text("💌 رسالة جديدة"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: "عنوان الرسالة"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: msgCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "اكتبي رسالتكِ هنا...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(selectedDate != null
                    ? "تُفتح: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : "اختاري تاريخ الفتح (اختياري)"),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setStateDialog(() => selectedDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                if (msgCtrl.text.isNotEmpty) {
                  setState(() => _lockedMessages.add({
                    "title": titleCtrl.text.isEmpty ? "رسالة لآلاء 💌" : titleCtrl.text,
                    "content": msgCtrl.text,
                    "openDate": selectedDate?.toIso8601String() ?? "",
                    "createdAt": DateTime.now().toIso8601String(),
                  }));
                  Navigator.pop(ctx);
                }
              },
              child: const Text("حفظ 🔒", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _openLockedMessage(Map<String, String> msg) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("💌 ${msg['title']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(msg["content"] ?? "", style: const TextStyle(fontSize: 16, height: 1.6)),
              const SizedBox(height: 15),
              Text(
                "كُتبت في: ${DateTime.tryParse(msg['createdAt'] ?? '')?.day ?? '—'}/${DateTime.tryParse(msg['createdAt'] ?? '')?.month ?? '—'}/${DateTime.tryParse(msg['createdAt'] ?? '')?.year ?? '—'}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إغلاق 💕")),
        ],
      ),
    );
  }

  void _editNursingCell(int rowIndex, String field) {
    if (!mounted) return;
    final ctrl = TextEditingController(
      text: _nursingSchedule.length > rowIndex ? _nursingSchedule[rowIndex][field] ?? "" : "");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(field == "subject" ? "📚 اسم المادة" : "🕐 وقت المحاضرة"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: field == "subject" ? "مثل: تشريح، فسيولوجيا..." : "مثل: 8:00 ص",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            onPressed: () {
              setState(() {
                while (_nursingSchedule.length <= rowIndex) {
                  _nursingSchedule.add({"subject": "", "time": ""});
                  _saveAll();
                }
                _nursingSchedule[rowIndex][field] = ctrl.text;
                _saveAll();
              });
              Navigator.pop(ctx);
            },
            child: const Text("حفظ ✅", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ================ صفحة السينما ===================================
  // ================================================================
  Widget _buildCinemaPage() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a1a1a), Color(0xFF0a0a0a)],
              ),
            ),
            child: Row(
              children: [
                const Text("🎬", style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("سينما آلاء 🍿",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("أفلامكِ في مكان واحد",
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addCinemaVideo,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("إضافة فيديو"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          // قائمة الفيديوهات
          Expanded(
            child: _cinemaVideos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🎥", style: TextStyle(fontSize: 70)),
                      const SizedBox(height: 16),
                      const Text("لا توجد أفلام بعد يا آلاء",
                        style: TextStyle(color: Colors.white60, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text("أضيفي أول فيديو لتبدأي السينما 🍿",
                        style: TextStyle(color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addCinemaVideo,
                        icon: const Icon(Icons.movie),
                        label: const Text("إضافة فيديو"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _cinemaVideos.length,
                  itemBuilder: (ctx, i) {
                    final path = _cinemaVideos[i];
                    final name = path.split('/').last.split('\\').last;
                    return Dismissible(
                      key: Key('cinema_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) { setState(() => _cinemaVideos.removeAt(i)); _saveAll(); },
                      child: GestureDetector(
                        onTap: () => _playCinemaVideo(path, name),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1e1e1e),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.play_circle_filled,
                                  color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                      style: const TextStyle(color: Colors.white,
                                        fontSize: 15, fontWeight: FontWeight.w500),
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    const Text("اضغطي للمشاهدة 🎬",
                                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.white24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCinemaVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        setState(() => _cinemaVideos.insert(0, result.files.single.path!));
        _saveAll();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")));
    }
  }

  Future<void> _playCinemaVideo(String path, String name) async {
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _VideoPlayerPage(videoPath: path, videoName: name),
    ));
  }
}

// ================================================================
// ================ صفحة عرض الصور ================================
// ================================================================
class _ImageViewerPage extends StatefulWidget {
  final String imagePath;
  const _ImageViewerPage({required this.imagePath});
  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage>
    with SingleTickerProviderStateMixin {
  bool _showUI = true;
  late AnimationController _uiFadeCtrl;
  late Animation<double> _uiFade;
  final TransformationController _transformCtrl = TransformationController();
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _uiFadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 250));
    _uiFade = CurvedAnimation(parent: _uiFadeCtrl, curve: Curves.easeInOut);
    _uiFadeCtrl.value = 1.0;
    _startHideTimer();
  }

  @override
  void dispose() {
    _uiFadeCtrl.dispose();
    _transformCtrl.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showUI) {
        setState(() => _showUI = false);
        _uiFadeCtrl.reverse();
      }
    });
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiFadeCtrl.forward();
      _startHideTimer();
    } else {
      _uiFadeCtrl.reverse();
    }
  }

  void _resetZoom() {
    _transformCtrl.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.imagePath.split(Platform.pathSeparator).last;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===== الصورة مع تكبير/تصغير =====
          GestureDetector(
            onTap: _toggleUI,
            onDoubleTap: () {
              if (_transformCtrl.value != Matrix4.identity()) {
                _resetZoom();
              } else {
                final zoomed = Matrix4.identity()..scale(2.5);
                _transformCtrl.value = zoomed;
              }
            },
            child: InteractiveViewer(
              transformationController: _transformCtrl,
              minScale: 0.3,
              maxScale: 8.0,
              child: Center(
                child: Hero(
                  tag: widget.imagePath,
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, err, __) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image_outlined,
                          color: Colors.white24, size: 80),
                        const SizedBox(height: 16),
                        const Text("تعذّر تحميل الصورة",
                          style: TextStyle(color: Colors.white38, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ===== شريط علوي =====
          FadeTransition(
            opacity: _uiFade,
            child: Container(
              height: 110,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(name,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out_map,
                        color: Colors.white, size: 22),
                      tooltip: "إعادة الحجم",
                      onPressed: _resetZoom,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 22),
                      tooltip: "مشاركة",
                      onPressed: () async {
                        await OpenFile.open(widget.imagePath);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ===== شريط سفلي (تعليمات) =====
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: FadeTransition(
              opacity: _uiFade,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: const Text(
                  "انقري مرتين للتكبير • اسحبي للتنقل",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerPage extends StatefulWidget {
  final String videoPath;
  final String videoName;
  const _VideoPlayerPage({required this.videoPath, required this.videoName});
  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  String _errorMsg = "";
  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;
  late AnimationController _controlsFadeCtrl;
  late Animation<double> _controlsFade;

  @override
  void initState() {
    super.initState();
    _controlsFadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));
    _controlsFade = CurvedAnimation(
      parent: _controlsFadeCtrl, curve: Curves.easeInOut);
    _controlsFadeCtrl.value = 1.0;
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller.initialize();
      _controller.addListener(() { if (mounted) setState(() {}); });
      if (mounted) {
        setState(() => _initialized = true);
        _controller.play();
        _startHideTimer();
      }
    } catch (e) {
      if (mounted) setState(() {
        _hasError = true;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controlsFadeCtrl.dispose();
    if (_initialized) _controller.dispose();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showControls && _initialized && _controller.value.isPlaying) {
        setState(() => _showControls = false);
        _controlsFadeCtrl.reverse();
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _controlsFadeCtrl.forward();
      _startHideTimer();
    } else {
      _controlsFadeCtrl.reverse();
    }
  }

  void _seekRelative(int seconds) {
    final pos = _controller.value.position;
    final dur = _controller.value.duration;
    final newPos = Duration(
      seconds: (pos.inSeconds + seconds).clamp(0, dur.inSeconds));
    _controller.seekTo(newPos);
    _startHideTimer();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.videoName.replaceAll(RegExp(r'\.[^.]+\$'), '');
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ===== الفيديو =====
            Center(
              child: _hasError
                ? _buildError()
                : !_initialized
                  ? _buildLoading()
                  : AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
            ),

            // ===== طبقة التحكم =====
            if (_initialized && !_hasError)
              FadeTransition(
                opacity: _controlsFade,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0, 0.15, 0.75, 1],
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // ===== شريط علوي =====
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(name,
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 14,
                                    fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // ===== أزرار التحكم المركزية =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ترجيع 10 ثواني
                          GestureDetector(
                            onTap: () => _seekRelative(-10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.replay_10,
                                    color: Colors.white, size: 28),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // تشغيل / إيقاف
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                              });
                              _startHideTimer();
                            },
                            child: Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white38, width: 1.5),
                              ),
                              child: Icon(
                                _controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                                color: Colors.white, size: 38),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // تقديم 10 ثواني
                          GestureDetector(
                            onTap: () => _seekRelative(10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.forward_10,
                                color: Colors.white, size: 28),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ===== شريط التقدم والوقت =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // شريط التقدم
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                                trackHeight: 3,
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.white,
                                overlayColor: Colors.white12,
                              ),
                              child: Slider(
                                value: _controller.value.position.inMilliseconds
                                  .toDouble().clamp(
                                    0,
                                    _controller.value.duration.inMilliseconds
                                      .toDouble()),
                                min: 0,
                                max: _controller.value.duration.inMilliseconds
                                  .toDouble().clamp(1, double.infinity),
                                onChanged: (v) {
                                  _controller.seekTo(Duration(
                                    milliseconds: v.toInt()));
                                  _startHideTimer();
                                },
                              ),
                            ),
                            // الوقت
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4),
                              child: Row(
                                mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                      _controller.value.position),
                                    style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                                  // حالة تشغيل
                                  if (_controller.value.isBuffering)
                                    const SizedBox(
                                      width: 14, height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white54)),
                                  Text(
                                    _formatDuration(
                                      _controller.value.duration),
                                    style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white54, strokeWidth: 2)),
        ),
        const SizedBox(height: 16),
        const Text("جاري تحميل الفيديو...",
          style: TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text("تعذّر تشغيل الفيديو",
            style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 8),
          Text(_errorMsg,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() { _hasError = false; _initialized = false; });
              await _initVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text("إعادة المحاولة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("رجوع",
              style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }
}
