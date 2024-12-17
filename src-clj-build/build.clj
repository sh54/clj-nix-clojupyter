(ns build
  (:require
   [clojure.tools.build.api :as b]
   [clojure.tools.logging :as log]
   [clojure.java.shell :refer [sh]]))

(def class-dir "target/classes")

(defn uberjar
  [{:keys [optimize debug verbose ::jar-name, ::skip-client]
    :or {optimize true, debug false, verbose false, skip-client false}
    :as args}]
  (prn :uberjar args jar-name)
  ; careful, shell quote escaping combines poorly with clj -X arg parsing, strings read as symbols
  (log/info `uberjar (pr-str args))
  (b/delete {:path "target"})

  ;;(b/copy-dir {:target-dir class-dir :src-dirs ["src" "src-prod" "resources"]})
  (b/copy-dir {:target-dir class-dir :src-dirs ["src-clj"]})
  (let [jar-name (or (some-> jar-name str) ; override for Dockerfile builds to avoid needing to reconstruct the name
                   )
        _ (println :jar-name jar-name)
        aliases [:prod]]
    (log/info `uberjar "included aliases:" aliases)
    (b/uber {:class-dir class-dir
             :uber-file jar-name
             :basis     (b/create-basis {:project "deps.edn" :aliases aliases})})
    (log/info jar-name)))

;; clj -X:build:prod build-client
;; clj -X:build:prod uberjar :build/jar-name "app.jar"
;; java -cp app.jar clojure.main -m prod
