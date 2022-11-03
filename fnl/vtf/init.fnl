(local {: autoload} (require :core.lib.autoload))
(local fennel (autoload :fennel))

(fn rand [n]
  "Draw a random floating point number between 0 and `n`, where `n` is 1.0 if omitted."
  (* (math.random) (or n 1)))

(fn nil? [x]
  "True if the value is equal to Lua `nil`."
  (= nil x))

(fn number? [x]
  "True if the value is of type 'number'."
  (= :number (type x)))

(fn boolean? [x]
  "True if the value is of type 'boolean'."
  (= :boolean (type x)))

(fn string? [x]
  "True if the value is of type 'string'."
  (= :string (type x)))

(fn table? [x]
  "True if the value is of type 'table'."
  (= :table (type x)))

(fn function? [value]
  "True if the value is of type 'function'."
  (= :function (type value)))

(fn keys [t]
  "Get all keys of a table."
  (let [result []]
    (when t
      (each [k _ (pairs t)]
        (table.insert result k)))
    result))

(fn count [xs]
  (if (table? xs)
      (let [maxn (table.maxn xs)]
        ;; We only count the keys if maxn returns 0.
        (if (= 0 maxn)
            (table.maxn (keys xs))
            maxn))
      (not xs)
      0
      (length xs)))

(fn empty? [xs]
  (= 0 (count xs)))

(fn first [xs]
  (when xs
    (. xs 1)))

(fn second [xs]
  (when xs
    (. xs 2)))

(fn last [xs]
  (when xs
    (. xs (count xs))))

(fn inc [n]
  "Increment n by 1."
  (+ n 1))

(fn dec [n]
  "Decrement n by 1."
  (- n 1))

(fn even? [n]
  (= (% n 2) 0))

(fn odd? [n]
  (not (even? n)))

(fn vals [t]
  "Get all values of a table."
  (let [result []]
    (when t
      (each [_ v (pairs t)]
        (table.insert result v)))
    result))

(fn kv-pairs [t]
  "Get all keys and values of a table zipped up in pairs."
  (let [result []]
    (when t
      (each [k v (pairs t)]
        (table.insert result [k v])))
    result))

(fn run! [f xs]
  "Execute the function (for side effects) for every xs."
  (when xs
    (let [nxs (count xs)]
      (when (> nxs 0)
        (for [i 1 nxs]
          (f (. xs i)))))))

(fn filter [f xs]
  "Filter xs down to a new sequential table containing every value that (f x) returned true for."
  (let [result []]
    (run! (fn [x]
            (when (f x)
              (table.insert result x))) xs)
    result))

(fn map [f xs]
  "p xs to a new sequential table by calling (f x) on each item."
  (let [result []]
    (run! (fn [x]
            (let [mapped (f x)]
              (table.insert result
                            (if (= 0 (select "#" mapped))
                                nil
                                mapped)))) xs)
    result))

(fn map-indexed [f xs]
  "p xs to a new sequential table by calling (f [k v]) on each item. "
  (map f (kv-pairs xs)))

(fn identity [x]
  "Returns what you pass it."
  x)

(fn reduce [f init xs]
  "Reduce xs into a result by passing each subsequent value into the fn with
  the previous value as the first arg. Starting with init."
  (var result init)
  (run! (fn [x]
          (set result (f result x))) xs)
  result)

(fn some [f xs]
  "Return the first truthy result from (f x) or nil."
  (var result nil)
  (var n 1)
  (while (and (nil? result) (<= n (count xs)))
    (let [candidate (f (. xs n))]
      (when candidate
        (set result candidate))
      (set n (inc n))))
  result)

(fn butlast [xs]
  (let [total (count xs)]
    (->> (kv-pairs xs)
         (filter (fn [[n v]]
                   (not= n total)))
         (map second))))

(fn rest [xs]
  (->> (kv-pairs xs)
       (filter (fn [[n v]]
                 (not= n 1)))
       (map second)))

