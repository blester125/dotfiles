mkdir -p $HOME/.config
mkdir -p $HOME/.config/systemd/user

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
ln -snf $HOME/.shellrc/inputrc $HOME/.inputrc
ln -snf $HOME/.shellrc/xbindkeysrc $HOME/.xbindkeysrc
ln -snf $HOME/.shellrc/wacom/xsetwacom.sh $HOME/.xsetwacom.sh
cp $HOME/.shellrc/wacom/wacom.service $HOME/.config/systemd/user/wacom.service

systemctl --user enable wacom
systemctl --user start wacom

if [ ! -L $HOME/.bashrc ]; then
    cp $HOME/.bashrc bashrc
    cat bashrc_add >> bashrc
    ln -snf $HOME/.shellrc/bashrc $HOME/.bashrc
fi

git clone https://github.com/blester125/mnist.git
mv mnist/mnist/mnist.py $HOME/.bin
rm -rf mnist
