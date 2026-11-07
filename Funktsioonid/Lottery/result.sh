#!/bin/bash
# result.sh - väljundi kuvamine ja tulemuse hinnang

show_header() {
    echo "=== LOTOMÄNG ==="
    echo
}

# Kuvab faili numbrid rida-realt
# Argumendid: pealkiri fail
show_numbers() {
    local title=$1
    local file=$2
    local n

    echo
    echo "$title"
    while read -r n; do
        echo "$n"
    done < "$file"
}

# Väljastab hinnangu tabamuste arvu järgi
get_result_text() {
    local matches=$1

    case $matches in
        5) echo "JACKPOT!" ;;
        4) echo "Väga hea tulemus!" ;;
        3) echo "Hea tulemus." ;;
        2) echo "Kaks tabamust." ;;
        1) echo "Üks tabamus." ;;
        0) echo "Seekord tabamusi ei olnud." ;;
    esac
}

# Argumendid: nimi tabamused kogus tulemus
show_result() {
    local name=$1
    local matches=$2
    local count=$3
    local result=$4

    echo "Mängija: $name"
    echo "Tabamusi: $matches / $count"
    echo "$result"
}