(fn concat [...]
  "Concatenates the sequential table arguments together."
  (let [result []]
    (run! (fn [xs]
            (run! (fn [x]
                    (table.insert result x)) xs)) [...])
    result))

(fn mapcat [f xs]
  (concat (unpack (map f xs))))

(fn pr-str [...]
  (let [s (table.concat (map (fn [x]
                               (fennel.view.serialise x {:one-line true}))
                             [...]) " ")]
    (if (or (nil? s) (= "" s)) :nil s)))

(fn str [...]
  (->> [...]
       (map (fn [s]
              (if (string? s)
                  s
                  (pr-str s))))
       (reduce (fn [acc s]
                 (.. acc s)) "")))

(fn println [...]
  (->> [...]
       (map (fn [s]
              (if (string? s)
                  s
                  (pr-str s))))
       (map-indexed (fn [[i s]]
                      (if (= 1 i)
                          s
                          (.. " " s))))
       (reduce (fn [acc s]
                 (.. acc s)) "")
       print))

(fn pr [...]
  (println (pr-str ...)))

(fn slurp [path silent?]
  "Read the file into a string."
  (match (io.open path :r)
    (nil msg) nil
    f (let [content (f:read :*all)]
        (f:close)
        content)))

(fn spit [path content]
  "Spit the string into the file."
  (match (io.open path :w)
    (nil msg) (error (.. "Could not open file: " msg))
    f (do
        (f:write content)
        (f:flush)
        (f:close)
        nil)))

(fn merge! [base ...]
  (reduce (fn [acc m]
            (when m
              (each [k v (pairs m)]
                (tset acc k v)))
            acc) (or base {}) [...]))

(fn merge [...]
  (merge! {} ...))

(fn select-keys [t ks]
  (if (and t ks)
      (reduce (fn [acc k]
                (when k
                  (tset acc k (. t k)))
                acc) {} ks)
      {}))

(fn get [t k d]
  (let [res (when (table? t)
              (let [val (. t k)]
                (when (not (nil? val))
                  val)))]
    (if (nil? res)
        d
        res)))

(fn get-in [t ks d]
  (let [res (reduce (fn [acc k]
                      (when (table? acc)
                        (get acc k))) t ks)]
    (if (nil? res)
        d
        res)))

(fn assoc [t ...]
  (let [[k v & xs] [...]
        rem (count xs)
        t (or t {})]
    (when (odd? rem)
      (error "assoc expects even number of arguments after table, found odd number"))
    (when (not (nil? k))
      (tset t k v))
    (when (> rem 0)
      (assoc t (unpack xs)))
    t))

(fn assoc-in [t ks v]
  (let [path (butlast ks)
        final (last ks)
        t (or t {})]
    (assoc (reduce (fn [acc k]
                     (let [step (get acc k)]
                       (if (nil? step)
                           (get (assoc acc k {}) k)
                           step))) t path) final v)
    t))

(fn update [t k f]
  (assoc t k (f (get t k))))

(fn update-in [t ks f]
  (assoc-in t ks (f (get-in t ks))))

(fn constantly [v]
  (fn []
    v))

(fn serialise [...]
  (fennel.view ...))

(local M {: spit : slurp : count : reduce : select-keys : keys : vals : pr-str})

(fn M.pecho [ok? ...]
  "nvim_echo vargs, as DiagnosticHint or DiagnosticError depending on ok?"
  (let [{: nvim_echo} vim.api
        {: view} (require :fennel)
        hl (if ok? :DiagnosticHint :DiagnosticError)
        list [...]
        output []]
    ;; TODO: this can be fcollect in fennel 1.2.0)
    (for [i 1 (select "#" ...)]
      (table.insert output (-> (. list i)
                               (#(match (type $1)
                                   :table (view $1)
                                   _ (tostring $1)))
                               (.. "\n"))))
    (nvim_echo (icollect [_ l (ipairs output)]
                 [l hl]) true {})))

(tset M :path (autoload :vtf.path))
(tset M :string (autoload :vtf.string))
(tset M :util (autoload :vtf.util))
(tset M :io (autoload :vtf.io))

M
