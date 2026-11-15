import java.lang.reflect.Method;
import java.nio.file.*;
import java.util.*;
import javax.el.*;
import org.apache.el.ExpressionFactoryImpl;

/** Parses every ${...} / #{...} in .jsp/.jspf/.tag/.tagx/.jspx files with Tomcat's jasper-el. Usage: ElSweep DIR... */
public class ElSweep {
  public static Object stub(Object o) { return null; }

  public static void main(String[] args) throws Exception {
    ExpressionFactory factory = new ExpressionFactoryImpl();
    final Method stub = ElSweep.class.getMethod("stub", Object.class);
    ELContext ctx = new ELContext() {
      public ELResolver getELResolver() { return null; }
      public VariableMapper getVariableMapper() { return null; }
      public FunctionMapper getFunctionMapper() {
        return new FunctionMapper() { public Method resolveFunction(String p, String n) { return stub; } };
      }
    };
    List<Path> files = new ArrayList<>();
    for (String root : args) {
      try (java.util.stream.Stream<Path> s = Files.walk(Paths.get(root))) {
        s.filter(p -> p.toString().matches(".*\\.(jsp|jspf|jspx|tag|tagx)") && !p.toString().contains("/build/")
            && !p.toString().contains("/.git/")).forEach(files::add);
      }
    }
    Collections.sort(files);
    int exprs = 0, bad = 0;
    for (Path p : files) {
      String t = new String(Files.readAllBytes(p), "UTF-8");
      for (int i = 0; ; ) {
        int a = t.indexOf("${", i), b = t.indexOf("#{", i);
        int s = a < 0 ? b : (b < 0 ? a : Math.min(a, b));
        if (s < 0) break;
        int depth = 0, e = -1; char q = 0;
        for (int k = s + 2; k < t.length() && e < 0; k++) {   // matching '}', skipping quoted strings
          char c = t.charAt(k);
          if (q != 0) { if (c == '\\') k++; else if (c == q) q = 0; }
          else if (c == '\'' || c == '"') q = c;
          else if (c == '{') depth++;
          else if (c == '}') { if (depth-- == 0) e = k; }
        }
        if (e < 0) { i = s + 2; continue; }
        String ex = t.substring(s, e + 1);
        exprs++; i = e + 1;
        try { factory.createValueExpression(ctx, ex, Object.class); }
        catch (Throwable x) {
          String m = String.valueOf(x.getMessage()).split("\n")[0];
          if (m.contains("specifies [")) continue;  // false positive: the stub takes 1 arg, real functions differ
          bad++;
          int line = 1; for (int k = 0; k < s; k++) if (t.charAt(k) == '\n') line++;
          System.out.println("BAD " + p + ":" + line + " " + ex.replace('\n', ' ') + "  -> " + m);
        }
      }
    }
    System.out.println("files=" + files.size() + " expressions=" + exprs + " failures=" + bad);
    System.exit(bad == 0 ? 0 : 1);
  }
}
