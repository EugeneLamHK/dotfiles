# dotfiles — CachyOS / Hyprland rice

Managed via git bare repo. Alias:

    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

## New machine setup

    # 1. SSH key (needed to clone this private repo)
    ssh-keygen -t ed25519 -C "your@email"
    cat ~/.ssh/id_ed25519.pub   # add to GitHub → Settings → SSH keys

    # 2. Clone + checkout
    git clone --bare git@github.com:EugeneLamHK/dotfiles.git $HOME/.dotfiles
    alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
    dotfiles checkout   # if conflicts: move listed files aside, retry
    dotfiles config --local status.showUntrackedFiles no

    # 3. Bootstrap (packages + hypr symlink)
    ./bootstrap.sh

Then log out/in. Fix monitor lines in ~/Downloads/ConfigFiles/hypr if panel differs (hyprctl monitors for names).

## Daily use

    dotfiles add <file>
    dotfiles commit -m "msg"
    dotfiles push
    dotfiles status
