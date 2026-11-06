@echo off
chcp 65001 > nul
echo ==========================================
echo Akilli Ders Asistani - Docker & AI Baslatici
echo ==========================================

echo [1/2] Docker servisleri (MongoDB, Ollama, n8n) baslatiliyor...
docker compose up -d

echo.
echo [2/2] Ollama qwen2.5:3b modeli calistiriliyor...
echo (Cikmak icin /bye yazabilirsiniz)
echo ------------------------------------------
docker exec -it akilli_ders_ollama ollama run qwen2.5:3b

pause