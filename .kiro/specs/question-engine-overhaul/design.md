# Design Document — Question Engine Overhaul

## Overview

The overhaul extends the existing Flutter TKA tryout app (Provider + Hive, targeting Android / iOS / Web) to fix 12 critical bugs and add three new surfaces: `DiagnosticsScreen`, `question_manifest.json`, and a fully wired submit → `ResultScreen` → `ReviewScreen` flow. All existing classes are **extended or corrected**, not replaced. The language is Dart/Flutter and the state layer uses `provider` with Hive for persistence.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│  UI Layer  (lib/screens/, lib/widgets/)                              │
│  ExamScreen → ResultScreen → ReviewScreen                            │
│  DiagnosticsScreen  PackageScreen  HomeScreen                        │
│  QuestionCardWidget  (dispatches per QuestionType)                   │
└────────────────────────┬────────────────────────────────────────────┘
                         │ Provider / ChangeNotifier
┌────────────────────────▼────────────────────────────────────────────┐
│  Service Layer  (lib/services/)                                      │
│  ExamService (ChangeNotifier)   ScoringService (static)              │
│  StorageService (static, Hive)  RandomSimulationService (static)     │
│  TimerService   AntiCheatService                                     │
└────────────────────────┬────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────────┐
│  Model Layer  (lib/models/)                                          │
│  Question  QuestionType  ExamPackage  ExamResult                     │
│  StimulusGroup  QuestionBreakdown  Subject                           │
└────────────────────────┬────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────────┐
│  Data Layer  (lib/data/)                                             │
│  english/  indonesian/  mathematics/  (19 packages total)            │
│  subjects_data.dart  leaderboard_data.dart                           │
└────────────────────────┬────────────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────────────┐
│  Assets  (assets/)                                                   │
│  question_manifest.json                                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 1. Question Model Architecture

The `Question` model in `lib/models/question.dart` is already structurally complete (all required fields are present as of the current codebase). The overhaul **validates** that every field is in place and that the serialization contract is enforced.

### 1.1 Field Inventory

| Field | Type | Nullable | Default |
|---|---|---|---|
| `id` | `String` | no | — |
| `sourceId` | `String?` | yes | `null` |
| `sourceUrl` | `String?` | yes | `null` |
| `sourceQuestionNumber` | `int?` | yes | `null` |
| `subjectId` | `String` | no | `''` |
| `packageId` | `String` | no | `''` |
| `packageName` | `String` | no | `''` |
| `questionType` | `QuestionType` | no | `singleChoice` |
| `displayNumber` | `int` | no | `0` |
| `stimulus` | `String?` | yes | `null` |
| `stimulusImageUrl` | `String?` | yes | `null` |
| `questionText` | `String` | no | — |
| `imageUrl` | `String?` | yes | `null` |
| `options` | `Map<String, String>` | no | — |
| `correctAnswers` | `List<String>` | no | — |
| `explanation` | `String?` | yes | `null` |
| `scoreCorrect` | `int` | no | `4` |
| `scoreWrong` | `int` | no | `-1` |
| `scoreEmpty` | `int` | no | `0` |
| `scoringRule` | `String` | no | `'exact'` |
| `metadata` | `Map<String, dynamic>?` | yes | `null` |

### 1.2 validate() Contract

```dart
List<String> validate() {
  final errors = <String>[];
  if (questionText.trim().isEmpty) errors.add('Question text is empty');
  if (options.isEmpty && !questionType.isTextInput) {
    errors.add('Question has no options');
  }
  if (correctAnswers.isEmpty ||
      (correctAnswers.length == 1 && correctAnswers.first.isEmpty)) {
    errors.add('No correct answer specified');
  }
  return errors;
}
```

This method is already present and correctly implemented. No changes needed.

### 1.3 Serialization Round-Trip

`toJson()` and `fromJson()` already cover all fields. The one gap to fix: `fromJson` must handle both `'QuestionType.singleChoice'` (enum `.toString()` format) and bare `'singleChoice'` tokens. The existing `parseQuestionType` fallback already handles this, but `Question.fromJson` should prefer `QuestionType.values.byName(token)` for the bare form before falling back to the string-prefix match.

