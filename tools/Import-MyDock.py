"""Restore separately supplied vendor inputs; never execute archive contents."""
from pathlib import Path
import argparse,hashlib,json,zipfile
p=argparse.ArgumentParser();p.add_argument('--archive',required=True);p.add_argument('--overlay',required=True);a=p.parse_args()
repo=Path(__file__).resolve().parents[1]
info=json.loads((repo/'Dock-Bilgisi.json').read_text('utf-8'))
data=Path(a.archive).read_bytes()
assert hashlib.sha256(data).hexdigest()==info['source_zip_sha256'],'Different MyDock archive; expected 5.10.1 source hash'
base=(Path(a.overlay)/'sources/$OEM$/$1/ProgramData/ULUTURK/Dock').resolve()
with zipfile.ZipFile(a.archive) as z:
 for rel,digest in info['files'].items():
  target=(base/rel).resolve()
  assert target.is_relative_to(base),'Output path outside overlay'
  if rel.startswith('MyDock/lang/'):
   assert target.is_file() and hashlib.sha256(target.read_bytes()).hexdigest()==digest,'Translated INI missing or changed'
   continue
  if rel.endswith('.sha256'):
   payload=(info['files'][rel[:-7]]+'\n').encode('utf-8')
  else:
   archive_name=rel if rel.startswith('MyDock/') else 'MyDock/'+Path(rel).name
   payload=z.read(archive_name)
  assert hashlib.sha256(payload).hexdigest()==digest,rel
  if target.exists():
   assert target.read_bytes()==payload,'Existing modified file protected: '+rel
  else:
   target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(payload)
print('Vendor inputs verified and staged; no programs executed.')
