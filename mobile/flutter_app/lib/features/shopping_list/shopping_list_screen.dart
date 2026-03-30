import "package:flutter/material.dart";

import "../../core/accessibility/es_accessibility.dart";
import "../../core/voice/voice_feedback.dart";
import "data/shopping_list_repository.dart";

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final VoiceFeedback _voice = VoiceFeedback.instance;

  @override
  void initState() {
    super.initState();
    ShoppingListRepository.instance.addListener(_onListChanged);
  }

  @override
  void dispose() {
    ShoppingListRepository.instance.removeListener(_onListChanged);
    super.dispose();
  }

  void _onListChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = esAccessibleBodyStyle(context);
    final items = ShoppingListRepository.instance.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alışveriş Listesi"),
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Liste boş. Ana ekrandan sesli komutla ürün ekleyebilirsiniz.",
                    style: bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return CheckboxListTile(
                    value: item.isCompleted,
                    onChanged: (_) async {
                      await ShoppingListRepository.instance.toggleCompleted(item.id);
                      await _voice.speakInfo(
                        item.isCompleted
                            ? "${item.label} tekrar bekleyenlere alindi."
                            : "${item.label} bulundu olarak isaretlendi.",
                      );
                    },
                    title: Text(item.label),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: IconButton(
                      onPressed: () async {
                        await ShoppingListRepository.instance.removeItem(item.id);
                        await _voice.speakInfo("${item.label} listeden silindi.");
                      },
                      icon: const Icon(Icons.delete_outline),
                      tooltip: "Listeden sil",
                    ),
                  );
                },
              ),
      ),
    );
  }
}
