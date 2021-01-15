;;; grep-popup.el --- grep popup

;;; Commentary:

;;; Code:

(require 'transient)

(defgroup grep-popup nil
  "Interactive search with grep."
  :group 'tools
  :group 'matching)

(defcustom grep-popup-function 'ignore
  "Function to perform the search.

This function must take two parameters: the first one is the
directory, the second one is a list of args for the search."
  :type 'function)

(defun grep-popup--map-args (transient-args)
  "Convert TRANSIENT-ARGS to a list of args."
  (mapcar
   (lambda (arg)
     (if (listp arg)
         (let ((args (cdr arg)))
           (mapconcat (lambda (x) (concat "--" x)) args " "))
       arg))
   transient-args))

(transient-define-argument grep-popup:--color ()
  :description "Use markers to highlight the matching strings"
  :class 'transient-switches
  :key "=c"
  :argument-format "--color=%s"
  :argument-regexp "\\(--color=\\(auto\\|always\\|never\\)\\)"
  :choices '("auto" "always" "never"))

(transient-define-argument grep-popup:--binary-files ()
  :description "Assume that binary files are TYPE"
  :class 'transient-switches
  :key "=b"
  :argument-format "--binary-files=%s"
  :argument-regexp "\\(--binary-files=\\(binary\\|text\\|without-match\\)\\)"
  :choices '("binary" "text" "without-match"))

;;;###autoload
(defun grep-popup-search-here ()
  "Search using `grep-popup-function' in the current directory with selected args."
  (interactive)
  (grep-popup-search default-directory))

;;;###autoload
(defun grep-popup-search (directory)
  "Search using `grep-popup-function' in a given DIRECTORY with selected args."
  (interactive "DDirectory: ")
  (let ((ag-args (grep-popup--map-args (transient-args 'grep-popup))))
    (funcall grep-popup-function directory ag-args)))

(define-transient-command grep-popup ()
  "Search popup using `grep'."
  [["Pattern Syntax"
    ("-E" "Extended regexp" "--extended-regexp")
    ("-F" "Fixed strings" "--fixed-strings")
    ("-G" "Basic regexp" "--basic-regexp")
    ("-P" "Perl regexp" "--perl-regexp")]
   ["Matching control"
    ("-i" "Ignore case" "--ignore-case")
    ("-v" "Invert match" "--invert-match")
    ("-w" "Word regexp" "--word-regexp")
    ("-x" "Line regexp" "--line-regexp")]]
  ["General output control"
   ("-c" "Count" "--count")
   (grep-popup:--color)
   (5 "-L" "Files without match" "--files-without-match")
   (5 "-l" "Files with match" "--files-with-match")
   ("-m" "Max count" "--max-count=" transient-read-number-N+)
   ("-o" "Only matching" "--only-matching")
   (5 "-q" "Quiet" "--quiet")
   (5 "-s" "No messages" "--no-messages")]
  ["Output line prefix control"
   (5 "-b" "Byte offset" "--byte-offset")
   ("-H" "With filename" "--with-filename")
   (5 "-h" "No filename" "--no-filename")
   ("-n" "Line number" "--line-number")
   (5 "-T" "Initial tab" "--initial-tab")
   (5 "-u" "Unix byte offsets" "--unix-byte-offsets")
   ("-Z" "Output zero byte after filename" "--null")]
  ["Context line control"
   ("-A" "Print NUM lines of trailing context" "--after-context=" transient-read-number-N+)
   ("-B" "Print NUM lines of leading context" "--before-context=" transient-read-number-N+)
   ("-C" "Print NUM lines of output context" "--context=" transient-read-number-N+)
   (5 "-U" "Do not strip CR characters at EOL (MSDOS/Windows)" "--binary")]
  ["File and directory selection"
   (grep-popup:--binary-files)
   (5 "-a" "Process a binary file as if it were text" "--text")
   (5 "-I" "Process a binary file as if it did not contain matching data")
   ("-r" "Read all files under each directory" "--recursive")
   ("-R" "Like -r but follow all symlinks" "--dereference-recursive")
   ("=i" "Include" "--include=" grep-read-regexp)]
  ["Search"
   ("s" "in current directory" grep-popup-search-here)
   ("o" "in other directory" grep-popup-search)])

(provide 'grep-popup)
;;; grep-popup.el ends here
