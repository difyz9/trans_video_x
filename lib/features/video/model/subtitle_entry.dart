class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String data;
  
  SubtitleEntry({
    required this.start,
    required this.end,
    required this.data,
  });
  
  @override
  String toString() => 'SubtitleEntry(start: $start, end: $end, data: $data)';
}