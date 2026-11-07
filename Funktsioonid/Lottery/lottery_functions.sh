#!/bin/bash
# lottery_functions.sh - loosimine ja tabamuste kontroll

# Loosib erinevad numbrid ja salvestab faili
# Argumendid: loto_fail kogus min max
generate_lottery_numbers() {
    local file=$1
    local count=$2
    local min=$3
    local max=$4
    local done_count=0
    local n

    while [ $done_count -lt $count ]; do
        n=$((RANDOM % (max - min + 1) + min))
        if ! number_in_file "$n" "$file"; then
            echo "$n" >> "$file"
            done_count=$((done_count + 1))
        fi
    done
}

# Võrdleb mängija numbreid loositutega, kuvab iga numbri tulemuse.
# Tagastab tabamuste arvu (return väärtusena, 0-255).
# Argumendid: mängija_fail loto_fail
check_matches() {
    local player_file=$1
    local lottery_file=$2
    local matches=0
    local n

    while read -r n; do
        echo "Kontrollin numbrit $n..."
        if number_in_file "$n" "$lottery_file"; then
            echo "TABAMUS!"
            matches=$((matches + 1))
        else
            echo "Ei tabanud."
        fi
        echo
    done < "$player_file"

    return $matches
}