```dart
// Corrected type parsing in fromJson:
qType = QuestionType.values.firstWhere(
  (t) => t.name == typeStr || t.toString() == typeStr,
  orElse: () => parseQuestionType(typeStr),
);
```

---

## 2. QuestionType Enum and Rendering Strategy

### 2.1 Enum Definition (lib/models/question_type.dart)

The enum currently contains all 10 required values and is correct as-is:

```dart
enum QuestionType {
  singleChoice,
  multipleChoice,
  trueOrFalse,
  suitableOrNot,
  matching,
  numericInput,
  shortText,
  imageBased,
  tableBased,
  complexChoice,
}
```

### 2.2 Rendering Strategy per Type

| QuestionType | Widget Strategy | Answer Storage Format |
|---|---|---|
| `singleChoice` | `AnswerOptionWidget` (radio, one selection) | `'A'` |
| `imageBased` | `AnswerOptionWidget` (radio) + `Image.network` above options | `'A'` |
| `tableBased` | `AnswerOptionWidget` (radio) + table rendered in stimulus | `'A'` |
| `multipleChoice` | `_MultiSelectOption` (checkbox, multi) | `'A,C'` |
| `complexChoice` | `_MultiSelectOption` (checkbox, multi, partial scoring) | `'A,C,E'` |
| `trueOrFalse` | `_TrueFalseRow` per option entry (Benar/Salah) | `'1:Benar,2:Salah'` |
| `suitableOrNot` | `_TrueFalseRow` per option entry (Sesuai/Tidak Sesuai) | `'1:Sesuai,2:Tidak Sesuai'` |
| `matching` | `_MultiSelectOption` (treated as multi-select for now) | `'A,C'` |
| `numericInput` | `TextField` with numeric keyboard | `'42'` |
| `shortText` | `TextField` with text keyboard | `'Paris'` |

The dispatch in `QuestionCardWidget._buildAnswerSection` covers all cases. The current `switch` statement needs one addition for `numericInput`/`shortText` to render a `TextField`:

```dart
case QuestionType.numericInput:
case QuestionType.shortText:
  return _buildTextInputAnswer();
```

### 2.3 parseQuestionType Additions

Add `'complexChoice'` and `QuestionType.complexChoice.toString()` to `parseQuestionType` and document all 10 canonical string tokens plus their `toString()` form and Indonesian labels:

```dart
// Token → QuestionType mapping table (all must not throw)
// 'singleChoice'     → singleChoice    // 'Pilihan Ganda'     → singleChoice
// 'multipleChoice'   → multipleChoice  // 'Pilihan Ganda Kompleks' → multipleChoice
// 'trueOrFalse'      → trueOrFalse     // 'Benar/Salah'        → trueOrFalse
// 'suitableOrNot'    → suitableOrNot   // 'Sesuai/Tidak Sesuai'→ suitableOrNot
// 'matching'         → matching        // 'Pencocokan'         → matching
// 'numericInput'     → numericInput    // 'Input Angka'        → numericInput
// 'shortText'        → shortText       // 'Uraian Singkat'     → shortText
// 'imageBased'       → imageBased      // 'Soal Berbasis Gambar'→ imageBased
// 'tableBased'       → tableBased      // 'Soal Berbasis Tabel' → tableBased
// 'complexChoice'    → complexChoice   // 'Pilihan Kompleks'   → complexChoice
```

---

## 3. StimulusGroup Model and Sharing Mechanism

### 3.1 StimulusGroup Model (lib/models/stimulus_group.dart)

Already present and correct. No structural changes needed:

```dart
class StimulusGroup {
  final String id;
  final String? text;       // maps to Question.stimulus
  final String? imageUrl;   // maps to Question.stimulusImageUrl
  final List<String> questionIds;
  final DateTime createdAt;
}
```

### 3.2 Sharing Mechanism in lib/data/

The sharing mechanism is **data-level, not runtime**: when authoring questions in Dart const files, every `Question` in a stimulus group receives identical `stimulus` and `stimulusImageUrl` values. The `StimulusGroup` model exists for diagnostics and potential future use.

