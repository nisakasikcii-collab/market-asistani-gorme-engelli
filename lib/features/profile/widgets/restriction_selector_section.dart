import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../../core/accessibility/es_accessibility.dart";
import "../../../core/voice/voice_feedback.dart";
import "../domain/dietary_restriction.dart";

/// Enhanced Kısıt seçimi: TalkBack ile anlamlı etiketler, sesli giriş, ikonlar.
class RestrictionSelectorSection extends StatefulWidget {
  const RestrictionSelectorSection({
    super.key,
    required this.selected,
    required this.onChanged,
    this.customRestrictions = const [],
    this.onCustomRestrictionsChanged,
  });

  final Set<DietaryRestriction> selected;
  final void Function(Set<DietaryRestriction>) onChanged;
  final List<String> customRestrictions;
  final void Function(List<String>)? onCustomRestrictionsChanged;

  @override
  State<RestrictionSelectorSection> createState() =>
      _RestrictionSelectorSectionState();
}

class _RestrictionSelectorSectionState extends State<RestrictionSelectorSection> {
  final VoiceFeedback _voice = VoiceFeedback.instance;
  late TextEditingController _customController;
  String _listeningFor = "";

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController(
      text: widget.customRestrictions.join(", "),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _toggle(DietaryRestriction r, bool? value) {
    final next = Set<DietaryRestriction>.from(widget.selected);
    final on = value ?? false;
    if (on) {
      next.add(r);
    } else {
      next.remove(r);
    }
    widget.onChanged(next);
  }

  /// Kullanıcıyı sesle dinle ve seçimi doğrudan güncelle
  Future<void> _listenForRestriction(DietaryRestriction restriction) async {
    setState(() => _listeningFor = restriction.name);
    try {
      // Haptik + beep feedback
      await HapticFeedback.mediumImpact();

      await _voice.speakInfo(
        "${restriction.displayNameTr} için lütfen konuşun. "
        "${restriction.hintTr}",
      );

      final result = await _voice.listenOnce(
        listenFor: const Duration(seconds: 10),
        localeId: "tr_TR",
      );

      if (result != null && result.isNotEmpty) {
        _toggle(restriction, true);
        await _voice.speakInfo("${restriction.displayNameTr} eklendi.");
      }
    } finally {
      if (mounted) setState(() => _listeningFor = "");
    }
  }

  /// "Diğer" için sesle özel kısıt dinle
  Future<void> _listenForCustom() async {
    setState(() => _listeningFor = "custom");
    try {
      // Haptik + beep feedback
      await HapticFeedback.mediumImpact();
      await _voice.speakInfo(
        "Özel sağlık koşulunuzu söyleyin. Örneğin: Hipertansiyon, Astım, vb.",
      );

      final result = await _voice.listenOnce(
        listenFor: const Duration(seconds: 12),
        localeId: "tr_TR",
      );

      if (result != null && result.isNotEmpty) {
        final customs = List<String>.from(widget.customRestrictions);
        if (!customs.contains(result)) {
          customs.add(result);
          widget.onCustomRestrictionsChanged?.call(customs);
          _customController.text = customs.join(", ");
          _toggle(DietaryRestriction.other, true);
          await _voice.speakInfo("'$result' eklendi.");
        }
      }
    } finally {
      if (mounted) setState(() => _listeningFor = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = esAccessibleBodyStyle(context);
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: "Sağlık kısıtları listesi",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Uyarı almak istediğiniz konuları seçin. Hiçbiri yoksa boş bırakabilirsiniz.",
            style: bodyStyle,
          ),
          const SizedBox(height: 16),
          // Profil Ayarları Kartı
          _buildProfileCard(context, theme, bodyStyle),
          const SizedBox(height: 24),
          // Ses Ayarları Kartı
          _buildVoiceCard(context, theme, bodyStyle),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ThemeData theme,
      TextStyle? bodyStyle) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Profil Ayarları",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildRestrictionItems(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCard(BuildContext context, ThemeData theme,
      TextStyle? bodyStyle) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  "Ses Ayarları",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.selected.contains(DietaryRestriction.other))
              _buildCustomRestrictionInput(context, theme),
            if (widget.selected.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Herhangi bir seçim yapmadınız.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRestrictionItems(BuildContext context, ThemeData theme) {
    return DietaryRestriction.values
        .where((r) => r != DietaryRestriction.other)
        .map((r) {
      final isOn = widget.selected.contains(r);
      final isListening = _listeningFor == r.name;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          toggled: isOn,
          label: "${r.displayNameTr}. ${r.hintTr}",
          child: GestureDetector(
            onTap: () => _toggle(r, !isOn),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOn
                    ? theme.colorScheme.primary.withAlpha(102) // 40% opacity
                    : Colors.transparent,
                border: Border.all(
                  color: isOn
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  width: isOn ? 3 : 2,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(128),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForRestriction(r.iconName),
                    color: isOn
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.displayNameTr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isOn ? FontWeight.bold : FontWeight.w500,
                            color: isOn
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.hintTr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isOn)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                  const SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: "${r.displayNameTr} için sesli seçim butonu",
                    hint: isListening ? "Dinleniyor" : "Mikrofon ile seç",
                    child: IconButton(
                      icon: Icon(
                        isListening ? Icons.stop : Icons.mic,
                        color: isListening
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                      onPressed: isListening
                          ? null
                          : () => _listenForRestriction(r),
                      tooltip: "Sesli seçim",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCustomRestrictionInput(
      BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          textField: true,
          label: "Diğer özel kısıtlamalar metin alanı",
          hint: "Virgülle ayırarak özel sağlık koşullarınızı yazın",
          child: TextField(
            controller: _customController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Diğer özel kısıtlamalarınız",
              hintText: "Örn: Hipertansiyon, Astım, Böbrek hastalığı",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
            onChanged: (value) {
              final customs = value
                  .split(",")
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              widget.onCustomRestrictionsChanged?.call(customs);
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Semantics(
            button: true,
            label: "Özel kısıt sesle ekle butonu",
            hint: _listeningFor == "custom" ? "Dinleniyor" : "Mikrofon ile özel kısıt ekle",
            child: ElevatedButton.icon(
              onPressed: _listeningFor == "custom"
                  ? null
                  : _listenForCustom,
              icon: Icon(_listeningFor == "custom" ? Icons.stop : Icons.mic),
              label: Text(
                _listeningFor == "custom"
                    ? "Dinleniyor..."
                    : "Sesle ekle",
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForRestriction(String iconName) {
    switch (iconName) {
      case "favorite":
        return Icons.favorite;
      case "grain":
        return Icons.grain;
      case "leaf":
        return Icons.eco;
      case "local_drink":
        return Icons.local_drink;
      default:
        return Icons.more_horiz;
    }
  }
}
