import '../models/door_status_model.dart';

class DoorService {
  DoorStatusModel _currentStatus = DoorStatusModel(isLocked: true);

  DoorStatusModel getCurrentStatus() {
    return _currentStatus;
  }

  Future<bool> lockDoor() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    _currentStatus = DoorStatusModel(
      isLocked: true,
      lastChanged: DateTime.now(),
      changedBy: 'User',
    );
    return true;
  }

  Future<bool> unlockDoor() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    _currentStatus = DoorStatusModel(
      isLocked: false,
      lastChanged: DateTime.now(),
      changedBy: 'User',
    );
    return true;
  }
}

