mkdir -p $HOME/.config

ln -snf $HOME/.shellrc/i3 $HOME/.config/i3
ln -snf $HOME/.shellrc/i3status $HOME/.config/i3status
ln -snf $HOME/.shellrc/bin $HOME/.bin
ln -snf $HOME/.shellrc/utils $HOME/.utils
ln -snf $HOME/.shellrc/vim $HOME/.vim
ln -snf $HOME/.shellrc/vim/vimrc $HOME/.vimrc
ln -snf $HOME/.shellrc/bash_aliases $HOME/.bash_aliases
ln -snf $HOME/.shellrc/bash_profile $HOME/.bash_profile
ln -snf $HOME/.shellrc/screenrc $HOME/.screenrc
ln -snf $HOME/.shellrc/gitconfig $HOME/.gitconfig
ln -snf $HOME/.bin/search.py $HOME/.bin/search
ln -snf $HOME/.bin/search.py $HOME/.bin/sr
ln -snf $HOME/.shellrc/xbindkeysrc $HOME/.xbindkeysrc

if [ ! -L $HOME/.bashrc ]; then
    cp $HOME/.bashrc bashrc
    cat bashrc_add >> bashrc
    ln -snf $HOME/.shellrc/bashrc $HOME/.bashrc
fi

git clone https://github.com/blester125/mnist.git
mv mnist/mnist/mnist.py $HOME/.bin
rm -rf mnist
