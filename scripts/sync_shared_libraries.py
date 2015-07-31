import subprocess
import re

readelf = "/home/hobinjk/B2G/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-readelf"

def get_references(library):
  libraries = []
  output = subprocess.check_output([readelf, '-a', 'lib/' + library]);
  library_regex = re.compile('library: \[([^]]+)]')
  for line in output.split('\n'):
    match = library_regex.search(line)
    if match:
      libraries.append(match.group(1))
  return libraries

def exists(path):
  output = subprocess.check_output(['adb', 'shell', 'ls', path])
  if output.strip() == path:
    print path + ' exists'
    return True
  return False

def library_exists(library):
  return exists('/system/lib/' + library)

ensured = set()
def ensure_references(library):
  global ensured
  if library in ensured:
    return
  ensured.add(library)

  refs = get_references(library)
  for ref in refs:
    print 'Forcing sync because you don\'t tell me what to do'
    subprocess.call(['adb', 'push', 'lib/' + ref, '/system/lib/'])
    ensure_references(ref)


print ensure_references('libandroid_runtime.so')
