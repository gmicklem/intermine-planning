#!/usr/bin/env python3
"""Dangling class-reference sweep: every org.intermine.* class name in non-Java text files (JSP, tags,
tld, struts/tiles/web/dwr XML, properties) must have a .java file (or be a package prefix / nested class)
in the given source roots. usage: classrefs.py <scan-root>... -- <java-root>..."""
import os, re, sys
a = sys.argv[1:]; i = a.index('--'); scan, jroots = a[:i], a[i+1:]
SKIP = {'vendor','build','.git','node_modules','.gate-logs','.gradle','test','docs'}
java = set(); pkgs = set()
for r in jroots:
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x not in {'build','.git','node_modules'}]
        for f in fs:
            if f.endswith('.java'):
                rel = os.path.relpath(os.path.join(d, f), r)
                m = re.search(r'(?:^|/)(?:src/(?:main|test)/java|src)/(org/.*)\.java$', rel) or re.search(r'(?:^|/)(org/.*)\.java$', rel)
                if m:
                    fq = m.group(1).replace('/', '.'); java.add(fq)
                    parts = fq.split('.')
                    for n in range(1, len(parts)): pkgs.add('.'.join(parts[:n]))
EXT = {'.jsp','.jspf','.tag','.tld','.xml','.properties','.js','.html'}
pat = re.compile(r'\borg\.intermine(?:\.[A-Za-z_]\w*)+')
bad = {}
for r in scan:
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x not in SKIP]
        for f in fs:
            if os.path.splitext(f)[1] not in EXT: continue
            p = os.path.join(d, f)
            try: t = open(p, encoding='utf-8', errors='replace').read()
            except Exception: continue
            for ln, line in enumerate(t.split('\n'), 1):
                for m in pat.finditer(line):
                    n = m.group(0)
                    if n in java or n in pkgs: continue
                    # nested class or member: strip trailing parts
                    parts = n.split('.'); ok = False
                    for k in range(len(parts)-1, 2, -1):
                        if '.'.join(parts[:k]) in java: ok = True; break
                    if not ok and re.search(r'\.(xml|properties|class|jsp|js)$', n): ok = True
                    if not ok: bad.setdefault(n, []).append('%s:%d' % (p, ln))
for n in sorted(bad): print('DANGLING', n, bad[n][:3])
print('dangling names:', len(bad))
