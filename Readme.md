# Implementasi Pipeline ETL dan Dashboard Visualisasi: Data Pendidikan Sekolah Dasar (SD) di Indonesia

---

## 📝 INTRODUCTION  
Proyek ini berfokus pada pengolahan dan analisis data pendidikan dasar di Indonesia yang mencakup berbagai aspek penting terkait kondisi sekolah dasar di setiap provinsi. Dengan memanfaatkan data tahun 2024 dari seluruh wilayah di Indonesia, proyek ini bertujuan membangun pipeline ETL yang terkontainerisasi untuk mengekstrak, mengolah, dan mengintegrasikan data secara sistematis. Pendekatan ini tidak hanya meningkatkan efisiensi pengelolaan data, tetapi juga memberikan wawasan mendalam yang dapat mendukung perencanaan dan evaluasi kebijakan pendidikan secara lebih akurat dan tepat sasaran.

---

## 📊 BUSINESS UNDERSTANDING  

### 🎯 Tujuan Proyek  
- Membangun pipeline ETL tercontainerisasi untuk mengintegrasikan dan mengolah data pendidikan dasar di Indonesia secara efisien dan terstruktur.  
- Menghasilkan dashboard visualisasi interaktif yang memudahkan pemantauan kondisi sekolah dasar dan tenaga pendidik di tingkat provinsi.  
- Mendukung pengambilan keputusan berbasis data oleh pemangku kepentingan pendidikan, seperti dinas pendidikan, pemerintah daerah, dan lembaga terkait.

### 🔑 Manfaat Proyek  
- Mempercepat proses pengolahan data pendidikan dasar yang sebelumnya manual dan terfragmentasi.  
- Memberikan gambaran komprehensif tentang kondisi sekolah dan tenaga pendidik di seluruh provinsi.  
- Memfasilitasi analisis tren dan perencanaan strategis berbasis data yang akurat dan up-to-date.

---

## 📂 DATA UNDERSTANDING  

| Dataset | Deskripsi Singkat | Variabel Utama |
|---------|-------------------|----------------|
| Gambaran Umum Keadaan Sekolah Dasar Tiap Provinsi | Data kondisi sekolah dasar, termasuk jumlah sekolah, siswa, kepala sekolah dan guru, tenaga pendidik, rombongan belajar, dan ruang kelas. | provinsi, jumlah_sekolah, jumlah_siswa, jumlah_siswa_mengulang, jumlah_siswa_putus_sekolah, jumlah_kepsek_guru, jumlah_tendik, jumlah_rombel, jumlah_ruang_kelas, status |
| Jumlah Kepala Sekolah dan Guru Menurut Golongan Tiap Provinsi | Data jumlah kepala sekolah dan guru berdasarkan golongan kepegawaian (PNS golongan II, III, IV, non-PNS). | provinsi, pns_gol_ii, pns_gol_iii, pns_gol_iv, pns, non_pns, jumlah_pns_non_pns, status |
| Jumlah Kepala Sekolah dan Guru Menurut Jenis Kelamin dan Ijazah Tertinggi Tiap Provinsi | Data distribusi kepala sekolah dan guru berdasarkan jenis kelamin dan tingkat pendidikan tertinggi (non-S1 dan S1 ke atas). | provinsi, lelaki_non_s1, lelaki_s1_keatas, jumlah_lelaki, pr_non_s1, pr_s1_keatas, jumlah_pr, jumlah_non_s1, jumlah_s1_keatas, jumlah_lk_pr, status |
| Jumlah Kepala Sekolah dan Guru Menurut Masa Kerja Tiap Provinsi | Data jumlah kepala sekolah dan guru berdasarkan masa kerja (0-4 tahun, 5-9 tahun, dst.). | provinsi, mk_0_4, mk_5_9, mk_10_14, mk_15_19, mk_20_24, mk_25_keatas, jumlah_kepsek_guru, status |

---

## 🗂️ ETL PIPELINE & SCHEMA DIAGRAM  
Proyek ini menggunakan pipeline ETL yang terdiri dari beberapa tahap utama: Extracting, Transforming, dan Loading data. Setiap tahap dijalankan secara tercontainerisasi untuk memastikan modularitas, skalabilitas, dan kemudahan pemeliharaan.

