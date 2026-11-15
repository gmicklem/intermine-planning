// bluegenes-runbundle.js - load a compiled BlueGenes bundle in a node vm with
// stub DOM globals and fail on any exception thrown while it loads.
//
// Usage: node bluegenes-runbundle.js [--allow-fail=<file.js>]... <app.js> [<app.js> ...]
//
// Catches load-order bugs that unit tests cannot: top-level defs that read a
// JS global (js/ReactTransitionGroup, js/Select, js/DayPicker, js/hljs) before
// the cljsjs stand-in namespace that sets it has run. Works for the release
// bundle and for a dev build compiled with {:devtools {:loader-mode :eval}}
// (one file). The dev loader catches a failing file and logs "The above error
// occurred when loading <file>" instead of throwing; that also counts as a
// failure unless the file is named with --allow-fail (the re-frame-10x dev
// preload needs a real DOM to render into, so the gate allows that one).
// It does not call bluegenes.core.init: it checks that the bundle
// loads, the four globals exist and init is a function.
// Exit code 0 = loaded OK, 1 = load error or missing global, 2 = usage.
// (Adapted from the im-7os.1 pre-merge reviewer's harness.)
'use strict';
const vm = require('vm'), fs = require('fs');
const args = process.argv.slice(2);
const allowed = args.filter(a => a.startsWith('--allow-fail=')).map(a => a.slice('--allow-fail='.length));
const files = args.filter(a => !a.startsWith('--'));
if (!files.length) { console.error('usage: node bluegenes-runbundle.js [--allow-fail=<file.js>]... <app.js>...'); process.exit(2); }

// A value that absorbs any property access, call or construction.
function deep() {
  const f = function () { return p; };
  const p = new Proxy(f, {
    get: (t, k) => k === Symbol.toPrimitive ? () => '' : k === 'then' ? undefined : p,
    apply: () => p,
    construct: () => p,
  });
  return p;
}

let failed = 0;
for (const file of files) {
  const src = fs.readFileSync(file, 'utf8');
  const loadErrors = [];
  const watch = (orig) => (...args) => {
    const msg = args.map(String).join(' ');
    const m = /error occurred when loading "([^"]*)"/.exec(msg);
    if (m && !allowed.includes(m[1])) loadErrors.push(msg.split('\n')[0]);
    if (m && allowed.includes(m[1])) return; // expected; keep the output short
    orig(...args);
  };
  const quiet = { ...console, log: watch(console.log), warn: watch(console.warn), error: watch(console.error) };
  const ctx = {
    console: quiet, setTimeout, clearTimeout, setInterval, clearInterval,
    document: deep(), navigator: { userAgent: 'node' }, location: deep(),
    localStorage: deep(), serverVars: null, initVars: null,
    XMLHttpRequest: function () {},
    // React 18's react-dom/server reads TextEncoder at load time; every browser has these
    TextEncoder, TextDecoder,
  };
  for (const k of ['DOMParser', 'XMLSerializer', 'Node', 'NodeList', 'NamedNodeMap',
                   'HTMLElement', 'Element', 'Event', 'MutationObserver', 'WebSocket']) ctx[k] = deep();
  ctx.window = ctx; ctx.self = ctx; ctx.globalThis = ctx;
  vm.createContext(ctx);
  try {
    vm.runInContext(src, ctx, { filename: file });
    // React 18 / react-select 5 line: DayPicker and ReactTransitionGroup were removed in im-7os.2
    const missing = ['Select', 'hljs'].filter(g => ctx[g] === undefined);
    const init = ctx.bluegenes && ctx.bluegenes.core && typeof ctx.bluegenes.core.init;
    if (loadErrors.length) {
      console.log(`LOAD ERROR ${file}: ${loadErrors.join('; ')}`);
      failed = 1;
    } else if (missing.length || init !== 'function') {
      console.log(`LOAD INCOMPLETE ${file}: missing globals [${missing.join(',')}], typeof bluegenes.core.init=${init}`);
      failed = 1;
    } else {
      console.log(`LOADED OK ${file} (${src.length} bytes): Select, hljs defined; bluegenes.core.init is a function`);
    }
  } catch (e) {
    console.log(`LOAD ERROR ${file}: ${e.name}: ${e.message} ${(e.stack || '').split('\n')[1] || ''}`);
    failed = 1;
  }
}
process.exit(failed);
