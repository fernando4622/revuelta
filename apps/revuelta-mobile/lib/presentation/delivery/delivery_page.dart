import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../shared/theme/app_colors.dart';

class DeliveryPage extends ConsumerStatefulWidget {
  final String? initialContainerId;

  const DeliveryPage({super.key, this.initialContainerId});

  @override
  ConsumerState<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends ConsumerState<DeliveryPage> {
  late final TextEditingController _containerIdController;
  final _borrowerIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  Map<String, dynamic>? _successResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _containerIdController =
        TextEditingController(text: widget.initialContainerId ?? '');
  }

  @override
  void dispose() {
    _containerIdController.dispose();
    _borrowerIdController.dispose();
    super.dispose();
  }

  void _submitDelivery() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitting = true;
        _error = null;
        _successResult = null;
      });

      try {
        final client = ref.read(apiClientProvider);
        final res = await client.post('/circulations', data: {
          'containerId': _containerIdController.text.trim(),
          'borrowerId': _borrowerIdController.text.trim(),
        });

        setState(() {
          _successResult = res;
          _submitting = false;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar Entrega'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Datos del Préstamo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _containerIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID del Envase (UUID)',
                          prefixIcon: Icon(Icons.qr_code_2),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Ingrese ID del envase'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _borrowerIdController,
                        decoration: const InputDecoration(
                          labelText: 'ID del Alumno Prestatario',
                          hintText: 'Ej. a0000000-0000-0000-0000-000000000003',
                          prefixIcon: Icon(Icons.person_pin_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Ingrese ID del alumno'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _submitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('CONFIRMAR ENTREGA'),
                              onPressed: _submitDelivery,
                            ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.errorRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Error al entregar: $_error',
                          style: const TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_successResult != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.primaryGreen, size: 28),
                            SizedBox(width: 10),
                            Text(
                              '\u00A1Entrega confirmada!',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          'ID Circulación: ${_successResult!['id']}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fecha Límite: ${_successResult!['dueAt']}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estado: ${_successResult!['status']}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
