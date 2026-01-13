/// Represents a musical key with proper notation.
class MusicalKey {
  final String note;
  final KeyMode mode;

  const MusicalKey._(this.note, this.mode);

  String get displayName => '$note ${mode.displayName}';
  String get storageValue => '$note ${mode.name}';

  static MusicalKey? fromStorageValue(String? value) {
    if (value == null || value.isEmpty) return null;

    for (final key in allKeys) {
      if (key.storageValue == value) return key;
    }
    return null;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicalKey && note == other.note && mode == other.mode;

  @override
  int get hashCode => Object.hash(note, mode);

  // All major keys
  static const cMajor = MusicalKey._('C', KeyMode.major);
  static const gMajor = MusicalKey._('G', KeyMode.major);
  static const dMajor = MusicalKey._('D', KeyMode.major);
  static const aMajor = MusicalKey._('A', KeyMode.major);
  static const eMajor = MusicalKey._('E', KeyMode.major);
  static const bMajor = MusicalKey._('B', KeyMode.major);
  static const fSharpMajor = MusicalKey._('F♯', KeyMode.major);
  static const cSharpMajor = MusicalKey._('C♯', KeyMode.major);
  static const fMajor = MusicalKey._('F', KeyMode.major);
  static const bFlatMajor = MusicalKey._('B♭', KeyMode.major);
  static const eFlatMajor = MusicalKey._('E♭', KeyMode.major);
  static const aFlatMajor = MusicalKey._('A♭', KeyMode.major);
  static const dFlatMajor = MusicalKey._('D♭', KeyMode.major);
  static const gFlatMajor = MusicalKey._('G♭', KeyMode.major);
  static const cFlatMajor = MusicalKey._('C♭', KeyMode.major);

  // All minor keys
  static const aMinor = MusicalKey._('A', KeyMode.minor);
  static const eMinor = MusicalKey._('E', KeyMode.minor);
  static const bMinor = MusicalKey._('B', KeyMode.minor);
  static const fSharpMinor = MusicalKey._('F♯', KeyMode.minor);
  static const cSharpMinor = MusicalKey._('C♯', KeyMode.minor);
  static const gSharpMinor = MusicalKey._('G♯', KeyMode.minor);
  static const dSharpMinor = MusicalKey._('D♯', KeyMode.minor);
  static const aSharpMinor = MusicalKey._('A♯', KeyMode.minor);
  static const dMinor = MusicalKey._('D', KeyMode.minor);
  static const gMinor = MusicalKey._('G', KeyMode.minor);
  static const cMinor = MusicalKey._('C', KeyMode.minor);
  static const fMinor = MusicalKey._('F', KeyMode.minor);
  static const bFlatMinor = MusicalKey._('B♭', KeyMode.minor);
  static const eFlatMinor = MusicalKey._('E♭', KeyMode.minor);
  static const aFlatMinor = MusicalKey._('A♭', KeyMode.minor);

  static const List<MusicalKey> majorKeys = [
    cMajor,
    gMajor,
    dMajor,
    aMajor,
    eMajor,
    bMajor,
    fSharpMajor,
    cSharpMajor,
    fMajor,
    bFlatMajor,
    eFlatMajor,
    aFlatMajor,
    dFlatMajor,
    gFlatMajor,
    cFlatMajor,
  ];

  static const List<MusicalKey> minorKeys = [
    aMinor,
    eMinor,
    bMinor,
    fSharpMinor,
    cSharpMinor,
    gSharpMinor,
    dSharpMinor,
    aSharpMinor,
    dMinor,
    gMinor,
    cMinor,
    fMinor,
    bFlatMinor,
    eFlatMinor,
    aFlatMinor,
  ];

  static List<MusicalKey> get allKeys => [...majorKeys, ...minorKeys];
}

enum KeyMode {
  major('Major'),
  minor('Minor');

  final String displayName;
  const KeyMode(this.displayName);
}
