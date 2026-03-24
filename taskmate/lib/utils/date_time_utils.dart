/// Date/Time utility helpers

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Strip time component
DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// First day of month
DateTime startOfMonth(DateTime anchor) =>
    DateTime(anchor.year, anchor.month, 1);

/// Last day of month
DateTime endOfMonth(DateTime anchor) =>
    DateTime(anchor.year, anchor.month + 1, 0);

/// Iterate each day from start (inclusive) to end (inclusive)
Iterable<DateTime> daysBetweenInclusive(DateTime start, DateTime end) sync* {
  var cur = start;
  while (!cur.isAfter(end)) {
    yield cur;
    cur = cur.add(const Duration(days: 1));
  }
}

/// Weekday match helper (1=Mon..7=Sun)
bool weekdayMatches(DateTime date, List<int> weekdays) =>
    weekdays.contains(date.weekday);
