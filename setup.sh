#!/bin/bash
# XipserCloud Setup Script for Termux
# Menginstal dependensi, mengunduh server, dan mengkonfigurasi semua fitur.

# --- Konfigurasi Server ---
SERVER_FOLDER="XipserCloud_Server"
SERVER_JAR="paper.jar"
MINECRAFT_VERSION="1.20.4"
NGROK_TOKEN="33RKXoLi8mLMccvpJbo1LoN3fCg_4AEGykdpBZeXx2TFHaCQj"
MAX_RAM="3072M" # 3 GB RAM, optimal untuk kualitas tinggi dan 30 pemain
MINECRAFT_PORT=25565

echo "=========================================================="
echo "          [SETUP] XipserCloud Server Installation         "
echo "=========================================================="

# 1. Instalasi Dependensi Dasar & Termux:API (Menambahkan git, jq, dan Java 17)
echo "[1/7] Memperbarui paket Termux dan menginstal Git, Java 17, Ngrok, jq, dan Termux-API..."
# Memastikan semua dependensi ada, termasuk git (walaupun sudah dipakai untuk clone)
pkg update -y
pkg install openjdk-17 wget screen ngrok jq termux-api git -y

# 2. Konfigurasi Ngrok
echo "[2/7] Mengkonfigurasi Ngrok..."
# Ngrok authtoken tidak akan error
ngrok authtoken $NGROK_TOKEN
echo "Ngrok telah berhasil diautentikasi."

# 3. Penyiapan Folder Server
echo "[3/7] Membuat folder server dan mengunduh PaperMC $MINECRAFT_VERSION..."
# Pengecekan agar tidak mengulang download jika folder sudah ada dari git clone
if [ ! -d "$SERVER_FOLDER" ]; then
    mkdir -p $SERVER_FOLDER
fi
cd $SERVER_FOLDER

PAPER_BUILD="514"
PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_BUILD/downloads/paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar"

if [ ! -f "$SERVER_JAR" ]; then
    echo "Mengunduh file server: $SERVER_JAR"
    wget -O $SERVER_JAR "$PAPER_URL"
fi

# 4. EULA dan Konfigurasi Awal
echo "[4/7] Menerima EULA dan menjalankan server sebentar untuk konfigurasi..."
echo "eula=true" > eula.txt

# Jalankan sebentar untuk menghasilkan file konfigurasi (jika belum ada)
if [ ! -f "server.properties" ]; then
    java -Xms128M -Xmx256M -jar $SERVER_JAR --nogui &
    SERVER_PID=$!
    sleep 20
    kill $SERVER_PID
    wait $SERVER_PID 2>/dev/null
fi

# Modifikasi server.properties (Kualitas Tinggi)
echo "Mengatur server.properties: Max Pemain=30, View Distance=10, MOTD=XipserCloud"
sed -i 's/max-players=20/max-players=30/' server.properties
sed -i 's/view-distance=10/view-distance=10/' server.properties
sed -i 's/motd=A Minecraft Server/motd=§l§6XipserCloud §r§f- §aServer Resmi§r/g' server.properties
sed -i 's/online-mode=true/online-mode=false/' server.properties 
echo "Konfigurasi server.properties selesai."

# 5. Manajemen Admin (File Input Admin)
echo "[5/7] Membuat admin_database.txt untuk daftar Operator..."
if [ ! -f "admin_database.txt" ]; then
    cat << EOF_ADMIN > admin_database.txt
# INI ADALAH DATABASE ADMIN XIPSERCLOUD
# Tambahkan username pemain yang ingin dijadikan Operator (Admin) di bawah ini.
# Skrip start.sh akan membaca file ini dan menjalankan perintah /op.
# Contoh: XipserAdmin
# Contoh: PlayerLain
EOF_ADMIN
    echo "admin_database.txt telah dibuat. Silakan edit file ini untuk mendaftarkan admin."
fi

# 6. Menginstal Plugin (GriefPrevention)
echo "[6/7] Menginstal plugin GriefPrevention untuk klaim wilayah permanen..."
mkdir -p plugins

GP_URL="https://dev.bukkit.org/projects/grief-prevention/files/4908920/download"

if [ ! -f "plugins/GriefPrevention.jar" ]; then
    wget -O plugins/GriefPrevention.jar "$GP_URL"
fi

# Konfigurasi GP
if [ ! -d "plugins/GriefPrevention" ]; then
    java -Xms128M -Xmx256M -jar $SERVER_JAR --nogui &
    SERVER_PID=$!
    sleep 20
    kill $SERVER_PID
    wait $SERVER_PID 2>/dev/null
fi

GP_CONFIG="plugins/GriefPrevention/config.yml"
if [ -f "$GP_CONFIG" ]; then
    # Mengaktifkan pemberian alat klaim (Golden Shovel) otomatis saat login pertama
    # Menggunakan \x20 sebagai pengganti spasi jika sed error, tapi spasi biasa harusnya bekerja
    sed -i 's/GiveManualClaimToolOnFirstLogin: false/GiveManualClaimToolOnFirstLogin: true/' $GP_CONFIG