Convention for data authors:
1. Define a `const String _stimulusPassage1 = '...'` variable at the top of the package file.
2. Assign `stimulus: _stimulusPassage1` to every `Question` in that group.
3. Leave `stimulus: null` for standalone questions.

### 3.3 Rendering in QuestionCardWidget

The existing `_buildStimulus()` method correctly renders the stimulus block when `question.stimulus != null && question.stimulus!.trim().isNotEmpty`. The `stimulusImageUrl` rendering path needs to be added:

```dart
Widget _buildStimulus() {
  final hasText = question.stimulus?.trim().isNotEmpty == true;
  final hasImage = question.stimulusImageUrl?.trim().isNotEmpty == true;
  if (!hasText && !hasImage) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        // ... existing decoration ...
        child: Column(
          children: [
            // header row (existing)
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  question.stimulusImageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: _imageLoadingBuilder,
                  errorBuilder: _imageErrorBuilder,
                ),
              ),
              if (hasText) const SizedBox(height: 8),
            ],
            if (hasText) MathText(text: question.stimulus!, ...),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
```

---

## 4. ScoringService Design

### 4.1 Responsibilities

`ScoringService` is a pure static utility — no state, no I/O:

- `calculate(...)` → `ExamResult` (already correct in current code)
- `formatDurationText(int seconds)` → `String` (already correct)
- `formatClock(int seconds)` → `String` (already correct)
- `calculateAccuracy(int correct, int total)` → `double`
- `getPerformanceRating(int score)` → `String`

### 4.2 Scoring Rules

| `scoringRule` | Behavior |
|---|---|
| `'exact'` | All selected answers must exactly match correctAnswers (order-insensitive set equality) |
| `'partial'` | Each correctly selected answer earns `scoreCorrect / correctAnswers.length` |
| `'any'` | Any one matching answer counts as correct (used for matching type) |

For `trueOrFalse` and `suitableOrNot`, the answer is stored as `'key:Value,key:Value,...'` and correctness is evaluated per-statement, then all statements must match for the question to be correct.

### 4.3 Score Formula

```
rawScore = Σ (per question: +scoreCorrect | scoreWrong | +scoreEmpty)
maxPossible = questions.length × scoreCorrect
clampedRaw = max(0, rawScore)
finalScore = maxPossible > 0 ? round((clampedRaw / maxPossible) × 100) : 0
```

---

## 5. Submit Flow with Double-Submit Guard

### 5.1 State Machine

```
IDLE ─[submitExam()]──► SUBMITTING ─[calculate() ok]──► DONE
       if guard==true,            [calculate() throws]──► IDLE
       return _result                                    (guard reset)
```

### 5.2 ExamService.submitExam() Implementation

The current implementation is functionally correct. The key guard block:

```dart
Future<ExamResult?> submitExam({
  bool forcedByTimeout = false,
  bool forcedByAntiCheat = false,
}) async {
  if (_isSubmitting || _submitGuard) return _result;  // guard
  _isSubmitting = true;
  _submitGuard = true;
  _timer?.cancel();
  _antiCheatService?.stopListening();
  notifyListeners();

  try {
    // ... ScoringService.calculate() ...
    await StorageService.appendHistory(_result!);
    await StorageService.clearActiveExam();
  } catch (e) {
    _isSubmitting = false;
    _submitGuard = false;
    notifyListeners();
    return null;
  }

  notifyListeners();
  return _result;
}
```

### 5.3 Post-Frame Navigation

In `_ExamContentState.build()`, the post-frame callback navigates when `exam.result != null`. This is already implemented:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;
  if (exam.result != null) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultScreen(result: exam.result!)),
    );
  }
});
```

**Bug to fix**: The callback is registered on every `build()` call, causing multiple `pushReplacement` calls. Fix by tracking navigation state:

```dart
bool _hasNavigated = false;

