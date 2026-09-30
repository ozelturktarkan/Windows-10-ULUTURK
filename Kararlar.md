# ULUTÜRK üretim kararları

Windows 10 Pro 22H2 x64, 19045.2965 tabanı. Hedef 16 GB+ RAM ve SSD; VM testi 4 GB RAM/1 vCPU ile sınırlı tutuldu. ERTÜRK görsel/hizmet tercihleri aktarılırken Store ve gerekli AppX bağımlılıkları korundu.

NTLite kaldırma listesi uygulanan XML'dedir. Defender kaldırıldı, güvenlik duvarı korundu. Otomatik Windows Update ilkeyle kapalı; elle bakım altyapısı ve Store güncelleme işlevleri kapatılmadı. Yerel arama korundu. Ölçülmemiş HPET/CPU/performance counter değişiklikleri uygulanmadı.

MyDock 5.10.1 kullanıcı tarafından sağlandı. Normal kullanıcı bağlamında LocalAppData kopyası, HKCU Run ve görev çubuğunu geri getiren kısayol kullanılır. Antivirüs istisnası, özel servis veya yönetici zorlaması eklenmedi. Paket EXE'leri imzasız, VC kurucuları üretim sırasında Microsoft imzalı olarak doğrulandı; bu bilgi genel güvenlik garantisi değildir.

Kullanıcının Türkçe çevirisindeki eksik 44 girdi ve Çince kaynakta bulunan 2 uyarı tamamlandı. Üç INI'de name dışında metinler aynıdır. 422 gerekli girdi eksiksiz; 815 toplam girdi, üç dosyada 2445 Windows INI okuma karşılaştırmasıyla denetlendi. Kullanıcı çevirilerinin mevcut değerleri korundu.

Test edilen r1 ile son r2 arasındaki fark üç dil dosyasıdır; WIM aynı. Kullanıcı uygulama testinde belirgin sorun bildirmedi, kapalı disk denetimi geçti. Son ISO tekrar kurulmadı; üç Windows kurulum hata kaydı ve test sınırları README/Kurulum-Kontrol.json içinde açıklanır.

GitHub yayını küçük kaynaklar, dil dosyaları, görseller ve raporlarla sınırlıdır. ISO proje sahibi tarafından ayrıca yüklenecek; dock ikilileri ayrı temin edilerek hazırlanır.
