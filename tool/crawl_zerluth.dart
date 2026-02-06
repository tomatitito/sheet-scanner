/// Crawler script for zerluth.de flute sheet music data.
///
/// This script crawls the zerluth.de website to extract sheet music data
/// including title, composer, difficulty level, and instrumentation.
///
/// Usage: dart run tool/crawl_zerluth.dart
///
/// Output: lib/data/sources/zerluth_flute.json
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// ANSI color codes for terminal output
class TerminalColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
}

/// Represents a single sheet music item from zerluth.de
class ZerluthItem {
  final String id;
  final String? composer;
  final String? title;
  final int? difficulty;
  final String? instrumentation;
  final String? category;

  ZerluthItem({
    required this.id,
    this.composer,
    this.title,
    this.difficulty,
    this.instrumentation,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        if (composer != null) 'composer': composer,
        if (title != null) 'title': title,
        if (difficulty != null) 'difficulty': difficulty,
        if (instrumentation != null) 'instrumentation': instrumentation,
        if (category != null) 'category': category,
      };

  @override
  String toString() {
    return 'ZerluthItem(id: $id, title: $title, composer: $composer, difficulty: $difficulty, instrumentation: $instrumentation)';
  }
}

/// Cookie jar for maintaining session state across requests
class SimpleCookieJar {
  final Map<String, String> _cookies = {};

  void updateFromResponse(http.Response response) {
    final setCookies = response.headers['set-cookie'];
    if (setCookies != null) {
      // Parse the set-cookie header
      for (final cookie in setCookies.split(',')) {
        final parts = cookie.split(';')[0].split('=');
        if (parts.length >= 2) {
          _cookies[parts[0].trim()] = parts.sublist(1).join('=').trim();
        }
      }
    }
  }

  String get cookieHeader =>
      _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');

  bool get isEmpty => _cookies.isEmpty;
}

/// Main crawler class for zerluth.de
class ZerluthCrawler {
  static const String _baseUrl = 'https://www.zerluth.de';
  static const String _searchUrl = '$_baseUrl/index.php?action=search';
  static const int _itemsPerPage = 500;
  static const Duration _requestDelay = Duration(milliseconds: 500);

  final http.Client _client;
  final SimpleCookieJar _cookieJar = SimpleCookieJar();

  ZerluthCrawler() : _client = http.Client();

  /// Initialize a search session by posting to the search endpoint
  Future<bool> initializeSearch() async {
    _log('Initializing search session...', color: TerminalColors.cyan);

    try {
      final response = await _client.post(
        Uri.parse(_searchUrl),
        body: {
          'db': 'Datenbank Zerluth',
          'Versender_Warengruppe': 'FLOETE',
          'titelzahl_pro_seite': '$_itemsPerPage',
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'User-Agent':
              'Mozilla/5.0 (compatible; SheetScanner/1.0; +https://github.com/sheet-scanner)',
        },
      );

      _cookieJar.updateFromResponse(response);

      if (response.statusCode == 200 || response.statusCode == 302) {
        _log('Session initialized successfully', color: TerminalColors.green);
        return true;
      } else {
        _log('Failed to initialize session: ${response.statusCode}',
            color: TerminalColors.red);
        return false;
      }
    } catch (e) {
      _log('Error initializing session: $e', color: TerminalColors.red);
      return false;
    }
  }

  /// Fetch a single page of results
  Future<List<ZerluthItem>> fetchPage(int pageNumber) async {
    final url =
        '$_baseUrl/index.php?action=showresult&page=$pageNumber&db=Datenbank+Zerluth';

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Cookie': _cookieJar.cookieHeader,
          'User-Agent':
              'Mozilla/5.0 (compatible; SheetScanner/1.0; +https://github.com/sheet-scanner)',
        },
      );

      _cookieJar.updateFromResponse(response);

      if (response.statusCode != 200) {
        _log('Page $pageNumber returned status ${response.statusCode}',
            color: TerminalColors.yellow);
        return [];
      }

