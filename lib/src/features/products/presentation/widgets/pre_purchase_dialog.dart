import 'package:flutter/material.dart';

class PrePurchaseDialog extends StatefulWidget {
  final String productName;

  const PrePurchaseDialog({
    super.key,
    required this.productName,
  });

  @override
  State<PrePurchaseDialog> createState() => _PrePurchaseDialogState();
}

class _PrePurchaseDialogState extends State<PrePurchaseDialog> {
  bool _reallyNeed = false;
  bool _alreadyHave = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Vent litt!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Før du kjøper "${widget.productName}", tenk over:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _reallyNeed,
            onChanged: (value) {
              setState(() {
                _reallyNeed = value ?? false;
              });
            },
            title: const Text('Trenger jeg virkelig dette?'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: !_alreadyHave,
            onChanged: (value) {
              setState(() {
                _alreadyHave = !(value ?? true);
              });
            },
            title: const Text('Har jeg IKKE noe tilsvarende fra før?'),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (!_reallyNeed || _alreadyHave) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kanskje du bør vente litt lengre?',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Avbryt'),
        ),
        FilledButton(
          onPressed: () {
            if (_reallyNeed && !_alreadyHave) {
              Navigator.of(context).pop(true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Du må krysse av begge punktene før du kan kjøpe!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: const Text('Kjøp likevel'),
        ),
      ],
    );
  }
}
