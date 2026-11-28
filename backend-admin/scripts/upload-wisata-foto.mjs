import { createClient } from '@supabase/supabase-js';
import { readdir, readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const photoRoot = path.join(root, 'seed', 'foto');
const bucket = 'lokatrip-wisata';
const url = process.env.SUPABASE_URL;
const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !serviceKey) {
  throw new Error('Set SUPABASE_URL dan SUPABASE_SERVICE_ROLE_KEY terlebih dahulu.');
}

const supabase = createClient(url, serviceKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});
const manifest = JSON.parse(
  await readFile(path.join(photoRoot, 'manifest.json'), 'utf8'),
);
const mimeTypes = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
};

for (const [slug, namaWisata] of Object.entries(manifest)) {
  const folder = path.join(photoRoot, slug);
  let entries;
  try {
    entries = await readdir(folder, { withFileTypes: true });
  } catch (error) {
    if (error.code === 'ENOENT') continue;
    throw error;
  }

  const photos = entries
    .filter((entry) => entry.isFile() && /^(\d+)\.(jpg|jpeg|png|webp)$/i.test(entry.name))
    .map((entry) => ({
      name: entry.name,
      order: Number(entry.name.match(/^(\d+)/)[1]),
    }))
    .sort((a, b) => a.order - b.order);
  if (!photos.length) continue;

  const { data: wisata, error: wisataError } = await supabase
    .from('wisata')
    .select('id_wisata')
    .eq('nama_wisata', namaWisata)
    .maybeSingle();
  if (wisataError) throw wisataError;
  if (!wisata) {
    console.warn(`Lewati ${slug}: wisata belum ada (${namaWisata}).`);
    continue;
  }

  for (const photo of photos) {
    const localPath = path.join(folder, photo.name);
    const objectPath = `${slug}/${photo.name}`;
    const bytes = await readFile(localPath);
    const contentType = mimeTypes[path.extname(photo.name).toLowerCase()];
    const { error: uploadError } = await supabase.storage
      .from(bucket)
      .upload(objectPath, bytes, { contentType, upsert: true });
    if (uploadError) throw uploadError;

    const publicUrl = supabase.storage.from(bucket).getPublicUrl(objectPath).data.publicUrl;
    const { data: existing, error: lookupError } = await supabase
      .from('foto_wisata')
      .select('id_foto')
      .eq('id_wisata', wisata.id_wisata)
      .eq('urutan', photo.order)
      .maybeSingle();
    if (lookupError) throw lookupError;

    const write = existing
      ? supabase.from('foto_wisata').update({ url_foto: publicUrl }).eq('id_foto', existing.id_foto)
      : supabase.from('foto_wisata').insert({
          id_wisata: wisata.id_wisata,
          url_foto: publicUrl,
          urutan: photo.order,
        });
    const { error: photoError } = await write;
    if (photoError) throw photoError;
    console.log(`${namaWisata}: ${photo.name} -> urutan ${photo.order}`);
  }
}