// In post-frame callback:
if (exam.result != null && !_hasNavigated) {
  _hasNavigated = true;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => ResultScreen(result: exam.result!)),
  );
}
```

### 5.4 Timer Auto-Submit

When `_remainingSeconds <= 0`, the timer calls `submitExam(forcedByTimeout: true)`, which runs through the same guard + save + navigate pipeline. Already implemented correctly.

---

## 6. ResultScreen Architecture

### 6.1 Component Structure

```
ResultScreen (StatelessWidget)
├── AppBar (automaticallyImplyLeading: false)
├── SingleChildScrollView
│   ├── Banner Card
│   │   ├── "TRYOUT SELESAI" label
│   │   ├── username + packageName
│   │   ├── Score Circle (120×120 gradient)
│   │   └── Trend Badge (conditional, >= 2 history entries)
│   ├── Stats Row (Benar / Salah / Kosong)
│   ├── Duration Card
│   ├── "Review Jawaban & Pembahasan" button → ReviewScreen
│   └── "Kembali ke Dashboard" button → Navigator.pop()
```

### 6.2 Trend Badge Logic

```dart
final history = StorageService.getHistoryByPackage(result.packageId);
// history[0] is current attempt (just appended)
int? diff;
if (history.length >= 2) {
  diff = result.score - history[1].score;
}
```

`diff > 0` → green upward trend; `diff < 0` → red downward trend; `diff == 0` → neutral.

### 6.3 AppBar

```dart
AppBar(
  automaticallyImplyLeading: false,
  title: const Text('Hasil Tryout'),
)
```

Already implemented. The screen is already correct structurally — implementation tasks focus on ensuring `result.score`, `result.correct`, `result.wrong`, `result.empty`, and `result.durationSeconds` are all non-zero from a correctly wired submit flow.

---

## 7. ReviewScreen Architecture

### 7.1 Component Structure

```
ReviewScreen (StatefulWidget)
├── AppBar (with back arrow, title: 'Review (N/Total)')
├── Status Bar (color-coded: green/red/grey)
│   ├── Status icon + label (BENAR / SALAH / TIDAK DIJAWAB)
│   └── "Kamu: X | Benar: Y" summary
├── Expanded
│   └── QuestionCardWidget(isReviewMode: true)
└── BottomNavigationBar
    ├── "Sebelumnya" (disabled on first question)
    └── "Berikutnya" / "Selesai Review" (last question → Navigator.pop)
```

### 7.2 Empty State

```dart
if (breakdownList.isEmpty) {
  return Scaffold(
    appBar: AppBar(title: const Text('Review Jawaban')),
    body: const Center(child: Text('Data review tidak tersedia.')),
  );
}
```

Already implemented correctly.

### 7.3 Status Colors

| `status` value | Bar color | Label |
|---|---|---|
| `'correct'` | `Color(0xFFF0FDF4)` green | `'BENAR'` |
| `'wrong'` | `Color(0xFFFFF1F2)` red | `'SALAH'` |
| `'empty'` | `Color(0xFFF1F5F9)` grey | `'TIDAK DIJAWAB'` |

---

## 8. RandomSimulationService Design

### 8.1 Public API

```dart
// Returns a deterministic, deduplicated list of questionCount questions.
static List<Question> createRandomSimulation({
  required List<Question> questionPool,
  int questionCount = 30,
  int? seed,
}) { ... }

// Returns true iff all question IDs are unique.
static bool validateNoDuplicates(List<Question> questions) { ... }

// Duration brackets: ≤20→3600, 21–25→4500, 26–30→5400.
static int calculateDurationSeconds(int questionCount) { ... }

