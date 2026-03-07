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

// موديل المعلومة
class InfoNote {
  String title;
  String content;
  String category; // ديني / علمي / طبي / تاريخي / أخرى
  String emoji;
  bool isFavorite;
  InfoNote(this.title, this.content, this.category,
    {this.emoji = "💡", this.isFavorite = false});
}

class StarModel {
  double x, y;
  double floatOffset;
  StarModel(this.x, this.y, {this.floatOffset = 0});
}

// موديل الذكريات المشتركة
class CoupleMemory {
  String title;
  String date;
  String note;
  String emoji;
  CoupleMemory(this.title, this.date, this.note, {this.emoji = "💕"});
}

// موديل تحديات الأسبوع
class WeekChallenge {
  String title;
  String description;
  bool alaasDone;
  bool husbandDone;
  String emoji;
  WeekChallenge(this.title, this.description,
    {this.alaasDone = false, this.husbandDone = false, this.emoji = "🏆"});
}

// موديل الكورسات
class CourseItem {
  String name;
  String category;  // مهارات / لغات / طب / تقنية / أخرى
  String videoUrl;
  String notes;
  bool isDone;
  String emoji;
  CourseItem(this.name, this.category,
    {this.videoUrl = "", this.notes = "", this.isDone = false, this.emoji = "📚"});
}

class RecipeModel {
  String name;
  String category;   // حلويات / رئيسية / مشروبات / سلطات
  String ingredients;
  String steps;
  String emoji;
  bool isFavorite;
  RecipeModel(this.name, this.category, this.ingredients, this.steps,
    {this.emoji = "🍽️", this.isFavorite = false});

  Map<String, String> toMap() => {
    "name": name, "category": category, "ingredients": ingredients,
    "steps": steps, "emoji": emoji, "fav": isFavorite ? "1" : "0",
  };
  static RecipeModel fromMap(Map<String, String> m) => RecipeModel(
    m["name"] ?? "", m["category"] ?? "", m["ingredients"] ?? "",
    m["steps"] ?? "", emoji: m["emoji"] ?? "🍽️",
    isFavorite: m["fav"] == "1",
  );
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
  List<String> _cinemaVideos = [];
  List<Map<String,String>> _coupleVideos = []; // روابط فيديوهات قائمة مع زوجي
  List<CoupleMemory> _coupleMemories = [];
  List<WeekChallenge> _weekChallenges = [];
  List<CourseItem> _courses = [];
  List<InfoNote> _infoNotes = [];
  String _infoCategory = "الكل";
  String _courseCategory = "الكل";
  String _moodNote = "";
  List<Map<String,String>> _moodHistory = []; // سجل المزاج
  List<RecipeModel> _recipes = [];
  String _recipeCategory = "الكل";          // صفحة السينما
  Timer? _timeOfDayTimer;                   // تحديث وقت اليوم
  String _timeOfDay = "morning";            // morning/afternoon/sunset/night
  String _natureScene = "sky";              // sky/river/waterfall/nature/farm
  final AudioPlayer _meditationPlayer = AudioPlayer();
  bool _meditationSoundOn = true;           // وضع الصوت مفعّل/مغلق

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
    
    // تهيئة مشغل التأمل
    _meditationPlayer.setReleaseMode(ReleaseMode.loop);
    _meditationPlayer.setVolume(0.65);

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
      final cvTitles = prefs.getStringList('coupleVideoTitles') ?? [];
      final cvUrls   = prefs.getStringList('coupleVideoUrls')   ?? [];
      if (cvTitles.isNotEmpty) {
        _coupleVideos = List.generate(cvTitles.length, (i) => {
          'title': cvTitles[i],
          'url':   i < cvUrls.length ? cvUrls[i] : '',
        });
      }
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
      // الوصفات
      // ===== الذكريات المشتركة =====
      final cmT = prefs.getStringList('cmTitles') ?? [];
      final cmD = prefs.getStringList('cmDates')  ?? [];
      final cmN = prefs.getStringList('cmNotes')  ?? [];
      final cmE = prefs.getStringList('cmEmojis') ?? [];
      if (cmT.isNotEmpty) {
        _coupleMemories = List.generate(cmT.length, (i) => CoupleMemory(
          cmT[i], i < cmD.length ? cmD[i] : '',
          i < cmN.length ? cmN[i] : '',
          emoji: i < cmE.length ? cmE[i] : '💕'));
      }
      // ===== تحديات الأسبوع =====
      final wcT = prefs.getStringList('wcTitles') ?? [];
      final wcD = prefs.getStringList('wcDescs')  ?? [];
      final wcE = prefs.getStringList('wcEmojis') ?? [];
      final wcA = prefs.getStringList('wcAlaa')   ?? [];
      final wcH = prefs.getStringList('wcHusb')   ?? [];
      if (wcT.isNotEmpty) {
        _weekChallenges = List.generate(wcT.length, (i) => WeekChallenge(
          wcT[i], i < wcD.length ? wcD[i] : '',
          emoji: i < wcE.length ? wcE[i] : '🏆',
          alaasDone:  i < wcA.length ? wcA[i] == '1' : false,
          husbandDone: i < wcH.length ? wcH[i] == '1' : false));
      }
      // ===== المعلومات =====
      final inT = prefs.getStringList('infoTitles')   ?? [];
      final inC = prefs.getStringList('infoContents') ?? [];
      final inCt= prefs.getStringList('infoCats')     ?? [];
      final inE = prefs.getStringList('infoEmojis')   ?? [];
      final inF = prefs.getStringList('infoFavs')     ?? [];
      if (inT.isNotEmpty) {
        _infoNotes = List.generate(inT.length, (i) => InfoNote(
          inT[i], i < inC.length ? inC[i] : '',
          i < inCt.length ? inCt[i] : 'أخرى',
          emoji: i < inE.length ? inE[i] : '💡',
          isFavorite: i < inF.length ? inF[i] == '1' : false));
      }
      // ===== الكورسات =====
      final cN = prefs.getStringList('courseNames') ?? [];
      final cC = prefs.getStringList('courseCats')  ?? [];
      final cU = prefs.getStringList('courseUrls')  ?? [];
      final cNt= prefs.getStringList('courseNotes') ?? [];
      final cEm= prefs.getStringList('courseEmoji') ?? [];
      final cDn= prefs.getStringList('courseDone')  ?? [];
      if (cN.isNotEmpty) {
        _courses = List.generate(cN.length, (i) => CourseItem(
          cN[i], i < cC.length ? cC[i] : 'أخرى',
          videoUrl: i < cU.length  ? cU[i]  : '',
          notes:    i < cNt.length ? cNt[i] : '',
          emoji:    i < cEm.length ? cEm[i] : '📚',
          isDone:   i < cDn.length ? cDn[i] == '1' : false));
      }
      // ===== المزاج =====
      _moodNote = prefs.getString('moodNote') ?? '';
      final mhT = prefs.getStringList('moodHistTimes')  ?? [];
      final mhV = prefs.getStringList('moodHistValues') ?? [];
      if (mhT.isNotEmpty) {
        _moodHistory = List.generate(mhT.length, (i) => {
          'time': mhT[i],
          'mood': i < mhV.length ? mhV[i] : ''});
      }
      // ===== الوصفات =====
      final rNames  = prefs.getStringList('recipeNames')  ?? [];
      final rCats   = prefs.getStringList('recipeCats')   ?? [];
      final rIngr   = prefs.getStringList('recipeIngr')   ?? [];
      final rSteps  = prefs.getStringList('recipeSteps')  ?? [];
      final rEmoji  = prefs.getStringList('recipeEmoji')  ?? [];
      final rFav    = prefs.getStringList('recipeFav')    ?? [];
      if (rNames.isNotEmpty) {
        _recipes = List.generate(rNames.length, (i) => RecipeModel(
          rNames[i],
          i < rCats.length   ? rCats[i]   : "",
          i < rIngr.length   ? rIngr[i]   : "",
          i < rSteps.length  ? rSteps[i]  : "",
          emoji:       i < rEmoji.length  ? rEmoji[i]  : "🍽️",
          isFavorite:  i < rFav.length    ? rFav[i] == "1" : false,
        ));
      }
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
    await prefs.setStringList('coupleVideoTitles',  _coupleVideos.map((v) => v['title']  ?? '').toList());
    await prefs.setStringList('coupleVideoUrls',    _coupleVideos.map((v) => v['url']    ?? '').toList());
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
    // الوصفات
    // ===== الذكريات المشتركة =====
    await prefs.setStringList('cmTitles', _coupleMemories.map((m) => m.title).toList());
    await prefs.setStringList('cmDates',  _coupleMemories.map((m) => m.date).toList());
    await prefs.setStringList('cmNotes',  _coupleMemories.map((m) => m.note).toList());
    await prefs.setStringList('cmEmojis', _coupleMemories.map((m) => m.emoji).toList());
    // ===== تحديات الأسبوع =====
    await prefs.setStringList('wcTitles', _weekChallenges.map((c) => c.title).toList());
    await prefs.setStringList('wcDescs',  _weekChallenges.map((c) => c.description).toList());
    await prefs.setStringList('wcEmojis', _weekChallenges.map((c) => c.emoji).toList());
    await prefs.setStringList('wcAlaa',   _weekChallenges.map((c) => c.alaasDone ? "1" : "0").toList());
    await prefs.setStringList('wcHusb',   _weekChallenges.map((c) => c.husbandDone ? "1" : "0").toList());
    // ===== المعلومات =====
    await prefs.setStringList('infoTitles',   _infoNotes.map((n) => n.title).toList());
    await prefs.setStringList('infoContents', _infoNotes.map((n) => n.content).toList());
    await prefs.setStringList('infoCats',     _infoNotes.map((n) => n.category).toList());
    await prefs.setStringList('infoEmojis',   _infoNotes.map((n) => n.emoji).toList());
    await prefs.setStringList('infoFavs',     _infoNotes.map((n) => n.isFavorite ? "1" : "0").toList());
    // ===== الكورسات =====
    await prefs.setStringList('courseNames', _courses.map((c) => c.name).toList());
    await prefs.setStringList('courseCats',  _courses.map((c) => c.category).toList());
    await prefs.setStringList('courseUrls',  _courses.map((c) => c.videoUrl).toList());
    await prefs.setStringList('courseNotes', _courses.map((c) => c.notes).toList());
    await prefs.setStringList('courseEmoji', _courses.map((c) => c.emoji).toList());
    await prefs.setStringList('courseDone',  _courses.map((c) => c.isDone ? "1" : "0").toList());
    // ===== المزاج =====
    await prefs.setString('moodNote', _moodNote);
    await prefs.setStringList('moodHistTimes',  _moodHistory.map((m) => m['time'] ?? '').toList());
    await prefs.setStringList('moodHistValues', _moodHistory.map((m) => m['mood'] ?? '').toList());
    // ===== الوصفات =====
    await prefs.setStringList('recipeNames',  _recipes.map((r) => r.name).toList());
    await prefs.setStringList('recipeCats',   _recipes.map((r) => r.category).toList());
    await prefs.setStringList('recipeIngr',   _recipes.map((r) => r.ingredients).toList());
    await prefs.setStringList('recipeSteps',  _recipes.map((r) => r.steps).toList());
    await prefs.setStringList('recipeEmoji',  _recipes.map((r) => r.emoji).toList());
    await prefs.setStringList('recipeFav',    _recipes.map((r) => r.isFavorite ? "1" : "0").toList());
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
    if (text.trim().isEmpty) {
      return "اكتبي شيئاً لأحلل حالتكِ يا آلاء 💭\nأنا هنا وأستمع لكِ بكل اهتمام 🤍";
    }
    final t = text.toLowerCase();

    // ===== مزاح وكوميديا =====
    if (t.contains("جعان") || t.contains("جوعان") || t.contains("جعانة") || t.contains("أكل") || t.contains("اكل")) {
      setState(() => currentMood = AlaaMood.cute);
      return "😄 يا إلهي يا آلاء! بطنكِ تتكلم أعلى من أفكاركِ!\n\nالتشخيص: حالة حرجة من الجوع المزمن 🍽️\n\nالوصفة الطبية: توجهي فوراً للمطبخ واصنعي أي شيء لذيذ! وإذا كان عبد الرحمن بالقرب، فهذه فرصة ذهبية تطلبي منه يطبخ لكِ 😂\n\nملاحظة طبية: لا يُسمح بالحديث عن أي موضوع قبل الأكل!";
    }
    if (t.contains("نعسان") || t.contains("نعسانة") || t.contains("تعبان") || t.contains("أنام") || t.contains("نوم")) {
      setState(() => currentMood = AlaaMood.exhausted);
      return "😴 آه يا آلاء.. عيونكِ تتحدث قبل كلامكِ!\n\nالتشخيص: الجسم يطالب بحقه في الراحة 🛌\n\nالوصفة الطبية: المكان الأفضل في الكون هو حضن عبد الرحمن الدافئ! روحي دق عليه وقوليله 'أنا نعسانة' وشوفي كيف يفتح ذراعيه فوراً 🤗\n\nتحذير طبي: ممنوع مقاومة النوم، الجسم المرتاح يساوي آلاء أجمل وأسعد!";
    }
    if (t.contains("زعلان") || t.contains("زعلانة") || t.contains("معصب") || t.contains("معصبة") || t.contains("ماخذ") || t.contains("غاضب") || t.contains("غاضبة")) {
      setState(() => currentMood = AlaaMood.warrior);
      return "😤 أوه! طاقة قوية جداً تصل إليّ يا آلاء!\n\nالتشخيص: موجة غضب مشروعة تماماً 🌊\n\nالوصفة الطبية: خذي نفساً عميقاً.. ثم توجهي لعبد الرحمن وعضيه بلطف! ثق بي هذا يريح الأعصاب طبياً 😂\nأو أخبريه بما يضايقكِ - فهو قرر أن يكون ملاذكِ الدائم 💪\n\nملاحظة: عبد الرحمن لا يفر من زعلكِ، بل يجري نحوكِ!";
    }
    if (t.contains("ملل") || t.contains("مملة") || t.contains("فاضي") || t.contains("فاضية") || t.contains("بور")) {
      setState(() => currentMood = AlaaMood.peaceful);
      return "😑 الملل؟ في وجود تطبيق آلاء؟ هذا غير مسموح طبياً!\n\nالتشخيص: نقص حاد في الإثارة والنشاط ⚡\n\nالوصفة الطبية (اختاري واحدة):\n• جربي وصفة جديدة من مطبخكِ 🍳\n• ابدئي كورساً كنتِ تؤجلينه 🎓\n• اكتبي قصيدة عشوائية 📝\n• أو ببساطة: أرسلي لعبد الرحمن رسالة تقولين فيها 'وحشتني' 💕";
    }

