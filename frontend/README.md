# frontend

Flutter istemcisi, n8n webhook servislerini kullanır. Yerel geliştirmede
n8n adresi `http://localhost:5678` olarak yapılandırılmıştır.

## Ders Notları

Chat ekranındaki **Ders Notları** kısayolu metin girişi veya `.txt` dosyasından
ders notlarını içeri aktarmayı sağlar. Metin UTF-8 olarak çözülür. Özetleme
`POST /webhook/summarize` adresine `title` ve `text` alanlarını gönderir.
Test oluşturma `POST /webhook/generate-quiz` adresine `source_id`, `title` ve
`text` gönderir; henüz özet üretilmediyse uygulama önce özet endpoint'inden
`source_id` alır. Test endpoint'i hata verirse istemci bir kez daha dener.
Her iki istek de mevcut 150 saniyelik HTTP timeout'unu kullanır.

Test yanıtları yalnızca soru metni ve seçenekleri içerir. İstemci doğru cevap
bilgisi beklemez; seçimler test ekranının belleğinde tutulur. Test tamamlandığında
seçimler `POST /webhook/submit-quiz` adresine `quiz_id` ve soru kimlikleri
anahtarlı `answers` nesnesi olarak gönderilir. Sunucudan gelen puan, her
soruya ait doğru/yanlış durumu, doğru cevap ve açıklama sonuçlarda gösterilir.
Yanıt biçimi `quiz_id`, `total_questions`, `correct_count`, `score_percent` ve
`results` dizisindeki `question_id`, `question`, `selected_answer`,
`correct_answer`, `is_correct`, `explanation` alanlarını içerir.
İstemci doğrudan nesne, tek elemanlı liste veya `data`/`body` ile sarılmış JSON
yanıtlarını kabul eder; eksik soru seçeneklerini ve metnini oluşturulan testten
tamamlar, eksik açıklamalar için doğru cevabı belirten varsayılan bir not gösterir.
