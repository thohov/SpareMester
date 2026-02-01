import 'package:flutter/material.dart';

class ExtendedCooldownDialog extends StatefulWidget {
  final String productName;

  const ExtendedCooldownDialog({
    super.key,
    required this.productName,
  });

  @override
  State<ExtendedCooldownDialog> createState() => _ExtendedCooldownDialogState();
}

class _ExtendedCooldownDialogState extends State<ExtendedCooldownDialog> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Tenk litt til?')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bra valg! Du valgte å ikke kjøpe "${widget.productName}".',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Vil du tenke litt lengre på det?',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Velg hvor mange dager du vil ha ekstra tenketid:',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_selectedDays ${_selectedDays == 1 ? 'dag' : 'dager'}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Ekstra tenketid',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _selectedDays.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: '$_selectedDays ${_selectedDays == 1 ? 'dag' : 'dager'}',
                  onChanged: (value) {
                    setState(() {
                      _selectedDays = value.toInt();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '1 dag',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '30 dager',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Produktet vil dukke opp igjen om $_selectedDays ${_selectedDays == 1 ? 'dag' : 'dager'}.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Avbryt'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(-1),
          child: const Text('Nei, ikke kjøp'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(_selectedDays),
          icon: const Icon(Icons.timer),
          label: const Text('Tenk litt til'),
        ),
      ],
    );
  }
}
