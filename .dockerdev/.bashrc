parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/:\1/'
}

PS1="🐳 \[\033[1;32m\]\h\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\]\[\033[0;36m\]\$(parse_git_branch) \[\033[0;32m\]\\$\[\033[0m\] "

alias fd=fdfind

rails-console() { (cd /app && IRBRC=irbrc.rb bin/rails console); }
rails-dbconsole() { (cd /app && bin/rails dbconsole -p $@); }
