;;; ac-unicode.el --- auto-complete source of Hipchat nicks

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'auto-complete)

(defgroup ac-hipchat-nick nil
  "auto-complete source of Hipchat-Nick."
  :group 'auto-complete)

;; This file is generated automatically. Don't change this file !!
(setq ac-hipchat-nick--data
      '((:nick "Ivey" :name "Ivey Rashid" :description "Scrumm master WF")
        (:nick "shajedul" :name "Shajedul Islam" :description "")
        (:nick "nahid" :name "Nahid E Mahbub" :description "")
        (:nick "Fariyah" :name "Tasnim Fariyah" :description "")
        (:nick "KibriaKaderi" :name "Kibria Kaderi" :description "")
        (:nick "anwar" :name "Sk Mohd Anwarul Islam" :description "")
        (:nick "Fasihul" :name "Fasihul Kabir" :description "")
        (:nick "Mustafa" :name "Mustafa Sariyar" :description "")
        (:nick "Imran" :name "Imran Chowdhury" :description "")
        (:nick "Ryana" :name "Ryana Quadir" :description "")
        (:nick "simen" :name "Simen Haagenrud" :description "")
        (:nick "KevinFlynn" :name "Kevin Flynn" :description "")
        (:nick "Apu" :name "Moshlehuddin Mazumder Apu" :description "")
        (:nick "TitliRoy" :name "Titli Roy" :description "")
        (:nick "mogsie" :name "Erik Mogensen" :description "")
        (:nick "torstein" :name "Torstein Krause Johansen" :description "")
        (:nick "Shihab" :name "Hasan Shihab Uddin" :description "")
        (:nick "Sohel" :name "Md. Asraful Haque" :description "")
        (:nick "rakib" :name "S. M. Rakibul Islam" :description "")
        ))

(defvar ac-hipchat-nick--candidates
  (cl-loop for hipchat-nick in ac-hipchat-nick--data
           collect
           (popup-make-item (plist-get hipchat-nick :nick)
                            :summary (plist-get hipchat-nick :name)
                            :document (plist-get hipchat-nick :description)
                            )))

;;;###autoload
(defun ac-hipchat-nick-setup ()
  (interactive)
  (add-to-list 'ac-sources 'ac-source-hipchat-nick))

(ac-define-source hipchat-nick
  '((candidates . ac-hipchat-nick--candidates)
    (prefix . "@\\(.*\\)")))

(provide 'ac-hipchat-nick)

;;; ac-hipchat-nick.el ends here
