// lib/screens/add_edit_match_screen.dart (COMPLETE FIXED)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';
import '../models/team.dart';

class AddEditMatchScreen extends StatefulWidget {
  final MatchModel? match;

  const AddEditMatchScreen({super.key, this.match});

  @override
  State<AddEditMatchScreen> createState() => _AddEditMatchScreenState();
}

class _AddEditMatchScreenState extends State<AddEditMatchScreen> {
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
          _homeTeam = teams.firstWhere(
                (t) => t.id == widget.match!.homeTeamId,
            orElse: () => teams.isNotEmpty ? teams.first : null as Team,
          );
          _awayTeam = teams.firstWhere(
                (t) => t.id == widget.match!.awayTeamId,
            orElse: () => teams.length > 1 ? teams[1] : null as Team,
          );
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
        id: widget.match?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      appBar: AppBar(
        title: Text(
          widget.match == null ? 'Tambah Pertandingan' : 'Edit Pertandingan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1020),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0A1020),
                Colors.green[800] ?? const Color(0xFF2E7D32),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Tanggal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal Pertandingan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF132040),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFFD4AF37),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card Tim Home
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Color(0xFF4ECDC4),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tim Rumah (Home)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<TeamProvider>(
                      builder: (ctx, teamProvider, _) {
                        return DropdownButtonFormField<Team>(
                          value: _homeTeam,
                          decoration: InputDecoration(
                            hintText: 'Pilih tim rumah',
                            filled: true,
                            fillColor: const Color(0xFF132040),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          dropdownColor: const Color(0xFF132040),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: teamProvider.teams
                              .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team.name),
                          ))
                              .toList(),
                          onChanged: (team) =>
                              setState(() => _homeTeam = team),
                          validator: (value) =>
                          value == null ? 'Pilih tim rumah' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Skor Rumah',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _homeScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 32,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF132040),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          ),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Card Tim Away
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1829),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.public,
                          color: Color(0xFFFF6B6B),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tim Tamu (Away)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Consumer<TeamProvider>(
                      builder: (ctx, teamProvider, _) {
                        return DropdownButtonFormField<Team>(
                          value: _awayTeam,
                          decoration: InputDecoration(
                            hintText: 'Pilih tim tamu',
                            filled: true,
                            fillColor: const Color(0xFF132040),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          dropdownColor: const Color(0xFF132040),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: teamProvider.teams
                              .map((team) => DropdownMenuItem(
                            value: team,
                            child: Text(team.name),
                          ))
                              .toList(),
                          onChanged: (team) =>
                              setState(() => _awayTeam = team),
                          validator: (value) =>
                          value == null ? 'Pilih tim tamu' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Skor Tamu',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _awayScoreController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 32,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF132040),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          ),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF0A0E1A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                    const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation(Color(0xFF0A0E1A)),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle),
                      const SizedBox(width: 8),
                      Text(
                        widget.match == null
                            ? 'Tambah Pertandingan'
                            : 'Perbarui Pertandingan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Batal
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}