import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_notifier.dart';
import '../shared/theme/app_colors.dart';

class ReturnPage extends ConsumerStatefulWidget {
  final String? initialContainerId;

  const ReturnPage({super.key, this.initialContainerId});

  @override
  ConsumerState<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends ConsumerState<ReturnPage> {
  late final TextEditingController _containerIdController;
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
    super.dispose();
  }

  void _submitReturn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _submitting = true;
        _error = null;
        _successResult = null;
      });

      try {
        final client = ref.read(apiClientProvider);
        final containerId = _containerIdController.text.trim();
        final res =
            await client.post('/circulations/containers/$containerId/return');

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
        title: const Text('Registrar Devolución'),
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
                        'Confirmar Devolución',
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
                          labelText: 'ID del Envase a Devolver (UUID)',
                          prefixIcon: Icon(Icons.qr_code_scanner),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Ingrese ID del envase'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _submitting
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              icon: const Icon(
                                  Icons.assignment_turned_in_outlined),
                              label: const Text('REGISTRAR DEVOLUCIÓN'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkGreen,
                              ),
                              onPressed: _submitReturn,
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
                          'Error al devolver: $_error',
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
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\u00A1Devolución Exitosa!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                Text(
                                  '\u00A1Gracias por completar el ciclo!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
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
                          'Devuelto en: ${_successResult!['returnedAt']}',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Puntualidad: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    _successResult!['punctuality'] == 'ON_TIME'
                                        ? AppColors.primaryGreen
                                        : AppColors.errorRed,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _successResult!['punctuality'] == 'ON_TIME'
                                    ? 'A TIEMPO'
                                    : 'TARDE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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
