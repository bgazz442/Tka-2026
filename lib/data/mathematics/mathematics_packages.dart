import '../../models/exam_package.dart';
import '../../models/question.dart';

class MathematicsPackages {
  static const String sourceName = 'Defantri.com';

  static final List<ExamPackage> list = [
    ExamPackage(
      id: 'math-01',
      subjectId: 'mathematics',
      title: 'Matematika Paket 1',
      description: 'Latihan TKA Matematika Wajib SMA — Aljabar & Logaritma',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/09/soal-tka-sma-matematika-wajib.html',
      questions: _package1Questions,
    ),
    ExamPackage(
      id: 'math-02',
      subjectId: 'mathematics',
      title: 'Matematika Paket 2',
      description: 'Latihan TKA Matematika Pilihan SMA — Matriks & Turunan',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/09/soal-tka-sma-matematika-pilihan.html',
      questions: _package2Questions,
    ),
    ExamPackage(
      id: 'math-03',
      subjectId: 'mathematics',
      title: 'Matematika Paket 3',
      description: 'Soal TKA Matematika Wajib 2025',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/07/soal-tka-sma-matematika-wajib-2025.html',
      questions: _package3Questions,
    ),
    ExamPackage(
      id: 'math-04',
      subjectId: 'mathematics',
      title: 'Matematika Paket 4',
      description: 'Pembahasan TKA Matematika Pilihan SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/07/pembahasan-tka-sma-matematika-pilihan.html',
      questions: _package4Questions,
    ),
    ExamPackage(
      id: 'math-05',
      subjectId: 'mathematics',
      title: 'Matematika Paket 5',
      description: 'Bank Soal UNBK / TKA Matematika SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2019/05/soal-dan-pembahasan-unbk-matematika-sma.html',
      questions: _package5Questions,
    ),
  ];

  static final List<Question> _package1Questions = [
    const Question(
      id: 1,
      question: r'Nilai dari \log_2 32 - \log_2 4 adalah ...',
      options: {
        'A': '2',
        'B': '3',
        'C': '4',
        'D': '5',
        'E': '6'
      },
      correctAnswer: 'B',
      explanation: r'\log_2 32 - \log_2 4 = \log_2 (32/4) = \log_2 8 = 3',
    ),
    const Question(
      id: 2,
      question: r'Jika f(x) = 2x^2 - 3x + 1, maka f(-2) adalah ...',
      options: {
        'A': '10',
        'B': '12',
        'C': '15',
        'D': '17',
        'E': '19'
      },
      correctAnswer: 'C',
      explanation: r'f(-2) = 2(-2)^2 - 3(-2) + 1 = 8 + 6 + 1 = 15',
    ),
    const Question(
      id: 3,
      question: r'Akar-akar persamaan x^2 - 5x + 6 = 0 adalah ...',
      options: {
        'A': 'x = 2 dan x = 3',
        'B': 'x = 1 dan x = 6',
        'C': 'x = -2 dan x = -3',
        'D': 'x = -1 dan x = -6',
        'E': 'x = 2 dan x = -3'
      },
      correctAnswer: 'A',
      explanation: r'(x - 2)(x - 3) = 0 \Rightarrow x = 2 atau x = 3',
    ),
    const Question(
      id: 4,
      question:
          'Diketahui deret aritmetika dengan suku pertama a = 3 dan beda b = 4. Suku ke-10 adalah ...',
      options: {
        'A': '37',
        'B': '39',
        'C': '41',
        'D': '43',
        'E': '45'
      },
      correctAnswer: 'B',
      explanation: r'U_{10} = a + (10-1)b = 3 + 9 \times 4 = 39',
    ),
    const Question(
      id: 5,
      question: r'Nilai \sin 30^\circ + \cos 60^\circ adalah ...',
      options: {
        'A': '0',
        'B': '1/2',
        'C': '1',
        'D': r'\sqrt{2}',
        'E': r'\sqrt{3}'
      },
      correctAnswer: 'C',
      explanation: r'\sin 30^\circ + \cos 60^\circ = 1/2 + 1/2 = 1',
    ),
    const Question(
      id: 6,
      question:
          'Suatu barisan geometri memiliki suku pertama 2 dan rasio 3. Suku ke-5 adalah ...',
      options: {
        'A': '162',
        'B': '243',
        'C': '486',
        'D': '54',
        'E': '108'
      },
      correctAnswer: 'A',
      explanation: r'U_5 = a \cdot r^4 = 2 \cdot 3^4 = 2 \cdot 81 = 162',
    ),
    const Question(
      id: 7,
      question: r'Bentuk sederhana dari \frac{x^2 - 4}{x - 2} adalah ...',
      options: {
        'A': 'x - 2',
        'B': 'x + 2',
        'C': 'x^2 + 2',
        'D': '2x',
        'E': 'x'
      },
      correctAnswer: 'B',
      explanation:
          r'\frac{(x-2)(x+2)}{x-2} = x + 2 \text{ (untuk } x \neq 2 \text{)}',
    ),
    const Question(
      id: 8,
      question:
          r'Jika matriks A = \begin{pmatrix} 2 & 1 \\ 3 & 4 \end{pmatrix}, maka determinan A adalah ...',
      options: {
        'A': '5',
        'B': '6',
        'C': '7',
        'D': '8',
        'E': '11'
      },
      correctAnswer: 'A',
      explanation: r'\det(A) = (2)(4) - (1)(3) = 8 - 3 = 5',
    ),
    const Question(
      id: 9,
      question:
          r'Sebuah tabung memiliki jari-jari 7 cm dan tinggi 10 cm. Volume tabung tersebut adalah ...',
      options: {
        'A': r'1.320 \text{ cm}^3',
        'B': r'1.450 \text{ cm}^3',
        'C': r'1.540 \text{ cm}^3',
        'D': r'1.650 \text{ cm}^3',
        'E': r'1.760 \text{ cm}^3'
      },
      correctAnswer: 'C',
      explanation:
          r'V = \pi r^2 t = \frac{22}{7} \cdot 7^2 \cdot 10 = 1.540 \text{ cm}^3',
    ),
    const Question(
      id: 10,
      question: r'Nilai dari \lim_{x \to 2} \frac{x^2 - 4}{x - 2} adalah ...',
      options: {
        'A': '0',
        'B': '2',
        'C': '4',
        'D': '6',
        'E': 'tidak ada'
      },
      correctAnswer: 'C',
      explanation: r'\lim_{x \to 2} (x + 2) = 2 + 2 = 4',
    ),
  ];

