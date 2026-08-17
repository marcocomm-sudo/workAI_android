import 'package:flutter/material.dart';
import 'dart:convert';
import 'services/cirpack_api.dart';

void main() {
  runApp(const CirpackAgentApp());
}

class CirpackAgentApp extends StatelessWidget {
  const CirpackAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cirpack Agent Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CirpackApiService _apiService = CirpackApiService();
  final TextEditingController _accountController = TextEditingController();

  bool _isLoading = false;
  String _serverStatus = 'Verifica in corso...';
  String _resultOutput = 'Inserisci un Account ID per avviare l\'audit o verificare le statistiche.';

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    try {
      final res = await _apiService.checkHealth();
      setState(() {
        _serverStatus = 'Online (${res['service'] ?? 'Cirpack API'})';
      });
    } catch (e) {
      setState(() {
        _serverStatus = 'Disconnesso / Errore Server';
      });
    }
  }

  Future<void> _handleAudit() async {
    if (_accountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un Account ID valido')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultOutput = 'Esecuzione audit in corso...';
    });

    try {
      final res = await _apiService.runAudit(_accountController.text.trim());
      setState(() {
        _resultOutput = const JsonEncoder.withIndent('  ').convert(res['data']);
      });
    } catch (e) {
      setState(() {
        _resultOutput = 'Errore: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cirpack Agent Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkServer,
            tooltip: 'Aggiorna Stato Server',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              color: _serverStatus.contains('Online')
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      _serverStatus.contains('Online')
                          ? Icons.check_circle
                          : Icons.error,
                      color: _serverStatus.contains('Online')
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Stato Server: $_serverStatus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _serverStatus.contains('Online')
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: 'Account ID / Numero di Telefono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_search),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleAudit,
              icon: const Icon(Icons.analytics),
              label: const Text('Esegui Audit Cirpack'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Risultati Agente:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Text(
                          _resultOutput,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
