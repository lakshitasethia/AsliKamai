-- Screenshots are saved as <hash>.jpg whatever their real format, and the
-- app sends the type it sniffs from the bytes; anything it can't identify
-- goes up as application/octet-stream rather than failing the backup.
update storage.buckets
set allowed_mime_types = array['application/json', 'application/pdf', 'image/png', 'image/jpeg', 'image/webp', 'application/octet-stream']
where id = 'backups';
