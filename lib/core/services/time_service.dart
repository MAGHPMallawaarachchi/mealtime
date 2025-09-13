abstract class TimeService {
  DateTime getCurrentTime();
  DateTime getCurrentSriLankanTime();
  int getCurrentSriLankanMonth();
  int getCurrentSriLankanYear();
}

class TimeServiceImpl implements TimeService {
  static const Duration _sriLankanOffset = Duration(hours: 5, minutes: 30);

  @override
  DateTime getCurrentTime() {
    return DateTime.now();
  }

  @override
  DateTime getCurrentSriLankanTime() {
    final utcTime = DateTime.now().toUtc();
    return utcTime.add(_sriLankanOffset);
  }

  @override
  int getCurrentSriLankanMonth() {
    return getCurrentSriLankanTime().month;
  }

  @override
  int getCurrentSriLankanYear() {
    return getCurrentSriLankanTime().year;
  }
}

class MockTimeService implements TimeService {
  final DateTime _mockTime;

  const MockTimeService(this._mockTime);

  @override
  DateTime getCurrentTime() {
    return _mockTime;
  }

  @override
  DateTime getCurrentSriLankanTime() {
    final utcMockTime = _mockTime.toUtc();
    const sriLankanOffset = Duration(hours: 5, minutes: 30);
    return utcMockTime.add(sriLankanOffset);
  }

  @override
  int getCurrentSriLankanMonth() {
    return getCurrentSriLankanTime().month;
  }

  @override
  int getCurrentSriLankanYear() {
    return getCurrentSriLankanTime().year;
  }
}