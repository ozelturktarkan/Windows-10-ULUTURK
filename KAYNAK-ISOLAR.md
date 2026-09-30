# Kaynak ISO doğrulaması — 1 Ekim 2026

Bu kayıt, özelleştirmeden önceki iki Windows ISO'suna aittir. Son ERTÜRK/ULUTÜRK ISO özetleri ayrı `HASHES.txt` dosyalarındadır.

| Kaynak | Sonuç |
| --- | --- |
| Windows 10 22H2 Türkçe x64 **v1** | Yerel SHA-256, [Microsoft'un resmî tablosundaki](https://www.microsoft.com/tr-tr/software-download/windows10ISO/) **Türkçe 64 bit** değeriyle birebir eşleşti. |
| Windows 10 1909 Türkçe x64 | Boyut, SHA-1 ve MD5 [Archive metaverisiyle](https://archive.org/metadata/win-10-1909-turkish-x-64) eşleşti. Bu dosya için erişilebilir resmî Microsoft referansı bulunamadığından **Microsoft özgünlüğü bağımsız doğrulanmış değildir**. |

İki yerel dosyanın tamamı okunarak SHA-256, SHA-1 ve MD5 hesaplandı; SHA-256 ayrıca PowerShell `Get-FileHash` ile aynı çıktı. Hesaplama sırasında dosya boyutu/değişiklik zamanı değişmedi. ISO içindeki `sources/install.wim` ayrıca okunup üretimin kayıtlı kaynak WIM'iyle SHA-256 üzerinden eşleştirildi. [Makine tarafından okunabilir rapor](KAYNAK-ISOLAR.json).

## ULUTÜRK: Windows 10 22H2

**Dosya:** `Win10_22H2_Turkish_x64v1.iso` — **5.765.529.600 bayt**.

```text
SHA-256 f66ad547fb42f9d37dc8e86214e1e326e515aa20843f734c7f8f947e967bee53
SHA-1   7ee135543dda5b30e77b489fe541e75a3ee02ac6
MD5     43cca3dd6eb05cac2cbfa2bea494e7de
```

[Microsoft indirme/doğrulama sayfası](https://www.microsoft.com/tr-tr/software-download/windows10ISO/) üretimde kullanılan v1 dosyasının resmî SHA-256 referansını sağlar. Kontrol edilen başlık Windows 10 2023 Güncelleştirmesi / 22H2'dir. İndirdiğiniz dosyayı yukarıdaki değerle karşılaştırın; sonraki medya revizyonları farklı olabilir.

Proje sahibinin verdiği [Archive 22H2 bağlantısı](https://archive.org/details/windows-10-2022-update-turkish-x64) **aynı ISO değildir**: orada `Win10_22H2_Turkish_x64.iso`, 4.553.572.352 bayt, SHA-1 `e5e95058681181ba0ee7607cc89225297f4fe724` ve MD5 `90a3b443eafaf569cb03710120cfae62` listelenir. Bu bağlantı farklı medya referansı olarak korunur; v1'in birebir indirme kaynağı veya yeniden üretim girdisi diye sunulmaz. Fark tek başına zararlı değişiklik kanıtı değildir.

ISO'daki `install.wim`: 4.804.079.948 bayt; SHA-256 `e6ffc9f6908956a5572fade7b13d4a70b123449b5cf042a301b6fe86d69dd8b0`. ULUTÜRK üretimindeki temiz kaynak WIM ile eşleşti.

## ERTÜRK: Windows 10 1909

[Sahibin bildirdiği indirme sayfası](https://archive.org/details/win-10-1909-turkish-x-64) · [Doğrudan ISO](https://archive.org/download/win-10-1909-turkish-x-64/Win10_1909_Turkish_x64.iso)

**Dosya:** `Win10_1909_Turkish_x64.iso` — **5.239.048.192 bayt**.

```text
SHA-256 957ca7887c596027762a395be12699ce541b38c6de990435fdd607849803e0aa
SHA-1   7b7afabcf751855c0b5aab40106ade9a98242e5f
MD5     8155a8cf62ee3a62f0e4328792781949
```

SHA-256 yerel dosyadan hesaplanmıştır; burada resmî Microsoft değeri diye gösterilmez. Boyut/SHA-1/MD5 Archive metaverisiyle eşleşir. Archive dosyası bu denetimde baştan indirilmedi. Bu eşleşme, bağımsız Microsoft doğrulamasının yerine geçmez; kaynak bu sınırla paylaşılır.

ISO'daki `install.wim`: 4.390.834.000 bayt; SHA-256 `d100034418028a3d6ddd01aacfd90fe5a1ae1253381b53062b8557ea7f13a1e9`. ERTÜRK üretimindeki kayıtlı kaynak WIM ile eşleşti.

## Kendiniz hesaplayın

PowerShell'de ISO'ların bulunduğu klasörde çalıştırın. Dosyalar yalnız okunur:

```powershell
$isoFiles = 'Win10_22H2_Turkish_x64v1.iso', 'Win10_1909_Turkish_x64.iso'
foreach ($isoFile in $isoFiles) {
    foreach ($algorithm in 'SHA256', 'SHA1', 'MD5') {
        Get-FileHash -LiteralPath $isoFile -Algorithm $algorithm
    }
}
```

SHA-256 esas karşılaştırmadır; SHA-1/MD5 eski kayıtlarla uyum için verilir. Microsoft kaynak ISO eşleşmesi, özelleştirilmiş son ISO'nun, dock'un veya diğer üçüncü taraf dosyaların güvenlik onayı değildir. Kaldırılan bileşenler, güncelleme/güvenlik tercihleri ve test sınırları README'de açıklanır.
