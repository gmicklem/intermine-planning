#!/usr/bin/env python3
"""GET every .jsp of the deployed webapp directly; classify EL parse/compile failures. Usage: jsp_sweep.py BASE WEBROOT"""
import sys, os, urllib.request, urllib.error, collections
base, root = sys.argv[1].rstrip("/"), sys.argv[2]
res = collections.Counter(); bad = []
for dp, dn, fn in os.walk(root):
    for f in sorted(fn):
        if not f.endswith(".jsp"): continue
        rel = os.path.relpath(os.path.join(dp, f), root)
        if rel.startswith("WEB-INF"): continue
        try:
            r = urllib.request.urlopen(base + "/" + rel, timeout=120); code = r.status; body = r.read().decode("utf-8", "replace")
        except urllib.error.HTTPError as e: code = e.code; body = e.read().decode("utf-8", "replace")
        except Exception as e: code = 0; body = str(e)
        el = ("not a valid Java identifier" in body) or ("Failed to parse the expression" in body) or ("invalid expression" in body)
        res[(code, el)] += 1
        if el: bad.append(rel)
print("per (http code, EL-parse-failure):", dict(res)); print("EL parse failures:", len(bad)); [print("  ", b) for b in bad]
