;; Used by gate-imcljs.sh: run as `clojure -M gate-imcljs-depcheck.clj <worktree>`.
;; Fails (exit 1) if the runtime dependencies of deps.edn (:deps) and project.clj
;; (:dependencies, minus clojure and clojurescript, which deps.edn leaves to the consumer)
;; differ in coordinates or versions, or if the project.clj version differs from the VERSION file.
(require '[clojure.edn :as edn] '[clojure.java.io :as io])
(let [wt   (first *command-line-args*)
      deps (:deps (edn/read-string (slurp (io/file wt "deps.edn"))))
      form (with-open [r (java.io.PushbackReader. (io/reader (io/file wt "project.clj")))]
             (read r))
      proj (apply hash-map (drop 3 form))
      norm (fn [sym] (if (namespace sym) sym (symbol (name sym) (name sym))))
      from-lein (into {} (for [[n v] (:dependencies proj)
                               :when (not (#{'org.clojure/clojure 'org.clojure/clojurescript} (norm n)))]
                           [(norm n) v]))
      from-deps (into {} (for [[n m] deps] [(norm n) (:mvn/version m)]))]
  (let [v (clojure.string/trim (slurp (io/file wt "VERSION")))]
    (when (not= v (nth form 2))
      (println (str "VERSION mismatch: VERSION file " v ", project.clj " (nth form 2)))
      (System/exit 1)))
  (if (= from-lein from-deps)
    (println (str "deps.edn and project.clj agree on " (count from-deps) " runtime dependencies"))
    (do (println "DEPENDENCY MISMATCH")
        (println "  only/different in project.clj:" (pr-str (into {} (remove (fn [[k v]] (= v (from-deps k))) from-lein))))
        (println "  only/different in deps.edn:   " (pr-str (into {} (remove (fn [[k v]] (= v (from-lein k))) from-deps))))
        (System/exit 1))))
