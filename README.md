XipserCloud - Server Minecraft PaperMC + Ngrok (Termux)
Proyek ini menyediakan skrip untuk menyebarkan server Minecraft XipserCloud yang sangat dioptimalkan di lingkungan Termux.
✨ Fitur dan Spesifikasi Server
| Fitur | Spesifikasi | Keterangan |
|---|---|---|
| RAM Alokasi | 3 GB (3072\text{M}) | Performa sangat stabil untuk View Distance tinggi. |
| Kualitas Grafis | View Distance 10 | Kualitas visual maksimal tanpa lag (berkat Aikar's Flags). |
| Database Admin | admin_database.txt | Sistem OP otomatis dan permanen saat server diluncurkan. |
| Auto Shutdown | 12 Jam atau Baterai 5% | Mati dan menyimpan dunia secara aman. |
🚀 Alur Instalasi (Wajib Diikuti Berurutan)
Ikuti urutan langkah ini dengan tepat di Termux Anda.
Persyaratan Awal
Pastikan Anda memiliki aplikasi Termux dan Termux:API terinstal di perangkat Android Anda.
Langkah 1: Clone Repositori dan Instal Dependensi Dasar
Anda harus menginstal git dan kemudian mengkloning repositori ini.
# Instal Git dan paket Termux dasar lainnya
pkg update -y && pkg install git -y

# Clone repositori Anda (ganti <URL> dengan URL GitHub Anda)
git clone [https://github.com/](https://github.com/)<username>/XipserCloud.git # Contoh URL

# Masuk ke folder proyek yang baru di-clone
cd XipserCloud

# Berikan izin eksekusi pada skrip utama
chmod +x setup.sh start.sh

Langkah 2: Jalankan Skrip Penyiapan Otomatis
Skrip ini akan menginstal Java, Ngrok, Termux-API, mengunduh server PaperMC, mengkonfigurasi 3\text{GB} RAM, dan menyiapkan semua fitur keamanan.
./setup.sh

> CATATAN PENTING: Proses ini akan mengunduh server dan menjalankan server sebentar untuk menghasilkan file konfigurasi.
> 
Langkah 3: Konfigurasi Database Admin
Setelah setup.sh selesai, Anda perlu mendaftarkan akun admin (operator) Anda.
# Masuk ke folder server
cd XipserCloud_Server

# Buka database admin
nano admin_database.txt

Tambahkan satu username Minecraft per baris (nama harus persis). Simpan dan keluar dari nano (Ctrl+X, lalu Y, lalu Enter).
▶️ Menjalankan Server
Setelah Anda berada di folder XipserCloud_Server, luncurkan skrip start.sh:
./start.sh

Skrip ini akan menjalankan Ngrok, Monitor Baterai/Waktu, dan Server Minecraft di sesi screen terpisah, kemudian otomatis mendaftarkan admin dari database Anda, dan terakhir melampirkan (attach) Anda ke konsol server Minecraft.
Informasi Penting
 * Mematikan Server: Selalu gunakan perintah stop di konsol Minecraft untuk mematikan server dengan aman.
 * Mengakses Kembali Konsol: Jika Anda terputus, gunakan screen -r mc untuk kembali ke konsol server.
