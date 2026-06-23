import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _taxController = TextEditingController();
  String _currency = r"$";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<FirebaseService>(context, listen: false).profile;
    if (profile != null) {
      _nameController.text = profile.businessName;
      _addressController.text = profile.businessAddress;
      _phoneController.text = profile.phone;
      _taxController.text = profile.taxRate.toString();
      _currency = profile.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<FirebaseService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.emerald.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.settings_rounded, color: Colors.emerald),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Terminal Settings",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.black, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Store Outlet Name",
                          hintText: "EasySell Main Outlet",
                        ),
                        validator: (v) => v == null || v.isEmpty ? "Require name" : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: "Support Phone Line",
                          hintText: "+1 (555) 0192",
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Physical Store Location Address",
                          hintText: "101 Plaza Blvd Suite",
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: const InputDecoration(labelText: "Shop Currency Symbol"),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _currency = val;
                                  });
                                }
                              },
                              items: [r"$", "€", "£", "¥", "₦", "₵"].map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c == r"$" ? r"USD ($)" : c),
                                  );
                                }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _taxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: "Standard Sales Tax (%)"),
                              validator: (v) => v == null || double.tryParse(v) == null ? "Require numerical" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          await service.updateSettings(
                            _nameController.text.trim(),
                            _addressController.text.trim(),
                            _phoneController.text.trim(),
                            _currency,
                            double.parse(_taxController.text),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Setup modifications applied successfully!"),
                              backgroundColor: Colors.emerald,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.emerald,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Apply Terminal Setup", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