[[ETL Schema Diagram.png](https://github.com/alvinmhabieb/Rubythalib_Data_Engineering_Minibootcamp/blob/main/ETL%20Schema%20Diagram.png)]

---

## 🐳 DOCKER CONTAINERIZATION  

Untuk menjalankan basis data PostgreSQL yang digunakan dalam proyek ini secara tercontainerisasi, Anda dapat menggunakan perintah Docker berikut:

```bash
docker run -d \
  --name postgres-container \
  -e POSTGRES_USER="POSTGRES_USER" \
  -e POSTGRES_PASSWORD="POSTGRES_PASSWORD" \
  -e POSTGRES_DB="POSTGRES_DB" \
  -p 5432:5432 \
  postgres:latest


## 📥 EXTRACTING DATA  
Proses ekstraksi data dilakukan melalui empat pipeline ETL paralel yang mengambil data mentah dari berbagai file CSV terkait pendidikan dasar di Indonesia tahun 2024. Setiap pipeline bertugas mengekstrak, membersihkan, dan memuat data ke dalam tabel basis data yang telah didefinisikan dengan skema terstruktur menggunakan skrip SQL, seperti tabel `data_sd.gambaran_umum` untuk data sekolah dan siswa, serta tabel `data_sd.kg_golongan`, `data_sd.kg_jk_ijazah`, dan `data_sd.kg_masa_kerja` untuk data kepegawaian kepala sekolah dan guru berdasarkan golongan, jenis kelamin, ijazah, dan masa kerja. Pendekatan ini memastikan data yang diolah bersih, terstruktur, dan siap untuk tahap transformasi. Proses ETL di Pentaho ada pada file etl_data_sd.ktr (https://github.com/alvinmhabieb/Rubythalib_Data_Engineering_Minibootcamp/blob/main/etl_data_sd.ktr)
---

## 🔄 TRANSFORMING DATA  
Pada tahap transformasi, berbagai dataset yang telah diekstrak dari sumber berbeda digabungkan menjadi satu tabel utama bernama `data_sd_indonesia`. Proses ini dilakukan dengan melakukan join antar tabel berdasarkan kolom `provinsi` dan `status` untuk menyatukan informasi dari gambaran umum sekolah, golongan kepegawaian, jenis kelamin dan ijazah, serta masa kerja kepala sekolah dan guru. Selanjutnya, dilakukan pembersihan data seperti penghapusan prefix "Prov. " pada nama provinsi dan normalisasi nama provinsi seperti mengubah "D.K.I. Jakarta" menjadi "DKI Jakarta" dan "D.I. Yogyakarta" menjadi "DI Yogyakarta". Kolom status juga diperbarui untuk menyamakan format penulisan menjadi "Negeri", "Swasta", atau "Lainnya". Selain itu, dilakukan agregasi data untuk membuat status gabungan yang mengkombinasikan data dari status negeri dan swasta, sehingga menghasilkan ringkasan data yang lebih komprehensif per provinsi. Script terkait proses ETL di SQL ada pada file etl_data_sd.sql(https://github.com/alvinmhabieb/Rubythalib_Data_Engineering_Minibootcamp/blob/main/etl_data_sd.sql)


---

## 💾 LOADING DATA  
Setelah proses transformasi selesai, data yang sudah bersih dan terstruktur dimuat ke dalam tabel `data_sd.data_sd_indonesia` di basis data. Tabel ini berfungsi sebagai sumber data utama yang siap digunakan untuk analisis dan visualisasi lebih lanjut. Proses loading ini meliputi pembuatan tabel baru dengan skema lengkap yang menggabungkan semua atribut penting dari berbagai sumber data, serta memasukkan data hasil transformasi dan agregasi ke dalam tabel tersebut. Dengan demikian, data yang dimuat sudah siap untuk tahap analitik dan pembuatan dashboard visualisasi yang akan memberikan insight mendalam mengenai kondisi pendidikan dasar di Indonesia.

---

## 📊 DEVELOPING DASHBOARD  
Dashboard interaktif dikembangkan menggunakan Tableau Public untuk memvisualisasikan data pendidikan dasar di Indonesia secara komprehensif. Dashboard ini memudahkan pemangku kepentingan dalam memantau kondisi sekolah dan tenaga pendidik di setiap provinsi secara real-time dan interaktif.

**Link Tableau Dashboard:**  
[Dashboard Pendidikan SD di Indonesia Tahun 2024](https://public.tableau.com/app/profile/alvinmhabieb/viz/PendidikanSDdiIndonesiaTahun2024/Dashboard1)
