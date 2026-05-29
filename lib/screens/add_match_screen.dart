// lib/screens/add_match_screen.dart (COMPLETE FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';
import '../models/team.dart';

class AddMatchScreen extends StatefulWidget {
  final MatchModel? match;

  const AddMatchScreen({super.key, this.match});

  @override
  State<AddMatchScreen> createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  late GlobalKey<FormState> _formKey;
  late DateTime _selectedDate;
  Team? _homeTeam;
  Team? _awayTeam;
  late TextEditingController _homeScoreController;
  late TextEditingController _awayScoreController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _selectedDate = widget.match?.date ?? DateTime.now();
    _homeScoreController =
        TextEditingController(text: widget.match?.homeScore.toString() ?? '0');
    _awayScoreController =
        TextEditingController(text: widget.match?.awayScore.toString() ?? '0');

    if (widget.match != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final teams = Provider.of<TeamProvider>(context, listen: false).teams;
        setState(() {
          _homeTeam = teams
              .firstWhere((t) => t.id == widget.match!.homeTeamId, orElse: () => teams.first);
          _awayTeam = teams
              .firstWhere((t) => t.id == widget.match!.awayTeamId, orElse: () => teams.last);
        });
      });
    }
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveMatch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_homeTeam == null || _awayTeam == null) {
      _showError('Pilih kedua tim (home dan away) terlebih dahulu');
      return;
    }
    if (_homeTeam!.id == _awayTeam!.id) {
      _showError('Tim home dan away tidak boleh sama');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final homeScore = int.parse(_homeScoreController.text);
      final awayScore = int.parse(_awayScoreController.text);

      final match = MatchModel(
        id: widget.match?.id ?? '',
        homeTeamId: _homeTeam!.id,
        awayTeamId: _awayTeam!.id,
        homeTeamName: _homeTeam!.name,  // ✅ ADDED
        awayTeamName: _awayTeam!.name,  // ✅ ADDED
        homeTeamLogo: _homeTeam!.logoUrl,
        awayTeamLogo: _awayTeam!.logoUrl,
        homeScore: homeScore,
        awayScore: awayScore,
        date: _selectedDate,
        status: 'finished',
        userId: '',  // ✅ ADDED
        createdAt: widget.match?.createdAt ?? DateTime.now(),  // ✅ ADDED
        matchWeek: 'Week 1',
      );

      final matchProvider =
      Provider.of<MatchProvider>(context, listen: false);

      if (widget.match == null) {
        await matchProvider.addMatch(match);
        _showSuccess('Pertandingan berhasil ditambahkan');
      } else {
        await matchProvider.updateMatch(match);
        _showSuccess('Pertandingan berhasil diperbarui');
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match == null ? 'Tambah Pertandingan' : 'Edit Pertandingan'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal
              const Text(
                'Tanggal Pertandingan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tim Home
              const Text(
                'Tim Rumah (Home)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<TeamProvider>(
                builder: (ctx, teamProvider, _) {
                  return DropdownButtonFormField<Team>(
                    value: _homeTeam,
                    decoration: InputDecoration(
                      hintText: 'Pilih tim rumah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: teamProvider.teams
                        .map((team) => DropdownMenuItem(
                      value: team,
                      child: Text(team.name),
                    ))
                        .toList(),
                    onChanged: (team) => setState(() => _homeTeam = team),
                    validator: (value) =>
                    value == null ? 'Pilih tim rumah' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Skor Home
              const Text(
                'Skor Rumah',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _homeScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skor harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Skor harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tim Away
              const Text(
                'Tim Tamu (Away)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Consumer<TeamProvider>(
                builder: (ctx, teamProvider, _) {
                  return DropdownButtonFormField<Team>(
                    value: _awayTeam,
                    decoration: InputDecoration(
                      hintText: 'Pilih tim tamu',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: teamProvider.teams
                        .map((team) => DropdownMenuItem(
                      value: team,
                      child: Text(team.name),
                    ))
                        .toList(),
                    onChanged: (team) => setState(() => _awayTeam = team),
                    validator: (value) =>
                    value == null ? 'Pilih tim tamu' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Skor Away
              const Text(
                'Skor Tamu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _awayScoreController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skor harus diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Skor harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Text(
                    widget.match == null
                        ? 'Tambah Pertandingan'
                        : 'Perbarui Pertandingan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}