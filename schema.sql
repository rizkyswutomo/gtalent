-- ==============================================================================
-- INNOTALENT CORPORATE LMS - SUPABASE POSTGRESQL SCHEMA & INITIAL DATA
-- Dirancang oleh: Manager Talent & Organization Development (TOD) & Lead Engineer
-- Eksekusi skrip ini di SQL Editor Supabase Anda untuk inisialisasi tabel otomatis
-- ==============================================================================

-- 1. TABEL PROFIL PENGGUNA & ROLE KARYAWAN
CREATE TABLE IF NOT EXISTS public.users_profile (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- PIN / Password akun
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'learner' CHECK (role IN ('learner', 'manager', 'tod_admin')),
    department TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABEL ROADMAP KURIKULUM 3 TINGKAT (BASIC, INTERMEDIATE, ADVANCED)
CREATE TABLE IF NOT EXISTS public.roadmap_kurikulum (
    id TEXT PRIMARY KEY,
    level TEXT NOT NULL CHECK (level IN ('Basic', 'Intermediate', 'Advanced')),
    urutan INT NOT NULL,
    course_id TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    content_type TEXT NOT NULL CHECK (content_type IN ('slides', 'video', 'article')),
    embed_url TEXT,
    is_mandatory BOOLEAN DEFAULT TRUE,
    passing_score INT DEFAULT 80,
    target_competency TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. TABEL BANK SOAL (PRE-TEST & POST-TEST)
CREATE TABLE IF NOT EXISTS public.bank_soal (
    id TEXT PRIMARY KEY,
    course_id TEXT NOT NULL REFERENCES public.roadmap_kurikulum(course_id) ON DELETE CASCADE,
    tipe_ujian TEXT NOT NULL CHECK (tipe_ujian IN ('pre_test', 'post_test')),
    pertanyaan TEXT NOT NULL,
    opsi_a TEXT NOT NULL,
    opsi_b TEXT NOT NULL,
    opsi_c TEXT NOT NULL,
    opsi_d TEXT NOT NULL,
    kunci_jawaban CHAR(1) NOT NULL CHECK (kunci_jawaban IN ('A', 'B', 'C', 'D')),
    pembahasan_tod TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. TABEL REKAPITULASI HASIL EVALUASI & KELULUSAN KUIS
CREATE TABLE IF NOT EXISTS public.rekap_hasil_kuis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_email TEXT NOT NULL,
    user_name TEXT NOT NULL,
    course_id TEXT NOT NULL,
    course_title TEXT NOT NULL,
    pre_score INT NOT NULL,
    post_score INT NOT NULL,
    delta_gain TEXT NOT NULL,
    is_passed BOOLEAN NOT NULL,
    cert_id TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AKTIFKAN ROW LEVEL SECURITY (RLS) DENGAN KEBIJAKAN AKSES CEPAT
ALTER TABLE public.users_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roadmap_kurikulum ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_soal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rekap_hasil_kuis ENABLE ROW LEVEL SECURITY;

-- Kebijakan Akses Baca & Tulis Terbuka untuk API Frontend (Public Anon)
CREATE POLICY "Allow public read users" ON public.users_profile FOR SELECT USING (true);
CREATE POLICY "Allow public insert users" ON public.users_profile FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update users" ON public.users_profile FOR UPDATE USING (true);

CREATE POLICY "Allow public all roadmap" ON public.roadmap_kurikulum FOR ALL USING (true);
CREATE POLICY "Allow public all bank_soal" ON public.bank_soal FOR ALL USING (true);
CREATE POLICY "Allow public all rekap_hasil" ON public.rekap_hasil_kuis FOR ALL USING (true);

-- ==============================================================================
-- INITIAL SEED DATA (DATA AWAL ROADMAP & SOAL)
-- ==============================================================================

-- 1. Insert Akun Admin TOD Utama & Akun Karyawan
INSERT INTO public.users_profile (email, password_hash, name, role, department)
VALUES 
    ('admin@innotalent.com', 'admin123', 'Amanda Putri, S.Psi, M.M.', 'tod_admin', 'Talent & Org Development'),
    ('budi.santoso@innotalent.com', '123456', 'Budi Santoso', 'learner', 'Software Engineering')
ON CONFLICT (email) DO NOTHING;

-- 2. Insert Roadmap Kurikulum 3 Tingkat
INSERT INTO public.roadmap_kurikulum (id, level, urutan, course_id, title, content_type, embed_url, is_mandatory, passing_score, target_competency)
VALUES
    -- LEVEL 1: BASIC
    ('R_BSC_01', 'Basic', 1, 'c1', 'Induksi Nilai Budaya 4C & Profil Perusahaan', 'slides', 'https://docs.google.com/presentation/d/e/2PACX-1vR2VfC7t4B3X1X8Y2y_EXAMPLE/embed?start=false&loop=false&delayms=3000', true, 80, 'Internalisasi Visi Misi, Budaya Kerja 4C & Nilai Inti'),
    ('R_BSC_02', 'Basic', 2, 'c2', 'Protokol Keamanan Informasi & Anti-Phishing (InfoSec 101)', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', true, 80, 'Perlindungan Aset Data Rahasia & Kesadaran Siber'),
    -- LEVEL 2: INTERMEDIATE
    ('R_INT_01', 'Intermediate', 1, 'c3', 'Structured Problem Solving & Root Cause Analysis (5-Whys)', 'slides', 'https://docs.google.com/presentation/d/e/2PACX-1vTghU-LMS_Sample_Slides/embed?start=false&loop=false&delayms=3000', true, 80, 'Kemampuan Analisis Akar Masalah Kerja & Solusi Nyata'),
    ('R_INT_02', 'Intermediate', 2, 'c4', 'Basic Warehouse & Workshop Management', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', false, 80, 'Standar Pengelolaan Bengkel Kerja & Pergudangan Modern'),
    -- LEVEL 3: ADVANCED
    ('R_ADV_01', 'Advanced', 1, 'c5', 'Leadership Acceleration: Coaching & Feedback SBI', 'slides', 'https://docs.google.com/presentation/d/e/2PACX-1vR2VfC7t4B3X1X8Y2y_EXAMPLE/embed?start=false&loop=false&delayms=3000', true, 80, 'Teknik 1-on-1 Coaching, GROW Model & SBI Feedback'),
    ('R_ADV_02', 'Advanced', 2, 'c6', 'Strategic Thinking & Execution Excellence', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', false, 80, 'Penyelarasan KPI, Manajemen Risiko & Sasaran Strategis')
ON CONFLICT (course_id) DO NOTHING;

-- 3. Insert Bank Soal
INSERT INTO public.bank_soal (id, course_id, tipe_ujian, pertanyaan, opsi_a, opsi_b, opsi_c, opsi_d, kunci_jawaban, pembahasan_tod)
VALUES
    ('q_c1_pre_1', 'c1', 'pre_test', 'Sebelum mengikuti induksi, apa fokus Continuous Learning?', 'Menghafal SOP', 'Belajar saat disuruh HR', 'Mengembangkan diri setiap hari & belajar dari kesalahan', 'Tidak perlu belajar', 'C', 'Mentalitas berkembang.'),
    ('q_c1_post_1', 'c1', 'post_test', 'Tindakan yang mencerminkan Customer Centricity:', 'Kenyamanan divisi sendiri', 'Menjadikan kepuasan mitra sebagai kompas inovasi', 'Menolak kritik', 'Membuat produk tanpa diskusi', 'B', 'Solusi bernilai tinggi bagi mitra.')
ON CONFLICT (id) DO NOTHING;
