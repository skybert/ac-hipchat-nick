;;; ac-unicode.el --- auto-complete source of Hipchat nicks
;;;
;;; Copyright (C) 2016 Torstein Krause Johansen
;;;
;;; This program is free software: you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.
;;;
;;; Commentary:
;;;
;;; Add the following to your .emacs:
;;;
;;; (setq ac-hipchat-nick-auth-token "foobar")
;;; (ac-hipchat-nick-set-current-room "all")
;;;
;;; Then, in the buffer where you want HipChat nick completion, run
;;; ac-hipchat-nick-setup.

;;; Code:

(require 'auto-complete)
(require 'json)

(defgroup ac-hipchat-nick nil
  "Auto completion of HipChat nicks (mention names)."
  :group 'auto-complete
  :prefix "ac-hipchat-nick-")

(defcustom ac-hipchat-nick-auth-token
  "foo"
  "The API auth token you've created for your HipChat user."
  :type 'string
  :group 'ac-hipchat-nick)

(defcustom ac-hipchat-nick-url
  "https://api.hipchat.com"
  "The URL of your HipChat server."
  :type 'string
  :group 'ac-hipchat-nick)

(defcustom ac-hipchat-nick-guess-room-by-buffer-name
  t
  "Guess the room you're in based on the buffer name."
  :group 'ac-hipchat-nick)

(defun ahn--fetch-json (url)
  "Fetches the URL and will return it as a JSON object."
  (with-current-buffer
      (url-retrieve-synchronously url)

    ;; Manually removing the HTTP headers since
    ;; url-http-end-of-headers no longer exists. 2016-01-12
    (goto-char (point-min))
    (re-search-forward "{")
    (delete-region (- (point) 1) (point-min))

    ;; Hack because of a bug in Emacs' json.el which doesn't parse the
    ;; Hipchat response correctly unless there's a space after the
    ;; opening brace (!)
    (save-excursion
      (goto-char 2)
      (insert " "))

    ;; This was useful for debugging
    ;;    (message (substring (buffer-string) 0 20))

    (json-read-object)))

(defun ahn--add-auth (url)
  "Add auth parameter to the passed URL."
  (concat url "?auth_token=" ac-hipchat-nick-auth-token))

(defun ahn--all-rooms-url ()
  "Return the URL of all the rooms."
  (concat ac-hipchat-nick-url
          "/v2/room" "?auth_token="
          ac-hipchat-nick-auth-token))

(defun ahn--room-list ()
  "Will return an list of all the room names and URLs."
  (mapcar
   (lambda (x)
     (cons (cdr (assoc 'name x))
           (cdr (assoc 'self (assoc 'links x)))))
   (cdr (assoc 'items (ahn--fetch-json (ahn--all-rooms-url))))))

;; (pp (ahn--room-list))

(defun ahn--users-in-room (room-url)
  "Return a list of alists with name & mention name for users in ROOM-URL."
  (mapcar
   (lambda (x)
     (list
      (assoc 'name x)
      (assoc 'mention_name x)))
   (cdr
    (assoc 'participants
           (ahn--fetch-json (ahn--add-auth room-url))))))

(defun ahn--nick-list (room-name)
  "Return nick list of the participants in ROOM-NAME."
  (let (result-list
        (tmp-list
         (mapcar
          (lambda (x)
            (if (string= (downcase (car x))
                         (downcase room-name))
                (ahn--users-in-room (cdr x))))
          (ahn--room-list))))

    ;; Create result list without nil elements.
    (while tmp-list
      (let ((head (pop tmp-list)))
        (if head (push head result-list))))
    result-list))

;; (ahn--nick-list "all")

(defun ahn--nick-candidates (room-name)
  "Create a list of nicks and user names in ROOM-NAME."
  (car
   (mapcar
    (lambda (y)
      ;; Only create popup items of the non-nil elements returned from
      ;; ahn--nick-list
      (if y
          (mapcar
           (lambda (x)
             (popup-make-item
              (cdr (assoc 'mention_name x))
              :summary (cdr (assoc 'name x))))
           y)))
    (ahn--nick-list room-name))))

;; (ahn--nick-candidates "all")

(defvar ahn--current-room-candidates
  nil
  "Local cache of the canidate nicks of the currently selected room.")

(defvar ahn--current-room
  ""
  "Local variable holding the current room")

(defun ac-hipchat-nick-guess-room-and-update-nick-list ()
  "Guess which room we're in and update the completion candidates."
  (interactive)
  (if ac-hipchat-nick-guess-room-by-buffer-name
      (let ((room-name (replace-regexp-in-string "[#]" "" (buffer-name))))
        (if (not (string= room-name ahn--current-room))
            (progn
              (setq ahn--current-room room-name)
              (message
               "Guessing we're in room %s, updating nick list..."
               room-name)
              (ac-hipchat-nick-set-current-room room-name)))))
  t)

(defun ac-hipchat-nick-set-current-room (room)
  "Populate the nick completion list to the given ROOM."
  (interactive "sRoom name: ")
  (setq ahn--current-room-candidates (ahn--nick-candidates room))
  t)

;; (ac-hipchat-nick-set-current-room "all")

(defvar ac-source-hipchat-nick
  '((candidates . ahn--current-room-candidates)
    (prefix . "@\\(.*\\)")
    (cache)))

(defun ac-hipchat-nick-setup ()
  "Set up ac-hipchat-nick."
  (interactive)
  (add-to-list 'ac-sources 'ac-source-hipchat-nick))

(provide 'ac-hipchat-nick)

;;; ac-hipchat-nick.el ends here
