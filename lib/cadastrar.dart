import 'package:flutter/material.dart';

import 'task_model.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _important = false;
  bool _notify = true;
  double _sliderValue = 50;
  String _priority = 'normal';
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final Task task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        important: _important,
        notify: _notify,
        priority: _priority,
        dueDate: _selectedDate ?? DateTime.now(),
      );
      Navigator.pop(context, task);
    }
  }

  void _showConfirmDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar tarefa'),
          content: const Text('Deseja salvar esta tarefa?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _saveTask();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showPreviewSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Pré-visualização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Título: ${_titleController.text}'),
              Text('Descrição: ${_descriptionController.text}'),
              Text('Importante: ${_important ? 'Sim' : 'Não'}'),
              Text('Notificar: ${_notify ? 'Sim' : 'Não'}'),
              Text('Prioridade: ${_priority.toUpperCase()}'),
              Text('Data: ${_selectedDate != null ? _selectedDate!.toLocal().toString().split(' ').first : 'Não selecionada'}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Mais opções'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _showConfirmDialog();
              },
              child: const Text('Confirmar e salvar'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                _showPreviewSheet();
              },
              child: const Text('Ver pré-visualização'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                title: const Text('Importante'),
                value: _important,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      _important = value;
                    });
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SwitchListTile(
                title: const Text('Notificar'),
                value: _notify,
                onChanged: (bool value) {
                  setState(() {
                    _notify = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              const Text('Urgência'),
              Slider(
                value: _sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                label: _sliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
              const SizedBox(height: 14),
              const Text('Prioridade'),
              RadioListTile<String>(
                title: const Text('Normal'),
                value: 'normal',
                groupValue: _priority,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              RadioListTile<String>(
                title: const Text('Alta'),
                value: 'alta',
                groupValue: _priority,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? 'Escolher data'
                      : 'Data: ${_selectedDate!.toLocal().toString().split(' ').first}',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showConfirmDialog,
                child: const Text('Salvar tarefa'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _showOptionsDialog,
                child: const Text('Mais opções'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
