XipserCloud - Server Minecraft PaperMC + Ngrok (Termux)
Proyek ini menyediakan skrip untuk menyebarkan server Minecraft XipserCloud yang sangat dioptimalkan di lingkungan Termux.
✨ Spesifikasi Inti
| Fitur | Detail |
|---|---|
| RAM Alokasi | 3 GB (3072\text{M}) dengan Aikar's Flags (Anti-Lag). |
| Kualitas Server | View Distance 10, Max Pemain 30. |
| Klaim Wilayah | Plugin GriefPrevention: Pemain otomatis dapat Golden Shovel saat join, alat tidak hilang saat mati. |
| Admin System | Dikelola via admin_database.txt. Status OP permanen saat server diluncurkan. |
| Koneksi | Ngrok (Token sudah terpasang). |
| Keselamatan | Auto-Shutdown Aman jika Baterai 5% atau Waktu Berjalan > 12 Jam. |
🚀 Alur Instalasi (Wajib Diikuti Berurutan)
Ikuti urutan langkah ini dengan tepat di Termux Anda untuk instalasi bebas error.
Langkah 1: Clone Repositori dan Izin Akses
# 1. Instal Git dan paket Termux dasar lainnya
pkg update -y && pkg install git -y

# 2. Clone repositori ini (ganti <URL> dengan URL GitHub Anda)
git clone [https://github.com/URL_REPOSITORI_ANDA/XipserCloud.git](https://github.com/URL_REPOSITORI_ANDA/XipserCloud.git) 

# 3. Masuk ke folder proyek
cd XipserCloud

# 4. Berikan izin eksekusi pada skrip utama
chmod +x setup.sh XipserCloud_Server/start.sh XipserCloud_Server/monitor.sh

Langkah 2: Jalankan Skrip Penyiapan Otomatis
Skrip ini akan menginstal Java 17, Ngrok, Termux:API, mengunduh server PaperMC, dan mengkonfigurasi semua file (termasuk Ngrok token dan server.properties).
./setup.sh

> CATATAN: Skrip ini akan menjalankan server sebentar untuk menghasilkan file konfigurasi. Biarkan proses ini berjalan hingga selesai.
> 
Langkah 3: Konfigurasi Database Admin
Sebelum menjalankan server, daftarkan akun admin Anda di file admin_database.txt.
nano XipserCloud_Server/admin_database.txt

Tambahkan satu username Minecraft per baris. Simpan dan keluar dari nano.
▶️ Menjalankan Server
Setelah langkah instalasi dan konfigurasi selesai, luncurkan server dari folder XipserCloud_Server:
cd XipserCloud_Server
./start.sh

Manajemen Server
 * Matikan Server (Wajib!): Selalu ketik stop di konsol Minecraft untuk mematikan dan menyimpan dunia dengan aman.
 * Akses Konsol: Jika Anda terputus, gunakan screen -r mc untuk kembali ke konsol server.
 * Cek IP Ngrok: Gunakan screen -r ngrok untuk melihat detail IP dan Port yang sedang aktif.
