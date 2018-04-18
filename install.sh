ln -snf $HOME/.shellrc/i3 $HOME/.config/i3
ln -snf $HOME/.shellrc/i3status $HOME/.config/i3status
ln -snf $HOME/.shellrc/scripts $HOME/scripts
ln -snf $HOME/.shellrc/vim $HOME/.vim
ln -snf $HOME/.shellrc/vim/vimrc $HOME/.vimrc
ln -snf $HOME/.shellrc/bash_aliases $HOME/.bash_aliases
ln -snf $HOME/.shellrc/bash_profile $HOME/.bash_profile
ln -snf $HOME/.shellrc/screenrc $HOME/.screenrc

if [ ! -L $HOME/.bashrc ]; then
    cp $HOME/.bashrc bashrc
    cat bashrc_add >> bashrc
    ln -snf $HOME/.shellrc/bashrc $HOME/.bashrc
fi
