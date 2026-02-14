import 'dart:async';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:flutter/foundation.dart';

enum MidiEventType { NoteOn, NoteOff, ControlChange, Other }

class MidiEvent {
  final MidiEventType type;
  final int channel; // 0-based
  final int note;
  final int velocity;

  MidiEvent({
    required this.type,
    required this.channel,
    required this.note,
    required this.velocity,
  });
}

class MidiService {
  static final MidiService instance = MidiService._internal();
  factory MidiService() => instance;
  MidiService._internal();

  final MidiCommand _midiCommand = MidiCommand();
  final StreamController<MidiEvent> _eventController =
      StreamController<MidiEvent>.broadcast();

  Stream<MidiEvent> get eventStream => _eventController.stream;

  void init() {
    debugPrint("Initializing MidiService...");
    _midiCommand.onMidiDataReceived?.listen(_handleMidiData);
    _connectToAllDevices();
  }

  Future<void> _connectToAllDevices() async {
    try {
      final devices = await _midiCommand.devices;
      if (devices != null) {
        for (var device in devices) {
          debugPrint(
            "Connecting to MIDI Device: ${device.name} (id: ${device.id})",
          );
          _midiCommand.connectToDevice(device);
        }
      }
    } catch (e) {
      debugPrint("Error connecting to MIDI devices: $e");
    }
  }

  void _handleMidiData(MidiPacket packet) {
    if (packet.data.length < 3) return;

    final status = packet.data[0];
    final note = packet.data[1];
    final velocity = packet.data[2];

    // Midi Command: Upper 4 bits
    final command = status & 0xF0;
    // Midi Channel: Lower 4 bits
    final channel = status & 0x0F;

    MidiEventType type = MidiEventType.Other;

    if (command == 0x90) {
      // Note On
      if (velocity > 0) {
        type = MidiEventType.NoteOn;
      } else {
        type = MidiEventType.NoteOff; // Velocity 0 often used as Note Off
      }
    } else if (command == 0x80) {
      // Note Off
      type = MidiEventType.NoteOff;
    } else if (command == 0xB0) {
      // Control Change
      type = MidiEventType.ControlChange;
    }

    if (type != MidiEventType.Other) {
      debugPrint("MIDI Parsed: $type Ch:$channel Note:$note Vel:$velocity");
      _eventController.add(
        MidiEvent(type: type, channel: channel, note: note, velocity: velocity),
      );
    }
  }
}
