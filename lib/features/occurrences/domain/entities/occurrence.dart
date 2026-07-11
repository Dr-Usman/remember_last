/// A single logged instance of an activity being done.
class Occurrence {
  const Occurrence({
    required this.id,
    required this.activityId,
    required this.doneAt,
    this.note,
  });

  final int id;
  final int activityId;
  final DateTime doneAt;
  final String? note;

  Occurrence copyWith({
    int? id,
    int? activityId,
    DateTime? doneAt,
    String? note,
  }) {
    return Occurrence(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      doneAt: doneAt ?? this.doneAt,
      note: note ?? this.note,
    );
  }
}
