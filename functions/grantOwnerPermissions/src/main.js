import { Client, Databases, Permission, Role } from 'node-appwrite';

/*
  Fungsi ini akan dipicu setiap kali ada dokumen baru di koleksi bookings.
  Payload dari trigger berisi data dokumen yang baru dibuat.
*/
export default async ({ req, res, log, error }) => {
  // Variabel ini diambil dari pengaturan function di Appwrite Console melalui process.env
  const {
    APPWRITE_FUNCTION_ENDPOINT,
    APPWRITE_FUNCTION_API_KEY,
    APPWRITE_FUNCTION_PROJECT_ID,
    OWNER_TEAM_ID,
    DATABASE_ID,
    BOOKINGS_COLLECTION_ID
  } = process.env;

  // Validasi variabel lingkungan
  if (
    !APPWRITE_FUNCTION_ENDPOINT ||
    !APPWRITE_FUNCTION_API_KEY ||
    !APPWRITE_FUNCTION_PROJECT_ID ||
    !OWNER_TEAM_ID ||
    !DATABASE_ID ||
    !BOOKINGS_COLLECTION_ID
  ) {
    error("Kesalahan: Variabel lingkungan tidak lengkap!");
    return res.json({ success: false, message: "Variabel lingkungan tidak lengkap." }, 500);
  }

  const client = new Client()
    .setEndpoint(APPWRITE_FUNCTION_ENDPOINT)
    .setProject(APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(APPWRITE_FUNCTION_API_KEY);

  const databases = new Databases(client);

  try {
    // Data dari trigger event bisa berada di req.bodyRaw atau req.payload.
    // Kita cek keduanya untuk membuat kode lebih tangguh.
    const payloadString = req.bodyRaw || req.payload;

    if (!payloadString || payloadString.trim() === '') {
      throw new Error("Payload (data trigger) kosong. Function mungkin tidak dipicu oleh event pembuatan dokumen.");
    }
    
    const newBooking = JSON.parse(payloadString);
    const documentId = newBooking.$id;
    const currentPermissions = newBooking.$permissions;

    if (!documentId || !currentPermissions) {
        throw new Error("Data payload tidak valid atau tidak berisi $id dan $permissions.");
    }

    log(`Memproses booking baru dengan ID: ${documentId}`);

    // Siapkan izin untuk tim owner
    const ownerPermissions = [
      Permission.read(Role.team(OWNER_TEAM_ID)),
      Permission.update(Role.team(OWNER_TEAM_ID)),
    ];

    // Gabungkan izin yang sudah ada dengan izin baru untuk owner
    const allPermissions = [...new Set([...currentPermissions, ...ownerPermissions])];

    // Update dokumen dengan izin yang baru
    await databases.updateDocument(
      DATABASE_ID,
      BOOKINGS_COLLECTION_ID,
      documentId,
      undefined, // Kita tidak mengubah data, hanya izin
      allPermissions
    );

    log(`Berhasil memperbarui izin untuk dokumen: ${documentId}`);
    return res.json({ success: true, message: "Izin berhasil diperbarui." });

  } catch (err) {
    error(`Terjadi kesalahan saat memproses function: ${err.message}`);
    return res.json({ success: false, message: err.message }, 500);
  }
};