      return _parsePage(response.body);
    } catch (e) {
      _log('Error fetching page $pageNumber: $e', color: TerminalColors.red);
      return [];
    }
  }

  /// Parse a page of HTML and extract all items
  List<ZerluthItem> _parsePage(String html) {
    final document = html_parser.parse(html);
    final items = <ZerluthItem>[];

    // Find all article containers
    final articleDivs = document.querySelectorAll('div[id^="art_"]');

    for (final div in articleDivs) {
      final item = _extractItem(div);
      if (item != null) {
        items.add(item);
      }
    }

    return items;
  }

  /// Extract a single item from its container div
  ZerluthItem? _extractItem(Element div) {
    try {
      // Extract ID from div id attribute (e.g., "art_*000258983")
      final divId = div.attributes['id'] ?? '';
      final id = divId.replaceFirst('art_', '');
      if (id.isEmpty) return null;

      // Try to get clean data from hidden form fields
      String? composer;
      String? title;

      final authorInput = div.querySelector('input[name="cart_autor"]');
      if (authorInput != null) {
        composer = authorInput.attributes['value']?.trim();
      }

      final titleInput = div.querySelector('input[name="cart_titel"]');
      if (titleInput != null) {
        title = titleInput.attributes['value']?.trim();
      }

      // Fallback to text content if hidden fields not available
      if (composer == null || composer.isEmpty) {
        final composerElem = div.querySelector('.artikeltext strong.link');
        composer = composerElem?.text.trim();
      }

      if (title == null || title.isEmpty) {
        final titleElem = div.querySelector('.artikeltext article');
        title = titleElem?.text.trim();
      }

      // Extract difficulty from ratings tab
      int? difficulty;
      final activatedTab = div.querySelector('.ratings-tab.activated');
      if (activatedTab != null) {
        final diffText = activatedTab.text.trim();
        difficulty = int.tryParse(diffText);
      }

      // Extract instrumentation using regex on artikeltext
      String? instrumentation;
      final artikelText = div.querySelector('.artikeltext');
      if (artikelText != null) {
        final htmlContent = artikelText.innerHtml;
        final instrMatch = RegExp(r'Instrumentierung:</b>&nbsp;\s*([^<]+)')
            .firstMatch(htmlContent);
        if (instrMatch != null) {
          instrumentation = instrMatch.group(1)?.trim();
        }
      }

      // Extract category
      String? category;
      if (artikelText != null) {
        final htmlContent = artikelText.innerHtml;
        final catMatch =
            RegExp(r'Kategorie:\s*</b>([^<]+)').firstMatch(htmlContent);
        if (catMatch != null) {
          category = catMatch.group(1)?.trim();
        }
      }

      return ZerluthItem(
        id: id,
        composer: composer,
        title: title,
        difficulty: difficulty,
        instrumentation: instrumentation,
        category: category,
      );
    } catch (e) {
      _log('Error extracting item: $e', color: TerminalColors.yellow);
      return null;
    }
  }

  /// Crawl all pages and return all items
  Future<List<ZerluthItem>> crawlAll({
    int maxPages = 35,
    bool verbose = true,
  }) async {
    final allItems = <ZerluthItem>[];

    // Initialize session
    if (!await initializeSearch()) {
      _log('Failed to initialize search session. Aborting.',
          color: TerminalColors.red);
      return [];
    }

    _log('\n${'=' * 60}', color: TerminalColors.magenta);
    _log('Starting crawl of zerluth.de flute catalog',
        color: TerminalColors.bold);
    _log('Expected: ~17,325 items across $maxPages pages',
        color: TerminalColors.cyan);
    _log('${'=' * 60}\n', color: TerminalColors.magenta);

    for (var page = 1; page <= maxPages; page++) {
      final startTime = DateTime.now();

      final items = await fetchPage(page);

      final elapsed = DateTime.now().difference(startTime);
      allItems.addAll(items);

      // Calculate progress
      final progress = (page / maxPages * 100).toStringAsFixed(1);
      final withDifficulty =
          items.where((i) => i.difficulty != null).length;
      final withInstr =
          items.where((i) => i.instrumentation != null).length;

      if (verbose) {
        _log(
          '${TerminalColors.green}[Page $page/$maxPages]${TerminalColors.reset} '
          '${TerminalColors.cyan}${items.length} items${TerminalColors.reset} '
          '(diff: $withDifficulty, instr: $withInstr) '
          '${TerminalColors.yellow}${elapsed.inMilliseconds}ms${TerminalColors.reset} '
          '${TerminalColors.magenta}[$progress%]${TerminalColors.reset}',
        );
      }

      // Be polite to the server
      if (page < maxPages) {
        await Future.delayed(_requestDelay);
      }
    }

    _log('\n${'=' * 60}', color: TerminalColors.magenta);
    _log('Crawl complete!', color: TerminalColors.green);
    _log('Total items: ${allItems.length}', color: TerminalColors.cyan);

    // Statistics
    final withDiff = allItems.where((i) => i.difficulty != null).length;
    final withInstr = allItems.where((i) => i.instrumentation != null).length;
    final withComposer = allItems.where((i) => i.composer != null).length;
    final withTitle = allItems.where((i) => i.title != null).length;

    _log('Items with difficulty: $withDiff (${(withDiff / allItems.length * 100).toStringAsFixed(1)}%)',
        color: TerminalColors.yellow);
    _log('Items with instrumentation: $withInstr (${(withInstr / allItems.length * 100).toStringAsFixed(1)}%)',
        color: TerminalColors.yellow);
    _log('Items with composer: $withComposer (${(withComposer / allItems.length * 100).toStringAsFixed(1)}%)',
        color: TerminalColors.yellow);
    _log('Items with title: $withTitle (${(withTitle / allItems.length * 100).toStringAsFixed(1)}%)',
        color: TerminalColors.yellow);
    _log('${'=' * 60}\n', color: TerminalColors.magenta);

    return allItems;
  }

  void close() {
    _client.close();
  }

  void _log(String message, {String color = ''}) {
    if (color.isNotEmpty) {
      print('$color$message${TerminalColors.reset}');
    } else {
      print(message);
    }
  }
}

