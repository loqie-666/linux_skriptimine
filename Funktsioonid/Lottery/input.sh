#!/bin/bash
# input.sh - mängija sisendi küsimine ja kontrollimine

# Küsib nime ja väljastab selle (tühja korral "Unknown")
read_player() {
    local name
    read -p "Sisesta oma nimi: " name
    echo "${name:-Unknown}"
}

# Kontrollib numbrit. Tagastab 0, kui number sobib, muidu 1 ja veateate.
# Argumendid: number min max mängija_fail
validate_number() {
    local num=$1
    local min=$2
    local max=$3
    local file=$4

    if [ -z "$num" ]; then
        echo "Viga: midagi ei sisestatud."
        return 1
    fi
    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "Viga: sisesta täisarv."
        return 1
    fi
    num=$((10#$num))
    if [ $num -lt $min ] || [ $num -gt $max ]; then
        echo "Viga: number peab olema vahemikus $min-$max."
        return 1
    fi
    if number_in_file "$num" "$file"; then
        echo "Viga: number $num on juba valitud."
        return 1
    fi
    return 0
}

# Küsib mängija numbrid ja salvestab faili
# Argumendid: mängija_fail kogus min max
read_player_numbers() {
    local file=$1
    local count=$2
    local min=$3
    local max=$4
    local done_count=0
    local num

    echo "Sisesta $count erinevat numbrit vahemikust $min-$max."
    while [ $done_count -lt $count ]; do
        read -p "Number $((done_count + 1)): " num
        if validate_number "$num" "$min" "$max" "$file"; then
            echo $((10#$num)) >> "$file"
            done_count=$((done_count + 1))
        fi
    done
}
