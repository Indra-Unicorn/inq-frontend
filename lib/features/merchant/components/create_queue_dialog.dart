import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateQueueDialog extends StatefulWidget {
  final Function({
    required String name,
    required int maxSize,
    required double inQoinRate,
    required int alertNumber,
    required int bufferNumber,
  }) onCreateQueue;

  const CreateQueueDialog({
    super.key,
    required this.onCreateQueue,
  });

  @override
  State<CreateQueueDialog> createState() => _CreateQueueDialogState();
}

class _CreateQueueDialogState extends State<CreateQueueDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxSizeController = TextEditingController(text: '10');
  final _inQoinRateController = TextEditingController(text: '10.0');
  final _alertNumberController = TextEditingController(text: '3');
  final _bufferNumberController = TextEditingController(text: '5');

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _maxSizeController.dispose();
    _inQoinRateController.dispose();
    _alertNumberController.dispose();
    _bufferNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onCreateQueue(
        name: _nameController.text.trim(),
        maxSize: int.parse(_maxSizeController.text),
        inQoinRate: double.parse(_inQoinRateController.text),
        alertNumber: int.parse(_alertNumberController.text),
        bufferNumber: int.parse(_bufferNumberController.text),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Queue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B0E0E),
                          ),
                        ),
                        Text(
                          'Set up a new queue for your customers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8B5B5C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Queue Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Queue Name',
                  hintText: 'Enter queue name',
                  prefixIcon: Icon(Icons.queue, color: Color(0xFF8B5B5C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a queue name';
                  }
                  if (value.trim().length < 2) {
                    return 'Queue name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Max Size
              TextFormField(
                controller: _maxSizeController,
                decoration: const InputDecoration(
                  labelText: 'Maximum Size',
                  hintText: 'Enter maximum queue size',
                  prefixIcon: Icon(Icons.people, color: Color(0xFF8B5B5C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum size';
                  }
                  final size = int.tryParse(value);
                  if (size == null || size <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  if (size > 1000) {
                    return 'Maximum size cannot exceed 1000';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // InQoin Rate
              TextFormField(
                controller: _inQoinRateController,
                decoration: const InputDecoration(
                  labelText: 'InQoin Rate',
                  hintText: 'Enter InQoin rate',
                  prefixIcon:
                      Icon(Icons.monetization_on, color: Color(0xFF8B5B5C)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter InQoin rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Alert and Buffer Numbers
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _alertNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Alert Number',
                        hintText: 'Alert threshold',
                        prefixIcon:
                            Icon(Icons.warning, color: Color(0xFF8B5B5C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(color: Color(0xFF4CAF50), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final alert = int.tryParse(value);
                        if (alert == null || alert < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bufferNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Buffer Number',
                        hintText: 'Buffer threshold',
                        prefixIcon: Icon(Icons.tune, color: Color(0xFF8B5B5C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide:
                              BorderSide(color: Color(0xFF4CAF50), width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final buffer = int.tryParse(value);
                        if (buffer == null || buffer < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5B5C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Queue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
