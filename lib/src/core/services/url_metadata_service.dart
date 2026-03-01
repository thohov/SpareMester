import 'package:http/http.dart' as http;

class UrlMetadataService {
  /// Extracts the Open Graph image URL from a webpage
  static Future<String?> extractImageFromUrl(String url) async {
    try {
      print('🌐 UrlMetadataService: Starter henting av bilde fra: $url');

      // Validate URL
      final uri = Uri.tryParse(url);
      if (uri == null || (!uri.scheme.startsWith('http'))) {
        print('❌ Ugyldig URL: $url');
        return null;
      }

      print('📡 Sender HTTP GET request til: $uri');

      // Fetch the webpage
      final response = await http.get(
        uri,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 Mottok respons: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('❌ Feil statuskode: ${response.statusCode}');
        return null;
      }

      final html = response.body;
      print('📄 HTML lengde: ${html.length} bytes');

      // Look for Open Graph image tag
      // Pattern: <meta property="og:image" content="URL">
      final ogImagePattern1 =
          '<meta[^>]*property=["\']og:image["\'][^>]*content=["\']([^"\']+)["\']';
      var match =
          RegExp(ogImagePattern1, caseSensitive: false).firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        var imageUrl = match.group(1);
        if (imageUrl != null) {
          imageUrl = _optimizeImageUrl(_resolveUrl(imageUrl, url));
          print(
              '✅ Fant bilde med pattern 1 (og:image property først): $imageUrl');
          return imageUrl;
        }
      }

      // Alternative format: content first, then property
      final ogImagePattern2 =
          '<meta[^>]*content=["\']([^"\']+)["\'][^>]*property=["\']og:image["\']';
      match = RegExp(ogImagePattern2, caseSensitive: false).firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        var imageUrl = match.group(1);
        if (imageUrl != null) {
          imageUrl = _optimizeImageUrl(_resolveUrl(imageUrl, url));
          print(
              '✅ Fant bilde med pattern 2 (og:image content først): $imageUrl');
          return imageUrl;
        }
      }

      // Try Twitter card image as fallback
      final twitterImagePattern1 =
          '<meta[^>]*name=["\']twitter:image["\'][^>]*content=["\']([^"\']+)["\']';
      match =
          RegExp(twitterImagePattern1, caseSensitive: false).firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        var imageUrl = match.group(1);
        if (imageUrl != null) {
          imageUrl = _optimizeImageUrl(_resolveUrl(imageUrl, url));
          print(
              '✅ Fant bilde med pattern 3 (twitter:image name først): $imageUrl');
          return imageUrl;
        }
      }

      // Alternative format for Twitter
      final twitterImagePattern2 =
          '<meta[^>]*content=["\']([^"\']+)["\'][^>]*name=["\']twitter:image["\']';
      match =
          RegExp(twitterImagePattern2, caseSensitive: false).firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        var imageUrl = match.group(1);
        if (imageUrl != null) {
          imageUrl = _optimizeImageUrl(_resolveUrl(imageUrl, url));
          print(
              '✅ Fant bilde med pattern 4 (twitter:image content først): $imageUrl');
          return imageUrl;
        }
      }

      print('⚠️ Ingen bilde-metadata funnet i HTML');

      // Fallback: Try to find product images in img tags
      print('🔍 Prøver fallback: søker etter produktbilder i <img> tags...');

      // Look for images with "product" or specific size indicators in src
      final productImgPatterns = [
        '<img[^>]*src=["\']([^"\']*(?:product|produkt|item|w640|w1024)[^"\']*\\.(?:jpg|jpeg|png|webp))["\']',
        '<img[^>]*data-rsBigImg=["\']([^"\']+)["\']',
        'data-rsBigImg=["\']([^"\']+)["\']',
      ];

      for (final pattern in productImgPatterns) {
        match = RegExp(pattern, caseSensitive: false).firstMatch(html);
        if (match != null && match.groupCount >= 1) {
          var imageUrl = match.group(1);
          if (imageUrl != null) {
            // Resolve relative URL then optimise size for mobile display
            imageUrl = _optimizeImageUrl(_resolveUrl(imageUrl, url));
            print('✅ Fant produktbilde i <img> tag: $imageUrl');
            return imageUrl;
          }
        }
      }

      print('❌ Ingen produktbilder funnet');
      return null;
    } catch (e, stackTrace) {
      // Log error and return null
      print('❌ Exception i UrlMetadataService: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Optimizes image URL for mobile display by preferring medium-sized versions
  static String _optimizeImageUrl(String imageUrl) {
    // Replace large image sizes with medium size for better performance
    var optimized = imageUrl;

    // Pattern 1: .w1024. style (e.g., image.w1024.png)
    optimized = optimized
        .replaceAll(RegExp(r'\.w1024\.'), '.w640.')
        .replaceAll(RegExp(r'\.w1200\.'), '.w640.')
        .replaceAll(RegExp(r'\.w2048\.'), '.w640.')
        .replaceAll(RegExp(r'\.w1500\.'), '.w640.');

    // Pattern 2: /1024/ style (e.g., /1024/image.png)
    optimized = optimized
        .replaceAll(RegExp(r'/1024/'), '/640/')
        .replaceAll(RegExp(r'/1200/'), '/640/')
        .replaceAll(RegExp(r'/1500/'), '/640/')
        .replaceAll(RegExp(r'/2048/'), '/640/');

    // Pattern 3: W= / w= query-parameter style (e.g. ?W=1500 or &w=1200)
    // IMPORTANT: must preserve ? vs & – replacing both with ? breaks multi-param URLs
    optimized = optimized.replaceAllMapped(
      RegExp(r'([?&])([Ww])=(1500|1200|2000|2048)'),
      (m) => '${m.group(1)}${m.group(2)}=640',
    );

    // Pattern 4: width=XXXX style (no separator issue here)
    optimized = optimized
        .replaceAll(RegExp(r'width=1500', caseSensitive: false), 'width=640')
        .replaceAll(RegExp(r'width=1200', caseSensitive: false), 'width=640')
        .replaceAll(RegExp(r'width=2000', caseSensitive: false), 'width=640');

    // Pattern 5: ?size=large or ?quality=high – preserve separator
    optimized = optimized.replaceAllMapped(
      RegExp(r'([?&])size=large', caseSensitive: false),
      (m) => '${m.group(1)}size=medium',
    );
    optimized = optimized.replaceAllMapped(
      RegExp(r'([?&])quality=high', caseSensitive: false),
      (m) => '${m.group(1)}quality=medium',
    );

    if (optimized != imageUrl) {
      print('📐 Optimalisert bildestørrelse: $imageUrl -> $optimized');
    }

    return optimized;
  }

  /// Resolves a potentially relative image URL to an absolute URL.
  /// e.g. /images/product.jpg → https://example.com/images/product.jpg
  static String _resolveUrl(String imageUrl, String pageUrl) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl; // Already absolute
    }
    if (imageUrl.startsWith('//')) {
      return 'https:$imageUrl'; // Protocol-relative
    }
    if (imageUrl.startsWith('/')) {
      final base = Uri.tryParse(pageUrl);
      if (base != null) {
        return '${base.scheme}://${base.host}$imageUrl';
      }
    }
    return imageUrl; // Unknown format – return as-is
  }
}