    // ===== مشاعر حقيقية =====
    bool isCreative = t.contains("خيال") || t.contains("نجم") || t.contains("بحر") ||
                      t.contains("شوق") || t.contains("قمر") || t.contains("ورد") ||
                      t.contains("سماء") || t.contains("شعر") || t.contains("كتاب");

    if (t.contains("تعب") || t.contains("مرهق") || t.contains("ضغط") || t.contains("مش قادر")) {
      setState(() => currentMood = AlaaMood.exhausted);
      String r = "🤍 آلاء، كلماتكِ تحمل ثقلاً حقيقياً وأنا أسمعكِ بكل قلبي.\n\nالتحليل: أنتِ في مرحلة الاستنزاف العاطفي - وهي مرحلة يمر بها كل إنسان مجتهد.\n\nما تشعرين به 100% طبيعي ومفهوم.\n\nللآلاء الجميلة: التوقف ليس فشلاً، بل هو شجاعة. أعطي نفسكِ إذن الراحة 🌸\n\nنصيحتي: ضعي كل شيء جانباً الآن وخذي قسطاً من الراحة.";
      if (isCreative) _showCreativeSuggestion("أرى في كلماتكِ روحاً شاعرة تحتاج للتعبير.. هل تودين الكتابة عن الراحة والهدوء؟");
      return r;
    }
    if (t.contains("قوة") || t.contains("تحدي") || t.contains("سأفعل") || t.contains("إنجاز") || t.contains("أقدر")) {
      setState(() => currentMood = AlaaMood.warrior);
      String r = "💪 وااو يا آلاء! أشعر بطاقتكِ حتى من هنا!\n\nالتحليل: أنتِ في حالة 'تدفق ذهني' - وهي أفضل حالات الإنسان الإنتاجية!\n\nهذه الطاقة نادرة، استثمريها الآن في أصعب مهمة عندكِ.\n\nتذكري: المحاربات الحقيقيات مثلكِ لا ينتظرن الوقت المثالي - يصنعنه! 🌟";
      if (isCreative) _showCreativeSuggestion("هذه الطاقة ملهِمة! لمَ لا تكتبين قصيدة عن القوة والتحدي؟");
      return r;
    }
    if (t.contains("حب") || t.contains("سعادة") || t.contains("جميل") || t.contains("فرح") || t.contains("سعيد")) {
      setState(() => currentMood = AlaaMood.cute);
      String r = "🥰 يا آلاء! سعادتكِ تضيء الشاشة!\n\nالتحليل: أنتِ في حالة 'توازن وجداني' - وهي أجمل حالات الإنسان.\n\nهذا الجمال الداخلي الذي تحملينه هو هديتكِ للعالم.\n\nانشري هذه الطاقة الجميلة.. ابتسامة آلاء تغير يوم من حولها 💕";
      if (isCreative) _showCreativeSuggestion("هذه المشاعر الجميلة تستحق أن تُخلَّد في قصيدة رقيقة!");
      return r;
    }
    if (t.contains("حزن") || t.contains("بكاء") || t.contains("ألم") || t.contains("زهقت") || t.contains("وحيد")) {
      setState(() => currentMood = AlaaMood.pensive);
      String r = "🌧️ آلاء الحبيبة، أشعر بحزنكِ وهو حزن حقيقي يستحق أن يُسمع.\n\nالتحليل: الحزن ليس ضعفاً - بل هو دليل على أنكِ تشعرين بعمق.\n\nلا تكتمي دموعكِ.. اتركيها تنزل فالبكاء راحة روح.\n\nبعد هذه اللحظة: تحدثي لعبد الرحمن، فهو اختار أن يكون ملاذكِ في كل حال. أنتِ لستِ وحدكِ 🤍";
      if (isCreative) _showCreativeSuggestion("الكتابة أحياناً أفضل دواء.. هل تودين التعبير عن مشاعركِ؟");
      return r;
    }
    if (t.contains("خوف") || t.contains("قلق") || t.contains("توتر") || t.contains("خايف") || t.contains("قلقان")) {
      setState(() => currentMood = AlaaMood.pensive);
      return "🫂 آلاء، القلق يزور الجميع، لكنه يختار الأذكياء أكثر!\n\nالتحليل: عقلكِ يعمل بطاقة عالية ويحاول حماية مستقبلكِ.\n\nتمرين بسيط الآن: ضعي يدكِ على قلبكِ وتنفسي 3 أنفاس بطيئة...\n\nتذكري: معظم ما نخشاه لا يحدث أبداً. وحتى لو حدث - أنتِ أقوى منه 💪";
    }
    if (t.contains("فخور") || t.contains("فخورة") || t.contains("نجح") || t.contains("نجحت") || t.contains("أتممت")) {
      setState(() => currentMood = AlaaMood.warrior);
      return "🏆 يا آلاء!! هذا هو الكلام!\n\nالتحليل: شعور الإنجاز هو أحلى مكافأة يمنحها الإنسان لنفسه.\n\nأنتِ تستحقين هذا الشعور وأكثر! كل خطوة صغيرة تخطينها هي انتصار حقيقي.\n\nاحتفلي بنفسكِ اليوم - أخبري عبد الرحمن وشاركيه فرحتكِ 🎉";
    }

    // الحالة الافتراضية
    setState(() => currentMood = AlaaMood.peaceful);
    String r = "🌸 آلاء العزيزة، قرأت كلماتكِ بعناية.\n\nالتحليل: أنتِ في حالة تأمل وهدوء داخلي - وهذا جميل.\n\nهدوؤكِ هو أرض خصبة للتفكير والإبداع.\n\nهذا الوقت مناسب جداً للتأمل أو القراءة أو الكتابة 🌙";
    if (isCreative) _showCreativeSuggestion("كلماتكِ تحمل نسمات إبداعية.. انتقلي لمحراب الأدب الآن!");
    return r;
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

  // كتابة اسم آلاء بالنجوم على السماء
  void _writeNameWithStars() {
    // نقاط تشكّل كلمة "آلاء" بشكل تقريبي
    // كل حرف له نقاط نسبية ، نضعها موزعة على الشاشة
    const double startX = 30;
    const double startY = 120;
    const double scale = 22.0;

    // نقاط رسم الحروف (مبسّطة) - x,y نسبية
    final letterPoints = <List<double>>[
      // آ
      [0,0],[0,1],[0,2],[0,3],[0.2,0],
      // ل
      [0.8,0],[0.8,1],[0.8,2],[1.0,2],[1.2,2],
      // ا
      [1.6,0],[1.6,1],[1.6,2],[1.6,3],
      // ء
      [2.0,1.5],[2.2,1],[2.1,0.8],
    ];

    setState(() {
      stars.clear();
      final rand = Random();
      for (final pt in letterPoints) {
        stars.add(StarModel(
          startX + pt[0] * scale * 2.8,
          startY + pt[1] * scale * 2.2,
          floatOffset: rand.nextDouble() * 2 * pi,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✨ اسمكِ يلمع في السماء يا آلاء"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.deepPurple,
      ),
    );
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
      case 17: return [const Color(0xFFFF6F00), const Color(0xFFFFCC02)];
      case 18: return [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)];
      case 19: return [const Color(0xFFAD1457), const Color(0xFFE91E63)];
      case 20: return [const Color(0xFF1565C0), const Color(0xFF42A5F5)];
      case 21: return [const Color(0xFF2E7D32), const Color(0xFF66BB6A)];
      case 22: return [const Color(0xFF0277BD), const Color(0xFF29B6F6)];
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
                _sidebarItem(17, "🍳 وصفاتي", Icons.restaurant_menu),
                _sidebarItem(18, "😊 مزاجي اليوم", Icons.mood),
                _sidebarItem(19, "💑 ذكرياتنا", Icons.photo_album),
                _sidebarItem(20, "🏆 تحدي الأسبوع", Icons.emoji_events),
                _sidebarItem(21, "🎓 كورساتي", Icons.school),
                _sidebarItem(22, "💡 معلوماتي", Icons.lightbulb),
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
      case 2:
        // شغّل صوت المشهد الحالي عند فتح صفحة التأمل
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedIndex == 2) _playMeditationSound(_natureScene);
        });
        return _buildLivingSky();
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
      case 17: return _buildRecipesPage();
      case 18: return _buildMoodPage();
      case 19: return _buildCoupleMemoriesPage();
      case 20: return _buildWeekChallengePage();
      case 21: return _buildCoursesPage();
      case 22: return _buildInfoPage();
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

