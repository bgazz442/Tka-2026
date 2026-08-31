/// Shared stimulus that can be used by multiple questions
class StimulusGroup {
  final String id;
  final String? text;
  final String? imageUrl;
  final List<String> questionIds;
  final DateTime createdAt;

  StimulusGroup({
    required this.id,
    this.text,
    this.imageUrl,
    required this.questionIds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'imageUrl': imageUrl,
        'questionIds': questionIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StimulusGroup.fromJson(Map<String, dynamic> json) => StimulusGroup(
        id: json['id'] as String,
        text: json['text'] as String?,
        imageUrl: json['imageUrl'] as String?,
        questionIds: List<String>.from(json['questionIds'] as List? ?? []),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
