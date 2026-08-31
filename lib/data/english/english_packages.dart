import '../../models/exam_package.dart';
import '../../models/question.dart';

class EnglishPackages {
  static const String sourceName = 'Defantri.com';
  static const String sourceUrl =
      'https://www.defantri.com/2026/08/30-latihan-soal-tka-bahasa-inggris.html';

  static final List<ExamPackage> list = [
    ExamPackage(
      id: 'english-01',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 1',
      description: 'Latihan TKA Bahasa Inggris — Reading & Grammar',
      sourceName: sourceName,
      sourceUrl: sourceUrl,
      questions: _package1Questions,
    ),
    ExamPackage(
      id: 'english-02',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 2',
      description: 'Soal TKA Bahasa Inggris Wajib SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/09/soal-tka-sma-bahasa-inggris-wajib.html',
      questions: _package2Questions,
    ),
    ExamPackage(
      id: 'english-03',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 3',
      description: 'Soal TKA Bahasa Inggris 2026',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/05/soal-tka-bahasa-inggris-sma-wajib-2026.html',
      questions: _package3Questions,
    ),
    ExamPackage(
      id: 'english-04',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 4',
      description: 'Soal TKA Bahasa Inggris Pilihan SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/07/soal-tka-sma-bahasa-inggris-pilihan.html',
      questions: _package4Questions,
    ),
    ExamPackage(
      id: 'english-05',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 5',
      description: 'Simulasi TKA Bahasa Inggris SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/10/sma-soal-tka-bahasa-inggris-wajib.html',
      questions: _package5Questions,
    ),
    ExamPackage(
      id: 'english-06',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 6',
      description: 'Soal Ujian Sekolah Bahasa Inggris XII',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2025/02/soal-ujian-sekolah-sma-bahasa-inggris-kelas-xii.html',
      questions: _package6Questions,
    ),
    ExamPackage(
      id: 'english-07',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 7',
      description: '30 Soal TKA Bahasa Inggris SMA',
      sourceName: sourceName,
      sourceUrl:
          'https://www.defantri.com/2026/07/30-soal-tka-bahasa-inggris-sma-dan-jawaban.html',
      questions: _package7Questions,
    ),
    ExamPackage(
      id: 'english-08',
      subjectId: 'english',
      title: 'Bahasa Inggris Paket 8',
      description: 'Bank Soal TKA Bahasa Inggris SMA',
      sourceName: sourceName,
      sourceUrl: 'https://www.defantri.com/2025/11/tka-bahasa-inggris-sma.html',
      questions: _package8Questions,
    ),
  ];

