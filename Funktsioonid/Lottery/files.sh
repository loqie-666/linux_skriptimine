#!/bin/bash
# files.sh - failidega seotud funktsioonid

# Tühjendab antud failid (loob need, kui neid pole)
clear_files() {
    local file
    for file in "$@"; do
        > "$file"
    done
}

# Kontrollib, kas number on failis. Tagastab 0 (jah) või 1 (ei).
number_in_file() {
    local number=$1
    local file=$2
    grep -qx "$number" "$file"
}

# Lisab tulemuse faili lõppu (ajalugu säilib)
# Argumendid: tulemuste_fail nimi mängija_fail loto_fail tabamused tulemus
save_result() {
    local results_file=$1
    local name=$2
    local player_file=$3
    local lottery_file=$4
    local matches=$5
    local result=$6

    {
        echo "========================================"
        echo "Date: $(date)"
        echo "Player: $name"
        echo "Player numbers:"
        cat "$player_file"
        echo "Lottery numbers:"
        cat "$lottery_file"
        echo "Matches: $matches"
        echo "Result: $result"
    } >> "$results_file"
}
