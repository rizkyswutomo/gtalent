// ==============================================================================
// INNOTALENT CORPORATE LMS - SUPABASE CLIENT CONFIGURATION
// Talent & Organization Development (TOD) Corporate Learning Hub
// ==============================================================================
// Masukkan kredensial dari dashboard Supabase Anda:
// Supabase Dashboard -> Project Settings -> API -> Project URL & Project API Keys (anon public)
// ==============================================================================

window.SUPABASE_CONFIG = {
  // Ganti URL ini dengan Project URL Supabase Anda (contoh: https://xyzcompany.supabase.co)
  url: "https://jvthmnuhoyysmttdedae.supabase.co/rest/v1/",

  // Ganti Anon Key ini dengan Project API Key 'anon' (public) Anda
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp2dGhtbnVob3l5c210dGRlZGFlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzMjY2MTUsImV4cCI6MjEwNjkwMjYxNX0.TjR0P9KmkayTtz3HFIu0q_zkqwFw6sbusoSQbMPzy7s"
};

// Inisialisasi Klien Supabase jika library telah dimuat
if (typeof supabase !== 'undefined' && window.SUPABASE_CONFIG.url !== "https://jvthmnuhoyysmttdedae.supabase.co/rest/v1/") {
  try {
    window.sbClient = supabase.createClient(window.SUPABASE_CONFIG.url, window.SUPABASE_CONFIG.anonKey);
    console.log("✓ Berhasil terhubung ke Supabase Database.");
  } catch (err) {
    console.error("Gagal inisialisasi Supabase client:", err);
    window.sbClient = null;
  }
} else {
  window.sbClient = null;
}
