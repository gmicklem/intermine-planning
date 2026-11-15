#!/usr/bin/env python3
"""JSP EL checks. Usage: jsp_checks.py BASE"""
import http.client, sys, re, json, urllib.request, urllib.parse, http.cookiejar, urllib.error, uuid
BASE = sys.argv[1].rstrip("/")
def client():
    return urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
def req(op, path, data=None, headers=None, method=None):
    url = path if path.startswith("http") else BASE + path
    r = urllib.request.Request(url, data=data, method=method)
    for k, v in (headers or {}).items(): r.add_header(k, v)
    try:
        resp = op.open(r, timeout=180)
        try: body = resp.read()
        except http.client.IncompleteRead as e: body = e.partial + b"<!-- INCOMPLETE READ -->"
        return resp.status, body.decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8", "replace")
def row(name, code, ok, detail=""): print("| %s | %s | %s | %s |" % (name, code, "PASS" if ok else "FAIL", detail), flush=True)
op = client(); req(op, "/begin.do")
b = "----x" + uuid.uuid4().hex
mp = "".join('--%s\r\nContent-Disposition: form-data; name="%s"\r\n\r\n%s\r\n' % (b, k, v) for k, v in [("username","superuser@intermine.org"),("password","intermine"),("action","Log in"),("returnToString","")]) + "--%s--\r\n" % b
c, t = req(op, "/loginAction.do", mp.encode(), {"Content-Type": "multipart/form-data; boundary=" + b})
row("login superuser", c, "Log out" in t)
# list via web service (token)
tc, tt = req(client(), "/service/user/token?format=json", headers={"Authorization": "Basic " + __import__("base64").b64encode(b"superuser@intermine.org:intermine").decode()})
tok = json.loads(tt).get("token", "")
name = "jqz37chk%d" % (uuid.uuid4().int % 100000)
c, t = req(client(), "/service/lists?name=%s&type=Gene&format=json" % name, b"ABCB1\nABCC2\nABCG2\nCYP2D6\nVKORC1\nTPMT\n", {"Authorization": "Token " + tok, "Content-Type": "text/plain"}, "POST")
row("create list %s" % name, c, '"listSize":' in t, t[:80])
# bagDetails
c, t = req(op, "/bagDetails.do?bagName=" + name)
widgets = len(re.findall(r'class="bootstrap widget"', t))
row("bagDetails.do", c, c == 200 and widgets > 0, "widget divs=%d, size=%d bytes" % (widgets, len(t)))
# the widget scripts (widgetScript.jsp)
row("bagDetails widget script present", c, "widgets" in t.lower() and "enrichment" in t.lower() or "chart" in t.lower() or "table" in t.lower(), "")
# template.do for each template
c, t = req(client(), "/service/templates?format=json"); tmpls = list(json.loads(t)["templates"])
for tn in tmpls:
    c, t = req(op, "/template.do?name=%s&scope=all" % tn)
    row("template.do %s" % tn, c, c == 200 and len(t) > 3000 and "templateAction" in t, "%d bytes" % len(t))
# boolean-constraint rendering: any template/query with boolean? just report
# report page and objectView
c, t = req(client(), "/service/query/results?format=json&query=" + urllib.parse.quote('<query model="genomic" view="Gene.id Gene.symbol" constraintLogic="A"><constraint path="Gene.symbol" op="=" value="CYP2D6" code="A"/></query>'))
gid = json.loads(t)["results"][0][0]
c, t = req(op, "/report.do?id=%s" % gid)
row("report.do?id=%s" % gid, c, c == 200 and "CYP2D6" in t, "%d bytes" % len(t))
c, t = req(op, "/mymine.do?subtab=lists")
row("mymine.do?subtab=lists (historyBagView)", c, c == 200 and name in t, "%d bytes" % len(t))
req(client(), "/service/lists?name=%s&format=json" % name, headers={"Authorization": "Token " + tok}, method="DELETE")