  static final List<Question> _package1Questions = [
    const Question(
      id: 'eng-01-001',
      stimulus:
          'Read the following text carefully.\n\nThe Amazon Rainforest, often called the "lungs of the Earth," covers about 5.5 million square kilometers across nine countries in South America. It produces more than 20% of the world\'s oxygen and is home to an estimated 10% of all species on Earth. However, deforestation has been a growing concern. Between 2000 and 2022, the Amazon lost approximately 17% of its total forest cover due to agricultural expansion, illegal logging, and infrastructure development.',
      questionText: 'What is the main purpose of the text above?',
      options: {
        'A': 'To describe the beauty of the Amazon Rainforest',
        'B':
            'To inform readers about the Amazon Rainforest and its deforestation issue',
        'C': 'To persuade readers to visit the Amazon Rainforest',
        'D': 'To explain the types of animals living in the Amazon Rainforest',
        'E': 'To compare the Amazon with other rainforests in the world'
      },
      correctAnswers: ['B'],
      explanation:
          'The text mainly informs readers about the Amazon Rainforest (its size, importance) and the growing problem of deforestation.',
    ),
    const Question(
      id: 'eng-01-002',
      questionText:
          'According to the text, how much of its forest cover has the Amazon lost between 2000 and 2022?',
      options: {
        'A': '10%',
        'B': '15%',
        'C': '17%',
        'D': '20%',
        'E': '25%'
      },
      correctAnswers: ['C'],
      explanation:
          'The text explicitly states: "the Amazon lost approximately 17% of its total forest cover."',
    ),
    const Question(
      id: 'eng-01-003',
      questionText:
          'The word "estimated" in the text is closest in meaning to...',
      options: {
        'A': 'exactly',
        'B': 'approximately',
        'C': 'certainly',
        'D': 'surprisingly',
        'E': 'recently'
      },
      correctAnswers: ['B'],
      explanation:
          '"Estimated" means approximately or roughly calculated.',
    ),
    const Question(
      id: 'eng-01-004',
      stimulus:
          'Read the following dialogue.\n\nSara: "I heard you got accepted at the University of Indonesia. Congratulations!"\nBudi: "Thank you. I\'m really excited but also a bit nervous."\nSara: "Don\'t worry. You\'ll do great. What will you major in?"\nBudi: "I plan to study Environmental Engineering. I want to contribute to solving Indonesia\'s environmental problems."',
      questionText: 'What can we infer about Budi from the dialogue?',
      options: {
        'A': 'He is not interested in environmental issues',
        'B': 'He has always wanted to study at a foreign university',
        'C':
            'He is motivated by a desire to help solve environmental problems',
        'D': 'He is unsure about his major',
        'E': 'He feels confident about university life'
      },
      correctAnswers: ['C'],
      explanation:
          'Budi explicitly says he wants to "contribute to solving Indonesia\'s environmental problems."',
    ),
    const Question(
      id: 'eng-01-005',
      questionText:
          'The expression "Don\'t worry. You\'ll do great." is used to...',
      options: {
        'A': 'warn someone',
        'B': 'give advice',
        'C': 'encourage someone',
        'D': 'apologize',
        'E': 'ask for permission'
      },
      correctAnswers: ['C'],
      explanation:
          'The expression is used to encourage Budi who feels nervous.',
    ),
    const Question(
      id: 'eng-01-006',
      questionText: 'Choose the correct sentence below.',
      options: {
        'A': 'She don\'t like to eat spicy food.',
        'B': 'They was playing football yesterday.',
        'C': 'He has been working here since five years.',
        'D': 'We have finished the project last night.',
        'E': 'The committee has not released the results yet.'
      },
      correctAnswers: ['E'],
      explanation:
          '"Has not released" uses Present Perfect correctly with "yet."',
    ),
    const Question(
      id: 'eng-01-007',
      questionText:
          'The students ______ studying for their final exams when the power went out.',
      options: {
        'A': 'are',
        'B': 'were',
        'C': 'was',
        'D': 'had',
        'E': 'have been'
      },
      correctAnswers: ['B'],
      explanation:
          'Past Continuous "were studying" is correct here for an ongoing action interrupted by the past simple ("power went out").',
    ),
    const Question(
      id: 'eng-01-008',
      questionText:
          'If she ______ harder last semester, she would have passed the exam.',
      options: {
        'A': 'studies',
        'B': 'studied',
        'C': 'had studied',
        'D': 'has studied',
        'E': 'would study'
      },
      correctAnswers: ['C'],
      explanation:
          'Third Conditional (past unreal): "If + Past Perfect, would have + V3".',
    ),
    const Question(
      id: 'eng-01-009',
      stimulus:
          'Read the following text.\n\nSolar energy is one of the most promising renewable energy sources available today. Photovoltaic (PV) panels convert sunlight directly into electricity through the photoelectric effect. Unlike fossil fuels, solar energy produces no direct carbon emissions during operation. The global solar capacity has grown from approximately 40 GW in 2010 to over 1,000 GW in 2022, representing a 25-fold increase in just over a decade.',
      questionText: 'What does the text mainly discuss?',
      options: {
        'A': 'The history of fossil fuels',
        'B': 'How to install solar panels at home',
        'C': 'The benefits and growth of solar energy',
        'D': 'The comparison between solar and wind energy',
        'E': 'Why Germany uses more solar energy than China'
      },
      correctAnswers: ['C'],
      explanation:
          'The text discusses both the benefits of solar energy and its impressive global growth.',
    ),
    const Question(
      id: 'eng-01-010',
      questionText:
          'According to the text, solar capacity grew from 40 GW to over 1,000 GW. This represents...',
      options: {
        'A': 'a 10-fold increase',
        'B': 'a 20-fold increase',
        'C': 'a 25-fold increase',
        'D': 'a 30-fold increase',
        'E': 'a 40-fold increase'
      },
      correctAnswers: ['C'],
      explanation:
          'The text explicitly states "representing a 25-fold increase in just over a decade."',
    ),
  ];

  static final List<Question> _package2Questions = [
    const Question(
      id: 'eng-02-001',
      stimulus:
          'Read the text below.\n\nTeleworking, also known as remote work, has become increasingly popular since the COVID-19 pandemic. Many companies have adopted permanent remote or hybrid work policies. Proponents argue that teleworking increases productivity, reduces commuting stress, and offers better work-life balance. Critics, however, claim that remote work can lead to social isolation, communication difficulties, and blurred boundaries between personal and professional life.',
      questionText: 'What is the text mainly about?',
      options: {
        'A': 'The history of the COVID-19 pandemic',
        'B': 'Different perspectives on teleworking',
        'C': 'How companies implement remote work policies',
        'D': 'The negative effects of working from home',
        'E': 'Why employees prefer office work'
      },
      correctAnswers: ['B'],
      explanation:
          'The text presents both sides — advantages (proponents) and disadvantages (critics) of teleworking.',
    ),
    const Question(
      id: 'eng-02-002',
      questionText: 'The word "proponents" is closest in meaning to...',
      options: {
        'A': 'opponents',
        'B': 'critics',
        'C': 'supporters',
        'D': 'employers',
        'E': 'researchers'
      },
      correctAnswers: ['C'],
      explanation:
          '"Proponents" are supporters or advocates — the opposite of opponents/critics.',
    ),
    const Question(
      id: 'eng-02-003',
      questionText: 'They have been living in Bandung ______ ten years.',
      options: {
        'A': 'since',
        'B': 'for',
        'C': 'during',
        'D': 'from',
        'E': 'at'
      },
      correctAnswers: ['B'],
      explanation: '"For" is used with a duration of time (ten years).',
    ),
    const Question(
      id: 'eng-02-004',
      questionText:
          'The project ______ by the time the investors arrive tomorrow.',
      options: {
        'A': 'will complete',
        'B': 'will be completed',
        'C': 'is completing',
        'D': 'has completed',
        'E': 'completes'
      },
      correctAnswers: ['B'],
      explanation: 'Future Perfect Passive: "will be completed."',
    ),
    const Question(
      id: 'eng-02-005',
      questionText: '______ he studied hard, he failed the exam.',
      options: {
        'A': 'Because',
        'B': 'So',
        'C': 'Although',
        'D': 'Since',
        'E': 'When'
      },
      correctAnswers: ['C'],
      explanation:
          '"Although" expresses contrast between studying hard and failing.',
    ),
  ];

