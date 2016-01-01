Autcomplete backend for entering HipChat nicks (aka mention names).

## Usage

Add this to your `.emacs`:
```
(setq ac-hipchat-nick-auth-token "foobar")
(ac-hipchat-nick-set-current-room "all")
```

Then, in the buffer where you want HipChat nick completion, you must
first have enabled `auto-completion-mode` (if you haven't already done
so) and then run `ac-hipchat-nick-setup`.

To change room, i.e. the room from which you want completion of the
nick/mention name, run:

```
M-x ac-hipchat-nick-set-current-room RET my-room RET
```

You're now set, any time you write `@`, you'll get a drop down list of
all the users in the current room.

## Copying

Please do, the code is released under GPLv3, see [LICENSE](LICENSE)
for further details.
