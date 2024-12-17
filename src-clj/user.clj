(ns user)

(defn hello-world []
  (println "hello world!")
  "hello world!")

(defn goodbye-world []
  (println "goodbye world!")
  "goodbye world!")

(defn main [& args]
  (println :args args)
  )
