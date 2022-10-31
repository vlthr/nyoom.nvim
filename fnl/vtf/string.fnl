;; (local vtf (require :vtf))

(fn join [...]
  "(join xs) (join sep xs)
  Joins all items of a table together with an optional separator.
  Separator defaults to an empty string.
  Values that aren't a string or nil will go through aniseed.core/pr-str."
  (let [args [...]
        [sep xs] (if (= 2 (vtf.count args))
                   args
                   ["" (vtf.first args)])
        len (vtf.count xs)]

    (var result [])

    (when (> len 0)
      (for [i 1 len]
        (let [x (. xs i)]
          (-?>> (if
                  (= :string (type x)) x
                  (= nil x) x
                  (vtf.pr-str x))
                (table.insert result)))))

    (table.concat result sep)))

(fn split [s pat]
  "Split the given string into a sequential table using the pattern."
  (var done? false)
  (var acc [])
  (var index 1)
  (while (not done?)
    (let [(start end) (string.find s pat index)]
      (if (= :nil (type start))
        (do
          (table.insert acc (string.sub s index))
          (set done? true))
        (do
          (table.insert acc (string.sub s index (- start 1)))
          (set index (+ end 1))))))
  acc)

(fn blank? [s]
  "Check if the string is nil, empty or only whitespace."
  (or (vtf.empty? s)
      (not (string.find s "[^%s]"))))

(fn escape-pattern [s]
  "creates a lua pattern matching a literal s"
  (let [(escaped _) (string.gsub s "([().%%%+%-*?%[^$%]])" "%%%1")]
    escaped))

(fn strip-suffix [s suffix]
  (string.gsub s (.. (escape-pattern suffix) "$") ""))

(fn strip-prefix [s prefix]
  (string.gsub s (.. (escape-pattern prefix) "$") ""))

(fn triml [s]
  "Removes whitespace from the left side of string."
  (string.gsub s "^%s*(.-)" "%1"))

(fn trimr [s]
  "Removes whitespace from the right side of string."
  (string.gsub s "(.-)%s*$" "%1"))

(fn trim [s]
  "Removes whitespace from both ends of string."
  (string.gsub s "^%s*(.-)%s*$" "%1"))

{: blank?
 : escape-pattern
 : strip-suffix
 : strip-prefix
 : triml
 : trimr
 : trim
 : join
 : split}