// Metadata map for session persistence.
static Map<String, dynamic> createSimulationMetadata({...}) { ... }
```

### 8.2 Determinism Contract

```dart
final random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);
final shuffled = List<Question>.from(questionPool)..shuffle(random);
final selected = shuffled.take(questionCount).toList();
```

Calling with the same `seed` always produces the same `selected` list from the same `questionPool`, because `dart:math Random(seed).shuffle` is deterministic for a given seed.

### 8.3 Duration Brackets

```dart
static int calculateDurationSeconds(int questionCount) {
  if (questionCount <= 0) return 0;
  if (questionCount <= 20) return 3600;   // 60 min
  if (questionCount <= 25) return 4500;   // 75 min
  return 5400;                            // 90 min (covers 26–30 and beyond)
}
```

The current implementation returns `3600/4500/5400` correctly, but uses boundary `<= 25` / `<= 30` with a `return 90 * 60` for the 26–30 range. Verify: `26 <= 30` → true → returns `90 * 60 = 5400`. Correct.

### 8.4 Session Resume

The session metadata stored in `StorageService.saveActiveExam()` must include:

```dart
{
  'packageId': simulationPackageId,
  'isSimulation': true,
  'seed': seed,
  'questionCount': questionCount,
  // ... standard exam session fields ...
}
```

On resume, `ExamScreen` reads `activeExamData['isSimulation'] == true`, extracts `seed` and `questionCount`, re-runs `createRandomSimulation(pool, questionCount, seed)`, and reconstructs the `ExamPackage` with the same question order.

---

## 9. StorageService — Hive Boxes

### 9.1 Box Registry

| Box name | Key | Content |
|---|---|---|
| `futureee_profile_box` | `'local_profile'` | `Map<String, dynamic>` user profile |
| `futureee_settings_box` | `'tka_settings'` | `Map<String, dynamic>` app settings |
| `futureee_settings_box` | `'tka_session_uid'` | `String` session UID |
| `futureee_settings_box` | `'tka_username'` | `String` username |
| `futureee_history_box` | `'tka_history'` | `List<Map>` serialized ExamResults |
| `futureee_active_exam_box` | `'tka_active_exam'` | `Map<String, dynamic>` active session |

### 9.2 appendHistory Contract

```dart
static Future<void> appendHistory(ExamResult result) async {
  final items = getHistory();   // deserialize existing
  items.insert(0, result);      // newest at index 0
  await saveHistory(items);     // re-serialize and persist
}
```

### 9.3 getHistory Error Tolerance

```dart
for (final item in data) {
  try {
    results.add(ExamResult.fromJson(Map<String, dynamic>.from(item as Map)));
  } catch (e) {
    // Skip malformed entry, continue
  }
}
```

Already implemented. No changes needed.

### 9.4 getBestScoreForPackage

```dart
static int? getBestScoreForPackage(String packageId) {
  final values = getHistoryByPackage(packageId).map((e) => e.score);
  if (values.isEmpty) return null;
  return values.reduce((a, b) => a > b ? a : b);
}
```

Already implemented correctly.

---

## 10. question_manifest.json Structure

### 10.1 File Location

```
assets/question_manifest.json
```

Declared in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/question_manifest.json
```

### 10.2 Schema

```json
[
  {
    "id": "english-01",
    "subjectId": "english",
    "title": "Bahasa Inggris Paket 1",
    "sourceUrl": "https://www.defantri.com/...",
    "questionCount": 30,
    "typeCounts": {
      "singleChoice": 25,
      "trueOrFalse": 3,
      "multipleChoice": 2
    }
  },
  {
    "id": "english-02",
    "subjectId": "english",
    "title": "Bahasa Inggris Paket 2",
    "sourceUrl": "https://www.defantri.com/...",
    "questionCount": 0,
    "typeCounts": {}
  }
]
```

Keys:
- `id` — matches `ExamPackage.id`
- `subjectId` — `'english'` | `'indonesian'` | `'mathematics'`
- `title` — `ExamPackage.title`
- `sourceUrl` — `ExamPackage.sourceUrl`
- `questionCount` — `ExamPackage.questions.length`
- `typeCounts` — object mapping `QuestionType.name` → count (only types with count > 0 are included, except when `questionCount == 0` the object is empty `{}`)

### 10.3 Generation

A standalone Dart script `tool/generate_manifest.dart` reads all three package lists at compile-time and writes `assets/question_manifest.json`. It is **not** invoked at app runtime. It should be run after any change to `lib/data/`.

