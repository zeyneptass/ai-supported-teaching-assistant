@echo off
chcp 65001 > nul
echo ==========================================
echo Akilli Ders Asistani - Docker Baslatici
echo ==========================================

echo Docker servisleri (MongoDB, n8n) baslatiliyor...
docker compose up -d
if errorlevel 1 (
  echo Docker servisleri baslatilamadi.
  pause
  exit /b 1
)

docker compose ps
pause