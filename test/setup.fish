#!/usr/bin/fish --no-config
# USAGE: source setup.fish && dbg
# TODO: generate cbz files

function dbg
    # yazi --clear-cache 2>/dev/null
    if [ "$PWD" = /home/fisher/repos/yazi-fork ]
        set -f yazi /home/fisher/repos/yazi-fork/target/debug/yazi
    else
        set -f yazi (command -v yazi)
    end
    YAZI_LOG=debug $yazi $argv # 2>/dev/null
    and clear
    cat ~/.local/state/yazi/yazi.log | sed -E '
        /emulator(.rs)?|DDS server on /d;
        /\S*at\S* yazi-(plugin|dds)/d;
        /^\s*$/d;
        s/^.*[0-9-]+T[0-9:\.]+Z\S* //;
        s/^DEBUG yazi_plugin::utils::log: //; '
end