```dart
// tool/generate_manifest.dart
import 'dart:convert';
import 'dart:io';
import '../lib/data/english/english_packages.dart';
import '../lib/data/indonesian/indonesian_packages.dart';
import '../lib/data/mathematics/mathematics_packages.dart';

void main() {
  final allPackages = [
    ...EnglishPackages.list,
    ...IndonesianPackages.list,
    ...MathematicsPackages.list,
  ];

  final manifest = allPackages.map((pkg) {
    final typeCounts = <String, int>{};
    for (final q in pkg.questions) {
      final key = q.questionType.name;
      typeCounts[key] = (typeCounts[key] ?? 0) + 1;
    }
    return {
      'id': pkg.id,
      'subjectId': pkg.subjectId,
      'title': pkg.title,
      'sourceUrl': pkg.sourceUrl,
      'questionCount': pkg.questions.length,
      'typeCounts': typeCounts,
    };
  }).toList();

  File('assets/question_manifest.json')
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(manifest));
  print('Manifest written: ${manifest.length} packages');
}
```

---

## 11. DiagnosticsScreen

### 11.1 Location

`lib/screens/diagnostics_screen.dart` — new file.

### 11.2 Access Point

In `SettingsScreen`, add a list tile in the DATA section:

```dart
ListTile(
  leading: const Icon(Icons.bug_report_rounded, color: Color(0xFF7C3AED)),
  title: const Text('Diagnostik Data'),
  subtitle: const Text('Periksa kualitas data soal', style: TextStyle(fontSize: 12)),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DiagnosticsScreen()),
  ),
),
```

### 11.3 DiagnosticsScreen Implementation

```dart
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  List<Map<String, dynamic>> _manifest = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadManifest();
  }

  Future<void> _loadManifest() async {
    try {
      final json = await rootBundle.loadString('assets/question_manifest.json');
      final list = jsonDecode(json) as List;
      setState(() {
        _manifest = list.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
```

### 11.4 Display Logic

1. **Summary header**: Total packages, total questions, per-subject breakdown (count packages and sum questionCount grouped by subjectId).
2. **Empty packages**: List entries where `questionCount == 0`, labeled "Paket kosong".
3. **In-memory validation**: For each package in the manifest, find the matching `ExamPackage` from the three package lists and call `Question.validate()` on every question. Group errors by error string.
4. **All valid state**: If no issues found, display `'Semua data soal valid.'`.

### 11.5 All Packages in DiagnosticsScreen

```dart
final _allPackages = [
  ...EnglishPackages.list,
  ...IndonesianPackages.list,
  ...MathematicsPackages.list,
];
```

---

## 12. Data Layer Organization (lib/data/)

### 12.1 Directory Structure

```
lib/data/
├── subjects_data.dart          (SubjectsData — existing)
├── leaderboard_data.dart       (LeaderboardData — existing)
├── english/
│   └── english_packages.dart  (EnglishPackages — 8 packages)
├── indonesian/
│   └── indonesian_packages.dart (IndonesianPackages — 6 packages)
└── mathematics/
    └── mathematics_packages.dart (MathematicsPackages — 5 packages)
```

Total: 19 `ExamPackage` instances across 3 subjects.

### 12.2 Package File Convention

Each package file follows the pattern:

```dart
// lib/data/english/english_packages.dart
class EnglishPackages {
  static final List<ExamPackage> list = [
    ExamPackage(id: 'english-01', ..., questions: _package1Questions),
    // ... 7 more
  ];
}

// Private question lists — one const list per package
const List<Question> _package1Questions = [ ... ];
const List<Question> _package2Questions = [ ... ];
// ...
```

Stimulus groups within a file use local const variables:

```dart
const String _pkg1Stimulus1 = 'Read the following text carefully.\n\n"The Amazon rainforest..."';

const List<Question> _package1Questions = [
  Question(
    id: 'eng-01-001',
    stimulus: _pkg1Stimulus1,
    questionText: 'What is the main topic of the text?',
    // ...
  ),
  Question(
    id: 'eng-01-002',
    stimulus: _pkg1Stimulus1,  // same passage
    questionText: 'According to the text, what...',
    // ...
  ),
];
```

### 12.3 Cross-Subject Aggregation

