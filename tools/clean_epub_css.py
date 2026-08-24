#!/usr/bin/env python3
"""Strip vendor-prefixed/blocked CSS declarations GPB rejects from EPUB xhtml files."""
import re, shutil, sys, zipfile

src = sys.argv[1]
dst = sys.argv[2] if len(sys.argv) > 2 else src

BAD = re.compile(r'\s*(?:-webkit-text-size-adjust|-webkit-touch-callout'
                 r'|-webkit-user-select|-khtml-user-select'
                 r'|-moz-user-select|-ms-user-select|user-select)\s*:[^;}]*;?')

zin = zipfile.ZipFile(src)
zout = zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED)
removed = 0
for item in zin.infolist():
    data = zin.read(item.filename)
    if item.filename.endswith(('.xhtml', '.html')):
        text = data.decode('utf-8')
        text, n = BAD.subn('', text)
        removed += n
        data = text.encode('utf-8')
    zout.writestr(item, data)
zout.close()
print(f"CLEAN_OK removed={removed}")
