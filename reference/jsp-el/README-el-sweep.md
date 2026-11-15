# ElSweep: find JSP EL expressions that current Tomcat rejects

Tomcat 8.5.100+ and 9.0.x reject Java keywords as EL property names (`widget.class`, `dec.boolean`, `${short ...}`):
"The identifier [class] is not a valid Java identifier as required by section 1.19 of the EL specification".
`ElSweep.java` finds every such expression in a webapp source tree without deploying anything. It extracts each
`${...}` and `#{...}` from `.jsp`, `.jspf`, `.jspx`, `.tag` and `.tagx` files and parses it with Tomcat's own
`jasper-el` (`ExpressionFactoryImpl.createValueExpression`). `/build/` and `/.git/` paths are skipped.

## Run

Needs a JDK (8 or later) and two jars from the Tomcat you care about (its `lib/` directory): `el-api.jar` and `jasper-el.jar`.
From a distribution (`https://archive.apache.org/dist/tomcat/`, the `apache-tomcat-X.Y.Z.tar.gz` file) or from a container:

```bash
mkdir -p /tmp/elsweep/jars /tmp/elsweep/out
for j in el-api jasper-el; do docker cp rdfc2im-ut-mine:/usr/local/tomcat/lib/$j.jar /tmp/elsweep/jars/; done
CP=/tmp/elsweep/jars/el-api.jar:/tmp/elsweep/jars/jasper-el.jar
javac -cp $CP -d /tmp/elsweep/out ElSweep.java
java -cp /tmp/elsweep/out:$CP ElSweep /path/to/mine/webapp/src /path/to/intermine/intermine/webapp/src
```

Pass one or more source directories. Run it from a directory that holds no untrusted `.class` files.
Output is one `BAD file:line expression -> message` line per failing expression, then
`files=N expressions=M failures=K`. The exit status is 1 if there is any failure. Use the jars of the Tomcat version you deploy on,
because the identifier check differs between versions (older 8.5.x releases accept keywords).

## Stub function mapper and the false-positive filter

Taglib functions (`fn:`, `imf:`) are not loaded, so a stub `FunctionMapper` resolves every prefixed function to a one-argument method.
Jasper checks argument counts against that method, so any call with another number of arguments reports
`Function [x] specifies [1] params, but [n] were declared`.
Those messages are the stub's doing, not the JSP's, and `ElSweep` drops them. Parse-time errors, which include the identifier check,
are raised before the arity check, so this filter cannot hide a keyword failure. (About 170 such false positives appear without it on InterMine 5.1.1.)

## Results on InterMine 5.1.1

- `e8035a509e` (release/5.1.1-candidate before the fix): 246 files, 3786 expressions, **10 failures**:
  `widget.jsp:16`, `template.jsp:148`, `historyBagView.jsp:146`, `objectView.jsp:60,66,101`, `tablePageLinks.jsp:14,24,38`, `bio/webapp/.../model/dataSourceShort.jsp:9`.
- With the im-89g.17 fixes (`3e84aebf7a`, the `.class` and keyword fixes from im-jqz.37 / im-jqz.38): 246 files, 3786 expressions, **0 failures**.

Fix pattern: use `imf:className(obj)` / `imf:simpleClassName(obj)` (`WebUtil`, `WEB-INF/functions.tld`) instead of `.class.name`,
and bracket notation (`dec['boolean']`, `pageScope['short']`) for other keywords.
