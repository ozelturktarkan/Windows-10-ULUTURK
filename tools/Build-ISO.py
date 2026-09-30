"""Assemble the generic ULUTURK installer from a prepared source and reviewed overlay.
Requires Python 3 and pycdlib. No VM disk or profile is read.
"""
from pathlib import Path
import argparse,io,json,hashlib,sys
p=argparse.ArgumentParser();p.add_argument('--source',required=True);p.add_argument('--overlay',required=True);p.add_argument('--output',required=True);p.add_argument('--report',required=True);p.add_argument('--python-libs');a=p.parse_args()
if a.python_libs:sys.path.insert(0,a.python_libs)
import pycdlib
source=Path(a.source).resolve();overlay=Path(a.overlay).resolve();out=Path(a.output).resolve();report=Path(a.report).resolve()
assert not out.exists(),'Existing ISO protected'
assert (source/'sources'/'install.wim').is_file() and (overlay/'autounattend.xml').is_file()
dock_manifest=json.loads((Path(__file__).resolve().parents[1]/'Dock-Bilgisi.json').read_text('utf-8'))
dock_base=overlay/'sources/$OEM$/$1/ProgramData/ULUTURK/Dock'
for rel,expected in dock_manifest['files'].items():
 f=(dock_base/rel).resolve()
 if not f.is_relative_to(dock_base.resolve()) or not f.is_file():
  raise SystemExit('Missing dock input; run Import-MyDock.py first: '+rel)
 with f.open('rb') as stream:actual=hashlib.file_digest(stream,'sha256').hexdigest()
 if actual!=expected:raise SystemExit('Dock input hash mismatch: '+rel)
excluded=[];files={}
for base in [source,overlay]:
 for f in base.rglob('*'):
  assert not f.is_symlink(),'Symlinks not allowed'
  if not f.is_file():continue
  rel=f.relative_to(base).as_posix()
  if base==source and ('/$OEM$/' in '/'+rel or rel=='autounattend.xml' or rel=='ULUTURK-MEDIA.json' or rel.startswith('ULUTURK-EkPaketler/')):continue
  if base==source and '/' not in rel and (rel.lower().endswith('.log') or rel.lower().endswith('.xml')):
   excluded.append(rel);continue
  files[rel]=f
assert len(files)>100
for rel in files:
 low=rel.lower()
 assert not any(x in low for x in ['guest-password','autotest','cpu-nt.ps1','loadjob.exe','ntuser.dat','vboxguestadditions','vboxpostinstall','private/'])
def digest(path):
 with path.open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
print('Files checked; hashing prepared WIM.',flush=True)
wimhash=digest(source/'sources'/'install.wim')
iso=pycdlib.PyCdlib();iso.new(interchange_level=3,udf='2.60',vol_ident='WINDOWS_10_ULUTURK')
dirs=set()
for rel in files:
 parent=Path(rel).parent
 while str(parent)!='.':dirs.add(parent.as_posix());parent=parent.parent
for d in sorted(dirs,key=lambda x:(x.count('/'),x)):iso.add_directory(udf_path='/'+d)
boot={'boot/etfsboot.com':'/ETFSBOOT.COM;1','efi/microsoft/boot/efisys.bin':'/EFISYS.BIN;1'}
found=set()
for rel,f in sorted(files.items()):
 kw={'udf_path':'/'+rel}
 if rel.lower() in boot:kw['iso_path']=boot[rel.lower()];found.add(rel.lower())
 iso.add_file(str(f),**kw)
assert found==set(boot)
iso.add_eltorito('/ETFSBOOT.COM;1',bootcatfile='/BOOT.CAT;1',boot_load_size=8,platform_id=0)
iso.add_eltorito('/EFISYS.BIN;1',boot_load_size=None,platform_id=0xef,efi=True)
print('Writing Windows 10 ULUTÜRK ISO.',flush=True)
iso.write(str(out));iso.close()
print('Verifying ISO directory and overlay bytes.',flush=True)
iso=pycdlib.PyCdlib();iso.open(str(out))
paths={d.rstrip('/')+'/'+f for d,ds,fs in iso.walk(udf_path='/') for f in fs}
assert paths=={'/'+r for r in files}|{'/boot.cat'}
assert iso.eltorito_boot_catalog is not None
hashes={}
for rel,f in files.items():
 if f.is_relative_to(overlay):
  b=io.BytesIO();iso.get_file_from_iso_fp(b,udf_path='/'+rel);assert b.getvalue()==f.read_bytes();hashes[rel]=hashlib.sha256(b.getvalue()).hexdigest()
iso.close()
summaries={name:hashlib.new(name) for name in ['sha256','sha1','md5']}
with out.open('rb') as stream:
 while block:=stream.read(8*1024*1024):
  for digestor in summaries.values():digestor.update(block)
summary={name:h.hexdigest() for name,h in summaries.items()}
result={'name':'Windows 10 ULUTÜRK','iso':str(out),'bytes':out.stat().st_size,'sha256':summary['sha256'],'sha1':summary['sha1'],'md5':summary['md5'],'source_wim_sha256':wimhash,'files':len(files),'overlay_sha256':hashes,'excluded_build_logs':excluded,'boot_catalog':'BIOS and x64 EFI','not_vm_capture':True,'fresh_install_test':'pending'}
report.write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
out.with_suffix('.iso.sha256').write_text(result['sha256']+' *'+out.name+'\n',encoding='utf-8')
out.with_name('HASHES.txt').write_text(''.join(name.upper()+' '+value+' *'+out.name+'\n' for name,value in summary.items()),encoding='utf-8')
print(json.dumps(result,ensure_ascii=False),flush=True)
