import 'package:flutter/material.dart';
import '../shared/theme/app_colors.dart';
import 'welcome_success_page.dart';

/// Screen representing "Completa tu perfil (opcional)" (Mockup Screen 9).
/// Allows adding photo, selecting academic program and semester.
class CompleteProfilePage extends StatefulWidget {
  final String? fullName;

  const CompleteProfilePage({super.key, this.fullName});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  late final TextEditingController _nameController;
  String? _selectedCareer;
  String? _selectedSemester;

  final List<String> _careers = [
    'Ingeniería en Sistemas Computacionales',
    'Ingeniería Industrial',
    'Ingeniería Mecánica',
    'Ingeniería Química',
    'Ingeniería Eléctrica',
    'Licenciatura en Administración',
  ];

  final List<String> _semesters = [
    '1° Semestre',
    '2° Semestre',
    '3° Semestre',
    '4° Semestre',
    '5° Semestre',
    '6° Semestre',
    '7° Semestre',
    '8° Semestre',
    '9°+ Semestre',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName ?? 'Valeria Torres');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _proceed() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeSuccessPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Completa tu perfil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Esta información nos ayuda a mejorar tu experiencia en ReVuelta.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Photo upload circle
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.forestGreen, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 32,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Agregar foto',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form fields
              const Text(
                'Nombre completo',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Ej. Valeria Torres',
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Carrera',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCareer,
                hint: const Text('Selecciona tu carrera'),
                decoration: const InputDecoration(),
                items: _careers.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _selectedCareer = val),
              ),
              const SizedBox(height: 16),

              const Text(
                'Semestre',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                hint: const Text('Selecciona tu semestre'),
                decoration: const InputDecoration(),
                items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _selectedSemester = val),
              ),
              const SizedBox(height: 36),

              // Bottom action buttons: Omitir por ahora | Guardar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _proceed,
                      child: const Text('Omitir por ahora'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _proceed,
                      child: const Text('Guardar'),
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
