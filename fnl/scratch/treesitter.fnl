;; (include :fnl.macros)
;; (require-macros :macros)
(local hotpot (require :hotpot))
(local hotpot-source (require :hotpot.api.source))
;; (hotpot-source)
(import-macros {: map! : nil? : str? } :macros)
;; (local vtf (require vtf))
;; (hotpot-source)


(local {: autoload} (require :core.lib.autoload))
;; (local treesitter (require :nvim-treesitter))
(local fennel (autoload :fennel))
;; (local query (require :nvim-treesitter.query))
(local hotpot-eval (autoload :hotpot.api.eval))
(local hotpot-compile (autoload :hotpot.api.compile))

(macro dbg! [s]
  ;; (assert-compile! (sym? ))
  (let [var-name (tostring s)
        value s
        name-text [var-name :DiagnosticHint]
        padding-text [" = " :Comment]
        value-text [`(_G.vim.inspect ,value) :DiagnosticHint]
        chunks [name-text padding-text value-text]]
   `(do
      (vim.api.nvim_echo ,chunks true {})
      ,value)))
    


(fn get-mark [name]
  ;; nvim_get_mark({name}, {opts})                                *nvim_get_mark()*
  ;;     Return a tuple (row, col, buffer, buffername) representing the position of
  ;;     the uppercase/file named mark. See |mark-motions|.
  ;;
  ;;     Marks are (1,0)-indexed. |api-indexing|
  ;;
  ;;     Note:
  ;;         fails with error if a lowercase or buffer local named mark is used.
  ;;
  ;;     Parameters:  
  ;;         {name}  Mark name
  ;;         {opts}  Optional parameters. Reserved for future use.
  ;;
  ;;     Return:  
  ;;         4-tuple (row, col, buffer, buffername), (0, 0, 0, '') if the mark is
  ;;         not set.
  ;;
  ;;     See also:  
  ;;         |nvim_buf_set_mark()|
  ;;         |nvim_del_mark()|
  (vim.api.nvim_get_mark name {}))

;; TODO: make this a macro (get-mark :bufnr :M)
(fn get-mark-bufnr [name]
  (let [[row col bufnr buffername] (get-mark name)]
    bufnr))

(fn parse-query [lang query]
  ;; Parse {query} as a string. (If the query is in a file, the caller should)
  ;; read the contents into a string before calling).
  ;;
  ;; Returns a `Query` (see |lua-treesitter-query|) object which can be used to search nodes in
  ;; the syntax tree for the patterns defined in {query} using `iter_*` methods below.
  ;;
  ;; Exposes `info` and `captures` with additional context about {query}.
  ;; • `captures` contains the list of unique capture names defined in {query}.
  ;;   -`info.captures` also points to `captures`.
  ;; • `info.patterns` contains information about predicates.
  ;;
  ;; Parameters:  
  ;;     {lang}   (string) Language to use for the query
  ;;     {query}  (string) Query in s-expr syntax
  ;;
  ;; Return:  
  ;;     Query Parsed query
  (vim.treesitter.parse_query lang query))
;; (fn pecho [ok? ...]
;;   "nvim_echo vargs, as DiagnosticHint or DiagnosticError depending on ok?"
;;   (let [{: nvim_echo} vim.api
;;         {: view} (require :fennel)
;;         hl (if ok? :DiagnosticHint :DiagnosticError)
;;         list [...]
;;         output []]
;;     ;; TODO: this can be fcollect in fennel 1.2.0)
;;     (each [i _ (ipairs list)]
;;       (table.insert output (-> (. list i)
;;                                (#(match (type $1)
;;                                    ;; :table (vim.inspect $1)
;;                                    :table (view $1)
;;                                    _ (tostring $1)))
;;                                (.. "\n"))))
;;     (nvim_echo (icollect [_ l (ipairs output)] [l hl]) true {})))