  static final List<Question> _package3Questions = [
    const Question(
      id: 'eng-03-001',
      stimulus:
          'Read the following text.\n\nArtificial Intelligence (AI) is rapidly transforming various industries, from healthcare and education to finance and manufacturing. In healthcare, AI algorithms can analyze medical images with accuracy comparable to trained physicians. In education, adaptive learning platforms personalize content based on each student\'s performance and learning pace.',
      questionText: 'What is the main idea of the text?',
      options: {
        'A': 'AI is replacing doctors in hospitals',
        'B': 'AI is transforming industries while raising concerns',
        'C': 'Education is the most important use of AI',
        'D': 'AI causes more problems than benefits',
        'E': 'Experts universally support AI development'
      },
      correctAnswers: ['B'],
      explanation:
          'The text covers AI\'s positive transformation across healthcare, education, and other sectors.',
    ),
    const Question(
      id: 'eng-03-002',
      questionText:
          'Not only ______ late, but he also forgot to bring his report.',
      options: {
        'A': 'he arrived',
        'B': 'did he arrive',
        'C': 'he did arrive',
        'D': 'arrived he',
        'E': 'has he arrived'
      },
      correctAnswers: ['B'],
      explanation:
          'Inversion after "Not only": "Not only did he arrive late..."',
    ),
  ];

  static final List<Question> _package4Questions = [
    const Question(
      id: 'eng-04-001',
      stimulus:
          'The following text is about climate change.\n\nClimate change refers to long-term shifts in global temperatures and weather patterns. Human activities — primarily burning fossil fuels — have been the main driver of climate change. Scientists warn that without significant reductions in greenhouse gas emissions, the consequences could be catastrophic and irreversible.',
      questionText: 'What does the text imply about climate change?',
      options: {
        'A': 'Climate change is entirely a natural phenomenon',
        'B': 'Human activities have little effect on climate change',
        'C': 'Urgent action is needed to prevent irreversible consequences',
        'D': 'The effects of climate change are temporary',
        'E': 'Only coastal cities are affected by climate change'
      },
      correctAnswers: ['C'],
      explanation:
          'The text warns that without reductions, consequences will be catastrophic and irreversible.',
    ),
  ];

  static final List<Question> _package5Questions = [
    const Question(
      id: 'eng-05-001',
      questionText: 'She ______ to the doctor if the pain continues.',
      options: {
        'A': 'go',
        'B': 'goes',
        'C': 'will go',
        'D': 'would go',
        'E': 'has gone'
      },
      correctAnswers: ['C'],
      explanation:
          'First Conditional: "If + present simple, will + base verb."',
    ),
  ];

  static final List<Question> _package6Questions = [
    const Question(
      id: 'eng-06-001',
      questionText:
          'She ______ working overtime this week because of the project deadline.',
      options: {
        'A': 'has',
        'B': 'is',
        'C': 'has been',
        'D': 'had been',
        'E': 'was'
      },
      correctAnswers: ['C'],
      explanation: 'Present Perfect Continuous: "has been working."',
    ),
  ];

  static final List<Question> _package7Questions = [
    const Question(
      id: 'eng-07-001',
      questionText:
          'Which city is described as the "global hub" of startup culture?',
      options: {
        'A': 'Berlin',
        'B': 'Singapore',
        'C': 'Jakarta',
        'D': 'Silicon Valley',
        'E': 'Bangalore'
      },
      correctAnswers: ['D'],
      explanation: 'Silicon Valley is widely known as the global startup hub.',
    ),
  ];

  static final List<Question> _package8Questions = [
    const Question(
      id: 'eng-08-001',
      questionText:
          'The construction of the new bridge ______ by the end of next year.',
      options: {
        'A': 'will complete',
        'B': 'is completed',
        'C': 'will have been completed',
        'D': 'has been completed',
        'E': 'completing'
      },
      correctAnswers: ['C'],
      explanation: 'Future Perfect Passive: "will have been completed."',
    ),
  ];
}
