alias myip="curl http://ipecho.net/plain; echo"
alias cclip='xclip -selection clipboard'
alias token='cat $HOME/Documents/GitHubToken.txt | cclip'
alias gh='history | grep'
#alias gpu="while true; do nvidia-smi | grep -o '1\?[0-9][0-9]%' | tr -d '\n'; sleep 1; echo -ne '\033[2K\r'; done"
alias gpu="while true; do view_gpu; sleep 1; done "
alias nvidia_audio="pactl list sinks | pcregrep -M --only-matching=1 'Sink #(\d)\n.*\n.*\n.*Description: HDA NVidia Digital Stereo \(HDMI\)\n'"
alias active_audio="pactl list sinks | pcregrep -M --only-matching=1 'Sink #(\d)\n.*Status: RUNNING\n'"
alias open="xdg-open"
alias sqlite="sqlite3 -column -header"
alias k="microk8s.kubectl"
alias kubectl="microk8s.kubectl"