fi

# 7. Membuat Skrip Peluncuran Akhir (start.sh dan monitor.sh)
echo "[7/7] Membuat skrip peluncuran start.sh dan monitor.sh..."

# Membuat monitor.sh (Fungsi Shutdown Otomatis Aman)
cat << 'MONITOR_EOF' > monitor.sh
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
        # Jika server mati sendiri, monitor juga mati
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
             # Hanya shutdown jika tidak sedang di-charge/dicolok
             if [ "$PLUGGED_STATUS" == "UNPLUGGED" ] || [ "$PLUGGED_STATUS" == "UNKNOWN" ]; then
                 safe_shutdown "Baterai perangkat hanya tersisa ${LOW_BATTERY_THRESHOLD}%"
             fi
        fi
    fi

    # Tidur sejenak
    sleep $CHECK_INTERVAL_SECONDS
done
MONITOR_EOF
chmod +x monitor.sh

# Membuat start.sh
cat << EOF > start.sh
#!/bin/bash
# XipserCloud Launch Script (Termux)

SERVER_JAR="paper.jar"
MAX_RAM="$MAX_RAM"
MINECRAFT_PORT=25565

# Aikar's Flags untuk Optimasi Kualitas Tinggi dan GC (Wajib untuk RAM besar)
AIKAR_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+AggressiveOpts -XX:G1HeapRegionSize=16M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedSiteCount=4 -XX:G1MixedSiteRatio=3 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://aikar.co/mcflags.html"

echo "================================================="
echo "           XipserCloud - Server Launcher         "
echo "================================================="
echo "Memulai 3 sesi 'screen': mc, ngrok, monitor."
echo "Menggunakan 3 GB RAM (\$MAX_RAM) dan Optimasi Aikar's Flags..."
echo "-------------------------------------------------"

# Fungsi untuk memproses admin_database.txt dan memberikan status OP
function process_admins() {
    echo "MEMPROSES DATABASE ADMIN..."
    
    if [ -f "admin_database.txt" ]; then
        while IFS= read -r player_name; do
            # Abaikan baris kosong dan komentar
            if [[ -n "\$player_name" && ! "\$player_name" =~ ^# ]]; then
                echo "-> Mengirim perintah OP untuk: \$player_name"
                # Mengirim perintah '/op <username>' ke konsol Minecraft (sesi mc)
                # Ini mengisi ops.json server, membuat status Admin permanen.
                screen -S mc -X stuff "op \$player_name\n"
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
screen -dmS ngrok bash -c "ngrok tcp \$MINECRAFT_PORT --log stdout > ngrok.log"
echo "Memulai Ngrok (Sesi: ngrok)..."
sleep 5

# 2. Memulai Monitor Otomatis
screen -dmS monitor bash -c "./monitor.sh"
echo "Memulai Monitor Otomatis (Sesi: monitor)..."

# 3. Memulai Server Minecraft
echo "Memulai Server PaperMC (Sesi: mc) dengan \$MAX_RAM..."
screen -dmS mc java -Xms512M -Xmx\$MAX_RAM \$AIKAR_FLAGS -jar \$SERVER_JAR --nogui

# 4. Tambahkan Admin (Tunggu 60 detik agar server memuat penuh)
echo "Menunggu 60 detik untuk server memuat agar perintah OP dapat dieksekusi..."
sleep 60
process_admins

echo "-------------------------------------------------"

# 5. Menampilkan IP dan Port Ngrok
echo "Menunggu alamat publik Ngrok..."
NGROK_URL=""
for i in {1..15}; do
    NGROK_URL=\$(grep -o 'tcp://[^[:space:]]*' ngrok.log | tail -1)
    if [ -n "\$NGROK_URL" ]; then
        break
    fi
    sleep 1
done

if [ -z "\$NGROK_URL" ]; then
    echo "  [!] Gagal mendapatkan IP Ngrok. Coba cek manual: screen -r ngrok"
else
    echo "  🌐 Server IP & Port (Bagikan Ini!):"
    echo "  ---> §l\$NGROK_URL"
    echo "  Catatan: Server siap. View Distance 10, 3 GB RAM."
fi

echo "-------------------------------------------------"

# 6. Lampirkan ke konsol server
echo "Melampirkan ke konsol server 'mc'..."
screen -r mc

EOF
chmod +x start.sh
cd ..

echo "=========================================================="
echo "          ✅ PENYIAPAN SELESAI! (XipserCloud)             "
echo "=========================================================="
echo "Silakan edit file 'XipserCloud_Server/admin_database.txt' untuk mendaftarkan OP."
echo "Kemudian, ikuti petunjuk di README.md untuk menjalankan server."
