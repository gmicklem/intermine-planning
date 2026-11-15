;; Used by gate-im-tables.sh: run as `clojure -M gate-im-tables-depcheck.clj <worktree>`.
;; Fails (exit 1) if
;;  - the runtime dependencies of deps.edn (:deps) and project.clj (:dependencies) differ in
;;    coordinates or versions. project.clj is allowed to list MORE only in three ways:
;;      org.clojure/clojure and org.clojure/clojurescript (deps.edn leaves them to the consumer)
;;      cljsjs/*  (deps.edn builds get the same libraries from npm; see package.json and shim/)
;;      day8.re-frame/test, once it has moved to the :kaocha profile (checked below)
;;  - day8.re-frame/test in the project.clj :kaocha profile differs from deps.edn :test alias
;;  - the project.clj version differs from the VERSION file.
(require '[clojure.edn :as edn] '[clojure.java.io :as io] '[clojure.string :as str])
(let [wt    (first *command-line-args*)
      dedn  (edn/read-string (slurp (io/file wt "deps.edn")))
      deps  (:deps dedn)
      form  (with-open [r (java.io.PushbackReader. (io/reader (io/file wt "project.clj")))]
              (read r))
      proj  (apply hash-map (drop 3 form))
      norm  (fn [sym] (if (namespace sym) sym (symbol (name sym) (name sym))))
      skip? (fn [n] (or (#{'org.clojure/clojure 'org.clojure/clojurescript} n)
                        (= "cljsjs" (namespace n))))
      from-lein (into {} (for [[n v] (:dependencies proj) :let [n (norm n)] :when (not (skip? n))] [n v]))
      from-deps (into {} (for [[n m] deps] [(norm n) (:mvn/version m)]))
      kaocha    (into {} (for [[n v] (get-in proj [:profiles :kaocha :dependencies])] [(norm n) v]))
      test-tool 'day8.re-frame/test
      from-test (get-in dedn [:aliases :test :extra-deps test-tool :mvn/version])
      fail (fn [& msg] (apply println msg) (System/exit 1))]
  (let [v (str/trim (slurp (io/file wt "VERSION")))]
    (when (not= v (nth form 2))
      (fail (str "VERSION mismatch: VERSION file " v ", project.clj " (nth form 2)))))
  (when (not= (get kaocha test-tool) from-test)
    (fail (str "test dependency mismatch: project.clj :kaocha has " (get kaocha test-tool)
               ", deps.edn :test has " from-test)))
  (if (= from-lein from-deps)
    (println (str "deps.edn and project.clj agree on " (count from-deps)
                  " runtime dependencies (cljsjs/*, clojure, clojurescript excluded)"))
    (fail "DEPENDENCY MISMATCH\n  only/different in project.clj:"
          (pr-str (into {} (remove (fn [[k v]] (= v (from-deps k))) from-lein)))
          "\n  only/different in deps.edn:   "
          (pr-str (into {} (remove (fn [[k v]] (= v (from-lein k))) from-deps))))))
