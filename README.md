# Akıllı Ders Asistanı (Smart Course Assistant)

Yapay zeka destekli, **Flutter**, **n8n** iş akışları, **Ollama** (yerel LLM - `qwen2.5:3b`) ve **MongoDB** tabanlı uçtan uca akıllı ders ve soru-cevap asistanı.

---

## Proje Yapısı

- `frontend/` — Flutter mobil ve masaüstü arayüzü (`LoginScreen`, `ChatScreen` ve ağ servisleri)
- `screenshots/` — Uygulama arayüzü ve n8n iş akışı ekran görüntüleri
- `ai-supported-teaching-assistant.json` — Dışa aktarılan n8n iş akışı (Webhook → Ollama → MongoDB)
- `docker-compose.yml` — n8n, Ollama ve MongoDB servis yapılandırmaları
- `start-ai.bat` — Docker servislerini ve yerel yapay zeka modelini başlatan otomasyon betiği

---

## Ekran Görüntüleri

### Mobil Arayüz (Flutter)

| Giriş Ekranı | Sohbet & Soru-Cevap Ekranı |
| :---: | :---: |
| <img src="screenshots/LoginScreen.jpeg" width="280" alt="Giriş Ekranı"/> | <img src="screenshots/Soru-CevapScreen.jpeg" width="280" alt="Soru-Cevap Ekranı"/> |

### n8n Otomasyon İş Akışı

![n8n Workflow](screenshots/n8n-workflow.png)

---

## Kurulum ve Çalıştırma

### 1. Altyapı Servislerini Başlatma (Docker)

Proje kök dizininde Docker konteynerlerini (`n8n`, `ollama`, `mongodb`) ayağa kaldırın veya `start-ai.bat` dosyasını çalıştırın:

```bash
docker compose up -d
```

### 2. Flutter Uygulamasını Çalıştırma

```bash
cd frontend
flutter pub get
flutter run
```