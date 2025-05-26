-- Cek schema data_sd
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name = 'data_sd';

-- Cek tabel-tabel di schema data_sd
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'data_sd';


CREATE TABLE data_sd.gambaran_umum
(
  provinsi VARCHAR(31)
, jumlah_sekolah BIGINT
, jumlah_siswa BIGINT
, jumlah_siswa_mengulang BIGINT
, jumlah_siswa_putus_sekolah BIGINT
, jumlah_kepsek_guru BIGINT
, jumlah_tendik BIGINT
, jumlah_rombel BIGINT
, jumlah_ruang_kelas BIGINT
, status VARCHAR(6)
)
;

CREATE TABLE data_sd.kg_golongan
(
  provinsi VARCHAR(31)
, pns_gol_ii BIGINT
, pns_gol_iii BIGINT
, pns_gol_iv BIGINT
, pns BIGINT
, non_pns BIGINT
, jumlah_pns_non_pns BIGINT
, status VARCHAR(6)
)
;

CREATE TABLE data_sd.kg_jk_ijazah
(
  provinsi VARCHAR(31)
, lelaki_non_s1 BIGINT
, lelaki_s1_keatas BIGINT
, jumlah_lelaki BIGINT
, pr_non_s1 BIGINT
, pr_s1_keatas BIGINT
, jumlah_pr BIGINT
, jumlah_non_s1 BIGINT
, jumlah_s1_keatas BIGINT
, jumlah_lk_pr BIGINT
, status VARCHAR(6)
)
;

CREATE TABLE data_sd.kg_masa_kerja
(
  provinsi VARCHAR(31)
, mk_0_4 BIGINT
, mk_5_9 BIGINT
, mk_10_14 BIGINT
, mk_15_19 BIGINT
, mk_20_24 BIGINT
, mk_25_keatas BIGINT
, jumlah_kepsek_guru BIGINT
, status VARCHAR(6)
)
;


-- Join merge all data in to data_sd_indonesia
CREATE TABLE data_sd.data_sd_indonesia AS
SELECT
    gu.provinsi,
    gu.status,
    gu.jumlah_sekolah,
    gu.jumlah_siswa,
    gu.jumlah_siswa_mengulang,
    gu.jumlah_siswa_putus_sekolah,
    gu.jumlah_kepsek_guru,
    gu.jumlah_tendik,
    gu.jumlah_rombel,
    gu.jumlah_ruang_kelas,

    kg.pns_gol_ii,
    kg.pns_gol_iii,
    kg.pns_gol_iv,
    kg.pns,
    kg.non_pns,
    kg.jumlah_pns_non_pns,

    jk.lelaki_non_s1,
    jk.lelaki_s1_keatas,
    jk.jumlah_lelaki,
    jk.pr_non_s1,
    jk.pr_s1_keatas,
    jk.jumlah_pr,
    jk.jumlah_non_s1,
    jk.jumlah_s1_keatas,
    jk.jumlah_lk_pr,

    mk.mk_0_4,
    mk.mk_5_9,
    mk.mk_10_14,
    mk.mk_15_19,
    mk.mk_20_24,
    mk.mk_25_keatas

FROM data_sd.gambaran_umum gu
INNER JOIN data_sd.kg_golongan kg
    ON gu.provinsi = kg.provinsi AND gu.status = kg.status
INNER JOIN data_sd.kg_jk_ijazah jk
    ON gu.provinsi = jk.provinsi AND gu.status = jk.status
INNER JOIN data_sd.kg_masa_kerja mk
    ON gu.provinsi = mk.provinsi AND gu.status = mk.status;

-- 1. Menghapus prefix 'Prov. ' dari nilai provinsi
UPDATE data_sd.data_sd_indonesia
SET provinsi = TRIM(SUBSTRING(provinsi FROM 6))  -- Mengambil substring mulai karakter ke-6 (setelah 'Prov. ')
WHERE provinsi LIKE 'Prov. %';

-- 2. Mengubah 'D.K.I. Jakarta' menjadi 'DKI Jakarta'
UPDATE data_sd.data_sd_indonesia
SET provinsi = 'DKI Jakarta'
WHERE provinsi = 'D.K.I. Jakarta';

-- 3. Mengubah 'D.I. Yogyakarta' menjadi 'DI Yogyakarta'
UPDATE data_sd.data_sd_indonesia
SET provinsi = 'DI Yogyakarta'
WHERE provinsi = 'D.I. Yogyakarta';


