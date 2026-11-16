#!/usr/bin/env python3
"""List every key of the webapp message bundle and where it is used.
usage: msgkeys.py <props-file> <root>... ; prints a table; exit 0.
Used = full key appears (not as part of a longer dotted/word token) in any text file under the
roots (jsp, tag, tld, java, js, xml, html, properties other than the bundle), vendor/build/.git excluded.
Prefix-used = a computed prefix such as "errors.foo." or key="foo.${x}" is present in code and
the key starts with it."""
import os, re, sys, json
props, roots = sys.argv[1], sys.argv[2:]
EXT = {'.jsp','.jspf','.tag','.tagx','.tld','.java','.js','.xml','.html','.htm','.properties','.jspx','.vm','.txt','.json','.md','.css'}
SKIP = {'vendor','build','.git','node_modules','.gate-logs','.gradle'}
keys, order = {}, []
cur = None
lines = open(props, encoding='utf-8', errors='replace').read().split('\n')
i = 0
while i < len(lines):
    l = lines[i]
    if l.strip() and not l.lstrip().startswith(('#','!')):
        m = re.match(r'\s*([^\s=:]+)\s*[=:]?', l)
        if m:
            k = m.group(1)
            keys.setdefault(k, i+1); order.append(k)
        while l.rstrip().endswith('\\') and i+1 < len(lines):
            i += 1; l = lines[i]
    i += 1
# also commented-out keys are ignored on purpose
files = []
pabs = os.path.abspath(props)
for r in roots:
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x not in SKIP]
        for f in fs:
            p = os.path.join(d, f)
            if os.path.abspath(p) == pabs: continue
            if os.path.splitext(f)[1].lower() in EXT:
                files.append(p)
corpus = []
for p in files:
    try:
        corpus.append((p, open(p, encoding='utf-8', errors='replace').read()))
    except Exception: pass
big = '\n'.join(t for _, t in corpus)
# computed prefixes: a quoted/attribute string ending in '.' followed by quote-close with +, or ${..}
prefixes = set()
for m in re.finditer(r'''["']([A-Za-z][\w]*(?:\.[\w]+)*\.)(?:\$\{|["']\s*\+|\#\{|<%=)''', big):
    prefixes.add(m.group(1))
for m in re.finditer(r'''["']([A-Za-z][\w]*(?:\.[\w]+)*\.)["']\s*\+''', big):
    prefixes.add(m.group(1))
tokfiles = {}
tokre = re.compile(r'[A-Za-z_][\w\-]*(?:\.[\w\-]+)*')
for p, t in corpus:
    for tok in set(tokre.findall(t)):
        tokfiles.setdefault(tok, []).append(p)
res = {}
for k in keys:
    where = tokfiles.get(k, [])
    pf = [x for x in prefixes if k.startswith(x) and x.count('.') >= 1]
    res[k] = {'line': keys[k], 'files': where[:3], 'nfiles': len(where), 'prefix': sorted(pf)}
unused = [k for k in keys if res[k]['nfiles'] == 0 and not res[k]['prefix']]
pfonly = [k for k in keys if res[k]['nfiles'] == 0 and res[k]['prefix']]
print('total keys', len(keys), '(%d key lines)' % len(order), 'files scanned', len(files))
print('unused', len(unused), ' prefix-only', len(pfonly))
print('computed prefixes found:', sorted(prefixes))
print('--- UNUSED')
for k in unused: print('%5d %s' % (keys[k], k))
print('--- PREFIX-ONLY (kept)')
for k in pfonly: print('%5d %s  <- %s' % (keys[k], k, ','.join(res[k]['prefix'])))
json.dump(res, open(os.environ.get('MSGKEYS_JSON','/dev/null'),'w'), indent=1)