Screens that aggregate across subjects (HomeScreen, DiagnosticsScreen, RandomSimulationService setup) import all three:

```dart
import 'package:futureee/data/english/english_packages.dart';
import 'package:futureee/data/indonesian/indonesian_packages.dart';
import 'package:futureee/data/mathematics/mathematics_packages.dart';

final allPackages = [
  ...EnglishPackages.list,
  ...IndonesianPackages.list,
  ...MathematicsPackages.list,
];
```

### 12.4 PackageScreen._getPackages()

```dart
List<ExamPackage> _getPackages(Subject subject) {
  return switch (subject.id) {
    'english'     => EnglishPackages.list,
    'indonesian'  => IndonesianPackages.list,
    'mathematics' => MathematicsPackages.list,
    _             => const [],
  };
}
```

### 12.5 HomeScreen._findPackageById()

```dart
ExamPackage? _findPackageById(String packageId) {
  for (final pkg in [
    ...EnglishPackages.list,
    ...IndonesianPackages.list,
    ...MathematicsPackages.list,
  ]) {
    if (pkg.id == packageId) return pkg;
  }
  return null;
}
```

---

## 13. Test Strategy

### 13.1 Unit Tests (test/)

#### test/scoring_service_test.dart

```dart
void main() {
  group('ScoringService.calculate()', () {
    test('all correct answers produce score 100', () { ... });
    test('all wrong answers produce score 0 (clamped)', () { ... });
    test('all empty answers produce score 0', () { ... });
    test('mixed answers compute correct rawScore', () { ... });
  });
}
```

#### test/random_simulation_service_test.dart

```dart
void main() {
  group('RandomSimulationService', () {
    test('same seed produces same question order', () {
      final pool = _buildPool(50);
      final a = RandomSimulationService.createRandomSimulation(
          questionPool: pool, seed: 42);
      final b = RandomSimulationService.createRandomSimulation(
          questionPool: pool, seed: 42);
      expect(a.map((q) => q.id).toList(),
             equals(b.map((q) => q.id).toList()));
    });

    test('throws StateError when questionCount > pool.length', () {
      expect(
        () => RandomSimulationService.createRandomSimulation(
            questionPool: _buildPool(5), questionCount: 10),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message',
            contains('Cannot create simulation'))),
      );
    });

    test('calculateDurationSeconds brackets', () {
      expect(RandomSimulationService.calculateDurationSeconds(15), 3600);
      expect(RandomSimulationService.calculateDurationSeconds(20), 3600);
      expect(RandomSimulationService.calculateDurationSeconds(21), 4500);
      expect(RandomSimulationService.calculateDurationSeconds(25), 4500);
      expect(RandomSimulationService.calculateDurationSeconds(26), 5400);
      expect(RandomSimulationService.calculateDurationSeconds(30), 5400);
    });
  });
}
```

#### test/question_test.dart

```dart
void main() {
  group('Question.isCorrect()', () {
    test('singleChoice: correct letter matches', () { ... });
    test('singleChoice: wrong letter does not match', () { ... });
    test('multipleChoice exact: must match all correct answers', () { ... });
    test('trueOrFalse: all statements must match', () { ... });
  });

  group('Question.validate()', () {
    test('empty questionText returns error', () { ... });
    test('empty options for singleChoice returns error', () { ... });
    test('empty correctAnswers returns error', () { ... });
    test('numericInput with empty options passes validation', () { ... });
  });

  group('Question serialization', () {
    test('toJson/fromJson round-trip preserves all fields', () { ... });
  });
}
```

#### test/storage_service_test.dart

```dart
void main() {
  group('StorageService', () {
    setUp(() async { /* init in-memory Hive */ });

    test('appendHistory inserts at index 0', () async { ... });
    test('getHistory returns reverse-chronological order', () async { ... });
    test('getBestScoreForPackage returns max score', () { ... });
    test('getOverallStats computes totalTryouts correctly', () { ... });
  });
}
```

### 13.2 Widget Tests (test/)