-- 1. Tambahkan kolom status jika belum ada
ALTER TABLE data_sd.data_sd_indonesia
ALTER COLUMN status TYPE VARCHAR(20);

-- 2. Update kolom status berdasarkan kolom status sekolah
UPDATE data_sd.data_sd_indonesia
SET status = CASE
    WHEN status ILIKE 'negeri' THEN 'Negeri'
    WHEN status ILIKE 'swasta' THEN 'Swasta'
    ELSE 'Lainnya'
END;

WITH agregat_gabungan AS (
    SELECT
        provinsi,
        'Gabungan' AS status,
        SUM(jumlah_sekolah) AS jumlah_sekolah,
        SUM(jumlah_siswa) AS jumlah_siswa,
        SUM(jumlah_siswa_mengulang) AS jumlah_siswa_mengulang,
        SUM(jumlah_siswa_putus_sekolah) AS jumlah_siswa_putus_sekolah,
        SUM(jumlah_kepsek_guru) AS jumlah_kepsek_guru,
        SUM(jumlah_tendik) AS jumlah_tendik,
        SUM(jumlah_rombel) AS jumlah_rombel,
        SUM(jumlah_ruang_kelas) AS jumlah_ruang_kelas,
        SUM(pns_gol_ii) AS pns_gol_ii,
        SUM(pns_gol_iii) AS pns_gol_iii,
        SUM(pns_gol_iv) AS pns_gol_iv,
        SUM(pns) AS pns,
        SUM(non_pns) AS non_pns,
        SUM(jumlah_pns_non_pns) AS jumlah_pns_non_pns,
        SUM(lelaki_non_s1) AS lelaki_non_s1,
        SUM(lelaki_s1_keatas) AS lelaki_s1_keatas,
        SUM(jumlah_lelaki) AS jumlah_lelaki,
        SUM(pr_non_s1) AS pr_non_s1,
        SUM(pr_s1_keatas) AS pr_s1_keatas,
        SUM(jumlah_pr) AS jumlah_pr,
        SUM(jumlah_non_s1) AS jumlah_non_s1,
        SUM(jumlah_s1_keatas) AS jumlah_s1_keatas,
        SUM(jumlah_lk_pr) AS jumlah_lk_pr,
        SUM(mk_0_4) AS mk_0_4,
        SUM(mk_5_9) AS mk_5_9,
        SUM(mk_10_14) AS mk_10_14,
        SUM(mk_15_19) AS mk_15_19,
        SUM(mk_20_24) AS mk_20_24,
        SUM(mk_25_keatas) AS mk_25_keatas
    FROM data_sd.data_sd_indonesia
    WHERE status IN ('Negeri', 'Swasta')
    GROUP BY provinsi
)

INSERT INTO data_sd.data_sd_indonesia (
    provinsi,
    status,
    jumlah_sekolah,
    jumlah_siswa,
    jumlah_siswa_mengulang,
    jumlah_siswa_putus_sekolah,
    jumlah_kepsek_guru,
    jumlah_tendik,
    jumlah_rombel,
    jumlah_ruang_kelas,
    pns_gol_ii,
    pns_gol_iii,
    pns_gol_iv,
    pns,
    non_pns,
    jumlah_pns_non_pns,
    lelaki_non_s1,
    lelaki_s1_keatas,
    jumlah_lelaki,
    pr_non_s1,
    pr_s1_keatas,
    jumlah_pr,
    jumlah_non_s1,
    jumlah_s1_keatas,
    jumlah_lk_pr,
    mk_0_4,
    mk_5_9,
    mk_10_14,
    mk_15_19,
    mk_20_24,
    mk_25_keatas
)
SELECT
    provinsi,
    status,
    jumlah_sekolah,
    jumlah_siswa,
    jumlah_siswa_mengulang,
    jumlah_siswa_putus_sekolah,
    jumlah_kepsek_guru,
    jumlah_tendik,
    jumlah_rombel,
    jumlah_ruang_kelas,
    pns_gol_ii,
    pns_gol_iii,
    pns_gol_iv,
    pns,
    non_pns,
    jumlah_pns_non_pns,
    lelaki_non_s1,
    lelaki_s1_keatas,
    jumlah_lelaki,
    pr_non_s1,
    pr_s1_keatas,
    jumlah_pr,
    jumlah_non_s1,
    jumlah_s1_keatas,
    jumlah_lk_pr,
    mk_0_4,
    mk_5_9,
    mk_10_14,
    mk_15_19,
    mk_20_24,
    mk_25_keatas
FROM agregat_gabungan;