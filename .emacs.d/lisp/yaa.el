;; -*- coding: utf-8 -*-

(defun yaa-toggle-fullscreen ()
  (interactive)
  (if (eq window-system 'x)
      (progn
        (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                               '(2 "_NET_WM_STATE_MAXIMIZED_VERT" 0))
        (x-send-client-message nil 0 nil "_NET_WM_STATE" 32
                               '(2 "_NET_WM_STATE_MAXIMIZED_HORZ" 0)))))

;; -------------------

(defun yaa-toggle-maximize-buffer () "Maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

;; --------------------

(defun yaa-which-command (command)
  (locate-file command exec-path exec-suffixes 1))

(defun yaa-choose-best-command-if (fn commands)
  (cond ((car (remove-if-not fn commands)) (car (remove-if-not fn commands)))
        (t (car (last commands)))))

(defun yaa-choose-best-command (commands)
  (yaa-choose-best-command-if 'yaa-which-command commands))

;; (yaa-choose-best-command '("okularr" "evincze" "evincexx"))

;; --------------------

(defun yaa-dired-open-in-external-app ()
  "Open the current file or dired marked files in external app."
  (interactive)
  (let ( doIt
         (myFileList
          (cond
           ((string-equal major-mode "dired-mode") (dired-get-marked-files))
           (t (list (buffer-file-name))))))
    (setq doIt (if (<= (length myFileList) 5)
                   t
                 (y-or-n-p "Open more than 5 files?")))
    (message "%s" myFileList)
    (when doIt
      (cond
       ((string-equal system-type "windows-nt")
        (mapc
         (lambda (fPath)
           (w32-shell-execute
            "open"
            (replace-regexp-in-string "/" "\\" fPath t t)) ) myFileList))
       ((string-equal system-type "darwin")
        (mapc
         (lambda (fPath)
           (let ((process-connection-type nil))
             (start-process "" nil "open" fPath))) myFileList))
       ((string-equal system-type "gnu/linux")
        (mapc
         (lambda (fPath)
           (let ((process-connection-type nil))
             (start-process "" nil "xdg-open" fPath))) myFileList))))))

;; --------------------

(defun yaa-open-dir-in-mc (f)
  "Open directory in mc"
  (message "%s" f)
  (let ((curdir (expand-file-name (file-name-directory f))))
    (cond
     ((string-equal system-type "windows-nt")
      (w32-shell-execute "open" (replace-regexp-in-string "/" "\\" curdir t t)))
     ((string-equal system-type "darwin")
      (let ((process-connection-type nil)) (start-process "" nil "open" curdir)))
     ((string-equal system-type "gnu/linux")
      (let ((process-connection-type nil))
        (message "Starting MC in folder...")
        (start-process "" nil "mc-folder.sh" curdir))))))

;; --------------------

(defun yaa-open-current-dir-in-mc ()
  "Open the current directory in mc"
  (interactive)
  (let ((curdir (file-name-directory (or load-file-name buffer-file-name))))
    (yaa-open-dir-in-mc curdir)))

;; --------------------

(defun yaa-dired-open-dired-directory-in-mc ()
  "Open the current directory in mc"
  (interactive)
    (yaa-open-dir-in-mc dired-directory))

;; -------------------

(defun gdb-setup-windows ()
  ;; (interactive)
  "Layout the window pattern for option `gdb-many-windows'."
  (gdb-get-buffer-create 'gdb-locals-buffer)
  (gdb-get-buffer-create 'gdb-stack-buffer)
  (gdb-get-buffer-create 'gdb-breakpoints-buffer)
  (set-window-dedicated-p (selected-window) nil)
  (switch-to-buffer gud-comint-buffer)
  (set-window-dedicated-p (selected-window) t)
  (delete-other-windows)
  (let ((win0 (selected-window))
        (win1 (split-window nil ( / ( * (window-height) 3) 4)))
        (win2 (split-window nil ( / (window-height) 3)))
        (win3 (split-window-right)))
    (gdb-set-window-buffer (gdb-locals-buffer-name) nil win3)
    (select-window win2)
    (set-window-buffer
     win2
     (if gud-last-last-frame
         (gud-find-file (car gud-last-last-frame))
       (if gdb-main-file
           (gud-find-file gdb-main-file)
         ;; Put buffer list in window if we
         ;; can't find a source file.
         (list-buffers-noselect))))
    (setq gdb-source-window (selected-window))
    (let ((win4 (split-window-right)))
      (gdb-set-window-buffer
       (gdb-get-buffer-create 'gdb-inferior-io) nil win4))
    (select-window win1)
    (gdb-set-window-buffer (gdb-stack-buffer-name))
    (let ((win5 (split-window-right)))
      (gdb-set-window-buffer (if gdb-show-threads-by-default
                                 (gdb-threads-buffer-name)
                               (gdb-breakpoints-buffer-name))
                             nil win5))
    (select-window win0)))

;; -------------------

;; (setq compilation-auto-jump-to-first-error t)
;; (add-hook 'compilation-mode 'next-error-follow-minor-mode)
;; Helper for compilation. Close the compilation window if
;; there was no error at all.
(defun compilation-exit-autoclose (status code msg)
  ;; If M-x compile exists with a 0
  (when (and (eq status 'exit) (zerop code))
    ;; then bury the *compilation* buffer, so that C-x b doesn't go there
    (bury-buffer)
    ;; and delete the *compilation* window
    (delete-window (get-buffer-window (get-buffer "*compilation*"))))
  ;; Always return the anticipated result of compilation-exit-message-function
  (cons msg code))
;; Specify my function (maybe I should have done a lambda function)
(setq compilation-exit-message-function 'compilation-exit-autoclose)

;; -------------------

(defun yaa-do-shell-and-copy-to-kill-ring (command &optional arg file-list)
  (interactive
   (let ((files (dired-get-marked-files t current-prefix-arg)))
     (list
      (dired-read-shell-command "! on %s: " current-prefix-arg files)
      current-prefix-arg
      files)))
  (dired-do-shell-command command arg file-list)
  (with-current-buffer "*Shell Command Output*"
    (copy-region-as-kill (point-min) (point-max))))

;; --------------------

(defun yaa-copy-line (arg)
    "Copy lines (as many as prefix argument) in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
    (interactive "p")
    (let ((beg (line-beginning-position))
          (end (line-end-position arg)))
      (when mark-active
        (if (> (point) (mark))
            (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
          (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (if (eq last-command 'copy-line)
          (kill-append (buffer-substring beg end) (< end beg))
        (kill-ring-save beg end)))
    (kill-append "\n" nil)
    (beginning-of-line (or (and arg (1+ arg)) 2))
    (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))

(defun yaa-copy-line-contents (arg)
    "Copy lines (as many as prefix argument) without newlines in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
    (interactive "p")
    (let ((beg (line-beginning-position))
          (end (line-end-position arg)))
      (when mark-active
        (if (> (point) (mark))
            (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
          (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
      (if (eq last-command 'copy-line-contents)
          (kill-append (buffer-substring beg end) (< end beg))
        (kill-ring-save beg end)))
    ;; (kill-append "\n" nil)
    (beginning-of-line (or (and arg (1+ arg)) 2))
    (if (and arg (not (= 1 arg))) (message "%d lines contents copied" arg)))

;; --------------------

(defun yaa-replace-chars-with-html-entities-region (start end)
  "Replace “<” to “&lt;” and other chars in HTML.
This works on the current region."
  (interactive "r")
  (xah-replace-pairs-region
   start end
   '(
     ;; ["&" "&amp;"]
     ;; ["<" "&lt;"]
     ;; [">" "&gt;"]
     ["«" "&laquo;"]
     ["»" "&raquo;"]
     ["–" "&ndash;"]
     ["—" "&mdash;"]
     [" " "&nbsp;"]
     ["'" "&#39;"]
     )))

(defalias 'yaa-u2h 'yaa-replace-chars-with-html-entities-region)

(defun yaa-replace-html-entities-with-chars-region (start end)
  "Replace “&lt;” to “<” and other chars in HTML.
This works on the current region."
  (interactive "r")
  (xah-replace-pairs-region
   start end
   '(
     ;; ["&amp;" "&"]
     ;; ["&lt;" "<"]
     ;; ["&gt;" ">"]
     ["&laquo;" "«"]
     ["&raquo;" "»"]
     ["&ndash;" "–"]
     ["&mdash;" "—"]
     ["&nbsp;" " "]
     ["&#39;" "'"]
     )))

(defalias 'yaa-h2u 'yaa-replace-html-entities-with-chars-region)

;; --------------------

(defun yaa-remove-extra-spaces (start end)
  "Collapse adjacent spaces"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (goto-char (point-min))
      (while (re-search-forward "[ \t]+" nil t)
        (replace-match " ")))))

;; --------------------

(defun yaa-fix-apostrophes (start end)
  "Replace “’” to “'”"
  (interactive "r")
  (xah-replace-pairs-region
   start end
   '(
     ["’" "'"]
     )))

;; --------------------

(defun yaa-romanize-region-as-russian (begin end)
  (interactive "r")
  (let ((case-fold-search nil))
  (xah-replace-pairs-region
   begin end
   '(
     ["Бе" "Bie"] ["Ве" "Vie"] ["Ге" "Gie"] ["Де" "Die"]
     ["Же" "Zhie"] ["Зе" "Zie"] ["Ке" "Kie"] ["Ле" "Lie"]
     ["Ме" "Mie"] ["Не" "Nie"] ["Пе" "Pie"] ["Ре" "Rie"]
     ["Се" "Sie"] ["Те" "Tie"] ["Фе" "Fie"] ["Хе" "Khie"]
     ["Це" "Tsie"] ["Че" "Chie"] ["Ше" "Shie"] ["Ще" "Shchie"]

     ["Бё" "Bio"] ["Вё" "Vio"] ["Гё" "Gio"] ["Дё" "Dio"]
     ["Жё" "Zhio"] ["Зё" "Zio"] ["Кё" "Kio"] ["Лё" "Lio"]
     ["Мё" "Mio"] ["Нё" "Nio"] ["Пё" "Pio"] ["Рё" "Rio"]
     ["Сё" "Sio"] ["Тё" "Tio"] ["Фё" "Fio"] ["Хё" "Khio"]
     ["Цё" "Tsio"] ["Чё" "Chio"] ["Шё" "Shio"] ["Щё" "Shchio"]

     ["Бю" "Biu"] ["Вю" "Viu"] ["Гю" "Giu"] ["Дю" "Diu"]
     ["Жю" "Zhiu"] ["Зю" "Ziu"] ["Кю" "Kiu"] ["Лю" "Liu"]
     ["Мю" "Miu"] ["Ню" "Niu"] ["Пю" "Piu"] ["Рю" "Riu"]
     ["Сю" "Siu"] ["Тю" "Tiu"] ["Фю" "Fiu"] ["Хю" "Khiu"]
     ["Цю" "Tsiu"] ["Чю" "Chiu"] ["Шю" "Shiu"] ["Щю" "Shchiu"]

     ["Бя" "Bia"] ["Вя" "Via"] ["Гя" "Gia"] ["Дя" "Dia"]
     ["Жя" "Zhia"] ["Зя" "Zia"] ["Кя" "Kia"] ["Ля" "Lia"]
     ["Мя" "Mia"] ["Ня" "Nia"] ["Пя" "Pia"] ["Ря" "Ria"]
     ["Ся" "Sia"] ["Тя" "Tia"] ["Фя" "Fia"] ["Хя" "Khia"]
     ["Ця" "Tsia"] ["Чя" "Chia"] ["Шя" "Shia"] ["Щя" "Shchia"]

     ["бе" "bie"] ["ве" "vie"] ["ге" "gie"] ["де" "die"]
     ["же" "zhie"] ["зе" "zie"] ["ке" "kie"] ["ле" "lie"]
     ["ме" "mie"] ["не" "nie"] ["пе" "pie"] ["ре" "rie"]
     ["се" "sie"] ["те" "tie"] ["фе" "fie"] ["хе" "khie"]
     ["це" "tsie"] ["че" "chie"] ["ше" "shie"] ["ще" "shchie"]

     ["бё" "bio"] ["вё" "vio"] ["гё" "gio"] ["дё" "dio"]
     ["жё" "zhio"] ["зё" "zio"] ["кё" "kio"] ["лё" "lio"]
     ["мё" "mio"] ["нё" "nio"] ["пё" "pio"] ["рё" "rio"]
     ["сё" "sio"] ["тё" "tio"] ["фё" "fio"] ["хё" "khio"]
     ["цё" "tsio"] ["чё" "chio"] ["шё" "shio"] ["щё" "shchio"]

     ["бю" "biu"] ["вю" "viu"] ["гю" "giu"] ["дю" "diu"]
     ["жю" "zhiu"] ["зю" "ziu"] ["кю" "kiu"] ["лю" "liu"]
     ["мю" "miu"] ["ню" "niu"] ["пю" "piu"] ["рю" "riu"]
     ["сю" "siu"] ["тю" "tiu"] ["фю" "fiu"] ["хю" "khiu"]
     ["цю" "tsiu"] ["чю" "chiu"] ["шю" "shiu"] ["щю" "shchiu"]

     ["бя" "bia"] ["вя" "via"] ["гя" "gia"] ["дя" "dia"]
     ["жя" "zhia"] ["зя" "zia"] ["кя" "kia"] ["ля" "lia"]
     ["мя" "mia"] ["ня" "nia"] ["пя" "pia"] ["ря" "ria"]
     ["ся" "sia"] ["тя" "tia"] ["фя" "fia"] ["хя" "khia"]
     ["ця" "tsia"] ["чя" "chia"] ["шя" "shia"] ["щя" "shchia"]

     ["а" "a"] ["б" "b"] ["в" "v"] ["г" "g"] ["д" "d"]
     ["е" "ye"] ["ё" "yo"] ["ж" "zh"] ["з" "z"] ["и" "i"]
     ["й" "y"] ["к" "k"] ["л" "l"] ["м" "m"] ["н" "n"]
     ["о" "o"] ["п" "p"] ["р" "r"] ["с" "s"] ["т" "t"]
     ["у" "u"] ["ф" "f"] ["х" "kh"] ["ц" "ts"] ["ч" "ch"]
     ["ш" "sh"] ["щ" "shch"] ["ъ" ""] ["ы" "y"] ["ь" ""]
     ["э" "e"] ["ю" "yu"] ["я" "ya"]

     ["А" "A"] ["Б" "B"] ["В" "V"] ["Г" "G"] ["Д" "D"]
     ["Е" "Ye"] ["Ё" "Yo"] ["Ж" "Zh"] ["З" "Z"] ["И" "I"]
     ["Й" "Y"] ["К" "K"] ["Л" "L"] ["М" "M"] ["Н" "N"]
     ["О" "O"] ["П" "P"] ["Р" "R"] ["С" "S"] ["Т" "T"]
     ["У" "U"] ["Ф" "F"] ["Х" "Kh"] ["Ц" "Ts"] ["Ч" "Ch"]
     ["Ш" "Sh"] ["Щ" "Shch"] ["Ъ" ""] ["Ы" "y"] ["Ь" ""]
     ["Э" "E"] ["Ю" "Yu"] ["Я" "Ya"]

     ["ґ" "g"] ["є" "ye"] ["і" "i"] ["ї" "yi"]

     ["Ґ" "G"] ["Є" "Ye"] ["І" "I"] ["Ї" "Yi"]
     ))))

;; --------------------

(defun yaa-romanize-region-as-ukrainian (begin end)
  (interactive "r")
  (let ((case-fold-search nil))
  (xah-replace-pairs-region
   begin end
   '(
     ["Бє" "Bie"] ["Вє" "Vie"] ["Гє" "Hie"] ["Ґє" "Gie"]
     ["Дє" "Die"] ["Жє" "Zhie"] ["Зє" "Zie"] ["Кє" "Kie"]
     ["Лє" "Lie"] ["Мє" "Mie"] ["Нє" "Nie"] ["Пє" "Pie"]
     ["Рє" "Rie"] ["Сє" "Sie"] ["Тє" "Tie"] ["Фє" "Fie"]
     ["Хє" "Khie"] ["Цє" "Tsie"] ["Чє" "Chie"] ["Шє" "Shie"]
     ["Щє" "Shchie"]

     ["Бю" "Biu"] ["Вю" "Viu"] ["Гю" "Hiu"] ["Ґю" "Giu"]
     ["Дю" "Diu"] ["Жю" "Zhiu"] ["Зю" "Ziu"] ["Кю" "Kiu"]
     ["Лю" "Liu"] ["Мю" "Miu"] ["Ню" "Niu"] ["Пю" "Piu"]
     ["Рю" "Riu"] ["Сю" "Siu"] ["Тю" "Tiu"] ["Фю" "Fiu"]
     ["Хю" "Khiu"] ["Цю" "Tsiu"] ["Чю" "Chiu"] ["Шю" "Shiu"]
     ["Щю" "Shchiu"]

     ["Бя" "Bia"] ["Вя" "Via"] ["Гя" "Hia"] ["Ґя" "Gia"]
     ["Дя" "Dia"] ["Жя" "Zhia"] ["Зя" "Zia"] ["Кя" "Kia"]
     ["Ля" "Lia"] ["Мя" "Mia"] ["Ня" "Nia"] ["Пя" "Pia"]
     ["Ря" "Ria"] ["Ся" "Sia"] ["Тя" "Tia"] ["Фя" "Fia"]
     ["Хя" "Khia"] ["Ця" "Tsia"] ["Чя" "Chia"] ["Шя" "Shia"]
     ["Щя" "Shchia"]

     ["бє" "bie"] ["вє" "vie"] ["гє" "hie"] ["ґє" "gie"]
     ["дє" "die"] ["жє" "zhie"] ["зє" "zie"] ["кє" "kie"]
     ["лє" "lie"] ["мє" "mie"] ["нє" "nie"] ["пє" "pie"]
     ["рє" "rie"] ["сє" "sie"] ["тє" "tie"] ["фє" "fie"]
     ["хє" "khie"] ["цє" "tsie"] ["чє" "chie"] ["шє" "shie"]
     ["щє" "shchie"]

     ["бю" "biu"] ["вю" "viu"] ["гю" "hiu"] ["ґю" "giu"]
     ["дю" "diu"] ["жю" "zhiu"] ["зю" "ziu"] ["кю" "kiu"]
     ["лю" "liu"] ["мю" "miu"] ["ню" "niu"] ["пю" "piu"]
     ["рю" "riu"] ["сю" "siu"] ["тю" "tiu"] ["фю" "fiu"]
     ["хю" "khiu"] ["цю" "tsiu"] ["чю" "chiu"] ["шю" "shiu"]
     ["щю" "shchiu"]

     ["бя" "bia"] ["вя" "via"] ["гя" "hia"] ["ґя" "gia"]
     ["дя" "dia"] ["жя" "zhia"] ["зя" "zia"] ["кя" "kia"]
     ["ля" "lia"] ["мя" "mia"] ["ня" "nia"] ["пя" "pia"]
     ["ря" "ria"] ["ся" "sia"] ["тя" "tia"] ["фя" "fia"]
     ["хя" "khia"] ["ця" "tsia"] ["чя" "chia"] ["шя" "shia"]
     ["щя" "shchia"]

     ["а" "a"] ["б" "b"] ["в" "v"] ["г" "h"] ["ґ" "g"]
     ["д" "d"] ["е" "e"] ["є" "ye"] ["ж" "zh"] ["з" "z"]
     ["и" "y"] ["і" "i"] ["ї" "yi"] ["й" "y"] ["к" "k"]
     ["л" "l"] ["м" "m"] ["н" "n"] ["о" "o"] ["п" "p"]
     ["р" "r"] ["с" "s"] ["т" "t"] ["у" "u"] ["ф" "f"]
     ["х" "kh"] ["ц" "ts"] ["ч" "ch"] ["ш" "sh"] ["щ" "shch"]
     ["ь" ""] ["ю" "yu"] ["я" "ya"]

     ["А" "A"] ["Б" "B"] ["В" "V"] ["Г" "H"] ["Ґ" "G"]
     ["Д" "D"] ["Е" "E"] ["Є" "Ye"] ["Ж" "Zh"] ["З" "Z"]
     ["И" "Y"] ["І" "I"] ["Ї" "Yi"] ["Й" "Y"] ["К" "K"]
     ["Л" "L"] ["М" "M"] ["Н" "N"] ["О" "O"] ["П" "P"]
     ["Р" "R"] ["С" "S"] ["Т" "T"] ["У" "U"] ["Ф" "F"]
     ["Х" "Kh"] ["Ц" "Ts"] ["Ч" "Ch"] ["Ш" "Sh"] ["Щ" "Shch"]
     ["Ь" ""] ["Ю" "Yu"] ["Я" "Ya"]

     ["ё" "yo"] ["ъ" ""] ["ы" "y"] ["э" "e"]

     ["Ё" "Yo"] ["Ъ" ""] ["Ы" "y"] ["Э" "E"]
     ))))

;; --------------------

(defun yaa-romanize-region-dummy (begin end)
  (interactive "r")
  (let ((case-fold-search nil))
  (xah-replace-pairs-region
   begin end
   '(
     ["а" "a"] ["б" "b"] ["в" "v"] ["г" "g"] ["д" "d"]
     ["е" "ye"] ["ё" "yo"] ["ж" "zh"] ["з" "z"] ["и" "i"]
     ["й" "y"] ["к" "k"] ["л" "l"] ["м" "m"] ["н" "n"]
     ["о" "o"] ["п" "p"] ["р" "r"] ["с" "s"] ["т" "t"]
     ["у" "u"] ["ф" "f"] ["х" "kh"] ["ц" "ts"] ["ч" "ch"]
     ["ш" "sh"] ["щ" "shch"] ["ъ" ""] ["ы" "y"] ["ь" ""]
     ["э" "e"] ["ю" "yu"] ["я" "ya"]

     ["А" "A"] ["Б" "B"] ["В" "V"] ["Г" "G"] ["Д" "D"]
     ["Е" "Ye"] ["Ё" "Yo"] ["Ж" "Zh"] ["З" "Z"] ["И" "I"]
     ["Й" "Y"] ["К" "K"] ["Л" "L"] ["М" "M"] ["Н" "N"]
     ["О" "O"] ["П" "P"] ["Р" "R"] ["С" "S"] ["Т" "T"]
     ["У" "U"] ["Ф" "F"] ["Х" "Kh"] ["Ц" "Ts"] ["Ч" "Ch"]
     ["Ш" "Sh"] ["Щ" "Shch"] ["Ъ" ""] ["Ы" "y"] ["Ь" ""]
     ["Э" "E"] ["Ю" "Yu"] ["Я" "Ya"]

     ["ґ" "g"] ["є" "ye"] ["і" "i"] ["ї" "yi"]

     ["Ґ" "G"] ["Є" "Ye"] ["І" "I"] ["Ї" "Yi"]
     ))))

;; --------------------

(defun yaa-romanize-region (begin end &optional rules)
  (interactive "r")
  (let ((case-fold-search nil))
    (let ((rules (or rules (completing-read
                            "Romanization rules: "
                            '(("russian" 1) ("ukrainian" 2) ("dummy" 3))))))
      (cond ((string= rules "ukrainian") (yaa-romanize-region-as-ukrainian begin end))
            ((string= rules "russian") (yaa-romanize-region-as-russian begin end))
            (t (yaa-romanize-region-dummy begin end))))))

;; (read-from-minibuffer "Romanization rules: ")

;; --------------------

(defun yaa-encoding-win ()
  "Revert to cp1251-dos"
  (interactive)
  (revert-buffer-with-coding-system 'cp1251-dos))

(defun yaa-encoding-utf ()
  "Revert to utf-8-unix"
  (interactive)
  (revert-buffer-with-coding-system 'utf-8-unix))

;; --------------------

(defun yaa-replace-in-string (what with in)
  "Simple replace in string"
  (replace-regexp-in-string (regexp-quote what) with in nil 'literal))

(defvar yaa-romanization-rules "russian")

(defun yaa-normalize-string (str)
  "Normalize string"
  (shell-command-to-string
   (concat "echo -n \'"
           (yaa-replace-in-string
            " " "_"
            (yaa-replace-in-string
             "'" ""
             (with-temp-buffer
               (insert str)
               (yaa-romanize-region
                (point-min) (point-max)
                yaa-romanization-rules)
               (buffer-string))))
           "\' | konwert utf8-ascii")))

;; (yaa-normalize-string "abc АБВ.doc")
;; (yaa-normalize-string "abc АБВє.doc")
;; (yaa-normalize-string "abc $PWD АБВ.doc")
;; (yaa-normalize-string "abc $PWD 'АБВ.doc")
;; (yaa-normalize-string "abc $PWD ''АБВ.doc")
;; (yaa-normalize-string "abc $PWD '''АБВ.doc")
;; (message "%s" (yaa-normalize-string "abc АБВ.doc"))
;; (yaa-normalize-string "АБВ.doc")
;; (yaa-normalize-string "")
;; (yaa-normalize-string nil)

(defun yaa-normalize-filename (f)
  "Normalize filename"
  (let ((dirname-orig (file-name-directory f))
        (fname-orig (file-name-nondirectory f)))
    (let ((fname (read-string "Normalized filename: "
                              (yaa-normalize-string fname-orig))))
      (concat dirname-orig fname))))

;; (yaa-normalize-filename "uploads/abc АБВ.doc")
;; (yaa-normalize-filename "uploads/АБВ.doc")
;; (yaa-normalize-filename "uploads/")
;; (yaa-normalize-filename "abcАБВ")
;; (yaa-normalize-filename ".doc")
;; (yaa-normalize-filename "uploads/.doc")

(defun yaa-get-human-readable-filesize (f)
  (with-temp-buffer
    (let ((ret)
          (env-lang-bak (getenv "LANG")))
      (setenv "LANG" "C")
      (call-process "/usr/bin/du" nil t nil "-sch" f)
      (progn
        (re-search-backward "\\(^[0-9.,]+\\)\\([A-Za-z]*\\).*total$")
        (setq ret (concat (match-string 1) " " (match-string 2))))
      (setenv "LANG" env-lang-bak)
      ret)))

;; (re-search-backward "\\(^[^[:blank:]]+\\).*total$")
;; (setq ret (match-string 1)))

;; (re-search-backward "\\(^[0-9.,]+[A-Za-z]+\\).*total$")
;; (setq ret (match-string 1)))

;; (yaa-get-human-readable-filesize "/bin/bash")
;; (yaa-get-human-readable-filesize "/usr/bin/Xephyr")

(defun yaahtml-autohref (original-filename)
  "Mormalize filename and prepare href with it"
  (let ((normalized-filename (yaa-normalize-filename original-filename)))
    (when (not (string= original-filename normalized-filename))
      (let ((backup-filename (concat original-filename "-bak")))
        (rename-file original-filename backup-filename t)
        (copy-file backup-filename normalized-filename t)))
    (let ((title (file-name-base original-filename))
          (extension (file-name-extension normalized-filename)))
      (let ((filetype (upcase (or extension "file")))
            (filesize (yaa-get-human-readable-filesize normalized-filename))
            (uploads-relative-filename
             (car (last (split-string normalized-filename "/uploads/")))))
        (concat "<a href=\"" (concat "/uploads/" uploads-relative-filename) "\" "
                "target=\"_blank\" "
                "title=\"" (file-name-nondirectory normalized-filename)
                " (" filesize "Б)\""
                ">" title " (" filetype ", " filesize "Б)</a>")))))

;; (add-name-to-file original-filename normalized-filename t)

(defun yaahtml-dired-autohref ()
  "Prepare hrefs from dired"
  (interactive)
  (let ((list-of-filenames (dired-get-marked-files nil current-prefix-arg)))
    (mapcar 'kill-new (mapcar 'yaahtml-autohref list-of-filenames))
    (dired-revert)))

;; (dired-unmark-all-files)

(defun yaahtml-wrap-autohref ()
  "Prepare href with already existing text"
  (interactive)
  (let ((filename (expand-file-name (read-file-name "Enter file name:"))))
    (insert (yaahtml-autohref filename))))

;; --------------------

(defun yaa-view (f)
  "View office file contents"
  (with-temp-buffer
    (let ((ret)
          (env-lang-bak (getenv "LANG")))
      ;; (setenv "LANG" "C")
      ;; (with-output-to-temp-buffer "*yaa-view*"
      ;;   (shell-command (concat "view-doc-as-text.sh" " " f)
      ;;                  "*yaa-view*"
      ;;                  nil)
      ;;   (pop-to-buffer "*yaa-view*"))
      (with-output-to-temp-buffer "*yaa-view*"
        (call-process "view-doc-as-text.sh" nil "*yaa-view*" nil f)
        (pop-to-buffer "*yaa-view*"))
      ;; (setenv "LANG" env-lang-bak)
      ret)))

(defun yaa-dired-view ()
  "Preview files from dired"
  (interactive)
  (let ((list-of-filenames (dired-get-marked-files nil current-prefix-arg)))
    (mapcar 'kill-new (mapcar 'yaa-view list-of-filenames))
    (dired-revert)))

;; --------------------

(defun yaa-kill-buffer-file-name ()
  "Kill buffer-file-name"
  (interactive)
  (kill-new buffer-file-name)
)

;; --------------------

(defun yaahtml-text-align-left ()
 "YAAHTML text align left."
 (interactive)
 (insert " style=\"text-align:left;\""))

(defun yaahtml-text-align-center ()
 "YAAHTML text align center."
 (interactive)
 (insert " style=\"text-align:center;\""))

(defun yaahtml-text-align-right ()
 "YAAHTML text align right."
 (interactive)
 (insert " style=\"text-align:right;\""))

;; --------------------

(defun yaahtml-wrap-with-tags (&rest tagNames)
  "Add tags to beginning and ending of current word or text selection."
  (interactive "sHTML tag:")
  (let (p1 p2)
    (if (use-region-p)
        (progn
          (setq p1 (region-beginning))
          (setq p2 (region-end)))
      (let ((bds (bounds-of-thing-at-point 'symbol)))
        (setq p1 (car bds))
        (setq p2 (cdr bds))))

    (when (and (bound-and-true-p p1) (bound-and-true-p p2))
      (save-excursion
        (goto-char p2)
        (mapcar
         (lambda (tagName)
           (insert "</" tagName ">"))
         tagNames))
      (save-excursion
        (goto-char p1)
        (mapcar
         (lambda (tagName)
           (insert "<" tagName ">"))
         (nreverse tagNames)))
      )))

;; --------------------

(defun yaahtml-wrap-logical-line-with-tag (tagName)
 "YAAHTML wrap logical line with a tag."
 (interactive)
 (move-beginning-of-line 1)
 (set-mark-command nil)
 (move-end-of-line 1)
 (yaahtml-wrap-with-tags tagName)
 (deactivate-mark 1)
 (next-line)
 (move-beginning-of-line 1))

;; --------------------

(add-hook 'html-mode-hook
          (lambda ()
            (setq sgml-xml-mode t)))

;; --------------------

(defun yaahtml-node-ref (nodeid)
  "Insert drupal node ref."
  (interactive "sEnter drupal node number: ")
  (insert "/?q=node/" nodeid))

;; --------------------

(defun yaahtml-uploads-template ()
 "Insert uploads template."
 (interactive)
 (insert "<a href=\"/uploads/filename.doc\" title=\"filename.doc (00 КБ)\">Назва (doc, 00 КБ)</a>"))

(defun yaahtml-dc-template ()
 "Insert DC template."
 (interactive)
 (insert "<a href=\"http://dspace.repo.edu.ua/handle/123456789/\" title=\"DC Опис\"><img alt=\"Dublic Core\" hspace=\"0\" src=\"/images/dc.gif\" style=\"display: inline; float: none; padding: 0; margin: 0; vertical-align: bottom;\" title=\"Dublic Core\" width=\"16\" /></a>"))

(defun yaahtml-foreign-link ()
 "Insert foreign link."
 (interactive)
 (insert "<a rel=\"nofollow noreferrer\" title=\"\" href=\"\"></a>"))

(defun yaahtml-native-link (relative-href)
 "Insert native link by relative-href."
 (interactive  "sEnter relative-href: ")
 (insert "<a title=\"\" href=\"" relative-href "\"></a>"))

(defun yaahtml-native-link-by-node-number (node-number)
  "Insert native link by relative-href."
  (interactive "sEnter drupal node number: ")
  (insert "<a title=\"\" href=\"/?q=node/" node-number "\"></a>" ""))

(defun yaahtml-employee-ref (nodeid)
  "Insert employee ref."
  (interactive "sEnter drupal node number: ")
  (insert "<a href=\"" "/?q=node/" nodeid "\" title=\"Ім'я По батькові Прізвище\">Прізвище Ім'я По батькові</a>"))

(defun yaahtml-wrap-employee-ref (nodeid)
  "Wrap employee with link."
  (interactive "sEnter node number: ")
  (let (p1 p2 inputText)
    (if (use-region-p)
        (progn
          (setq p1 (region-beginning))
          (setq p2 (region-end)))
      (let ((bds (bounds-of-thing-at-point 'symbol)))
        (setq p1 (car bds))
        (setq p2 (cdr bds))))

    (setq pib (buffer-substring p1 p2))

    (save-excursion
      (goto-char p2)
      (insert "</a>")
      (goto-char p1)
      (insert "<a href=\"" "/?q=node/" nodeid "\" title=\"" pib "\">")
      ;; (goto-char p2)
      )))

(defun yaahtml-employee-regalia ()
  "Insert employee regalia."
  (interactive)
  (insert "<a href=\"/?q=node/XXX\" title=\"Адміністрація університету\">проректор</a>, директор <a href=\"/institut-\" title=\"Інститут\">інституту</a>, декан <a href=\"/fakultet-\" title=\"Факультет\">факультету</a>, завідувач <a href=\"/kafedra-\" title=\"Кафедра\">кафедри</a>"))

(defun yaahtml-gallery (img-count)
  "Insert image gallery."
  (interactive "nEnter number of images:")
  (insert "
<hr />
<p> </p>
")
  (let ((img-index 1))
    (while (<= img-index img-count)
      (insert (format "<p align=\"center\"><a href=\"/uploads/news/YYYYMMDD-II/img-%03d.jpg\" rel=\"lightbox[news-YYYYMMDD-II]\" target=\"_blank\" title=\"Збільшити зображення\"><img alt=\"\" src=\"/images/news/YYYYMMDD-II/img-%03d.jpg\" style=\"float: none; align: center;\" title=\"Збільшити зображення\" width=\"500\" /></a></p>
" img-index img-index))
      (setq img-index (1+ img-index))))
  (insert "<p> </p>
"))

;; --------------------

(defun yaref-cpp ()
  "Browse local cppreference"
  (interactive)
  (eww "file:///usr/share/cppreference/doc/html/en/index.html"))

(defun yaref-stl-manual ()
  "Browse local stl-manual"
  (interactive)
  (eww "file:///usr/share/doc/stl-manual/html/index.html"))

