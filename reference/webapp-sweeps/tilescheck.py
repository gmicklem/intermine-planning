#!/usr/bin/env python3
"""tiles-defs.xml / struts-config.xml consistency: tile path JSP missing, controllerUrl without action,
tile never referenced, action type class missing. usage: tilescheck.py <webapp-src-main-webapp> <repo-root-for-java>..."""
import os, re, sys
W = sys.argv[1]; jr = sys.argv[2:]
tiles = open(W+'/WEB-INF/tiles-defs.xml').read(); struts = open(W+'/WEB-INF/struts-config.xml').read()
java = set()
for r in jr:
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x not in ('build', '.git', 'node_modules')]
        for f in fs:
            if f.endswith('.java'):
                m = re.search(r'(org/.*)\.java$', os.path.join(d, f))
                if m: java.add(m.group(1).replace('/', '.'))
actions = dict(re.findall(r'<action\s+path="([^"]+)"[^>]*?(?:type="([^"]+)")?', struts))
for m in re.finditer(r'<action\s[^>]*>', struts):
    a = m.group(0); p = re.search(r'path="([^"]+)"', a).group(1); t = re.search(r'type="([^"]+)"', a)
    actions[p] = t.group(1) if t else None
allfiles = ''
for d, ds, fs in os.walk(W):
    ds[:] = [x for x in ds if x != 'vendor']
    for f in fs:
        if f.endswith(('.jsp', '.tag', '.xml', '.js')):
            allfiles += open(os.path.join(d, f), encoding='utf-8', errors='replace').read()
for r in jr:
    for d, ds, fs in os.walk(r):
        ds[:] = [x for x in ds if x not in ('build', '.git', 'node_modules', 'vendor')]
        for f in fs:
            if f.endswith(('.java', '.jsp', '.xml')) and 'webapp' in d:
                try: allfiles += open(os.path.join(d, f), encoding='utf-8', errors='replace').read()
                except Exception: pass
print('--- struts actions whose type class does not exist')
for p, t in sorted(actions.items()):
    if t and t.startswith('org.') and t not in java: print(p, t)
print('--- tile definitions: JSP path missing / controllerUrl without action / name never used elsewhere')
for m in re.finditer(r'<definition\s+name="([^"]+)"([^>]*)>', tiles):
    n, rest = m.group(1), m.group(2)
    pm = re.search(r'path="([^"]+)"', rest); cm = re.search(r'controllerUrl="([^"]+)"', rest)
    probs = []
    if pm and not os.path.exists(W + '/' + pm.group(1).lstrip('/')) and not os.path.exists(os.path.join(os.path.dirname(W), pm.group(1).lstrip('/'))): probs.append('jsp missing ' + pm.group(1))
    if cm:
        ap = cm.group(1).replace('.do', '')
        if ap not in actions: probs.append('no action ' + ap)
        elif actions[ap] and actions[ap].startswith('org.') and actions[ap] not in java: probs.append('controller class missing ' + actions[ap])
    uses = len(re.findall(r'["\'>]' + re.escape(n) + r'["\'<]', allfiles))
    if uses <= 1: probs.append('referenced %d time(s) (own definition counts 1)' % uses)
    if probs: print(n, '|', '; '.join(probs))
