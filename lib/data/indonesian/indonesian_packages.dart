import '../../models/exam_package.dart';
import '../../models/question.dart';

class IndonesianPackages {
  static const String sourceName = 'Defantri.com';

  static final List<ExamPackage> list = [
    ExamPackage(
      id: 'indo-01',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 1',
      description: 'Latihan TKA Bahasa Indonesia Wajib SMA — Paragraf & Diksi',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/09/soal-tka-sma-bahasa-indonesia-wajib.html',
      questions: _package1Questions,
    ),
    ExamPackage(
      id: 'indo-02',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 2',
      description: 'Simulasi TKA Bahasa Indonesia SMA — Teks Eksplanasi & Novel',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/08/soal-simulasi-tka-bahasa-indonesia-sma.html',
      questions: _package2Questions,
    ),
    ExamPackage(
      id: 'indo-03',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 3',
      description: 'Bank Soal TKA Bahasa Indonesia SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2024/06/bank-soal-tka-bahasa-indonesia-sma.html',
      questions: _package3Questions,
    ),
    ExamPackage(
      id: 'indo-04',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 4',
      description: 'Soal TKA Bahasa Indonesia Pilihan SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/10/soal-tka-sma-bahasa-indonesia-pilihan.html',
      questions: _package4Questions,
    ),
    ExamPackage(
      id: 'indo-05',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 5',
      description: 'Soal TKA SMA Bahasa Indonesia Wajib',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/10/sma-soal-tka-sma-bahasa-indonesia-wajib.html',
      questions: _package5Questions,
    ),
    ExamPackage(
      id: 'indo-06',
      subjectId: 'indonesian',
      title: 'Bahasa Indonesia Paket 6',
      description: 'Latihan TKA Bahasa Indonesia (20 Soal)',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/10/sma-soal-tka-sma-bahasa-indonesia-wajib.html',
      questions: _package6Questions,
    ),
  ];

  static final List<Question> _package1Questions = [
    const Question(
      id: 'indo-01-001',
      stimulus:
          'Bacalah teks berikut!\n\nSampah plastik telah menjadi ancaman serius bagi ekosistem laut Indonesia. Berdasarkan data dari Kementerian Lingkungan Hidup dan Kehutanan, Indonesia menghasilkan sekitar 7,2 juta ton sampah plastik per tahun, dan sebagian besar berakhir di lautan. Dampaknya sangat nyata: terumbu karang rusak, ikan-ikan mengonsumsi partikel mikroplastik, dan nelayan kesulitan mendapat tangkapan.',
      questionText: 'Gagasan pokok paragraf tersebut adalah ...',
      options: {
        'A': 'Indonesia menghasilkan 7,2 juta ton sampah plastik per tahun.',
        'B': 'Ancaman sampah plastik bagi ekosistem laut Indonesia.',
        'C': 'Gerakan pengurangan plastik sekali pakai semakin masif.',
        'D': 'Nelayan Indonesia kesulitan mendapat tangkapan ikan.',
        'E': 'Pemerintah belum memberikan dukungan kebijakan yang kuat.'
      },
      correctAnswers: ['B'],
      explanation:
          'Gagasan pokok berada di kalimat pertama: "Sampah plastik telah menjadi ancaman serius bagi ekosistem laut Indonesia."',
    ),
    const Question(
      id: 'indo-01-002',
      questionText: 'Kata "masif" dalam paragraf tersebut bermakna ...',
      options: {
        'A': 'lambat dan bertahap',
        'B': 'besar-besaran dan menyeluruh',
        'C': 'lokal dan terbatas',
        'D': 'modern dan canggih',
        'E': 'resmi dan terorganisasi'
      },
      correctAnswers: ['B'],
      explanation:
          '"Masif" berarti besar-besaran, luas, dan menyeluruh.',
    ),
    const Question(
      id: 'indo-01-003',
      questionText: 'Kalimat yang menggunakan tanda baca dengan benar adalah ...',
      options: {
        'A': 'Ibu membeli: sayur, ikan, dan tempe di pasar.',
        'B': 'Ayah berkata, "Kita harus berangkat pagi-pagi sekali."',
        'C': 'Dia tidak datang, karena sakit.',
        'D': 'Presiden Jokowi; meresmikan jembatan baru itu.',
        'E': 'Selamat pagi, Bapak-bapak dan Ibu-ibu yang terhormat!.'
      },
      correctAnswers: ['B'],
      explanation:
          'Kalimat langsung menggunakan koma setelah kata kerja berkata, lalu petik dua membungkus ucapan langsung.',
    ),
    const Question(
      id: 'indo-01-004',
      questionText: 'Penulisan kata serapan yang benar terdapat pada kalimat ...',
      options: {
        'A': 'Dia mendapat beasiswa untuk melanjutkan studi ke luar negeri.',
        'B': 'Tim itu sudah mendapat approve dari direktur.',
        'C': 'Kami mengadakan rapat untuk membahas strategi marketing.',
        'D': 'Proyek itu sudah di-cancel oleh klien.',
        'E': 'Laporan itu sudah di-submit kemarin.'
      },
      correctAnswers: ['A'],
      explanation:
          '"Beasiswa" dan "studi" adalah kata yang sudah diserap/baku dalam bahasa Indonesia.',
    ),
    const Question(
      id: 'indo-01-005',
      questionText: 'Kalimat efektif terdapat pada ...',
      options: {
        'A': 'Para peserta-peserta seminar diharapkan hadir tepat waktu.',
        'B': 'Dalam rapat itu membahas tentang anggaran tahunan perusahaan.',
        'C': 'Siswa-siswi mengerjakan ujian dengan tenang dan tertib.',
        'D': 'Kami semua pergi bersama-sama ke tempat acara tersebut.',
        'E': 'Adalah penting bagi kami untuk hadir dalam acara ini.'
      },
      correctAnswers: ['C'],
      explanation:
          'Subjek (Siswa-siswi), Predikat (mengerjakan), Objek (ujian), Keterangan (dengan tenang dan tertib). Struktur jelas tanpa pemborosan kata.',
    ),
  ];

