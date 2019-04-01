This Zsh plugin puts current command and working directory in your terminal
title. It can also set tmux window name and pane title.

## Configuration

Outside of tmux there's no real configuration to consider. The plugin simply
sends an OSC sequence and the terminal emulator changes its window title
accordingly.

When running under tmux, things get complicated:

- we now have at least three "titles": terminal emulator window title, tmux
window name and tmux pane title,
- any of which can be configured to be updated automatically by tmux itself
(i.e. independent of this plugin),
- there's no single "good" configuration that will work for everybody, because
that depends on tmux workflow.

Here's a configuration that works for me:

0.	Do _not_ use this plugin to set the tmux window name, let tmux
	manage it.

	Either set:

		TERM_TITLE_SET_MULTIPLEXER=0

	in plugin configuration

	or

	disallow all application originating name changes:

		set -g allow-rename 0

	in tmux configuration.

	The reason for this is: if you set the window name, tmux will not
	update it when switching panes (even if you have enabled automatic
	window renaming). This is confusing, so - don't do it.

0.	Optionally enable tmux automatic window renaming:

		set -g automatic-rename 1

	and set the format of automatically updated names to include pane
	title (or it's part):

		set -g automatic-rename-format " #I:#{=30:pane_title}#F "

	Note: the above is basically a workaround to make the `choose-window`
	command easier to use in older tmux versions. Since tmux version 2.6
	`choose-window` is an alias for `choose-tree -w`; this makes the
	workaround redundant.

0.	Remove the pane title from other formats used in the status line - it
	is superfluous there when it is also visible in window names. By
	default, `pane_title` is included in `status-right` format, along with
	the clock, so if you want to keep the clock:

		set -g status-right " %H:%M %d-%b-%y"

0.	Enable updating of the terminal emulator window title:

		set -g set-titles on

	and set its format to include tmux pane title, e.g.:

		set -g set-titles-string "#h:#S:#{pane_title} #{session_alerts}"

## UTF-8 in titles

If you want UTF-8 characters in XTerm window title, set the `utf8Title`
resource to `true`. This can be achieved by placing the following in your
`~/.Xresources` file:

```
XTerm*vt100.utf8Title: true
```

Also note that the `titleModes` resource overrides `utf8Title`.
For details see the XTerm manual.

## Non printable characters

Both XTerm and urxvt define the title string as:

> A text parameter composed of printable characters

Therefore, unprintable characters are removed when setting the title.

## Using `echo` vs. `printf`

From XTerm manual:
> #### Window Titles
> Some scripts use echo with options -e and -n to tell the shell to interpret
> the string "\e" as the escape character and to suppress a trailing newline
> on output. Those are not portable, not recommended. Instead, use printf
> (POSIX).

## Sources of information about the escape codes / control sequences

- XTerm: [XTerm Control Sequences (the ctlseqs.ms file)](http://invisible-island.net/xterm/ctlseqs/ctlseqs.html),
- rxvt-unicode / urxvt: the rxvt-unicode reference, `man 7 urxvt`,
_XTerm Operating System Commands_ section,
- tmux: the tmux manual, `man tmux`, _NAMES AND TITLES_ section.

## Acknowledgments

- [Title and Hardstatus](http://zshwiki.org/home/examples/hardstatus)
- [xterm title/screen title+hardstatus](http://www.zsh.org/mla/workers/2000/msg03988.html)