/// Save items to JSON file
Future<void> saveToJson(List<ZerluthItem> items, String filePath) async {
  final file = File(filePath);

  // Ensure directory exists
  await file.parent.create(recursive: true);

  // Convert to JSON
  final jsonData = items.map((item) => item.toJson()).toList();
  final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

  await file.writeAsString(jsonString);

  print('${TerminalColors.green}Saved ${items.length} items to $filePath${TerminalColors.reset}');
}

Future<void> main(List<String> args) async {
  print('''
${TerminalColors.bold}${TerminalColors.cyan}
  ____          _       _   _       ____                    _
 |__  | ___ _ _| | _ _ | |_| |_    / ___|_ __ __ ___      _| | ___ _ __
   / / / _ \\ '_| || | ||  _|   \\  | |   | '__/ _\` \\ \\ /\\ / / |/ _ \\ '__|
  / /__  __/ | | || |_|| |_| | | | | |___| | | (_| |\\ V  V /| |  __/ |
 /____|\\___|_| |_|\\__,_|\\__|_| |_|  \\____|_|  \\__,_| \\_/\\_/ |_|\\___|_|
${TerminalColors.reset}
''');

  // Parse arguments
  final testMode = args.contains('--test');
  final maxPages = testMode ? 1 : 35;

  if (testMode) {
    print('${TerminalColors.yellow}Running in TEST mode (1 page only)${TerminalColors.reset}\n');
  }

  final crawler = ZerluthCrawler();

  try {
    final items = await crawler.crawlAll(maxPages: maxPages);

    if (items.isNotEmpty) {
      final outputPath = 'lib/data/sources/zerluth_flute.json';
      await saveToJson(items, outputPath);

      // Print some sample data
      print('\n${TerminalColors.cyan}Sample data (first 5 items):${TerminalColors.reset}');
      for (var i = 0; i < 5 && i < items.length; i++) {
        final item = items[i];
        print('  ${i + 1}. ${item.title ?? "Unknown"} by ${item.composer ?? "Unknown"}');
        print('     Difficulty: ${item.difficulty ?? "N/A"}, Instrumentation: ${item.instrumentation ?? "N/A"}');
      }
    } else {
      print('${TerminalColors.red}No items crawled.${TerminalColors.reset}');
    }
  } finally {
    crawler.close();
  }
}