  static final List<Question> _package2Questions = [
    const Question(
      id: 'indo-02-001',
      stimulus:
          'Bacalah teks berikut!\n\nRevitalisasi sungai-sungai di kota-kota besar Indonesia menjadi agenda penting dalam pembangunan berkelanjutan. Sungai yang dulu menjadi tempat pembuangan sampah kini ditata ulang menjadi ruang terbuka hijau yang nyaman.',
      questionText: 'Ide pokok paragraf tersebut adalah ...',
      options: {
        'A': 'Sungai di kota-kota besar dijadikan tempat rekreasi warga.',
        'B': 'Revitalisasi sungai sebagai agenda pembangunan berkelanjutan.',
        'C': 'Masyarakat harus aktif menjaga kebersihan sungai.',
        'D': 'Kualitas air sungai di Indonesia semakin baik.',
        'E': 'Program revitalisasi sungai sangat mahal.'
      },
      correctAnswers: ['B'],
      explanation:
          'Kalimat utama menyatakan: Revitalisasi sungai sebagai agenda pembangunan.',
    ),
  ];

  static final List<Question> _package3Questions = [
    const Question(
      id: 'indo-03-001',
      questionText: 'Kalimat utama paragraf deduktif terletak di ...',
      options: {
        'A': 'Awal paragraf',
        'B': 'Akhir paragraf',
        'C': 'Tengah paragraf',
        'D': 'Awal dan akhir paragraf',
        'E': 'Seluruh paragraf'
      },
      correctAnswers: ['A'],
      explanation: 'Paragraf deduktif meletakkan kalimat utama di awal paragraf.',
    ),
  ];

  static final List<Question> _package4Questions = [
    const Question(
      id: 'indo-04-001',
      questionText: 'Kalimat yang menggunakan kata baku dengan tepat adalah ...',
      options: {
        'A': 'Hasil analisa laboratorium sudah keluar.',
        'B': 'Metoda mengajar guru sangat menyenangkan.',
        'C': 'Kualitas produk harus menjadi prioritas utama.',
        'D': 'Dia mendapat ijin dari kepala sekolah.',
        'E': 'Jadwal aktifitas harian sudah disusun.'
      },
      correctAnswers: ['C'],
      explanation:
          '"Kualitas" dan "prioritas" adalah kata baku (bukan kwalitas / priyoritas).',
    ),
  ];

  static final List<Question> _package5Questions = [
    const Question(
      id: 'indo-05-001',
      questionText: 'Kata "resistensi" bermakna ...',
      options: {
        'A': 'Dukungan',
        'B': 'Penolakan atau perlawanan',
        'C': 'Adaptasi',
        'D': 'Inovasi',
        'E': 'Keterbukaan'
      },
      correctAnswers: ['B'],
      explanation: '"Resistensi" berarti penolakan atau perlawanan.',
    ),
  ];

  static final List<Question> _package6Questions = [
    const Question(
      id: 'indo-06-001',
      questionText: 'Kata "integritas" bermakna ...',
      options: {
        'A': 'Kemampuan memimpin',
        'B': 'Kejujuran dan konsistensi dalam bertindak sesuai nilai',
        'C': 'Keberanian',
        'D': 'Kemampuan beradaptasi',
        'E': 'Pengetahuan yang luas'
      },
      correctAnswers: ['B'],
      explanation:
          '"Integritas" berarti kejujuran dan konsistensi prinsip moral.',
    ),
  ];
}
