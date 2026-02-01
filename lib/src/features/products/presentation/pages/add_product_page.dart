import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pengespareapp/l10n/app_localizations.dart';
import 'package:pengespareapp/src/core/providers/products_provider.dart';
import 'package:pengespareapp/src/core/providers/settings_provider.dart';
import 'package:pengespareapp/src/features/products/domain/models/product_category.dart';
import 'package:pengespareapp/src/core/services/url_metadata_service.dart';
import 'package:pengespareapp/src/core/services/error_log_service.dart';

class AddProductPage extends ConsumerStatefulWidget {
  const AddProductPage({super.key});

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  double _desireScore = 5.0;
  ProductCategory _selectedCategory = ProductCategory.other;
  bool _isLoading = false;
  bool _isFetchingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _fetchImageFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Vennligst skriv inn en URL først'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ URL må starte med http:// eller https://'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isFetchingImage = true);

    try {
      print('🔍 Henter bilde fra: $url');
      final imageUrl = await UrlMetadataService.extractImageFromUrl(url);
      
      if (!mounted) return;
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _imageUrlController.text = imageUrl;
        print('✅ Bilde funnet: $imageUrl');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produktbilde funnet!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('⚠️ Ingen bilde funnet på siden');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Fant ikke noe produktbilde på denne siden'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Feil ved henting av bilde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Feil: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingImage = false);
      }
    }
  }

  String _getWaitingPeriodText(double price) {
    final settings = ref.read(settingsProvider);
    final l10n = AppLocalizations.of(context);
    
    if (price < settings.smallAmountThreshold) {
      return l10n.hours(settings.smallAmountWaitHours);
    } else if (price < settings.mediumAmountThreshold) {
      return l10n.days(settings.mediumAmountWaitDays);
    } else {
      return l10n.days(settings.largeAmountWaitDays);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final url = _urlController.text.trim().isEmpty ? null : _urlController.text.trim();
    final imageUrl = _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim();
    final desireScore = _desireScore.round();

    try {
      await ref.read(productsProvider.notifier).addProduct(
        name: name,
        price: price,
        url: url,
        imageUrl: imageUrl,
        desireScore: desireScore,
        category: _selectedCategory,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final period = _getWaitingPeriodText(price);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.productAdded(period)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Log error for debugging
      ErrorLogService.logError(
        errorType: 'AddProductError',
        errorMessage: e.toString(),
        additionalContext: {
          'action': 'save_product',
          'hasUrl': url != null,
          'hasImageUrl': imageUrl != null,
          'category': _selectedCategory.toString(),
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    
    final price = double.tryParse(_priceController.text) ?? 0;
    final workHours = price > 0 ? price / settings.hourlyWage : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addProduct),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.productName,
                  hintText: l10n.enterProductName,
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: l10n.price,
                  hintText: l10n.enterPrice,
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: settings.currencySymbol,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterPrice;
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return l10n.pleaseEnterValidPrice;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 16),

              // URL (optional)
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: l10n.url,
                  hintText: l10n.optionalUrl,
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: _isFetchingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.image_search),
                          tooltip: 'Hent produktbilde fra siden',
                          onPressed: _fetchImageFromUrl,
                        ),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '💡 Trykk på søkeikonet for å hente produktbilde automatisk',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Image URL (optional) - show preview if available
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Bilde-URL',
                      hintText: 'Hentes automatisk fra produktside',
                      prefixIcon: Icon(Icons.image),
                      helperText: 'Du kan også lime inn direktelenke hvis du vil',
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_imageUrlController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrlController.text.trim(),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: theme.colorScheme.errorContainer,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Kunne ikke laste bilde',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<ProductCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Text(_selectedCategory.emoji, style: const TextStyle(fontSize: 24)),
                  prefixIconConstraints: const BoxConstraints(minWidth: 56),
                ),
                items: ProductCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Text(category.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Text(category.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),

              const SizedBox(height: 32),

              // Desire Score Slider
              Text(
                l10n.howMuchDoYouWantThis,
                style: theme.textTheme.titleMedium,
              ),
              Row(
                children: [
                  Text(l10n.notMuch, style: theme.textTheme.bodySmall),
                  Expanded(
                    child: Slider(
                      value: _desireScore,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _desireScore.round().toString(),
                      onChanged: (value) {
                        setState(() => _desireScore = value);
                      },
                    ),
                  ),
                  Text(l10n.veryMuch, style: theme.textTheme.bodySmall),
                ],
              ),

              const SizedBox(height: 24),

              // Work Hours Calculation
              if (price > 0) ...[
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.thisWillCost,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.hoursOfWork(workHours.toStringAsFixed(1)),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.waitingPeriod(_getWaitingPeriodText(price)),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