(macro query-bind! [bindings ...]
  "treesitter iter_captures macro"
  (import-macros {: nil? : str? : tbl? } :macros)
  (let [[binds q-args] bindings]
      ;; (assert-compile (tbl? binds) "Expected a table, e.g. [id node]" binds)

      (λ make-lazy-binder []
         (var B {})
         ;; field -> definition (fn)
         (var defs {})
         ;; field -> desired bind symbol
         (var let-symbols {})
         ;; field -> value body
         (var let-values {})
         ;; ordering of binds in let
         (var bind-order [])

         ;; field -> subfield -> subsymbol index
         (var subfields {})

         (fn parse-path [field-path]
            (var (root-field sub) (string.match field-path "^(.-)%.(.*)$"))
            (set root-field (or root-field field-path))
            (values root-field sub))
           

         (λ B.get-bind [self field-path]
            (if (. let-values field-path) (. let-symbols field-path)
                (do
                   (var (root-field sub) (parse-path field-path))
                   (if sub
                       (self:get-bind root-field))
                   (var bind (. let-symbols field-path))
                   (var value-body ((. defs field-path) self))
                   (tset let-values field-path value-body)
                   (table.insert bind-order field-path)
                   bind)))
         (fn B.resolve-symbol [self field-path]
           (var (root-field sub) (parse-path field-path))
           (print root-field " . " sub)
           (print (view subfields))
           (if sub
               (?. (self:resolve-symbol root-field) (?. subfields root-field sub))
               (?. let-symbols root-field)))
                   
         (fn B.has-field? [self field-path]
           (var (root-field sub) (parse-path field-path))
           (print root-field " . " sub)
           (print (view subfields))
           (and
             (not (= nil (. defs root-field)))
             (or 
               (= nil sub)
               (not (= nil (?. subfields root-field sub))))))
           
         (λ B.define [self field def ?subfields]
           ;; define a default symbol for each field which may be
           ;; overridden or skipped if not needed
           (if (= nil ?subfields)
             (tset let-symbols field (gensym field))
             (do
               (var submap (collect [i sub (ipairs ?subfields)]
                             (values sub i)))
               (each [i sub (ipairs ?subfields)]
                 (tset defs 
                      (string.format "%s.%s" field sub)
                      #(values (. let-symbols field i))))
               (tset subfields field submap)
               (print (string.format "?subfields = %s" (view ?subfields))) 
               (print (string.format "set subfields[%s] = %s" field (view (. subfields field))))
               (tset let-symbols field (list (unpack (icollect [_ subfield (ipairs ?subfields)]
                                                       (gensym subfield)))))))
           ;; register the field's definition
           (tset defs field def))
         (fn B.into-let-binds [self field-to-sym]
           (each [field symbol (pairs field-to-sym)]
             (tset let-symbols field symbol))
           (each [field (pairs field-to-sym)]
             (self:get-bind field))
           (var binds [])
           (each [_ field (ipairs bind-order)]
             (assert (. let-symbols field) (string.format "No field-symbol for %s" field))
             (assert (. let-values field) (string.format "No field-value for %s" field))
             (do (table.insert binds (. let-symbols field))
                 (table.insert binds (. let-values field))))
           binds)
         (fn B.into-let [self field-to-sym ...]
           (print "defs: " (view defs))
           (var binds (self:into-let-binds field-to-sym))
           `(let ,[(unpack binds)]
              ,...))
         B)
           
      (λ sym-name! [s]
        (assert-compile (sym? s) (.. "expected symbol, got " (view s)) s)
        (. s 1))
      (λ find [xs pred]
         (var found nil)
         (each [_ v (pairs xs)] :until (not (nil? found))
           (when (pred v)
             (set found v)))
         found)
      (λ empty? [xs]
        "Check if given table is empty"
        (assert-compile (tbl? xs) "expected table for xs" xs)
        (= 0 (length xs)))
      (var id-gensym (gensym "id"))
      (var node-gensym (gensym "node"))
      (var metadata-gensym (gensym "metadata"))
      (var query-gensym (gensym "query"))
      (var root-gensym (gensym "root"))
      (var source-gensym (gensym "source"))

      ;; (outer-binder:define :__iter #(: ($:get-bind :__query) :iter_captures ($:get-bind :__root) ($:get-bind :__source)))
      (var binder (make-lazy-binder))
      (binder:define :id #(values id-gensym))
      (binder:define :node #(values node-gensym))
      (binder:define :metadata #(values metadata-gensym))
      (binder:define :name #(values `(query.captures ,id-gensym)))
      (binder:define :type #(values `(: ,node-gensym :type)))
      (binder:define :text #(values `(vim.treesitter.query.get_node_text ,node-gensym ,source-gensym)))
      (binder:define :range #(values `(: ,node-gensym :range)) [:start-row :start-col :end-row :end-col])
      
      (fn bind-seq->bind-map [seq]
        (var field-to-sym {})
        (fn add-bind [symbol field field-str]
          (print "add-bind " (view symbol) (view field) (view field-str))
          (if (not (binder:has-field? field-str))
              (assert-compile false (string.format "Not a query field: %s" (view field-str)) field))
          (if (. field-to-sym field-str)
              (assert-compile false (string.format "Field already bound: %s" (view field-str)) field))
          (tset field-to-sym field-str symbol))

      ;; (fn to-gensym [s]
      ;;   (if (str? s) (. gensym s)
      ;;       (sym? s) (to-gensym (sym-name! s))
      ;;       (assert-compile false (.. "to-gensym " (view s) ": " (type s)) s)))
      ;;  
        (fn parse-next [...]
           (let [[symbol ?field & rest] ...]
               (print (string.format "parse-next %s: %s, %s: %s, %s" (view symbol) (type symbol) (view ?field) (type ?field) (view rest)))
               (assert-compile (sym? symbol) (string.format "Parse-next: expected symbol for symbol (got %s: %s)" (view symbol) (type symbol)) symbol)
                  ;; (print "symbol: " symbol)
                  ;; (print "->str symbol: " (->str symbol))
               ;; (print "view symbol: " (view symbol) " " (to-gensym symbol))
               ;; (print "view ?field: " (view ?field) " " (to-gensym ?field))
               ;; (match [symbol ?field]
               ;;   (where [b nil] (and (sym? symbol) (to-gensym b))) (add-bind b b (view b))
               ;;   (where [b t] (and (sym? symbol) (str? ?field))) (add-bind b t t)
               ;;   _ (assert-compile false (.. "symbol: " (view symbol) " ?field: " (view ?field)) symbol)) 
               (if (nil? ?field)
                   (do 
                     (print "?field == nil")
                     (add-bind symbol symbol (sym-name! symbol)))
                   (= :string (type ?field))
                   (do
                     (print "?field is str: " (tostring ?field))
                     (add-bind symbol ?field `,?field)
                     (if (not (empty? rest))
                         (parse-next rest)))
                   (do 
                     (print "?field is neither nil nor str " (view ?field))
                     (add-bind symbol symbol (sym-name! symbol))
                     (parse-next [?field (unpack rest)])))))
        (parse-next seq)
        field-to-sym)
      (print "STARTING")
      (print "binds: " (view binds))
      (var field-to-sym (bind-seq->bind-map binds))
      (print "field-to-sym: " (view field-to-sym))
      (let [inner-let (binder:into-let field-to-sym ...)
            collect-form `(icollect [,id-gensym ,node-gensym ,metadata-gensym (: ,query-gensym :iter_captures ,root-gensym ,source-gensym)]
                           ,inner-let)]
        `(let [q-args# ,q-args
               ,query-gensym q-args#.query 
               ,root-gensym q-args#.root
               ,source-gensym q-args#.source]
           ,collect-form))))
               
            
      
                      
        
      


(macro test! [x]
  (import-macros {: map! : nil? : str? : tbl? } :macros)
  (fn sym-name [s]
    (assert-compile (sym? s) (.. "expected symbol, got " (view s)) s)
    (. s 1))
  
  (print "type " (type x))
  (print "view " (view x))
  (print "tostring " (tostring x))
  (assert-compile (= (tostring x) "id") "tostring != \"id\"" x)
  ;; (assert-compile (= (->str x) "id") "->str != \"id\"" x)
  ;; (assert-compile (sym? x) "not sym?" x)
  ;; (assert-compile (tbl? x) "not tbl?" x)
  ;; (assert-compile (= (tostring x) :x) "not tbl?" x)
  ;; (assert-compile (str? x) "not str?" x)
  (when (sym? x) 
    (print "sym? true" " (" (view (sym-name x)) ")"))
    
  (when (str? x) (print "str? true")))



(var [row col bufnr bufname] (get-mark :M))
;; (vim.api.nvim_buf_get_lines (get-mark-bufnr :M) (- row 1) (+ row 2) false)
(local parser (vim.treesitter.get_parser bufnr))
(local (trees changes) (parser:parse))
(dbg! trees)
(var tree (. trees 1))
(dbg! tree)
(var root (tree:root))
(var ft (vim.api.nvim_buf_get_option bufnr :filetype))

(local query (parse-query ft "
(fn
  name: (symbol) @capture)
                          "))
;; buf
;; (get-mark-bufnr :M)
;; (test! id)

;; (each [a b c (query:iter_captures root bufnr)]
;;   (print a b c))
;; (query-bind! [[id node :node meta :metadata field :type] (query:iter_captures root bufnr)]
;;           (vim.treesitter.query.get_node_text node bufnr))
(query-bind! [[id :id node :node text :text start-row :range.start-row end-row :range.end-row] {:query query :root root :source bufnr}]
            start-row)
         ;; (vim.treesitter.query.get_node_text node bufnr))
           
;; (icollect [_ tree (ipairs trees)]
;;   (-> (tree:root)
;;       (collect (query:iter_captures))))
;; ;; ft


;; (var field "range.row")
;; (dbg! field)
;; (dbg! sub)
