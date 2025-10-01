#!/bin/bash
# Skrip Monitor Otomatis XipserCloud (Untuk Termux)

# --- Konfigurasi Shutdown ---
MAX_RUNTIME_SECONDS=$((12 * 60 * 60)) # 12 jam
LOW_BATTERY_THRESHOLD=5              # 5 persen
CHECK_INTERVAL_SECONDS=60            # Cek setiap 1 menit
RUNTIME_START=$(date +%s)
SCREEN_SESSION_MC="mc"

function safe_shutdown() {
    local reason=$1
    
    echo "[MONITOR] Memicu shutdown aman: $reason"
    
    # Kirim peringatan ke pemain 
    screen -S $SCREEN_SESSION_MC -X stuff "say §c[SERVER] §4Otomatis mati dalam 60 detik! Karena: $reason. Dunia sedang disimpan...\n"
    sleep 30
    screen -S $SCREEN_SESSION_MC -X stuff "say §c[SERVER] §4Shutdown final dalam 30 detik! Menyimpan dunia...\n"
    sleep 30

    screen -S $SCREEN_SESSION_MC -X stuff "save-all\n"
    sleep 5
    screen -S $SCREEN_SESSION_MC -X stuff "stop\n"
    
    echo "[MONITOR] Server Minecraft telah diperintahkan untuk mati. Mengakhiri monitor."
    exit 0
}

while true; do
    # Periksa apakah sesi mc masih hidup
    if ! screen -list | grep -q ".$SCREEN_SESSION_MC"; then
        echo "[MONITOR] Sesi server 'mc' tidak aktif. Mengakhiri monitor."
        exit 0
    fi
    
    # 1. Cek Waktu Berjalan
    CURRENT_TIME=$(date +%s)
    RUNTIME=$((CURRENT_TIME - RUNTIME_START))
    
    if [ $RUNTIME -ge $MAX_RUNTIME_SECONDS ]; then
        safe_shutdown "Waktu maksimal berjalan (12 jam) telah tercapai"
    fi
    
    # 2. Cek Baterai (Memerlukan termux-api dan jq)
    if command -v termux-battery-status &> /dev/null; then
        BATTERY_INFO=$(termux-battery-status 2>/dev/null)
        BATTERY_PERCENTAGE=$(echo "$BATTERY_INFO" | jq -r '.percentage' 2>/dev/null)
        PLUGGED_STATUS=$(echo "$BATTERY_INFO" | jq -r '.plugged' 2>/dev/null)

        if [ -n "$BATTERY_PERCENTAGE" ] && [ "$BATTERY_PERCENTAGE" -le "$LOW_BATTERY_THRESHOLD" ]; then
             if [ "$PLUGGED_STATUS" == "UNPLUGGED" ] || [ "$PLUGGED_STATUS" == "UNKNOWN" ]; then
                 safe_shutdown "Baterai perangkat hanya tersisa ${LOW_BATTERY_THRESHOLD}%"
             fi
        fi
    fi

    # Tidur sejenak
    sleep $CHECK_INTERVAL_SECONDS
done
