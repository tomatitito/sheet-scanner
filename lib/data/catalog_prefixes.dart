/// Catalog/Verzeichnis prefix mappings for classical composers.
///
/// Maps composer names to their standard catalog numbering systems.
/// Users can still override these suggestions.
library;

/// Common catalog prefix systems for well-known composers.
///
/// Key: Composer name (matching the names in composers.dart)
/// Value: Catalog prefix with trailing space for easy concatenation
const Map<String, String> kComposerCatalogPrefixes = {
  // Bach family
  'Johann Sebastian Bach': 'BWV ',
  'Carl Philipp Emanuel Bach': 'Wq. ',
  'Johann Christian Bach': 'W. ',

  // Viennese Classical
  'Wolfgang Amadeus Mozart': 'K. ',
  'Joseph Haydn': 'Hob. ',
  'Ludwig van Beethoven': 'Op. ',

  // Romantic Era
  'Franz Schubert': 'D. ',
  'Robert Schumann': 'Op. ',
  'Frédéric Chopin': 'Op. ',
  'Franz Liszt': 'S. ',
  'Johannes Brahms': 'Op. ',
  'Felix Mendelssohn': 'Op. ',
  'Richard Wagner': 'WWV ',
  'Anton Bruckner': 'WAB ',
  'Gustav Mahler': 'Op. ',
  'Richard Strauss': 'TrV ',
  'Antonín Dvořák': 'B. ',
  'Pyotr Ilyich Tchaikovsky': 'TH ',
  'Sergei Rachmaninoff': 'Op. ',
  'Sergei Prokofiev': 'Op. ',
  'Dmitri Shostakovich': 'Op. ',

  // Baroque
  'Antonio Vivaldi': 'RV ',
  'George Frideric Handel': 'HWV ',
  'Domenico Scarlatti': 'K. ',
  'Arcangelo Corelli': 'Op. ',
  'Henry Purcell': 'Z. ',
  'Jean-Philippe Rameau': 'RCT ',
  'Georg Philipp Telemann': 'TWV ',
  'Jean-Baptiste Lully': 'LWV ',

  // French Impressionists
  'Claude Debussy': 'L. ',
  'Maurice Ravel': 'M. ',
  'Erik Satie': 'Op. ',
  'Gabriel Fauré': 'Op. ',

  // 20th Century
  'Igor Stravinsky': 'K ',
  'Béla Bartók': 'Sz. ',
  'Arnold Schoenberg': 'Op. ',
  'Alban Berg': 'Op. ',
  'Anton Webern': 'Op. ',
  'Benjamin Britten': 'Op. ',
  'Olivier Messiaen': 'I. ',
  'John Cage': 'JP ',

  // Others
  'Camille Saint-Saëns': 'Op. ',
  'Edward Elgar': 'Op. ',
  'Jean Sibelius': 'Op. ',
  'Edvard Grieg': 'Op. ',
  'Giacomo Puccini': 'SC ',
  'Giuseppe Verdi': 'Op. ',
};

/// Get the catalog prefix for a given composer name.
///
/// Returns null if no standard catalog system is known.
/// Performs case-insensitive matching and handles partial matches.
String? getCatalogPrefixForComposer(String composerName) {
  final normalized = composerName.trim().toLowerCase();
  if (normalized.isEmpty) return null;

  // Direct match (case-insensitive)
  for (final entry in kComposerCatalogPrefixes.entries) {
    if (entry.key.toLowerCase() == normalized) {
      return entry.value;
    }
  }

  // Partial match (last name only)
  for (final entry in kComposerCatalogPrefixes.entries) {
    final lastName = entry.key.split(' ').last.toLowerCase();
    if (normalized == lastName ||
        normalized.endsWith(' $lastName') ||
        normalized.startsWith('$lastName ')) {
      return entry.value;
    }
  }

  return null;
}
