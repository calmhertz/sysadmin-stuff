#!/bin/bash
# for installing binary apps to user

set -euo pipefail

install_to_user() {
    [[ $# -eq 1 ]] || {
        printf "[E] -- Invalid number of Args.\n"
        return 1
    }

    [[ -f "$1" ]] || {
        printf "[E] -- File does not exist. -> %s\n" "$1"
        return 1
    }

    local archive="$1"
    local filename
    filename=$(basename "$archive")

    local target_name
    target_name="${filename%%-*}"

    local extract_target
    extract_target=$(mktemp -d)

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$extract_target"
            ;;
        *.tar.xz)
            tar -xJf "$archive" -C "$extract_target"
            ;;
        *.tar.zst)
            tar --zstd -xf "$archive" -C "$extract_target"
            ;;
        *.zip)
            unzip -q "$archive" -d "$extract_target"
            ;;
        *)
            printf "[E] -- Unknown file type.\n"
            rm -rf "$extract_target"
            return 1
            ;;
    esac

    local src_dir
    src_dir=$(find "$extract_target" -mindepth 1 -maxdepth 1 -type d | head -n1)

    [[ -n "$src_dir" ]] || src_dir="$extract_target"

    local user_dir="$HOME/.local/bin"
    mkdir -p "$user_dir"

    local bin_target_dir="$user_dir/$target_name"
    rm -rf "$bin_target_dir"

    cp -r "$src_dir" "$bin_target_dir"

    local bin_target
    if [[ -d "$bin_target_dir/bin" ]]; then
        bin_target="$bin_target_dir/bin"
    else
        bin_target="$bin_target_dir"
    fi

    local path_str="export PATH=\"\$PATH:$bin_target\""

    if grep -qsF "$bin_target" "$HOME/.bashrc"; then
        printf "[W] -- Binary target directory already in .bashrc\n"
    else
        printf "[I] -- Adding to PATH\n%s\n" "$path_str"
        printf "%s\n" "$path_str" >> "$HOME/.bashrc"
    fi

    rm -rf "$extract_target"
}

usage() {
    printf "Usage: ibatu [mode] [source]\n\n"
    printf "[mode]\n"
    printf "\tf\tSingle archive file (.tar.gz .tar.xz .tar.zst .zip)\n"
    printf "\td\tDirectory containing archive files\n"
    printf "\ts\tSingle executable file\n\n"
    printf "[source]\n"
    printf "\tPath to source\n"
}

[[ $# -ge 2 ]] || {
    printf "[E] -- Invalid Args.\n\n"
    usage
    exit 1
}

case "$1" in
    f)
        install_to_user "$2"
        ;;
    s)
        [[ -f "$2" ]] || {
            printf "[E] -- File does not exist.\n"
            exit 1
        }

        user_dir="$HOME/.local/bin"
        mkdir -p "$user_dir"

        chmod 0755 "$2"
        cp "$2" "$user_dir"

        path_str='export PATH="$PATH:$HOME/.local/bin"'

        if ! grep -qsF '.local/bin' "$HOME/.bashrc"; then
            printf "[I] -- Adding to PATH.\n%s\n" "$path_str"
            printf "%s\n" "$path_str" >> "$HOME/.bashrc"
        fi
        ;;
    d)
        for src_file in "$2"/*; do
            [[ -f "$src_file" ]] && install_to_user "$src_file"
        done
        ;;
    *)
        printf "[E] -- Invalid Args.\n\n"
        usage
        exit 1
        ;;
esac
