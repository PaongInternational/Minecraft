#!/bin/bash
# XipserCloud Setup Script for Termux
# Skrip ini menginstal semua dependensi dan melakukan konfigurasi file server.

# --- Konfigurasi Server ---
SERVER_FOLDER="XipserCloud_Server"
SERVER_JAR="paper.jar"
MINECRAFT_VERSION="1.20.4"
NGROK_TOKEN="33RKXoLi8mLMccvpJbo1LoN3fCg_4AEGykdpBZeXx2TFHaCQj"
MINECRAFT_PORT=25565

echo "=========================================================="
echo "          [SETUP] XipserCloud Server Installation         "
echo "=========================================================="

# 1. Instalasi Dependensi Dasar & Termux:API
echo "[1/6] Memperbarui paket Termux dan menginstal Java 17, Ngrok, jq, dan Termux-API..."
pkg update -y
pkg install openjdk-17 wget screen ngrok jq termux-api -y

# 2. Konfigurasi Ngrok
echo "[2/6] Mengkonfigurasi Ngrok..."
ngrok authtoken $NGROK_TOKEN
echo "Ngrok telah berhasil diautentikasi."

# 3. Penyiapan Folder dan Download JAR
echo "[3/6] Mengunduh server PaperMC $MINECRAFT_VERSION..."
cd $SERVER_FOLDER

PAPER_BUILD="514"
PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/$MINECRAFT_VERSION/builds/$PAPER_BUILD/downloads/paper-$MINECRAFT_VERSION-$PAPER_BUILD.jar"

if [ ! -f "$SERVER_JAR" ]; then
    echo "Mengunduh file server PaperMC..."
    wget -O $SERVER_JAR "$PAPER_URL"
fi

# 4. EULA, Konfigurasi Awal, dan Plugin
echo "[4/6] Menerima EULA dan menjalankan server sebentar untuk menghasilkan konfigurasi..."
echo "eula=true" > eula.txt

# Jalankan sebentar untuk menghasilkan server.properties dan folder plugins/
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

# 5. Instalasi Plugin (GriefPrevention)
echo "[5/6] Menginstal plugin GriefPrevention..."
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
    sed -i 's/GiveManualClaimToolOnFirstLogin: false/GiveManualClaimToolOnFirstLogin: true/' $GP_CONFIG
fi
echo "Plugin GriefPrevention dikonfigurasi agar Golden Shovel otomatis diberikan."

# 6. Verifikasi File Peluncuran
echo "[6/6] Memverifikasi skrip start.sh dan monitor.sh..."
if [ ! -f "start.sh" ]; then
    echo "ERROR: start.sh hilang dari folder. Pastikan Git clone berhasil."
    exit 1
fi
if [ ! -f "monitor.sh" ]; then
    echo "ERROR: monitor.sh hilang dari folder. Pastikan Git clone berhasil."
    exit 1
fi

cd ..

echo "=========================================================="
echo "          ✅ PENYIAPAN SELESAI! (XipserCloud)             "
echo "=========================================================="
echo "Lanjut ke README.md Langkah 3: Edit admin_database.txt, lalu jalankan server."