  String _getMoodLabel(AlaaMood mood) {
    switch(mood) {
      case AlaaMood.warrior:   return "متحفزة اليوم 💪";
      case AlaaMood.cute:      return "رومانسية وحنونة 🥰";
      case AlaaMood.peaceful:  return "هادئة وبخير 😌";
      case AlaaMood.romantic:  return "محبة ورومانسية 💕";
      case AlaaMood.pensive:   return "تفكير عميق 🤔";
      case AlaaMood.exhausted: return "تحتاج للراحة 😴";
      default:                 return "بخير الحمد لله";
    }
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

  // حالة عناصر المشاهد المتحركة
  // =================== مشاهد التأمل بـ CustomPainter ===================


  // =================== صوت التأمل ===================
  String _getMeditationSoundFile(String scene) {
    switch (scene) {
      case 'sky':       return '846440__nikoletb__bowed-saw-glissando-dry-raw.wav';
      case 'rain':      return '845583__tsp-talk__light-rain-village-ambience-distant-children-subtle-rural-atmosphere-altenthann-16-feb-2026-260217_001.wav';
      case 'river':     return '101332__jgrzinich__night_bird_sounds_by_river.wav';
      case 'waterfall': return '101332__jgrzinich__night_bird_sounds_by_river.wav';
      case 'forest':    return '847153__klankbeeld__moor-frogs-zandbergsvennen-kampina-netherlands-1230-pm-260302_0080.wav';
      case 'fire':      return 'Burning-Logs_-The-Calming-Sound-of-Fire.mp3';
      default:          return '846440__nikoletb__bowed-saw-glissando-dry-raw.wav';
    }
  }

  Future<void> _playMeditationSound(String scene) async {
    if (!_meditationSoundOn) return;
    try {
      final file = _getMeditationSoundFile(scene);
      await _meditationPlayer.stop();
      await _meditationPlayer.play(AssetSource('audio/$file'));
    } catch (_) {}
  }

  Future<void> _stopMeditationSound() async {
    try { await _meditationPlayer.stop(); } catch (_) {}
  }

  Widget _buildLivingSky() {
    return Stack(
      children: [
        // الرسام الاحترافي
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _skyAnimationController,
            builder: (ctx, _) => CustomPaint(
              painter: _NatureScenePainter(
                scene: _natureScene,
                progress: _skyAnimationController.value,
                timeOfDay: _timeOfDay,
              ),
            ),
          ),
        ),

        // تسمية عائمة
        Positioned(
          top: 28, left: 0, right: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: Colors.black.withOpacity(0.30),
                child: Text(_getNatureLabel(),
                  style: const TextStyle(color: Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w600,
                    letterSpacing: 0.6)),
              ),
            ),
          ),
        ),

        // أزرار تبديل المشاهد
        Positioned(
          bottom: 18, left: 0, right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    _sceneBtn("sky",       "☁️", "السماء",   [Color(0xFF0D1B2A), Color(0xFF1C3A5E)]),
                    _sceneBtn("rain",      "🌧️", "المطر",    [Color(0xFF1A237E), Color(0xFF283593)]),
                    _sceneBtn("river",     "🌊", "النهر",    [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                    _sceneBtn("waterfall", "💧", "الشلال",   [Color(0xFF006064), Color(0xFF00838F)]),
                    _sceneBtn("forest",    "🌿", "الغابة",   [Color(0xFF1B5E20), Color(0xFF33691E)]),
                    _sceneBtn("fire",      "🔥", "النار",    [Color(0xFF3E0000), Color(0xFF7F0000)]),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_natureScene == "sky") ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniBtn("⭐", "نجمة", _addStar),
                    const SizedBox(width: 8),
                    _miniBtn("✍️", "اسمكِ", _writeNameWithStars),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        isNightMode = !isNightMode;
                        _timeOfDay = isNightMode ? "night" : "morning";
                      }),
                      icon: Icon(_timeOfDay == "night"
                        ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined, size: 16),
                      label: Text(_timeOfDay == "night" ? "نهار" : "ليل",
                        style: const TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text("اسحبي النجوم • اضغطي طويلاً للحذف",
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              ] else
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _meditationSoundOn = !_meditationSoundOn);
                      if (_meditationSoundOn) {
                        _playMeditationSound(_natureScene);
                      } else {
                        _stopMeditationSound();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _meditationSoundOn
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _meditationSoundOn ? Icons.volume_up : Icons.volume_off,
                            color: Colors.white, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            _meditationSoundOn ? "صوت مفعّل" : "صامت",
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_getMeditationHint(),
                    style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        // النجوم القابلة للسحب (فقط عند السماء)
        if (_natureScene == "sky")
          ...stars.asMap().entries.map((e) {
            final idx = e.key; final star = e.value;
            final emoji = _timeOfDay == "night" ? "⭐"
              : _timeOfDay == "sunset" ? "✨" : "🌸";
            return AnimatedBuilder(
              animation: _skyAnimationController,
              builder: (ctx, _) {
                final fy = sin(_skyAnimationController.value*2*pi+star.floatOffset)*6;
                return Positioned(
                  left: star.x, top: star.y + fy,
                  child: GestureDetector(
                    onPanUpdate: (d) => setState(() {
                      star.x = (star.x+d.delta.dx).clamp(-10.0, 380.0);
                      star.y = (star.y+d.delta.dy).clamp(-10.0, 700.0);
                    }),
                    onLongPress: () => setState(() => stars.removeAt(idx)),
                    child: Text(emoji,
                      style: TextStyle(fontSize: 14.0+(idx%4)*4.0))));
              });
          }),
      ],
    );
  }

  String _getNatureLabel() {
    switch (_natureScene) {
      case "rain":      return "🌧️ المطر الهادئ المنعش";
      case "river":     return "🌊 على ضفة النهر الهادئ";
      case "waterfall": return "💧 عند شلال الطبيعة";
      case "forest":    return "🌿 في أعماق الغابة السحرية";
      case "fire":      return "🔥 أمام المدفأة الدافئة";
      default: return _timeOfDay == "night" ? "🌙 سماء الليل المرصّعة"
        : _timeOfDay == "sunset" ? "🌅 غروب الشمس الذهبي"
        : "☀️ سماء الصباح الصافية";
    }
  }

  String _getMeditationHint() {
    switch (_natureScene) {
      case "rain":      return "أغمضي عينيكِ واستمعي لصوت المطر 🌧️";
      case "river":     return "تخيلي نفسكِ جالسة على ضفة النهر 🌿";
      case "waterfall": return "دعي همومكِ تتدفق مع الشلال 💧";
      case "forest":    return "تنفسي هواء الغابة النقي 🌿";
      case "fire":      return "استدفئي بدفء النار وارتاحي 🔥";
      default: return "تأملي جمال السماء يا آلاء ✨";
    }
  }

  Widget _sceneBtn(String scene, String emoji, String label, List<Color> grad) {
    final sel = _natureScene == scene;
    return GestureDetector(
      onTap: () {
        setState(() => _natureScene = scene);
        _playMeditationSound(scene);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 9),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          gradient: sel ? LinearGradient(colors: [Colors.white, Colors.white])
                       : LinearGradient(colors: [Colors.black38, Colors.black26]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: sel ? Colors.white : Colors.white30, width: 1.5),
          boxShadow: sel ? [BoxShadow(
            color: Colors.white.withOpacity(0.25), blurRadius: 10)] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(
              color: sel ? Colors.black87 : Colors.white,
              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
              fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(String emoji, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Text(emoji, style: const TextStyle(fontSize: 14)),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    );
  }

  Widget _buildPsychologySection() {


    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)]),
          ),
          child: Column(
            children: [
              const Text("🧠", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              const Text("طبيبتكِ النفسية الخاصة",
                style: TextStyle(color: Colors.white, fontSize: 20,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("أنا هنا لأسمعكِ يا آلاء.. فضفضي بحرية 💜",
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة الكتابة
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 12, offset: const Offset(0,4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(16,12,16,0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                shape: BoxShape.circle),
                              child: const Icon(Icons.edit_note,
                                color: Colors.purple, size: 20)),
                            const SizedBox(width: 8),
                            const Text("كيف حالكِ اليوم؟",
                              style: TextStyle(fontWeight: FontWeight.bold,
                                color: Colors.purple)),
                          ],
                        ),
                      ),
                      TextField(
                        controller: _feelingController,
                        maxLines: 7,
                        decoration: const InputDecoration(
                          hintText: "اكتبي بحرية تامة.. جعانة؟ نعسانة؟ زعلانة؟ سعيدة؟\nأنا أفهم كل شيء 😊",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // اقتراحات سريعة
                const Text("اقتراحات سريعة:",
                  style: TextStyle(fontWeight: FontWeight.w600,
                    color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    "😴 نعسانة","😤 زعلانة","😂 جعانة",
                    "😢 حزينة","💪 متحمسة","😌 بخير",
                    "😰 قلقانة","🥰 سعيدة",
                  ].map((s) => GestureDetector(
                    onTap: () => setState(() {
                      _feelingController.text = s.substring(2).trim();
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.shade200)),
                      child: Text(s,
                        style: TextStyle(color: Colors.purple.shade700,
                          fontSize: 13))),
                  )).toList(),
                ),

                const SizedBox(height: 20),

                // زر التحليل
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      String result = _performProfessionalAnalysis(
                        _feelingController.text);
                      _showAnalysisResultDialog(result);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A148C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold),
                    ),
                    child: const Text("🔮 تحليل مشاعري"),
                  ),
                ),

                // آخر تحليل
                if (lastAnalysisResult != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade100)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history,
                              color: Colors.purple, size: 18),
                            const SizedBox(width: 6),
                            Text("آخر تحليل",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(lastAnalysisResult!,
                          style: TextStyle(color: Colors.grey.shade700,
                            fontSize: 13, height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // ===== Header =====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink.shade700, Colors.pink.shade400]),
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text("💑 قائمة مع زوجي",
                  style: TextStyle(color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("كل شيء نتشاركه في مكان واحد 💕",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 12),
                const TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  tabs: [
                    Tab(icon: Icon(Icons.checklist_rounded), text: "المهام المشتركة"),
                    Tab(icon: Icon(Icons.video_library_rounded), text: "صندوق الفيديوهات"),
                  ],
                ),
              ],
            ),
          ),

          // ===== المحتوى =====
          Expanded(
            child: TabBarView(
              children: [

                // ========== تاب 1: المهام المشتركة ==========
                Column(
                  children: [
                    Expanded(
                      child: coupleTasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("💕", style: TextStyle(fontSize: 60)),
                                const SizedBox(height: 12),
                                Text("أضيفا أول مهمة مشتركة!",
                                  style: TextStyle(color: Colors.grey.shade500,
                                    fontSize: 16)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: coupleTasks.length,
                            itemBuilder: (ctx, i) => Dismissible(
                              key: Key('couple_$i'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.delete_sweep,
                                  color: Colors.white, size: 26),
                              ),
                              onDismissed: (_) {
                                setState(() => coupleTasks.removeAt(i));
                                _saveTasks();
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: Colors.pink.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.pink.shade100,
                                      shape: BoxShape.circle),
                                    child: const Icon(Icons.favorite,
                                      color: Colors.pink, size: 20)),
                                  title: Text(coupleTasks[i],
                                    style: const TextStyle(fontSize: 15)),
                                ),
                              ),
                            ),
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: _addCoupleTask,
                        icon: const Icon(Icons.add),
                        label: const Text("إضافة مهمة مشتركة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade500,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),

                // ========== تاب 2: صندوق الفيديوهات ==========
                Column(
                  children: [
                    // Banner صندوق
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade700, Colors.pink.shade500]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.video_library,
                              color: Colors.white, size: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("📦 صندوق الفيديوهات",
                                  style: TextStyle(color: Colors.white,
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("${_coupleVideos.length} رابط محفوظ",
                                  style: const TextStyle(color: Colors.white70,
                                    fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // قائمة الروابط
                    Expanded(
                      child: _coupleVideos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("📦", style: TextStyle(fontSize: 60)),
                                const SizedBox(height: 12),
                                Text("الصندوق فارغ!\nأضيفا أول فيديو معاً 🎬",
                                  style: TextStyle(color: Colors.grey.shade500,
                                    fontSize: 15),
                                  textAlign: TextAlign.center),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _coupleVideos.length,
                            itemBuilder: (ctx, i) {
                              final v = _coupleVideos[i];
                              final url = v['url'] ?? '';
                              final isYoutube = url.contains('youtube') ||
                                url.contains('youtu.be');
                              final isTiktok = url.contains('tiktok');
                              return Dismissible(
                                key: Key('cvid_$i'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.delete_sweep,
                                    color: Colors.white, size: 26),
                                ),
                                onDismissed: (_) {
                                  setState(() => _coupleVideos.removeAt(i));
                                  _saveAll();
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () async {
                                      final uri = Uri.tryParse(url);
                                      if (uri != null && await canLaunchUrl(uri)) {
                                        await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          // أيقونة المنصة
                                          Container(
                                            width: 48, height: 48,
                                            decoration: BoxDecoration(
                                              color: isYoutube
                                                ? Colors.red.shade50
                                                : isTiktok
                                                  ? Colors.black12
                                                  : Colors.purple.shade50,
                                              borderRadius: BorderRadius.circular(12)),
                                            child: Center(
                                              child: Text(
                                                isYoutube ? "▶️"
                                                  : isTiktok ? "🎵"
                                                  : "🔗",
                                                style: const TextStyle(fontSize: 24)),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                              children: [
                                                Text(v['title'] ?? 'فيديو',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 3),
                                                Text(url,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 11),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.open_in_new,
                                            color: Colors.purple.shade300,
                                            size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                    ),

                    // زر إضافة رابط
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        onPressed: _addCoupleVideo,
                        icon: const Icon(Icons.add_link),
                        label: const Text("إضافة رابط فيديو 🎬"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addCoupleVideo() {
    final titleCtrl = TextEditingController();
    final urlCtrl   = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("📦 إضافة فيديو للصندوق"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: "اسم الفيديو",
                hintText: "مثال: فيلم رومانسي 💕",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: "رابط الفيديو",
                hintText: "https://youtube.com/...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (urlCtrl.text.trim().isEmpty) return;
              setState(() => _coupleVideos.insert(0, {
                'title': titleCtrl.text.trim().isEmpty
                  ? 'فيديو ${_coupleVideos.length + 1}'
                  : titleCtrl.text.trim(),
                'url': urlCtrl.text.trim(),
              }));
              _saveAll();
              Navigator.pop(ctx);
            },
            child: const Text("💾 حفظ")),
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
    _meditationPlayer.stop();
    _meditationPlayer.dispose();
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

// ================================================================
// ================ صفحة عرض الصور ================================
// ================================================================
  // =================== صفحة الوصفات ===================
  Widget _buildRecipesPage() {
    final cats = [
      {"label": "الكل",       "emoji": "🍽️"},
      {"label": "🍖 رئيسية",  "emoji": "🍖"},
      {"label": "🍰 حلويات",  "emoji": "🍰"},
      {"label": "🥗 سلطات",   "emoji": "🥗"},
      {"label": "🧃 مشروبات", "emoji": "🧃"},
      {"label": "⭐ مفضلة",   "emoji": "⭐"},
    ];
    final filtered = _recipeCategory == "الكل"
      ? _recipes
      : _recipeCategory == "⭐ مفضلة"
        ? _recipes.where((r) => r.isFavorite).toList()
        : _recipes.where((r) => r.category == _recipeCategory).toList();

    return Column(
      children: [
        // ===== Header مطبخي =====
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [const Color(0xFFE65100), const Color(0xFFFF8F00)]),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("👩‍🍳 مطبخ آلاء",
                          style: TextStyle(color: Colors.white, fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(
                          _recipes.isEmpty
                            ? "أضيفي وصفتكِ الأولى!"
                            : "${_recipes.length} وصفة • ${_recipes.where((r) => r.isFavorite).length} مفضلة",
                          style: const TextStyle(color: Colors.white70,
                            fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _addRecipe,
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ===== فلتر الفئات =====
        Container(
          color: Colors.white,
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final cat  = cats[i]["label"]!;
              final sel  = _recipeCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _recipeCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFE65100) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: sel ? [BoxShadow(
                      color: const Color(0xFFE65100).withOpacity(0.35),
                      blurRadius: 8, offset: const Offset(0, 3))] : [],
                  ),
                  child: Text(cat,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.grey.shade700,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13)),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // ===== قائمة الوصفات =====
        Expanded(
          child: filtered.isEmpty
            ? _emptyRecipes()
            : GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final r = filtered[i];
                  final realIdx = _recipes.indexOf(r);
                  return _recipeCard(r, realIdx);
                },
              ),
        ),

        // ===== زر الإضافة =====
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: _addRecipe,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("وصفة جديدة"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
              textStyle: const TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyRecipes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: const Text("👩‍🍳", style: TextStyle(fontSize: 60)),
          ),
          const SizedBox(height: 20),
          Text(
            _recipes.isEmpty
              ? "مطبخكِ فارغ يا آلاء!\nأضيفي أول وصفة 🍳"
              : "لا توجد وصفات في هذه الفئة",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16,
              height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _recipeCard(RecipeModel r, int realIdx) {
    // لون الفئة
    final catColor = r.category.contains("حلوي")
      ? Colors.pink.shade400
      : r.category.contains("مشرو")
        ? Colors.blue.shade400
        : r.category.contains("سلط")
          ? Colors.green.shade500
          : Colors.orange.shade600;

    return GestureDetector(
      onTap: () => _showRecipeDetail(r, realIdx),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07),
              blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // صورة/أيقونة الوصفة
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [
                      catColor.withOpacity(0.15),
                      catColor.withOpacity(0.30),
                    ]),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(r.emoji,
                        style: const TextStyle(fontSize: 52))),
                    // زر المفضلة
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() =>
                            _recipes[realIdx].isFavorite =
                              !_recipes[realIdx].isFavorite);
                          _saveAll();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                              color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Icon(
                            r.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: r.isFavorite ? Colors.red : Colors.grey,
                            size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // معلومات الوصفة
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.name,
                      style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            r.category.replaceAll(RegExp(r'^[^ ]+ '), ''),
                            style: TextStyle(color: catColor, fontSize: 10,
                              fontWeight: FontWeight.w600)),
                        ),
                        GestureDetector(
                          onTap: () => _editRecipe(realIdx),
                          child: Icon(Icons.edit_outlined,
                            size: 16, color: Colors.grey.shade400)),
                      ],
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

  void _showRecipeDetail(RecipeModel r, int idx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 44, height: 5, margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3)),
            ),
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.orange.shade100, width: 2),
                    ),
                    child: Center(
                      child: Text(r.emoji,
                        style: const TextStyle(fontSize: 40))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name,
                          style: const TextStyle(fontSize: 20,
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10)),
                          child: Text(r.category,
                            style: TextStyle(color: Colors.orange.shade800,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      r.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: r.isFavorite ? Colors.red : Colors.grey),
                    onPressed: () {
                      setState(() => _recipes[idx].isFavorite = !_recipes[idx].isFavorite);
                      _saveAll();
                      Navigator.pop(ctx);
                      _showRecipeDetail(_recipes[idx], idx);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // المحتوى
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailSection("🧂 المكونات", r.ingredients,
                      Colors.green.shade700),
                    const SizedBox(height: 20),
                    _detailSection("📝 طريقة التحضير", r.steps,
                      Colors.orange.shade700),
                  ],
                ),
              ),
            ),
            // أزرار
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _editRecipe(idx); },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("تعديل"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE65100),
                        side: const BorderSide(color: Color(0xFFE65100)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _recipes.removeAt(idx));
                        _saveAll();
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("حذف"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      ),
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

  Widget _detailSection(String title, String body, Color color) {
    final lines = body.split("\n");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 20,
              decoration: BoxDecoration(color: color,
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.asMap().entries.map((e) {
              final line = e.value.trim();
              if (line.isEmpty) return const SizedBox(height: 4);
              final isNumbered = RegExp(r"^[0-9]+[.)]").hasMatch(line);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNumbered) const SizedBox()
                    else Padding(
                      padding: const EdgeInsets.only(top: 5, left: 4),
                      child: Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                    ),
                    if (!isNumbered) const SizedBox(width: 8),
                    Expanded(
                      child: Text(line,
                        style: const TextStyle(fontSize: 14, height: 1.6))),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _addRecipe() => _showRecipeDialog();
  void _editRecipe(int idx) =>
    _showRecipeDialog(existing: _recipes[idx], idx: idx);

  void _showRecipeDialog({RecipeModel? existing, int? idx}) {
    final nameCtrl  = TextEditingController(text: existing?.name ?? "");
    final ingrCtrl  = TextEditingController(text: existing?.ingredients ?? "");
    final stepsCtrl = TextEditingController(text: existing?.steps ?? "");
    String selCat   = existing?.category ?? "🍖 رئيسية";
    String selEmoji = existing?.emoji    ?? "🍽️";

    const emojis = ["🍽️","🍗","🥩","🍝","🍲","🥘","🍛","🥗","🍰","🧁",
                    "🍪","🎂","🥧","🍩","🧃","☕","🫖","🥤","🍜","🥞"];
    const cats   = ["🍖 رئيسية","🍰 حلويات","🥗 سلطات","🧃 مشروبات"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.90,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle + عنوان
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFE65100), Colors.orange.shade400]),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Text(existing == null ? "🍳 وصفة جديدة" : "✏️ تعديل الوصفة",
                        style: const TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                // النموذج
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الوصفة
                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "اسم الوصفة *",
                            prefixText: "$selEmoji  ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // اختيار الإيموجي
                        const Text("🎨 الأيقونة",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: emojis.length,
                            itemBuilder: (ctx, i) => GestureDetector(
                              onTap: () => setS(() => selEmoji = emojis[i]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 46, height: 46,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: selEmoji == emojis[i]
                                    ? Colors.orange.shade100 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selEmoji == emojis[i]
                                      ? Colors.orange : Colors.transparent,
                                    width: 2),
                                ),
                                child: Center(child: Text(emojis[i],
                                  style: const TextStyle(fontSize: 24))),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // الفئة
                        const Text("📂 الفئة",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: cats.map((c) => Expanded(
                            child: GestureDetector(
                              onTap: () => setS(() => selCat = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selCat == c
                                    ? const Color(0xFFE65100)
                                    : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(c,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selCat == c
                                      ? Colors.white : Colors.grey.shade700,
                                    fontSize: 11,
                                    fontWeight: selCat == c
                                      ? FontWeight.bold : FontWeight.normal)),
                              ),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),

                        // المكونات
                        const Text("🧂 المكونات",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: ingrCtrl,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "مثال: 2 كوب دقيق، 1 بيضة، ملح...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // الخطوات
                        const Text("📝 طريقة التحضير",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: stepsCtrl,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: "1. سخّني الفرن...\n2. اخلطي المكونات...\n3. ...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                // زر الحفظ
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final recipe = RecipeModel(
                        nameCtrl.text.trim(), selCat,
                        ingrCtrl.text.trim(), stepsCtrl.text.trim(),
                        emoji: selEmoji,
                        isFavorite: existing?.isFavorite ?? false,
                      );
                      setState(() {
                        if (idx != null) {
                          _recipes[idx] = recipe;
                        } else {
                          _recipes.insert(0, recipe);
                        }
                      });
                      _saveAll();
                      Navigator.pop(ctx);
                    },
                    child: Text(existing == null ? "✅ حفظ الوصفة" : "✅ تحديث"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  // =================== صفحة المزاج ===================
  Widget _buildMoodPage() {
    final moods = [
      {"key": "happy",     "emoji": "😊", "label": "سعيدة",    "color": "0xFFFFD700"},
      {"key": "peaceful",  "emoji": "😌", "label": "هادئة",    "color": "0xFF81C784"},
      {"key": "romantic",  "emoji": "🥰", "label": "رومانسية", "color": "0xFFF48FB1"},
      {"key": "excited",   "emoji": "🤩", "label": "متحمسة",   "color": "0xFFFFAB40"},
      {"key": "tired",     "emoji": "😴", "label": "متعبة",    "color": "0xFF90A4AE"},
      {"key": "stressed",  "emoji": "😤", "label": "متوترة",   "color": "0xFFEF9A9A"},
      {"key": "sad",       "emoji": "😔", "label": "حزينة",    "color": "0xFF80DEEA"},
      {"key": "motivated", "emoji": "💪", "label": "متحفزة",   "color": "0xFFCE93D8"},
    ];

    final moodNoteCtrl = TextEditingController(text: _moodNote);
    final currentMoodKey = currentMood.name;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)]),
            ),
            child: Column(
              children: [
                Text(_getMoodEmoji(currentMood), style: const TextStyle(fontSize: 64)),
                const SizedBox(height: 10),
                Text("كيف حالكِ اليوم يا آلاء؟",
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_getMoodLabel(currentMood),
                  style: const TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار المزاج
                const Text("اختاري مزاجكِ 💜",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: moods.map((m) {
                    final isSelected = currentMoodKey == m["key"];
                    final col = Color(int.parse(m["color"]!));
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentMood = AlaaMood.values.firstWhere(
                            (v) => v.name == m["key"],
                            orElse: () => AlaaMood.peaceful);
                          // سجل في التاريخ
                          _moodHistory.insert(0, {
                            'time': DateTime.now().toString().substring(0,16),
                            'mood': m["label"]!,
                            'emoji': m["emoji"]!,
                          });
                          if (_moodHistory.length > 30) _moodHistory.removeLast();
                        });
                        _saveAll();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? col : col.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? col : Colors.transparent,
                            width: 2),
                          boxShadow: isSelected ? [BoxShadow(
                            color: col.withOpacity(0.4),
                            blurRadius: 8, offset: const Offset(0,3))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(m["emoji"]!,
                              style: TextStyle(fontSize: isSelected ? 28 : 24)),
                            const SizedBox(height: 4),
                            Text(m["label"]!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                  ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey.shade700),
                              textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // ملاحظة المزاج
                const Text("📝 ما الذي يدور في بالكِ؟",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: moodNoteCtrl,
                  maxLines: 4,
                  onChanged: (v) => _moodNote = v,
                  decoration: InputDecoration(
                    hintText: "اكتبي ما تشعرين به الآن...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.purple.shade200)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.purple.shade400, width: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () { _moodNote = moodNoteCtrl.text; _saveAll();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("✅ تم حفظ مزاجكِ"),
                        backgroundColor: Colors.purple));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    child: const Text("حفظ المزاج 💜",
                      style: TextStyle(fontSize: 16)),
                  ),
                ),

                // سجل المزاج
                if (_moodHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text("🕐 سجل المزاج",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...List.generate(_moodHistory.length.clamp(0, 7), (i) {
                    final h = _moodHistory[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Text(h['emoji'] ?? "😊",
                            style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h['mood'] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                                Text(h['time'] ?? "",
                                  style: TextStyle(
                                    color: Colors.grey.shade500, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }



  // =================== صفحة ذكرياتنا ===================
  Widget _buildCoupleMemoriesPage() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFAD1457), Color(0xFFE91E63)]),
          ),
          child: Column(
            children: [
              const Text("💑 ذكرياتنا معاً",
                style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${_coupleMemories.length} ذكرى جميلة",
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),

        // Timeline
        Expanded(
          child: _coupleMemories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("💕", style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 12),
                    Text("أضيفي أول ذكرى جميلة!\nكل لحظة تستحق التوثيق 📸",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      textAlign: TextAlign.center),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                itemCount: _coupleMemories.length,
                itemBuilder: (ctx, i) {
                  final m = _coupleMemories[i];
                  return Dismissible(
                    key: Key("mem_$i"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.delete_sweep,
                        color: Colors.white, size: 26),
                    ),
                    onDismissed: (_) {
                      setState(() => _coupleMemories.removeAt(i));
                      _saveAll();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // خط التايم لاين
                        Column(
                          children: [
                            Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: Colors.pink.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.pink.shade300, width: 2)),
                              child: Center(
                                child: Text(m.emoji,
                                  style: const TextStyle(fontSize: 20))),
                            ),
                            if (i < _coupleMemories.length - 1)
                              Container(
                                width: 2, height: 40,
                                color: Colors.pink.shade100),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(
                                color: Colors.pink.withOpacity(0.1),
                                blurRadius: 8, offset: const Offset(0,3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                      size: 12, color: Colors.grey.shade400),
                                    const SizedBox(width: 4),
                                    Text(m.date,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12)),
                                  ],
                                ),
                                if (m.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(m.note,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13, height: 1.5)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addCoupleMemory,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text("إضافة ذكرى جميلة 💕"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAD1457),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ],
    );
  }

  void _addCoupleMemory() {
    final titleCtrl = TextEditingController();
    final dateCtrl  = TextEditingController(
      text: DateTime.now().toString().substring(0,10));
    final noteCtrl  = TextEditingController();
    String selEmoji = "💕";
    final emojis = ["💕","💍","🌹","✈️","🎂","🎉","🏖️","🌙","⭐","🎁","🥂","🏠"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20,14,20,14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFAD1457), Color(0xFFE91E63)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  child: Row(
                    children: [
                      const Text("💕 ذكرى جديدة",
                        style: TextStyle(color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            labelText: "عنوان الذكرى",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: dateCtrl,
                          decoration: InputDecoration(
                            labelText: "التاريخ",
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 12),
                        const Text("الأيقونة:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: emojis.map((e) => GestureDetector(
                            onTap: () => setS(() => selEmoji = e),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selEmoji == e
                                  ? Colors.pink.shade100 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selEmoji == e
                                    ? Colors.pink : Colors.transparent)),
                              child: Text(e,
                                style: const TextStyle(fontSize: 22))),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: noteCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "وصف الذكرى",
                            hintText: "اكتبي تفاصيل هذه اللحظة الجميلة...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18,0,18,24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAD1457),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) return;
                      setState(() => _coupleMemories.insert(0,
                        CoupleMemory(titleCtrl.text.trim(),
                          dateCtrl.text.trim(), noteCtrl.text.trim(),
                          emoji: selEmoji)));
                      _saveAll();
                      Navigator.pop(ctx);
                    },
                    child: const Text("حفظ الذكرى 💕",
                      style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================== صفحة تحدي الأسبوع ===================
  Widget _buildWeekChallengePage() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20,20,20,24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
          ),
          child: Column(
            children: [
              const Text("🏆 تحدي الأسبوع",
                style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${_weekChallenges.length} تحدٍّ مشترك",
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),

        Expanded(
          child: _weekChallenges.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🏆", style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 12),
                    Text("لا يوجد تحدي حالياً!\nأضيفا تحدياً ممتعاً معاً 💪",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      textAlign: TextAlign.center),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: _weekChallenges.length,
                itemBuilder: (ctx, i) {
                  final c = _weekChallenges[i];
                  final bothDone = c.alaasDone && c.husbandDone;
                  return Dismissible(
                    key: Key("wc_$i"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.delete_sweep,
                        color: Colors.white, size: 26),
                    ),
                    onDismissed: (_) {
                      setState(() => _weekChallenges.removeAt(i));
                      _saveAll();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: bothDone
                          ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: bothDone
                            ? Colors.blue.shade300 : Colors.grey.shade200),
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8, offset: const Offset(0,3))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(c.emoji,
                                  style: const TextStyle(fontSize: 28)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: bothDone
                                            ? TextDecoration.lineThrough
                                            : null)),
                                      if (c.description.isNotEmpty)
                                        Text(c.description,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (bothDone)
                                  const Text("✅ مكتمل!",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                        _weekChallenges[i].alaasDone =
                                          !_weekChallenges[i].alaasDone);
                                      _saveAll();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                      decoration: BoxDecoration(
                                        color: c.alaasDone
                                          ? Colors.blue.shade600
                                          : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                          MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            c.alaasDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                            size: 16,
                                            color: c.alaasDone
                                              ? Colors.white
                                              : Colors.grey),
                                          const SizedBox(width: 6),
                                          Text("آلاء",
                                            style: TextStyle(
                                              color: c.alaasDone
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                              fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() =>
                                        _weekChallenges[i].husbandDone =
                                          !_weekChallenges[i].husbandDone);
                                      _saveAll();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                      decoration: BoxDecoration(
                                        color: c.husbandDone
                                          ? Colors.blue.shade600
                                          : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        mainAxisAlignment:
                                          MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            c.husbandDone
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                            size: 16,
                                            color: c.husbandDone
                                              ? Colors.white
                                              : Colors.grey),
                                          const SizedBox(width: 6),
                                          Text("الزوج",
                                            style: TextStyle(
                                              color: c.husbandDone
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                              fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addWeekChallenge,
            icon: const Icon(Icons.add),
            label: const Text("إضافة تحدي جديد 🏆"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ],
    );
  }

  void _addWeekChallenge() {
    final titleCtrl = TextEditingController();
    final descCtrl  = TextEditingController();
    String selEmoji = "🏆";
    const emojis = ["🏆","💪","📚","🏃","🍎","🎨","🌙","⭐","🎯","🧘","🤝","❤️"];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
          title: const Text("🏆 تحدي جديد"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: "اسم التحدي",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "وصف التحدي",
                    hintText: "مثال: نمشي 30 دقيقة يومياً",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                const Text("الأيقونة:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: emojis.map((e) => GestureDetector(
                    onTap: () => setS(() => selEmoji = e),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: selEmoji == e
                          ? Colors.blue.shade100 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selEmoji == e
                            ? Colors.blue : Colors.transparent)),
                      child: Text(e,
                        style: const TextStyle(fontSize: 22))),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                setState(() => _weekChallenges.insert(0,
                  WeekChallenge(titleCtrl.text.trim(),
                    descCtrl.text.trim(), emoji: selEmoji)));
                _saveAll();
                Navigator.pop(ctx);
              },
              child: const Text("إضافة ✅")),
          ],
        ),
      ),
    );
  }

  // =================== صفحة الكورسات ===================
  Widget _buildCoursesPage() {
    final cats = ["الكل","📱 تقنية","🏥 طب","🗣️ لغات","🎨 مهارات","📖 أخرى"];
    final filtered = _courseCategory == "الكل"
      ? _courses
      : _courses.where((c) => c.category == _courseCategory).toList();
    final done   = _courses.where((c) => c.isDone).length;
    final total  = _courses.length;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20,18,20,22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
          ),
          child: Column(
            children: [
              const Text("🎓 كورساتي",
                style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (total > 0) ...[
                Text("$done / $total مكتملة",
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total > 0 ? done / total : 0,
                    backgroundColor: Colors.white30,
                    color: Colors.white,
                    minHeight: 8,
                  ),
                ),
              ] else
                const Text("ابدئي رحلة التعلم! 🌱",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),

        // فلتر
        Container(
          color: Colors.white,
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final cat = cats[i];
              final sel = _courseCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _courseCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF2E7D32) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: sel ? [BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                      blurRadius: 6)] : [],
                  ),
                  child: Text(cat,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.grey.shade700,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13)),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // القائمة
        Expanded(
          child: filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("🎓", style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 12),
                    Text(
                      _courses.isEmpty
                        ? "أضيفي أول كورس تريدين تعلّمه!"
                        : "لا يوجد كورسات في هذه الفئة",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      textAlign: TextAlign.center),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final c = filtered[i];
                  final realIdx = _courses.indexOf(c);
                  return Dismissible(
                    key: Key("course_$realIdx"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.delete_sweep,
                        color: Colors.white, size: 26),
                    ),
                    onDismissed: (_) {
                      setState(() => _courses.removeAt(realIdx));
                      _saveAll();
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onLongPress: () => _editCourse(realIdx),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // أيقونة
                              Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: c.isDone
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: Text(c.emoji,
                                    style: const TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: c.isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                        color: c.isDone
                                          ? Colors.grey : Colors.black87)),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(6)),
                                          child: Text(c.category,
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 10)),
                                        ),
                                        if (c.videoUrl.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () async {
                                              final uri = Uri.tryParse(c.videoUrl);
                                              if (uri != null && await canLaunchUrl(uri)) {
                                                await launchUrl(uri,
                                                  mode: LaunchMode.externalApplication);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(6)),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.play_circle,
                                                    size: 12,
                                                    color: Colors.red),
                                                  SizedBox(width: 3),
                                                  Text("فيديو",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (c.notes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(c.notes,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    ],
                                  ],
                                ),
                              ),
                              // Checkbox إتمام
                              GestureDetector(
                                onTap: () {
                                  setState(() =>
                                    _courses[realIdx].isDone =
                                      !_courses[realIdx].isDone);
                                  _saveAll();
                                },
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: c.isDone
                                      ? Colors.green : Colors.grey.shade200,
                                    shape: BoxShape.circle),
                                  child: Icon(Icons.check,
                                    color: c.isDone
                                      ? Colors.white : Colors.grey.shade400,
                                    size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addCourse,
            icon: const Icon(Icons.add),
            label: const Text("إضافة كورس جديد 🎓"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ],
    );
  }

  void _addCourse()          => _showCourseDialog();
  void _editCourse(int idx)  => _showCourseDialog(existing: _courses[idx], idx: idx);

  void _showCourseDialog({CourseItem? existing, int? idx}) {
    final nameCtrl  = TextEditingController(text: existing?.name ?? "");
    final urlCtrl   = TextEditingController(text: existing?.videoUrl ?? "");
    final notesCtrl = TextEditingController(text: existing?.notes ?? "");
    String selCat   = existing?.category ?? "📖 أخرى";
    String selEmoji = existing?.emoji ?? "📚";
    const emojis = ["📚","🎓","💻","🏥","🗣️","🎨","🎵","📐","🔬","✍️","🌍","🧠"];
    const cats   = ["📱 تقنية","🏥 طب","🗣️ لغات","🎨 مهارات","📖 أخرى"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20,14,20,14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)]),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24))),
                  child: Row(
                    children: [
                      Text(existing == null
                        ? "🎓 كورس جديد" : "✏️ تعديل الكورس",
                        style: const TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "اسم الكورس *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 14),
                        const Text("الأيقونة:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: emojis.length,
                            itemBuilder: (ctx, i) => GestureDetector(
                              onTap: () => setS(() => selEmoji = emojis[i]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 44, height: 44,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: selEmoji == emojis[i]
                                    ? Colors.green.shade100
                                    : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selEmoji == emojis[i]
                                      ? Colors.green : Colors.transparent,
                                    width: 2)),
                                child: Center(child: Text(emojis[i],
                                  style: const TextStyle(fontSize: 22))),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text("الفئة:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: cats.map((c) => GestureDetector(
                            onTap: () => setS(() => selCat = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selCat == c
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                              child: Text(c,
                                style: TextStyle(
                                  color: selCat == c
                                    ? Colors.white : Colors.grey.shade700,
                                  fontWeight: selCat == c
                                    ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12)),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: urlCtrl,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: "رابط الفيديو (اختياري)",
                            hintText: "https://youtube.com/...",
                            prefixIcon: const Icon(Icons.link),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "ملاحظات",
                            hintText: "لماذا تريدين تعلّم هذا؟",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18,0,18,24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final course = CourseItem(
                        nameCtrl.text.trim(), selCat,
                        videoUrl: urlCtrl.text.trim(),
                        notes:    notesCtrl.text.trim(),
                        emoji:    selEmoji,
                        isDone:   existing?.isDone ?? false);
                      setState(() {
                        if (idx != null) {
                          _courses[idx] = course;
                        } else {
                          _courses.insert(0, course);
                        }
                      });
                      _saveAll();
                      Navigator.pop(ctx);
                    },
                    child: Text(existing == null
                      ? "✅ حفظ الكورس" : "✅ تحديث",
                      style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // =================== صفحة المعلومات ===================
  Widget _buildInfoPage() {
    final cats = ["الكل","🕌 ديني","🔬 علمي","🏥 طبي","📜 تاريخي","⭐ مفضلة","📝 أخرى"];
    final filtered = _infoCategory == "الكل"
      ? _infoNotes
      : _infoCategory == "⭐ مفضلة"
        ? _infoNotes.where((n) => n.isFavorite).toList()
        : _infoNotes.where((n) => n.category == _infoCategory).toList();

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20,18,20,22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF29B6F6)]),
          ),
          child: Column(
            children: [
              const Text("💡 معلوماتي",
                style: TextStyle(color: Colors.white, fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text("${_infoNotes.length} معلومة محفوظة",
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),

        // فلتر الفئات
        Container(
          color: Colors.white,
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final cat = cats[i];
              final sel = _infoCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _infoCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFF0277BD) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: sel ? [BoxShadow(
                      color: const Color(0xFF0277BD).withOpacity(0.3),
                      blurRadius: 6)] : [],
                  ),
                  child: Text(cat,
                    style: TextStyle(
                      color: sel ? Colors.white : Colors.grey.shade700,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12)),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),

        // القائمة
        Expanded(
          child: filtered.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("💡", style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 12),
                    Text(
                      _infoNotes.isEmpty
                        ? "سجّلي أول معلومة اليوم!\nكل معرفة تضيف نوراً 🌟"
                        : "لا توجد معلومات في هذه الفئة",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      textAlign: TextAlign.center),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final n = filtered[i];
                  final realIdx = _infoNotes.indexOf(n);
                  final catColor = n.category.contains("دين")
                    ? Colors.green.shade600
                    : n.category.contains("علم")
                      ? Colors.blue.shade600
                      : n.category.contains("طب")
                        ? Colors.red.shade500
                        : n.category.contains("تاريخ")
                          ? Colors.brown.shade500
                          : Colors.blueGrey;
                  return Dismissible(
                    key: Key("info_$realIdx"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.delete_sweep,
                        color: Colors.white, size: 26),
                    ),
                    onDismissed: (_) {
                      setState(() => _infoNotes.removeAt(realIdx));
                      _saveAll();
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showInfoDetail(n, realIdx),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 46, height: 46,
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(n.emoji,
                                  style: const TextStyle(fontSize: 24))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6)),
                                      child: Text(n.category,
                                        style: TextStyle(color: catColor,
                                          fontSize: 10, fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(n.content,
                                      style: TextStyle(color: Colors.grey.shade600,
                                        fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() =>
                                    _infoNotes[realIdx].isFavorite =
                                      !_infoNotes[realIdx].isFavorite);
                                  _saveAll();
                                },
                                child: Icon(
                                  n.isFavorite ? Icons.star : Icons.star_border,
                                  color: n.isFavorite ? Colors.amber : Colors.grey,
                                  size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addInfoNote,
            icon: const Icon(Icons.add),
            label: const Text("إضافة معلومة جديدة 💡"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0277BD),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
          ),
        ),
      ],
    );
  }

  void _showInfoDetail(InfoNote n, int idx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Container(
              width: 44, height: 5, margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(n.emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title,
                          style: const TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(n.category,
                            style: TextStyle(color: Colors.blue.shade700,
                              fontSize: 12, fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14)),
                  child: Text(n.content,
                    style: const TextStyle(fontSize: 15, height: 1.8)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16,8,16,24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _editInfoNote(idx); },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text("تعديل"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0277BD),
                        side: const BorderSide(color: Color(0xFF0277BD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0277BD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                      child: const Text("إغلاق"),
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

  void _addInfoNote()          => _showInfoDialog();
  void _editInfoNote(int idx)  => _showInfoDialog(existing: _infoNotes[idx], idx: idx);

  void _showInfoDialog({InfoNote? existing, int? idx}) {
    final titleCtrl   = TextEditingController(text: existing?.title ?? "");
    final contentCtrl = TextEditingController(text: existing?.content ?? "");
    String selCat   = existing?.category ?? "📝 أخرى";
    String selEmoji = existing?.emoji ?? "💡";
    const emojis = ["💡","🌙","📖","🔬","🏥","📜","🌍","⚗️","🧬","🕌","🌟","🤔"];
    const cats   = ["🕌 ديني","🔬 علمي","🏥 طبي","📜 تاريخي","📝 أخرى"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20,14,20,14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0277BD), Color(0xFF29B6F6)]),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24))),
                  child: Row(
                    children: [
                      Text(existing == null ? "💡 معلومة جديدة" : "✏️ تعديل",
                        style: const TextStyle(color: Colors.white,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          decoration: InputDecoration(
                            labelText: "عنوان المعلومة *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                        ),
                        const SizedBox(height: 14),
                        const Text("الأيقونة:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: emojis.length,
                            itemBuilder: (ctx, i) => GestureDetector(
                              onTap: () => setS(() => selEmoji = emojis[i]),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 44, height: 44,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: selEmoji == emojis[i]
                                    ? Colors.blue.shade100 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selEmoji == emojis[i]
                                      ? Colors.blue : Colors.transparent,
                                    width: 2)),
                                child: Center(child: Text(emojis[i],
                                  style: const TextStyle(fontSize: 22))),
                              )),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text("الفئة:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: cats.map((c) => GestureDetector(
                            onTap: () => setS(() => selCat = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selCat == c
                                  ? const Color(0xFF0277BD) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)),
                              child: Text(c,
                                style: TextStyle(
                                  color: selCat == c
                                    ? Colors.white : Colors.grey.shade700,
                                  fontWeight: selCat == c
                                    ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12)),
                            ),
                          )).toList(),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: contentCtrl,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: "المعلومة *",
                            hintText: "اكتبي المعلومة بالتفصيل...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                            alignLabelWithHint: true),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18,0,18,24),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0277BD),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty ||
                          contentCtrl.text.trim().isEmpty) return;
                      final note = InfoNote(
                        titleCtrl.text.trim(), contentCtrl.text.trim(), selCat,
                        emoji: selEmoji,
                        isFavorite: existing?.isFavorite ?? false);
                      setState(() {
                        if (idx != null) {
                          _infoNotes[idx] = note;
                        } else {
                          _infoNotes.insert(0, note);
                        }
                      });
                      _saveAll();
                      Navigator.pop(ctx);
                    },
                    child: Text(existing == null ? "✅ حفظ المعلومة" : "✅ تحديث",
                      style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

// ================================================================
// ============= Particle System - مشاهد حية احترافية =============
// ================================================================

/// جسيم عام (مطر، شلال، نار، فقاعة، ورقة شجر)
class _Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;
  _Particle({required this.x, required this.y, required this.vx,
    required this.vy, required this.life, required this.maxLife,
    required this.size, required this.color});
  double get alpha => (life / maxLife).clamp(0.0, 1.0);
}

class _NatureScenePainter extends CustomPainter {
  final String scene;
  final double progress; // 0.0→1.0 looping
  final String timeOfDay;

  _NatureScenePainter({
    required this.scene,
    required this.progress,
    required this.timeOfDay,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    switch (scene) {
      case "rain":      _paintRain(canvas, sz);      break;
      case "river":     _paintRiver(canvas, sz);     break;
      case "waterfall": _paintWaterfall(canvas, sz); break;
      case "forest":    _paintForest(canvas, sz);    break;
      case "fire":      _paintFire(canvas, sz);      break;
      default:          _paintSky(canvas, sz);       break;
    }
  }

  // ─────────────────────────────────────────────
  // ☁️  السماء  ☁️
  // ─────────────────────────────────────────────
  void _paintSky(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;
    final night  = timeOfDay == "night";
    final sunset = timeOfDay == "sunset";

    // تدرج السماء
    _fillGradient(canvas, sz, night
      ? [const Color(0xFF020818), const Color(0xFF0A1628), const Color(0xFF0D0D30)]
      : sunset
        ? [const Color(0xFF0C0020), const Color(0xFFAA3000), const Color(0xFFFF7A1A), const Color(0xFFFFBB44)]
        : [const Color(0xFF0A3060), const Color(0xFF1565C0), const Color(0xFF64B5F6), const Color(0xFFB3E5FC)]);

    if (night) {
      // 120 نجمة متلألئة بأحجام مختلفة
      final rng = _Rng(7);
      for (int i = 0; i < 120; i++) {
        final sx = rng.f() * w;
        final sy = rng.f() * h * 0.75;
        final twinkle = (sin(progress * 2 * pi * (0.5 + rng.f()*2) + i * 1.3) + 1) / 2;
        final r = rng.f() * 1.8 + 0.4;
        // هالة للنجوم الكبيرة
        if (r > 1.5) {
          canvas.drawCircle(Offset(sx, sy), r * 3,
            Paint()..color = Colors.white.withOpacity(twinkle * 0.12)
                   ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
        }
        canvas.drawCircle(Offset(sx, sy), r,
          Paint()..color = Colors.white.withOpacity(0.4 + twinkle * 0.6));
      }
      // درب التبانة
      for (int i = 0; i < 200; i++) {
        final mx = rng.f() * w * 0.6 + w * 0.2;
        final my = rng.f() * h * 0.45 + h * 0.05;
        final a = rng.f() * 0.3;
        canvas.drawCircle(Offset(mx, my), 0.5,
          Paint()..color = Colors.white.withOpacity(a));
      }
      // القمر + هالته
      final mx = w * 0.78; final my = h * 0.14;
      canvas.drawCircle(Offset(mx, my), 38,
        Paint()..color = const Color(0xFFFFF8DC)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawCircle(Offset(mx, my), 56,
        Paint()..color = const Color(0xFFFFF8DC).withOpacity(0.12)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
      // ظل القمر
      canvas.drawCircle(Offset(mx + 8, my - 5), 34,
        Paint()..color = const Color(0xFF0A1628).withOpacity(0.35));
      // سحب ليلية
      _cloud(canvas, Offset(w*0.15, h*0.28), 0.8, const Color(0xFF0D2040).withOpacity(0.9));
      _cloud(canvas, Offset(w*0.6,  h*0.2),  0.6, const Color(0xFF0D2040).withOpacity(0.7));

    } else if (sunset) {
      // الشمس الغاربة
      final sy = h * 0.58 + sin(progress * 2 * pi) * 6;
      for (double gr = 90; gr >= 20; gr -= 14) {
        canvas.drawCircle(Offset(w*0.5, sy), gr,
          Paint()..color = const Color(0xFFFF6600).withOpacity(0.05)
                 ..maskFilter = MaskFilter.blur(BlurStyle.normal, gr * 0.5));
      }
      canvas.drawCircle(Offset(w*0.5, sy), 34,
        Paint()..color = const Color(0xFFFFCC00));
      canvas.drawCircle(Offset(w*0.5, sy), 20,
        Paint()..color = const Color(0xFFFFFF99));
      // أشعة
      for (int i = 0; i < 16; i++) {
        final a = i * pi / 8 + progress * pi * 0.3;
        canvas.drawLine(
          Offset(w*0.5 + cos(a)*42, sy + sin(a)*42),
          Offset(w*0.5 + cos(a)*(70+sin(progress*pi*4+i)*15), sy + sin(a)*(70+sin(progress*pi*4+i)*15)),
          Paint()..color = const Color(0xFFFFCC44).withOpacity(0.25)
                 ..strokeWidth = 1.5 + sin(progress*pi*6+i)*0.5
                 ..strokeCap = StrokeCap.round);
      }
      // انعكاس على الأفق
      _fillGradientRect(canvas,
        Rect.fromLTWH(w*0.15, sy, w*0.7, h - sy),
        [const Color(0xFFFF8800).withOpacity(0.35), Colors.transparent]);
      _cloud(canvas, Offset(w*0.1, h*0.25), 1.1, const Color(0xFFCC3300).withOpacity(0.8));
      _cloud(canvas, Offset(w*0.62, h*0.18), 0.75, const Color(0xFF991100).withOpacity(0.7));
      _cloud(canvas, Offset(w*0.4, h*0.35), 0.5, const Color(0xFF771100).withOpacity(0.6));

    } else {
      // نهار: شمس + غيوم متحركة
      final sunX = w * 0.78; final sunY = h * 0.12;
      canvas.drawCircle(Offset(sunX, sunY), 44,
        Paint()..color = const Color(0xFFFFEE44).withOpacity(0.18)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28));
      canvas.drawCircle(Offset(sunX, sunY), 34, Paint()..color = const Color(0xFFFFD700));
      canvas.drawCircle(Offset(sunX, sunY), 22, Paint()..color = const Color(0xFFFFFFAA));
      final off = progress * w * 0.18;
      _cloud(canvas, Offset(w*0.05 + off, h*0.14), 1.1, Colors.white.withOpacity(0.92));
      _cloud(canvas, Offset(w*0.38 + off*0.7, h*0.08), 0.8, Colors.white.withOpacity(0.85));
      _cloud(canvas, Offset(-w*0.1 + off*1.3, h*0.2), 0.9, Colors.white.withOpacity(0.78));
    }

    // أرض + أشجار
    _fillGradientRect(canvas,
      Rect.fromLTWH(0, h*0.76, w, h*0.24),
      night
        ? [const Color(0xFF050E08), const Color(0xFF030806)]
        : sunset
          ? [const Color(0xFF3D1500), const Color(0xFF1A0800)]
          : [const Color(0xFF3A8C3A), const Color(0xFF1B5E20)]);
    final tCol = night ? const Color(0xFF030D06)
      : sunset ? const Color(0xFF2A0E00) : const Color(0xFF1B5E20);
    for (int i = 0; i < 7; i++) {
      _treeSimple(canvas, Offset((i/6)*w, h*0.76),
        35 + (i%3)*18.0, tCol.withOpacity(0.9));
    }
  }

  // ─────────────────────────────────────────────
  // 🌧️  المطر  🌧️
  // ─────────────────────────────────────────────
  void _paintRain(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;

    // سماء داكنة ممطرة
    _fillGradient(canvas, sz, [
      const Color(0xFF0D1B2A), const Color(0xFF1C2E3D),
      const Color(0xFF253545), const Color(0xFF1A2A38)]);

    // غيوم ثقيلة متحركة
    for (int i = 0; i < 5; i++) {
      final cx = (progress * w * 0.4 + i * w * 0.22) % (w + 120) - 60;
      final cy = h * 0.04 + i * h * 0.055;
      _cloud(canvas, Offset(cx, cy),
        0.8 + (i%2)*0.4,
        const Color(0xFF1A2640).withOpacity(0.95));
    }
    // غيوم أمامية داكنة جداً
    for (int i = 0; i < 3; i++) {
      final cx = (progress * w * 0.25 + i * w * 0.4) % (w + 100) - 50;
      _cloud(canvas, Offset(cx, h * 0.1 + i * h * 0.07),
        1.2, const Color(0xFF101820).withOpacity(0.98));
    }

    // أضواء البرق (ومضات عشوائية)
    final lightningPhase = (progress * 7) % 1.0;
    if (lightningPhase < 0.07) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h),
        Paint()..color = Colors.white.withOpacity((0.07 - lightningPhase) / 0.07 * 0.2));
      // خط البرق
      final lx = w * 0.3 + lightningPhase * w * 5;
      _drawLightning(canvas, Offset(lx % w, 0), h * 0.55);
    }

    // قطرات المطر (120 قطرة)
    final rng = _Rng(42);
    final rainPaint = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 120; i++) {
      final baseX = rng.f() * w;
      final speed = 0.6 + rng.f() * 0.8;
      final ry = (progress * h * speed * 1.8 + i * (h / 120) * 1.8) % (h * 1.1) - h * 0.1;
      final rx = baseX + ry * 0.15; // ميل خفيف
      final len = 10 + rng.f() * 14;
      final alpha = 0.3 + rng.f() * 0.5;
      rainPaint.color = const Color(0xFF90CAF9).withOpacity(alpha);
      canvas.drawLine(Offset(rx, ry), Offset(rx + 2, ry + len), rainPaint);
    }

    // ضباب خفيف
    for (int i = 0; i < 3; i++) {
      final fogX = (progress * w * 0.3 + i * w * 0.4) % (w + 200) - 100;
      canvas.drawOval(
        Rect.fromLTWH(fogX, h * 0.55 + i * h * 0.12, w * 0.6, h * 0.12),
        Paint()..color = Colors.white.withOpacity(0.04 + i * 0.02)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    }

    // أرض مبلولة + انعكاس
    _fillGradientRect(canvas, Rect.fromLTWH(0, h*0.78, w, h*0.22),
      [const Color(0xFF0A1218), const Color(0xFF060C10)]);
    // بركة انعكاس
    canvas.drawOval(
      Rect.fromLTWH(w*0.2, h*0.8, w*0.6, h*0.08),
      Paint()..color = const Color(0xFF1C3A55).withOpacity(0.7));
    // دوائر المطر على البركة
    for (int i = 0; i < 6; i++) {
      final rr = ((progress * 2 + i * 0.17) % 1.0) * w * 0.12;
      canvas.drawCircle(
        Offset(w * 0.3 + i * w * 0.08, h * 0.83),
        rr,
        Paint()
          ..color = Colors.white.withOpacity(((1 - rr/(w*0.12)) * 0.25).clamp(0,1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
    }
    // أشجار في المطر
    for (int i = 0; i < 5; i++) {
      _treeSimple(canvas, Offset(i * w*0.25, h*0.78),
        40 + i*12.0, const Color(0xFF0A1808).withOpacity(0.95));
    }
  }

  void _drawLightning(Canvas canvas, Offset start, double len) {
    final p = Paint()..color = const Color(0xFFE8F4FF).withOpacity(0.9)
                    ..strokeWidth = 2.5
                    ..strokeCap = StrokeCap.round
                    ..style = PaintingStyle.stroke;
    // هالة البرق
    final glow = Paint()..color = Colors.white.withOpacity(0.25)
                        ..strokeWidth = 8
                        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
                        ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(start.dx, start.dy);
    double x = start.dx; double y = start.dy;
    final rng = _Rng(33);
    while (y < start.dy + len) {
      x += (rng.f() - 0.5) * 30;
      y += len * 0.12;
      path.lineTo(x, y);
    }
    canvas.drawPath(path, glow);
    canvas.drawPath(path, p);
  }

  // ─────────────────────────────────────────────
  // 🌊  النهر  🌊
  // ─────────────────────────────────────────────
  void _paintRiver(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;

    // سماء النهر
    _fillGradient(canvas, sz, [
      const Color(0xFF0A2744), const Color(0xFF1565C0),
      const Color(0xFF42A5F5), const Color(0xFF81D4FA)]);
    // شمس
    canvas.drawCircle(Offset(w*0.8, h*0.11), 30,
      Paint()..color = const Color(0xFFFFE082));
    canvas.drawCircle(Offset(w*0.8, h*0.11), 44,
      Paint()..color = const Color(0xFFFFE082).withOpacity(0.2)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    _cloud(canvas, Offset(w*0.08, h*0.09), 0.9, Colors.white.withOpacity(0.88));
    _cloud(canvas, Offset(w*0.52, h*0.06), 0.7, Colors.white.withOpacity(0.75));

    // ضفتا النهر (أرض خضراء)
    final grassP = Paint()..shader = LinearGradient(
      colors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, h*0.42, w, h*0.58));
    canvas.drawRect(Rect.fromLTWH(0, h*0.42, w*0.22, h*0.58), grassP);
    canvas.drawRect(Rect.fromLTWH(w*0.78, h*0.42, w*0.22, h*0.58), grassP);

    // جسم النهر
    final riverPath = Path()
      ..moveTo(w*0.22, h*0.42)
      ..lineTo(w*0.78, h*0.42)
      ..lineTo(w*0.74, h)
      ..lineTo(w*0.26, h)
      ..close();
    canvas.drawPath(riverPath,
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF1565C0), const Color(0xFF0D47A1), const Color(0xFF0A3A80)],
      ).createShader(Rect.fromLTWH(w*0.22, h*0.42, w*0.56, h*0.58)));

    // تموجات النهر (طبقات متعددة)
    for (int row = 0; row < 10; row++) {
      final wy = h * 0.48 + row * h * 0.055;
      final wPaint = Paint()
        ..color = Colors.white.withOpacity(0.07 + (row % 3) * 0.04)
        ..strokeWidth = row % 2 == 0 ? 2.5 : 1.5
        ..style = PaintingStyle.stroke;
      final wavePath = Path();
      bool first = true;
      for (double x = w*0.23; x < w*0.77; x += 8) {
        final y = wy + sin((x * 0.08) + progress * 2 * pi * 1.5 + row * 0.6) * (3 + row * 0.3);
        if (first) { wavePath.moveTo(x, y); first = false; }
        else wavePath.lineTo(x, y);
      }
      canvas.drawPath(wavePath, wPaint);
    }

    // انعكاس الشمس على النهر
    final reflPaint = Paint()
      ..color = const Color(0xFFFFE082).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    for (int i = 0; i < 5; i++) {
      final rx = w*0.4 + (sin(progress*2*pi + i)*w*0.08);
      final ry = h*0.5 + i * h*0.045;
      canvas.drawOval(Rect.fromLTWH(rx, ry, w*0.2, h*0.025), reflPaint);
    }

    // أشجار الضفتين مع تأرجح
    for (int i = 0; i < 5; i++) {
      final sway = sin(progress * 2 * pi * 0.5 + i * 0.9) * 3;
      _tree(canvas, Offset(w*0.01 + i*w*0.043 + sway, h*0.42), 55+i*9.0, const Color(0xFF1B5E20));
      _tree(canvas, Offset(w*0.79 + i*w*0.042 + sway, h*0.42), 52+i*8.0, const Color(0xFF2E7D32));
    }

    // زهور الضفة
    final flowerColors = [const Color(0xFFFF80AB), const Color(0xFFFFFF8D), const Color(0xFFB9F6CA)];
    for (int i = 0; i < 7; i++) {
      _flower(canvas, Offset(w*0.01 + i*w*0.028, h*0.78 + (i%3)*h*0.04), flowerColors[i%3]);
      _flower(canvas, Offset(w*0.79 + i*w*0.028, h*0.75 + (i%2)*h*0.05), flowerColors[(i+1)%3]);
    }

    // طيور تطير
    for (int i = 0; i < 3; i++) {
      final bx = (progress * w * 1.2 + i * w * 0.38) % (w + 60) - 30;
      _bird(canvas, Offset(bx, h*0.14 + i*h*0.05), progress + i * 0.33);
    }

    // سمكة تظهر وتختفي
    final fishX = w*0.3 + sin(progress*2*pi)*w*0.2;
    final fishY = h*0.72 + cos(progress*2*pi*0.7)*h*0.06;
    if (sin(progress * 2 * pi * 2) > 0.7) {
      _fish(canvas, Offset(fishX, fishY));
    }
  }

  void _fish(Canvas canvas, Offset pos) {
    canvas.drawOval(Rect.fromLTWH(pos.dx, pos.dy, 18, 8),
      Paint()..color = const Color(0xFFFF8F00).withOpacity(0.8));
    final tail = Path()
      ..moveTo(pos.dx, pos.dy + 4)
      ..lineTo(pos.dx - 7, pos.dy)
      ..lineTo(pos.dx - 7, pos.dy + 8)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFFFF6F00).withOpacity(0.8));
  }

  // ─────────────────────────────────────────────
  // 💧  الشلال  💧
  // ─────────────────────────────────────────────
  void _paintWaterfall(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;

    // خلفية الشلال
    _fillGradient(canvas, sz, [
      const Color(0xFF0D2A1A), const Color(0xFF1B5E20),
      const Color(0xFF2E7D32), const Color(0xFF1A4A10)]);

    // الصخرة الرئيسية
    final rockPaint = Paint()..color = const Color(0xFF37474F);
    final rockPath = Path()
      ..moveTo(w*0.15, h*0.28)
      ..quadraticBezierTo(w*0.5, h*0.01, w*0.85, h*0.28)
      ..lineTo(w*0.85, h*0.38)
      ..quadraticBezierTo(w*0.5, h*0.18, w*0.15, h*0.38)
      ..close();
    canvas.drawPath(rockPath, rockPaint);
    canvas.drawPath(rockPath,
      Paint()..color = const Color(0xFF263238)
             ..style = PaintingStyle.stroke
             ..strokeWidth = 2);
    // تشقق الصخرة
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(w*0.25 + i*w*0.15, h*0.1),
        Offset(w*0.22 + i*w*0.15 + 8, h*0.25),
        Paint()..color = const Color(0xFF1A252A).withOpacity(0.5)
               ..strokeWidth = 1);
    }

    // شرائط الماء المتدفق (Particle متعدد)
    final rng = _Rng(55);
    for (int col = 0; col < 18; col++) {
      final cx = w*0.22 + col * w*0.033;
      // سرعات متفاوتة لكل شريط
      final speed = 0.7 + rng.f() * 0.6;
      final phase = rng.f();
      for (int drop = 0; drop < 3; drop++) {
        final yStart = h * 0.32;
        final fy = (progress * h * speed + phase * h + drop * h*0.28) % (h * 0.55) + yStart;
        final dropH = h * 0.1 + rng.f() * h * 0.12;
        final alpha = 0.25 + rng.f() * 0.45;
        final ww = 3.0 + (col % 4) * 1.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(cx - ww/2, fy, ww, dropH),
            const Radius.circular(4)),
          Paint()..shader = LinearGradient(
            colors: [
              Colors.white.withOpacity(alpha),
              const Color(0xFF90CAF9).withOpacity(alpha * 0.7),
              Colors.transparent,
            ],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ).createShader(Rect.fromLTWH(cx, fy, ww, dropH)));
      }
    }

    // رذاذ عند القاع (Particles صغيرة)
    final sprayRng = _Rng(77);
    for (int i = 0; i < 40; i++) {
      final sx = w*0.22 + sprayRng.f() * w*0.56;
      final sy = h*0.75 + ((progress * 90 + i * 20) % 50);
      final sr = sprayRng.f() * 2.5 + 0.8;
      final sa = ((sin(progress * 2 * pi * 3 + i * 0.5) + 1) / 2) * 0.5 + 0.1;
      canvas.drawCircle(Offset(sx, sy), sr,
        Paint()..color = Colors.white.withOpacity(sa));
    }

    // البركة
    final poolPaint = Paint()..shader = RadialGradient(
      center: Alignment.topCenter,
      colors: [const Color(0xFF64B5F6), const Color(0xFF0D47A1), const Color(0xFF082060)],
    ).createShader(Rect.fromLTWH(w*0.1, h*0.74, w*0.8, h*0.18));
    canvas.drawOval(Rect.fromLTWH(w*0.1, h*0.74, w*0.8, h*0.18), poolPaint);

    // دوائر البركة المتمددة
    for (int r = 0; r < 5; r++) {
      final rp = ((progress + r * 0.2) % 1.0);
      final rippleR = rp * w * 0.3;
      canvas.drawCircle(Offset(w*0.5, h*0.8), rippleR,
        Paint()
          ..color = Colors.white.withOpacity(((1-rp)*0.3).clamp(0,1))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8 - rp * 1.5);
    }

    // أشجار الغابة المحيطة بتأرجح
    for (int i = 0; i < 4; i++) {
      final sway = sin(progress * 2 * pi * 0.4 + i * 1.2) * 3;
      _tallTree(canvas, Offset(w*0.01 + i*w*0.055 + sway, h*0.74), 80+i*14.0, const Color(0xFF1B5E20));
      _tallTree(canvas, Offset(w*0.79 + i*w*0.06 + sway*0.8, h*0.74), 75+i*12.0, const Color(0xFF2E7D32));
    }

    // طيور
    for (int i = 0; i < 2; i++) {
      final bx = (progress * w + i * w * 0.55) % (w + 50) - 25;
      _bird(canvas, Offset(bx, h*0.18 + i*h*0.06), progress + i*0.5);
    }

    // ضباب عند البركة
    canvas.drawRect(Rect.fromLTWH(0, h*0.7, w, h*0.12),
      Paint()..color = Colors.white.withOpacity(0.06)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
  }

  // ─────────────────────────────────────────────
  // 🌿  الغابة  🌿
  // ─────────────────────────────────────────────
  void _paintForest(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;

    // الغابة - تدرج خضري عميق
    _fillGradient(canvas, sz, [
      const Color(0xFF051205), const Color(0xFF0D2A0D),
      const Color(0xFF1B5E20), const Color(0xFF2E7D32)]);

    // ضوء يتسرب من الأعلى (شعاع شمسي)
    final beamOff = sin(progress * 2 * pi * 0.25) * w * 0.12;
    for (int b = 0; b < 3; b++) {
      final bx = w * 0.25 + b * w * 0.25 + beamOff;
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFFFFF9C4).withOpacity(0.22), Colors.transparent],
        ).createShader(Rect.fromLTWH(bx - w*0.07, 0, w*0.14, h*0.68))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.save();
      canvas.translate(bx, 0);
      canvas.rotate(sin(progress * 2 * pi * 0.2 + b) * 0.08);
      canvas.translate(-bx, 0);
      canvas.drawRect(Rect.fromLTWH(bx - w*0.07, 0, w*0.14, h*0.68), beamPaint);
      canvas.restore();
    }

    // أرضية الغابة
    _fillGradientRect(canvas, Rect.fromLTWH(0, h*0.72, w, h*0.28),
      [const Color(0xFF1B3A1B), const Color(0xFF0D200D)]);

    // جذور وصخور
    final rng = _Rng(31);
    for (int i = 0; i < 12; i++) {
      canvas.drawOval(
        Rect.fromLTWH(rng.f()*w, h*0.78 + rng.f()*h*0.18, 6+rng.f()*12, 4+rng.f()*8),
        Paint()..color = const Color(0xFF4E342E).withOpacity(0.4));
    }

    // أشجار بعيدة (خلفية)
    for (int i = 0; i < 10; i++) {
      final sway = sin(progress * 2 * pi * 0.4 + i * 0.75) * 2.5;
      _tallTree(canvas, Offset((i/9)*w + sway, h*0.72),
        70 + (i%3)*25.0, const Color(0xFF1B5E20).withOpacity(0.65));
    }
    // أشجار أمامية (أكبر، أوضح)
    for (int i = 0; i < 6; i++) {
      final sway = sin(progress * 2 * pi * 0.35 + i * 1.0) * 4;
      _tallTree(canvas, Offset(i * w*0.2 + sway, h*0.68),
        110 + (i%2)*45.0, const Color(0xFF2E7D32));
    }

    // فراشات طائرة (5 فراشات)
    for (int i = 0; i < 5; i++) {
      final bx = w*0.1 + (progress*w*0.7 + i*w*0.2) % (w*0.8);
      final by = h*0.35 + sin(progress*2*pi*2 + i*1.4) * h*0.14;
      _butterfly(canvas, Offset(bx, by), progress + i * 0.2);
    }

    // ضباب أرضي
    for (int i = 0; i < 3; i++) {
      final fogX = (progress*w*0.2 + i*w*0.4) % (w+180) - 90;
      canvas.drawOval(
        Rect.fromLTWH(fogX - w*0.2, h*0.68 + i*h*0.05, w*0.8, h*0.08),
        Paint()..color = Colors.white.withOpacity(0.055 + i*0.015)
               ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));
    }

    // حشرات مضيئة (Fireflies) في الليل / ذرات بريق
    for (int i = 0; i < 18; i++) {
      final frng = _Rng(i * 17);
      final fx = frng.f() * w;
      final fy = h*0.3 + frng.f() * h*0.5;
      final fBlink = (sin(progress*2*pi*2 + i*1.7) + 1) / 2;
      if (fBlink > 0.55) {
        canvas.drawCircle(Offset(fx, fy), 2.5,
          Paint()..color = const Color(0xFFFFFF99).withOpacity(fBlink * 0.8)
                 ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      }
    }
  }

  // ─────────────────────────────────────────────
  // 🔥  النار  🔥
  // ─────────────────────────────────────────────
  void _paintFire(Canvas canvas, Size sz) {
    final w = sz.width; final h = sz.height;

    // خلفية دافئة ليلية
    _fillGradient(canvas, sz, [
      const Color(0xFF0A0505), const Color(0xFF1A0800),
      const Color(0xFF2D0F00), const Color(0xFF180800)]);

    // أرضية مع حجارة المدفأة
    _fillGradientRect(canvas, Rect.fromLTWH(0, h*0.78, w, h*0.22),
      [const Color(0xFF1A0A00), const Color(0xFF0D0500)]);

    // حجارة الموقد
    final stonePaint = Paint()..color = const Color(0xFF3E2723);
    canvas.drawOval(Rect.fromLTWH(w*0.12, h*0.74, w*0.76, h*0.12), stonePaint);
    canvas.drawOval(Rect.fromLTWH(w*0.15, h*0.75, w*0.7, h*0.09),
      Paint()..color = const Color(0xFF2A1A14));

    // جذوع الحطب
    for (int i = 0; i < 3; i++) {
      canvas.save();
      canvas.translate(w*0.3 + i*w*0.12, h*0.77);
      canvas.rotate(-0.3 + i*0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-w*0.1, -h*0.025, w*0.2, h*0.035),
          const Radius.circular(4)),
        Paint()..color = const Color(0xFF4E342E));
      canvas.restore();
    }
    // جمر تحت النار
    final emberColors = [const Color(0xFFFF3D00), const Color(0xFFFF6D00), const Color(0xFFFF9100)];
    final rng = _Rng(88);
    for (int i = 0; i < 15; i++) {
      final ex = w*0.28 + rng.f()*w*0.44;
      final ey = h*0.74 + rng.f()*h*0.05;
      final pulse = (sin(progress*2*pi*3+i*0.8)+1)/2;
      canvas.drawCircle(Offset(ex, ey), 3+rng.f()*4,
        Paint()..color = emberColors[i%3].withOpacity(0.6+pulse*0.4));
    }

    // ====== لهب النار (Particle System) ======
    // عدة طبقات من اللهب
    final flameLayers = [
      // [يسار مركز، عرض نسبي، ارتفاع، خصائص]
      [0.28, 0.44, 0.48, 0], // طبقة رئيسية
      [0.33, 0.34, 0.38, 1], // طبقة وسط
      [0.38, 0.24, 0.28, 2], // طبقة داخلية
    ];

    for (int li = 0; li < flameLayers.length; li++) {
      final layer = flameLayers[li];
      final lx = w * layer[0]; final lw = w * layer[1];
      final lh = h * layer[2];
      final base = h * 0.74;
      final layerProg = progress + li * 0.12;

      for (int col = 0; col < 12; col++) {
        final cx = lx + col * (lw / 11);
        final flameH = lh * (0.5 + sin(layerProg * 2 * pi * 2 + col * 0.7) * 0.5);
        final wobble = sin(layerProg * 2 * pi * 3 + col * 0.5) * w * 0.018;

        final flameColors = li == 0
          ? [const Color(0xFFFFFF00).withOpacity(0.0), const Color(0xFFFFCC00).withOpacity(0.7),
             const Color(0xFFFF6600).withOpacity(0.85), const Color(0xFFCC2200).withOpacity(0.9)]
          : li == 1
            ? [const Color(0xFFFFFFFF).withOpacity(0.0), const Color(0xFFFFFF88).withOpacity(0.5),
               const Color(0xFFFFAA00).withOpacity(0.7), const Color(0xFFFF4400).withOpacity(0.8)]
            : [const Color(0xFFFFFFFF).withOpacity(0.0), const Color(0xFFFFFFCC).withOpacity(0.6),
               const Color(0xFFFFCC44).withOpacity(0.8), const Color(0xFFFFFFFF).withOpacity(0.0)];

        final flamePath = Path()
          ..moveTo(cx - lw*0.04, base)
          ..quadraticBezierTo(
            cx - lw*0.02 + wobble * 0.5, base - flameH * 0.5,
            cx + wobble, base - flameH)
          ..quadraticBezierTo(
            cx + lw*0.02 + wobble * 0.5, base - flameH * 0.5,
            cx + lw*0.04, base)
          ..close();

        canvas.drawPath(flamePath,
          Paint()..shader = LinearGradient(
            begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors: flameColors,
          ).createShader(Rect.fromLTWH(cx - lw*0.04, base - flameH, lw*0.08, flameH)));
      }
    }

    // جزيئات الشرر الطائرة
    final sparkRng = _Rng(66);
    for (int i = 0; i < 25; i++) {
      final baseX = w*0.3 + sparkRng.f()*w*0.4;
      final speed = 0.3 + sparkRng.f() * 0.7;
      final sy = h*0.74 - ((progress * h * speed + i*(h/25)) % (h*0.6));
      final sx = baseX + sin(progress*2*pi*2 + i*1.1) * w*0.06;
      final sa = ((1 - (h*0.74-sy)/(h*0.6)).clamp(0.0, 1.0)) * 0.85;
      if (sa > 0.05) {
        canvas.drawCircle(Offset(sx, sy), 1.5 + sparkRng.f()*2,
          Paint()..color = const Color(0xFFFFCC44).withOpacity(sa)
                 ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
      }
    }

    // توهج النار على المحيط
    canvas.drawOval(
      Rect.fromLTWH(w*0.1, h*0.4, w*0.8, h*0.38),
      Paint()..color = const Color(0xFFFF4400).withOpacity(0.08)
             ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));

    // دخان
    final smokeRng = _Rng(44);
    for (int i = 0; i < 8; i++) {
      final smProgress = (progress * 0.4 + i * 0.125) % 1.0;
      final sx = w*0.4 + sin(smProgress * 2 * pi + i) * w*0.12;
      final sy = h*0.26 - smProgress * h*0.22;
      final sr = 15 + smProgress * 35;
      canvas.drawCircle(Offset(sx, sy), sr,
        Paint()..color = const Color(0xFF1A1A1A).withOpacity((1-smProgress)*0.2)
               ..maskFilter = MaskFilter.blur(BlurStyle.normal, sr*0.7));
    }
  }

  // ─────────────────────────────────────────────
  // دوال مساعدة
  // ─────────────────────────────────────────────
  void _fillGradient(Canvas canvas, Size sz, List<Color> colors) {
    final stops = List.generate(colors.length, (i) => i / (colors.length - 1));
    canvas.drawRect(Rect.fromLTWH(0, 0, sz.width, sz.height),
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: colors, stops: stops,
      ).createShader(Rect.fromLTWH(0, 0, sz.width, sz.height)));
  }

  void _fillGradientRect(Canvas canvas, Rect rect, List<Color> colors) {
    canvas.drawRect(rect,
      Paint()..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect));
  }

  void _cloud(Canvas canvas, Offset pos, double scale, Color color) {
    final p = Paint()..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final r = 24.0 * scale;
    canvas.drawCircle(pos, r, p);
    canvas.drawCircle(pos + Offset(-r*0.72, r*0.05), r*0.78, p);
    canvas.drawCircle(pos + Offset( r*0.72, r*0.05), r*0.78, p);
    canvas.drawCircle(pos + Offset(-r*1.35, r*0.3),  r*0.62, p);
    canvas.drawCircle(pos + Offset( r*1.35, r*0.3),  r*0.62, p);
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - r*1.6, pos.dy, r*3.2, r*0.55),
      Paint()..color = color);
  }

  void _tree(Canvas canvas, Offset base, double h, Color color) {
    canvas.drawRect(Rect.fromLTWH(base.dx-4, base.dy-h*0.32, 8, h*0.32),
      Paint()..color = const Color(0xFF5D4037));
    final p = Paint()..color = color;
    canvas.drawCircle(base + Offset(0, -h*0.55), h*0.38, p);
    canvas.drawCircle(base + Offset(-h*0.22, -h*0.44), h*0.28, p);
    canvas.drawCircle(base + Offset( h*0.22, -h*0.44), h*0.28, p);
  }

  void _tallTree(Canvas canvas, Offset base, double h, Color color) {
    canvas.drawRect(Rect.fromLTWH(base.dx-5, base.dy-h*0.38, 10, h*0.38),
      Paint()..color = const Color(0xFF3E2723));
    final p = Paint()..color = color;
    for (int t = 0; t < 3; t++) {
      final ty = base.dy - h * (0.35 + t * 0.25);
      final tw = h * (0.38 - t * 0.08);
      final path = Path()
        ..moveTo(base.dx, base.dy - h * (0.6 + t * 0.18))
        ..lineTo(base.dx - tw, ty)
        ..lineTo(base.dx + tw, ty)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  void _treeSimple(Canvas canvas, Offset base, double h, Color color) {
    canvas.drawRect(Rect.fromLTWH(base.dx-3, base.dy-h*0.3, 6, h*0.3),
      Paint()..color = const Color(0xFF3E2723));
    final path = Path()
      ..moveTo(base.dx, base.dy - h)
      ..lineTo(base.dx - h*0.28, base.dy - h*0.3)
      ..lineTo(base.dx + h*0.28, base.dy - h*0.3)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _flower(Canvas canvas, Offset pos, Color color) {
    canvas.drawLine(pos, pos+const Offset(0,14),
      Paint()..color = const Color(0xFF4CAF50)..strokeWidth = 2);
    final pp = Paint()..color = color;
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5;
      canvas.drawCircle(pos + Offset(cos(a)*6, sin(a)*6), 4, pp);
    }
    canvas.drawCircle(pos, 4, Paint()..color = const Color(0xFFFFD700));
  }

  void _bird(Canvas canvas, Offset pos, double t) {
    final flap = sin(t * 2 * pi * 4) * 5;
    final p = Paint()..color = Colors.white.withOpacity(0.8)
                    ..strokeWidth = 1.8
                    ..style = PaintingStyle.stroke
                    ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(pos.dx-10, pos.dy)
      ..quadraticBezierTo(pos.dx-5, pos.dy-flap, pos.dx, pos.dy)
      ..quadraticBezierTo(pos.dx+5, pos.dy-flap, pos.dx+10, pos.dy);
    canvas.drawPath(path, p);
  }

  void _butterfly(Canvas canvas, Offset pos, double t) {
    final flap = sin(t * 2 * pi * 6);
    final colors = [const Color(0xFFE91E63), const Color(0xFF9C27B0),
                    const Color(0xFFFF9800), const Color(0xFF00BCD4)];
    final c = colors[(t * 8).toInt() % colors.length];
    for (int side = 0; side < 2; side++) {
      final sx = side == 0 ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(pos.dx, pos.dy)
        ..quadraticBezierTo(pos.dx+sx*18, pos.dy-flap*9, pos.dx+sx*14, pos.dy+9)
        ..quadraticBezierTo(pos.dx+sx*7,  pos.dy+12,     pos.dx, pos.dy);
      canvas.drawPath(path, Paint()..color = c.withOpacity(0.72));
    }
    canvas.drawCircle(pos, 1.5, Paint()..color = Colors.black54);
  }

  @override
  bool shouldRepaint(_NatureScenePainter o) =>
    o.progress != progress || o.scene != scene || o.timeOfDay != timeOfDay;
}

class _Rng {
  int _s;
  _Rng(int seed) : _s = seed ^ 0xDEADBEEF;
  double f() {
    _s = (_s ^ (_s << 13)) & 0xFFFFFFFF;
    _s = (_s ^ (_s >> 17)) & 0xFFFFFFFF;
    _s = (_s ^ (_s << 5))  & 0xFFFFFFFF;
    return (_s & 0xFFFF) / 65535.0;
  }
}


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
