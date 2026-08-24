import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

class FormDemoPage extends StatefulWidget {
  const FormDemoPage({super.key});

  @override
  State<FormDemoPage> createState() => _FormDemoPageState();
}

class _FormDemoPageState extends State<FormDemoPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: NexoValidators.compose([
              NexoValidators.requiredField(fieldName: 'Email'),
              NexoValidators.email(),
            ]),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Телефон (необязательно)',
              border: OutlineInputBorder(),
            ),
            validator: NexoValidators.phone(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(),
            ),
            validator: NexoValidators.compose([
              NexoValidators.requiredField(fieldName: 'Пароль'),
              NexoValidators.password(minLength: 6),
            ]),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Отправить'),
            onPressed: () {
              final valid = _formKey.currentState?.validate() ?? false;
              if (!valid) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Форма валидна, отправляем!')),
                );
            },
          ),
        ],
      ),
    );
  }
}
