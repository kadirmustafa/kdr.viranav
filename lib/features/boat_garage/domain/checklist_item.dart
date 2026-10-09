class ChecklistItem {
  final String id;
  final String title;
  final String category; // 'Motor & Mekanik', 'Emniyet & Güvenlik', 'Elektrik & Telsiz', 'Seyir Donanımı'
  final bool isCompleted;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    this.isCompleted = false,
  });

  ChecklistItem copyWith({bool? isCompleted}) {
    return ChecklistItem(
      id: id,
      title: title,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  static List<ChecklistItem> defaultMaritimeChecklist() {
    return const [
      ChecklistItem(
        id: 'c1',
        title: 'Sintine pompası çalışması ve sintine suyu seviyesi kontrolü',
        category: 'Motor & Mekanik',
      ),
      ChecklistItem(
        id: 'c2',
        title: 'Motor yağı, şanzıman yağı ve soğutma sıvısı seviyeleri',
        category: 'Motor & Mekanik',
      ),
      ChecklistItem(
        id: 'c3',
        title: 'Deniz suyu emiş filtresi ve vanaları (Seacocks) açık mı?',
        category: 'Motor & Mekanik',
      ),
      ChecklistItem(
        id: 'c4',
        title: 'VHF Telsiz testi (Kanal 16 & Sahil Güvenlik acil frekansı)',
        category: 'Elektrik & Telsiz',
      ),
      ChecklistItem(
        id: 'c5',
        title: 'Akü voltajları (Servis ve Motor start aküleri > 12.6V)',
        category: 'Elektrik & Telsiz',
      ),
      ChecklistItem(
        id: 'c6',
        title: 'Can yelekleri (Kişi sayısı kadar + yedek tüpler)',
        category: 'Emniyet & Güvenlik',
      ),
      ChecklistItem(
        id: 'c7',
        title: 'Can simidi, at nalı ve ışıklı şamandıra hazır mı?',
        category: 'Emniyet & Güvenlik',
      ),
      ChecklistItem(
        id: 'c8',
        title: 'İşaret fişekleri ve yangın söndürücü son kullanım tarihleri',
        category: 'Emniyet & Güvenlik',
      ),
      ChecklistItem(
        id: 'c9',
        title: 'Navigasyon fenerleri (İskele, Sancak, Pupa, Silyon)',
        category: 'Seyir Donanımı',
      ),
      ChecklistItem(
        id: 'c10',
        title: 'Demir ırgatı, zincir kilidi ve yedek çapa kontrolü',
        category: 'Seyir Donanımı',
      ),
    ];
  }
}
