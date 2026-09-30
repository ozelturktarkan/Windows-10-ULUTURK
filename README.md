# Windows 10 ULUTÜRK

**Türkçe Windows 10 Pro 22H2 · x64 · 19045.2965 · r2 Türkçe dock**

[HAKANLAR dizisinin](https://github.com/ozelturktarkan/Windows-10-11-HAKANLAR-Dizesi) 16 GB+ RAM ve SSD hedefli sürümü. Kurulum testi 4 GB RAM ve 1 sanal işlemciyle yapıldı; 16 GB bir proje hedefidir. Microsoft Store korunur; MyDock 5.10.1, Türkçe arayüz ve otomatik gizlenen Windows görev çubuğu ile gelir.

## İndirmeler

**Son ULUTÜRK ISO'sunun Archive bağlantısı bekleniyor.** Büyük dosyayı proje sahibi yükleyecek. Bu repodaki ve [sürüm sayfasındaki](https://github.com/ozelturktarkan/Windows-10-ULUTURK/releases/tag/v1.0-r2) kaynak ZIP dosyaları Windows kurulum ISO'su değildir.

- [Windows 10 22H2 resmî Microsoft indirme ve SHA-256 tablosu](https://www.microsoft.com/tr-tr/software-download/windows10ISO/) — üretimdeki `x64v1` dosyası bu tabloyla eşleşti.
- [ERTÜRK için Windows 10 1909 Türkçe x64 ISO kaynağı](https://archive.org/details/win-10-1909-turkish-x-64)
- [Kaynak ISO dosya adları, özetleri ve doğrulama kapsamı](KAYNAK-ISOLAR.md)
- [Türk bayrağı imleci](https://github.com/ozelturktarkan/Windows-10-ULUTURK/releases/download/v1.0-r2/turk.ani) · [Arka plan](https://github.com/ozelturktarkan/Windows-10-ULUTURK/releases/download/v1.0-r2/ULUTURK.jpg) · [Türkçe dock dil paketi](https://github.com/ozelturktarkan/Windows-10-ULUTURK/releases/download/v1.0-r2/MyDock-Turkce-Dil-Paketi.zip)

**Kaynak denetimi:** 22H2 v1, Microsoft SHA-256 tablosuyla doğrulandı. Verilen Archive 22H2 bağlantısındaki ISO farklıdır; birebir üretim kaynağı olarak gösterilmez. 1909 yalnız Archive metaverisiyle eşleşti; resmî Microsoft doğrulaması tamamlanamadı. [Tam özetler ve kapsam](KAYNAK-ISOLAR.md).

İmleç ve arka plan için Windows'u yeniden kurmanız gerekmez. [Kullanım](assets/README.md).

<img src="assets/ULUTURK.jpg" alt="Windows 10 ULUTÜRK arka planı" width="720">

## Neler değişti?

- **Store, Store Purchase App, Hesap Makinesi, Fotoğraflar, Ses Kaydedici ve gerekli AppX altyapısı korunur.** Klasik Paint, yerel arama/WSearch, ses, sürücüler, güvenlik duvarı ve mevcut Edge korunur. Firefox eklenmedi.
- Cortana ve Game DVR kapalı; DiagTrack devre dışı. OneDrive ve seçilmiş yerleşik uygulamalar kaldırıldı. Tam liste [uygulanan NTLite XML'inde](NTLite-ULUTURK-Uygulanan.xml).
- **Defender kaldırıldı.** Otomatik Windows Update `NoAutoUpdate=1` ile kapalı; elle bakım/güncelleme altyapısı korunur. Store güncellemesini ayrıca kapatan bir ilke eklenmedi. Bu seçimler güvenlik güncellemelerinin yerini tutmaz.
- Dört Windows efekti açık: yazı yumuşatma, masaüstü simge yazısı gölgesi, menü seçimi solması, pencere gölgesi. Diğer efektler/saydamlık kapalı; [22 kontrolün](Kurulum-Kontrol.json) `true` değeri beklenen ayara uyulduğunu gösterir.
- Türk bayrağı imleci ve ALP ER TUNGA/ERTÜRK ile ortak arka plan; yerleşim **Genişlet**.
- Dock normal kullanıcı hesabında açılır, Windows görev çubuğu otomatik gizlenir. Masaüstündeki **Dock kapat - Windows cubugunu goster** kısayolu geri dönüş sağlar. Üç INI dosyasındaki metinler Türkçe; `name=` alanları English / 简体中文 / Türkçe olarak korunur.
- HPET, çekirdek sınırı, güç planı, SysMain, bellek sıkıştırması, sayfalama dosyası ve performans sayaçlarına hızlandırma müdahalesi yapılmadı. Dock animasyonları Windows efektlerinden ayrıdır.

## Şeffaflık ve yeniden hazırlama

[NTLite XML](NTLite-ULUTURK.xml), kurulum betikleri ve Medya-Eki birlikte kullanılır. XML tek başına kişiselleştirmeleri üretmez. [Adım adım tarif](YENIDEN-URETIM.md).

**Üçüncü taraf dock EXE/DLL/font dosyaları ve VC kurucuları bu GitHub deposunda yoktur.** Gerekli MyDock 5.10.1 arşivinin SHA-256 değeri ve tek tek dosya özetleri [Dock-Bilgisi.json](Dock-Bilgisi.json) içindedir. Aynı arşivi sağlayınca `tools/Import-MyDock.py` doğrulayarak yerleştirir; farklı bir sürüm sessizce kabul edilmez. Üç Türkçe dil dosyası repoda bulunur. Dock kaynağı olarak [geliştiricinin sitesi](https://www.mydockfinder.com/index_en.html) gösterilir; güncel Steam sürümü ile eski 5.10.1 paketinin aynı olduğu söylenmez.

Temiz kaynak ve işlenmiş WIM özetleri [Kaynak-Bilgisi.json](Kaynak-Bilgisi.json) ve [WIM-Dogrulama.json](WIM-Dogrulama.json) içindedir. Bağımsız bir ortamda bayt bayt aynı ISO'yu yeniden üretme testi yapılmadı.

## Test kapsamı

Kullanıcı r1 kurulumu sonrasında uygulamaları deneyip belirgin sorun görmediğini ve dock'un çalıştığını bildirdi. Asistan, kapalı VM diskini **salt okunur** inceledi: profil/ilk oturum tamamlandı, 90 kurulum dosyası ISO'yla eşleşti, dock başlangıç ve görev çubuğu kayıtları, VC kurulumları ve görsel profil doğrulandı. Mağaza ve temel uygulama kayıtları mevcut. [Kurulum raporu](Kurulum-Kontrol.json).

**r2 yalnız üç dock dil dosyasını değiştirir; WIM aynı.** Son ISO'nun içerik/önyükleme denetimleri geçti; r2 ile ikinci Windows kurulumu yapılmadı. [r1–r2 farkı](Onceki-Surum-Farki.json). Asistan uygulamaları yeniden açmadı; kapsamlı donanım, ses dinleme, boşta RAM veya stres testi iddiası yoktur.

Windows kurulum günlüklerinde IBS `0x00000490`, CBS `0x80070002`, OOBE LocalUser Plugin `0x80070490` kayıtları bulunur. Kurulumu ve ULUTÜRK profilini tamamlamayı engellemediler; kök nedenleri kesinleştirilmedi. Günlükler tamamen hatasız diye sunulmaz.

## Son ISO özeti

`Windows 10 ULUTÜRK.iso` — **5.161.299.968 bayt (4,81 GiB)**. Tek Pro indeksi; BIOS ve x64 EFI kayıtları.

```text
SHA-256 069cd731adf5285feb50b4a8bd6d4801d855960324e171d6f94ff2b6b4fa45d8
SHA-1   96735f2b2ed3887797b5bce5cc4df2f80d1e64fc
MD5     713744c6eb3a1d9af3247c7681ae0839
```

```powershell
Get-FileHash -LiteralPath '.\Windows 10 ULUTÜRK.iso' -Algorithm SHA256
```

[HASHES.txt](HASHES.txt) ile karşılaştırın. SHA-256 tercih edilir; eşleşme aynı dosyayı aldığınızı gösterir, zararsızlık sertifikası değildir. Kaynak ISO ile son ULUTÜRK ISO'sunun hashleri farklıdır.

Bu çalışma Microsoft'un resmî sürümü değildir; uygun Windows lisansı gerekir. Etkinleştirme atlatma, özel ürün anahtarı, kayıtlı hesap/parola veya otomatik disk silme yoktur. Genel Pro kurulum anahtarı lisans sağlamaz. Güncel güvenlik desteği veya ESU hakkı/uyumluluğu vaat edilmez. [Lisans notları](LISANS-NOTU.md).

Sorunları sürüm, donanım ve tekrar adımlarıyla [Issues](https://github.com/ozelturktarkan/Windows-10-ULUTURK/issues) bölümüne yazabilirsiniz.
