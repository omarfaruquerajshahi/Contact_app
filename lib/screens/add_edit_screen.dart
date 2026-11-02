import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/contact.dart';

class AddEditScreen extends StatefulWidget {
  final Contact? contact; // null = add new, not null = edit
  const AddEditScreen({super.key, this.contact});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  bool isFavorite = false;

  bool get isEdit => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final c = widget.contact!;
      nameCtrl.text = c.name;
      phoneCtrl.text = c.phone;
      emailCtrl.text = c.email;
      addressCtrl.text = c.address;
      isFavorite = c.isFavorite;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final contact = Contact(
      id: widget.contact?.id,
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      isFavorite: isFavorite,
    );

    if (isEdit) {
      await DBHelper.updateContact(contact);
    } else {
      await DBHelper.insertContact(contact);
    }
    if (mounted) Navigator.pop(context, true);
  }

  Widget field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Update Contact' : 'Add Contact')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isEdit)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('ID: ${widget.contact!.id}',
                    style: const TextStyle(color: Colors.grey)),
              ),
            field(nameCtrl, 'Name', Icons.person,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null),
            field(phoneCtrl, 'Phone Number', Icons.phone,
                type: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Phone is required' : null),
            field(emailCtrl, 'Email', Icons.email,
                type: TextInputType.emailAddress, validator: (v) {
              if (v != null && v.isNotEmpty && !v.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            }),
            field(addressCtrl, 'Address', Icons.home),
            SwitchListTile(
              title: const Text('Mark as Favorite'),
              secondary: const Icon(Icons.star, color: Colors.amber),
              value: isFavorite,
              onChanged: (v) => setState(() => isFavorite = v),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