  static final List<Question> _package2Questions = [
    const Question(
      id: 1,
      question: r'Nilai dari \log_3 81 adalah ...',
      options: {
        'A': '2',
        'B': '3',
        'C': '4',
        'D': '5',
        'E': '6'
      },
      correctAnswer: 'C',
      explanation: r'\log_3 81 = \log_3 3^4 = 4',
    ),
    const Question(
      id: 2,
      question:
          r'Himpunan penyelesaian dari |2x - 4| \leq 6 adalah ...',
      options: {
        'A': r'-1 \leq x \leq 5',
        'B': r'-1 \leq x \leq 4',
        'C': r'0 \leq x \leq 5',
        'D': r'1 \leq x \leq 5',
        'E': r'-1 < x < 5'
      },
      correctAnswer: 'A',
      explanation:
          r'-6 \leq 2x - 4 \leq 6 \Rightarrow -2 \leq 2x \leq 10 \Rightarrow -1 \leq x \leq 5',
    ),
  ];

  static final List<Question> _package3Questions = [
    const Question(
      id: 1,
      question: r'Nilai 2^{10} \div 2^7 adalah ...',
      options: {
        'A': '4',
        'B': '6',
        'C': '8',
        'D': '16',
        'E': '32'
      },
      correctAnswer: 'C',
      explanation: r'2^{10-7} = 2^3 = 8',
    ),
  ];

  static final List<Question> _package4Questions = [
    const Question(
      id: 1,
      question:
          r'Nilai dari \sqrt{75} - 2\sqrt{3} + \sqrt{12} adalah ...',
      options: {
        'A': r'3\sqrt{3}',
        'B': r'4\sqrt{3}',
        'C': r'5\sqrt{3}',
        'D': r'6\sqrt{3}',
        'E': r'7\sqrt{3}'
      },
      correctAnswer: 'C',
      explanation:
          r'5\sqrt{3} - 2\sqrt{3} + 2\sqrt{3} = 5\sqrt{3}',
    ),
  ];

  static final List<Question> _package5Questions = [
    const Question(
      id: 1,
      question: r'Hasil dari (-2)^3 + 4^2 - \sqrt{144} adalah ...',
      options: {
        'A': '-4',
        'B': '-2',
        'C': '0',
        'D': '2',
        'E': '4'
      },
      correctAnswer: 'C',
      explanation: r'(-8) + 16 - 12 = -4',
    ),
  ];
}
