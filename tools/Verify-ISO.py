from pathlib import Path
import sys,json,hashlib,io,argparse
from xml.etree import ElementTree as ET
p=argparse.ArgumentParser();p.add_argument('--report',required=True);p.add_argument('--wim-report',required=True);p.add_argument('--python-libs');a=p.parse_args()
if a.python_libs:sys.path.insert(0,a.python_libs)
import pycdlib
report=Path(a.report);meta=json.loads(report.read_text('utf-8'));wim_checks=json.loads(Path(a.wim_report).read_text('utf-8'))
assert wim_checks['processed_wim_sha256']==meta['source_wim_sha256'] and wim_checks['single_pro_x64']
assert all(wim_checks['file_checks'].values()) and all(wim_checks['protected_applications'].values())
assert all(wim_checks['required_framework_staging_unchanged'].values()) and all(wim_checks['retained_app_and_dependency_manifests_present'].values())
iso=pycdlib.PyCdlib();iso.open(meta['iso'])
class Sink:
 def __init__(self):self.hash=hashlib.sha256();self.count=0
 def write(self,b):self.hash.update(b);self.count+=len(b);return len(b)
 def tell(self):return self.count
try:
 s=Sink();iso.get_file_from_iso_fp(s,udf_path='/sources/install.wim');assert s.hash.hexdigest()==meta['source_wim_sha256']
 paths={d.rstrip('/')+'/'+f for d,ds,fs in iso.walk(udf_path='/') for f in fs}
 for name in ['boot/etfsboot.com','efi/microsoft/boot/efisys.bin','efi/boot/bootx64.efi','sources/boot.wim','sources/sxs/microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab']:
  assert '/'+name in {x.lower() for x in paths},name
 assert not any(x.lower().endswith('.log') and x.count('/')==1 for x in paths)
 b=io.BytesIO();iso.get_file_from_iso_fp(b,udf_path='/autounattend.xml');xml=ET.fromstring(b.getvalue())
 prohibited={'UserAccounts','AutoLogon','DiskConfiguration','ImageInstall','ComputerName'}
 assert not any(e.tag.split('}')[-1] in prohibited for e in xml.iter())
 ns={'u':'urn:schemas-microsoft-com:unattend'}
 product_keys=xml.findall('.//u:ProductKey',ns)
 intended=xml.find("u:settings[@pass='windowsPE']/u:component[@name='Microsoft-Windows-Setup']/u:UserData/u:ProductKey",ns)
 assert len(product_keys)==1 and product_keys[0] is intended
 assert intended.findtext('u:Key',namespaces=ns)=='VK7JG-NPHTM-C97JM-9MPGT-3V66T'
 assert intended.findtext('u:WillShowUI',namespaces=ns)=='Always'
 components=[e for e in xml.iter() if e.tag.split('}')[-1]=='component']
 assert components and all(e.get('processorArchitecture')=='amd64' for e in components)
 cat=iso.eltorito_boot_catalog
 assert cat.validation_entry.platform_id==0 and any(e.platform_id==0xef for e in cat.sections)
 result={'iso_wim_hash_matches_prepared_wim':True,'single_pro_x64':True,'store_packages_preserved':True,'wim_bytes':s.count,'bios_boot_entry':True,'x64_efi_boot_entry':True,'netfx3_source_present':True,'production_answer_no_accounts_or_disk_wipe':True,'only_public_pro_setup_key':True,'product_key_ui':'Always','amd64_answer_components':True,'fresh_install_test':'pending user installation','store_online_test':'pending user installation'}
finally:iso.close()
(report.parent/'Icerik-dogrulama.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8');print(json.dumps(result))