```dart
// test/widgets/question_card_test.dart
void main() {
  testWidgets('trueOrFalse renders _TrueFalseRow', (tester) async { ... });
  testWidgets('multipleChoice renders checkbox options', (tester) async { ... });
  testWidgets('stimulus block shown when non-null', (tester) async { ... });
  testWidgets('stimulus block hidden when null', (tester) async { ... });
  testWidgets('image error placeholder shows correct text', (tester) async { ... });
}
```

### 13.3 Property-Based Testing

Property-based tests are implemented using `package:test` with manual generators (the Dart ecosystem does not have a first-class QuickCheck library in the standard toolchain; use `dart:math Random` to drive parameterized property tests with 100+ random seeds):

```dart
// Parametrized property helper pattern
void forAll<T>(T Function(Random) gen, void Function(T) test,
    {int runs = 100, int seed = 0}) {
  final rng = Random(seed);
  for (var i = 0; i < runs; i++) {
    test(gen(rng));
  }
}
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Question Validation — Empty Text

*For any* string composed entirely of whitespace characters, constructing a `Question` with that string as `questionText` and calling `validate()` must return a list containing `'Question text is empty'`.

**Validates: Requirements 1.2**

---

### Property 2: Question Validation — Missing Options

*For any* `QuestionType` that is not `numericInput` or `shortText`, constructing a `Question` with an empty `options` map and calling `validate()` must return a list containing `'Question has no options'`.

**Validates: Requirements 1.3**

---

### Property 3: Question Validation — No Correct Answer

*For any* `Question` constructed with an empty `correctAnswers` list, `validate()` must return a list containing `'No correct answer specified'`.

**Validates: Requirements 1.4**

---

### Property 4: Question Serialization Round-Trip

*For any* `Question` with non-null required fields, calling `Question.fromJson(q.toJson())` must produce a `Question` that is field-by-field equal to the original across all 21 fields.

**Validates: Requirements 1.7**

---

### Property 5: ExamPackage Question Count

*For any* list of `Question` objects passed to `ExamPackage`, `package.questionCount` must always equal `package.questions.length`.

**Validates: Requirements 5.1**

---

### Property 6: Submit Idempotence

*For any* completed exam state (where `_submitGuard == true` and `_result` is non-null), calling `submitExam()` again must return the same `ExamResult` instance without re-running `ScoringService.calculate()` or modifying storage.

**Validates: Requirements 6.2**

---

### Property 7: History Insertion Order

*For any* `ExamResult` appended to any (possibly empty) history list via `StorageService.appendHistory()`, the result must appear at index 0 of the list returned by the subsequent `StorageService.getHistory()` call, and the list length must be exactly one greater than before the append.

**Validates: Requirements 9.1, 9.2**

---

### Property 8: Best Score Is Maximum

*For any* non-empty list of `ExamResult` entries sharing the same `packageId`, `StorageService.getBestScoreForPackage(packageId)` must return a value greater than or equal to every individual `result.score` in that list.

**Validates: Requirements 9.3**

---

### Property 9: Overall Stats Invariants

*For any* non-empty history list, the map returned by `StorageService.getOverallStats()` must satisfy: `lowestScore <= avgScore <= bestScore`, `totalTryouts == history.length`, and `totalQuestions == Σ result.totalQuestions`.

**Validates: Requirements 9.4**

---

### Property 10: Simulation Determinism

*For any* question pool and any integer seed, calling `RandomSimulationService.createRandomSimulation(questionPool: pool, seed: s)` twice must return two lists with identical question `id` sequences.

**Validates: Requirements 10.1, 10.2**

---

### Property 11: Simulation No-Duplicates

*For any* result of `createRandomSimulation()`, `RandomSimulationService.validateNoDuplicates(result)` must return `true` — no `id` may appear more than once in the returned list.

**Validates: Requirements 10.4**

---

### Property 12: Duration Bracket Invariant

*For any* integer `n` in [1, 20], `calculateDurationSeconds(n)` must equal `3600`. *For any* `n` in [21, 25], the result must equal `4500`. *For any* `n` in [26, 30], the result must equal `5400`.

**Validates: Requirements 10.7**
