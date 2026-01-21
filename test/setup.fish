#!/usr/bin/fish --no-config
# USAGE: source setup.fish && dbg
# TODO: generate cbz files

ln -fs "$XDG_STATE_HOME/yazi/yazi.log" (status dirname)

function dbg
    set YAZI_LOG debug
    yazi --clear-cache 2>/dev/null
    YAZI_LOG=debug yazi $argv # 2>/dev/null
    and clear
    cat ~/.local/state/yazi/yazi.log \
        | sed -E /emulator/d \
        | sed -E '/emulator.rs/d' \
        | sed -E 's/^\s+[0-9-]+T[0-9:\.]+Z (DEBUG|ERROR) yazi_plugin::(.*):\s+/\1 \2 /' \
        | sed -E '/at yazi-plugin/d' \
        | sed -E '/^\s*$/d'
end
