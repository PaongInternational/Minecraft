#!/bin/bash
# XipserCloud Launch Script (Termux)
# File ini menjalankan server, Ngrok, monitor, dan memproses admin secara otomatis.

SERVER_JAR="paper.jar"
MAX_RAM="3072M"
MINECRAFT_PORT=25565

# Aikar's Flags untuk Optimasi Kualitas Tinggi dan GC (Wajib untuk RAM besar)
AIKAR_FLAGS="-Xms512M -Xmx$MAX_RAM -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+AggressiveOpts -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedSiteCount=4 -XX:G1MixedSiteRatio=3 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://aikar.co/mcflags.html"

echo "================================================="
echo "           XipserCloud - Server Launcher         "
echo "================================================="
echo "Memulai 3 sesi 'screen': mc, ngrok, monitor."
echo "Menggunakan 3 GB RAM ($MAX_RAM) dan Optimasi Aikar's Flags..."
echo "-------------------------------------------------"

# Fungsi untuk memproses admin_database.txt dan memberikan status OP
function process_admins() {
    echo "MEMPROSES DATABASE ADMIN..."
    
    if [ -f "admin_database.txt" ]; then
        while IFS= read -r player_name; do
            # Abaikan baris kosong dan komentar
            if [[ -n "$player_name" && ! "$player_name" =~ ^# ]]; then
                echo "-> Mengirim perintah OP untuk: $player_name"
                # Mengirim perintah '/op <username>' ke konsol Minecraft (sesi mc)
                screen -S mc -X stuff "op $player_name\n"
                sleep 0.5 
            fi
        done < admin_database.txt
        echo "✅ SEMUA ADMIN DARI DATABASE TELAH DIPROSES. Status OP kini permanen."
    else
        echo "PERINGATAN: admin_database.txt tidak ditemukan. Tidak ada admin yang didaftarkan secara otomatis."
    fi
}

# Membersihkan sesi screen yang mungkin terputus agar tidak ada error
screen -wipe > /dev/null

# 1. Memulai Ngrok 
screen -dmS ngrok bash -c "ngrok tcp $MINECRAFT_PORT --log stdout > ngrok.log"
echo "Memulai Ngrok (Sesi: ngrok)..."
sleep 5

# 2. Memulai Monitor Otomatis
screen -dmS monitor bash -c "./monitor.sh"
echo "Memulai Monitor Otomatis (Sesi: monitor)..."

# 3. Memulai Server Minecraft
echo "Memulai Server PaperMC (Sesi: mc)..."
screen -dmS mc java $AIKAR_FLAGS -jar $SERVER_JAR --nogui

# 4. Tambahkan Admin (Tunggu 60 detik agar server memuat penuh)
echo "Menunggu 60 detik untuk server memuat agar perintah OP dapat dieksekusi..."
sleep 60
process_admins

echo "-------------------------------------------------"

# 5. Menampilkan IP dan Port Ngrok
echo "Menunggu alamat publik Ngrok..."
NGROK_URL=""
for i in {1..15}; do
    NGROK_URL=$(grep -o 'tcp://[^[:space:]]*' ngrok.log | tail -1)
    if [ -n "$NGROK_URL" ]; then
        break
    fi
    sleep 1
done

if [ -z "$NGROK_URL" ]; then
    echo "  [!] Gagal mendapatkan IP Ngrok. Coba cek manual: screen -r ngrok"
else
    echo "  🌐 Server IP & Port (Bagikan Ini!):"
    echo "  ---> §l$NGROK_URL"
    echo "  Catatan: Server siap. Kualitas tinggi diaktifkan."
fi

echo "-------------------------------------------------"

# 6. Lampirkan ke konsol server
echo "Melampirkan ke konsol server 'mc'..."
screen -r mc
