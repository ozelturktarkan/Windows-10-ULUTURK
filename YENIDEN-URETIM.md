# ULUTÜRK'ü yeniden hazırlama

Bu betikler kurulum medyası içindir; günlük kullanılan Windows'ta doğrudan çalıştırmayın. XML, Medya-Eki ve üçüncü taraf dock girdileri birlikte gerekir. Test VM'sinin diski ISO'ya yakalanmadı.

1. [Microsoft 22H2 sayfasından](https://www.microsoft.com/tr-tr/software-download/windows10ISO/) `Win10_22H2_Turkish_x64v1.iso` kaynağını sağlayın, SHA-256 `f66ad547fb42f9d37dc8e86214e1e326e515aa20843f734c7f8f947e967bee53` eşleşmesini doğrulayıp ayrı bir çalışma klasörüne açın. İndirme kaynağı ve özetlerin kapsamı KAYNAK-ISOLAR.md içinde. Üretimdeki temiz WIM 19045.2965 ve Pro indeksi 4'tü; kendi medyanızda sürüm/Pro indeksini doğrulayın. Farklı revizyonla aynı çıktı hash'i beklemeyin.
2. NTLite'ta Pro x64 imajına `NTLite-ULUTURK-Uygulanan.xml` ayarlarını uygulayın ve yalnız Pro içeren `install.wim` olarak kaydedip boşaltın. Üretimde NTLite 2026.09.12209.0 kullanıldı. Ücretli seçenekler için uygun NTLite lisansı gerekir. NTLite programı/lisansı bu depoda yoktur.
3. **MyDock 5.10.1 arşivini ayrı sağlayın.** Üretimde kullanılan ZIP SHA-256: `b69019974aafadea527111285bf1cb8bec9b45f513bee371fdd324d8d84e023f`. Güncel MyDockFinder paketi aynı dosya değildir. Bu girdiye sahip değilseniz yayımlanan dock'lu ISO'yu eksiksiz yeniden hazırlayamazsınız. EXE/DLL/font/VC dosyaları ve beklenen özetleri Dock-Bilgisi.json içinde listelenir. Dil dosyaları repodan alınır.
4. Python 3.11+ ile aşağıdaki örneği çalıştırın. D: yollarını kendi çalışma yollarınızla değiştirin; çıktı klasörünü oluşturun.

```powershell
py -3 -m pip install -r requirements.txt
py -3 tools/Import-MyDock.py --archive "D:\MyDockFinder.zip" --overlay "Medya-Eki"
py -3 tools/Build-ISO.py --source "D:\ULUTURK-HAZIR-MEDYA" --overlay "Medya-Eki" --output "D:\CIKTI\Windows 10 ULUTÜRK.iso" --report "D:\CIKTI\ISO-Uretim.json"
```

Import aracı yalnız dosyaları doğrular/kopyalar; programları çalıştırmaz. Yanlış ZIP veya hash farkında durur; Türkçe INI'leri eski İngilizce/Çince dosyalarla değiştirmez. Arşivdeki yardımcı DOCX/sorun giderici yüklenmez. Medya-Eki betikleri kurulumda VC çalışma zamanlarını ve kullanıcı dock başlangıcını hazırlar.

Build aracı mevcut çıktı üzerine yazmaz; BIOS ve x64 EFI kayıtları, OEM eki, tema, imleç, arka plan ve yanıt dosyasıyla ISO oluşturur. Kişisel ürün anahtarı, hesap/parola veya disk silme ayarı içermez. Genel Pro kurulum anahtarı etkinleştirme sağlamaz.

Yayımlanan işlenmiş WIM SHA-256: `745f315be4ae091b5555e62afb5e1fc593b1bf91c56feea32ea3dab3e8623576`. WIM-Dogrulama.json bu WIM'in üretim kaydıdır; başka bir WIM'i otomatik olarak onaylamaz. Hash aynıysa ek ISO denetimi:

```powershell
py -3 tools/Verify-ISO.py --report "D:\CIKTI\ISO-Uretim.json" --wim-report "WIM-Dogrulama.json"
```

Hash farklıysa kendi imajınızı ayrıca inceleyin; testi geçirtmek için rapor değerlerini değiştirmeyin. Yeni ISO'yu temiz VM'de kurarak Store, temel uygulamalar, ses, arama, dock, görev çubuğu geri dönüşü ve yeniden başlatmayı kontrol edin. Bağımsız ortamda bayt bayt aynı ISO üretimi doğrulanmadı; zaman damgaları, kaynak ve araç sürümü çıktıyı etkileyebilir.
