dotfiles
========

.zshrc and cousins

![image](https://cloud.githubusercontent.com/assets/235410/6504067/7899cc44-c333-11e4-9b72-26cf4493841a.png "Screenshot of a ZSH session")


##Features

* [XDG basedirs](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)
* Powerline support if installed
* virtualenvwrapper support if installed
* zsh-syntax-highlight support if installed
* Git integration enabled
* 256-color support by default
  * Colors enabled by default in ls, grep, dmesg and less!
* Add your extra stuff in $XDG_CONFIG_HOME/zsh/profile
  * Put your custom completions in $XDG_CONFIG_HOME/zsh/completion/

##Extra functions

* **bk** \<file\>: Back up a file
* **htmime** \<url\>: Get the content type of a URL
* **google** \<query\>: Open your default browser on a google query
* **hr**: print a terminal-wide banner
* **launch** \<app\> [args]: Launch a binary, disowning it from the terminal immediately
* **lscolors**: list all available colors
* **urlencode** \<text\>: Return the url-encoded value of `text`
* **zurl** \<url\>: Shorten a URL (uses goo.gl service)


##Extra aliases

* **http**: Run a webserver in cwd (uses Python 3 http.server)
* **json**: Indent and prettify json code
* **myip**: Print the machine's public ip (uses ifconfig.me service)
* **perms** \<args\>: Print file permissions (octal and text)


##Other fun stuff

* Ctrl+E: Edit the current line in your $EDITOR
* Expand "...": Typing ... is expanded to ../..; .... expands to ../../.. and so on.
* Typing a naked directory assumes "cd <dir>" is implied.
* The "⇄" icon will show up on the right side of the tty when the shell is running in a SSH session.
