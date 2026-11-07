#!/bin/bash
# lottery.sh - lotomängu käivitusfail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/files.sh"
source "$DIR/input.sh"
source "$DIR/lottery_functions.sh"
source "$DIR/result.sh"

PLAYER_FILE="player_numbers.txt"
LOTTERY_FILE="lottery_numbers.txt"
RESULTS_FILE="results.txt"
COUNT=5
MIN=1
MAX=50

main() {
    local name matches result

    show_header
    clear_files "$PLAYER_FILE" "$LOTTERY_FILE"
    name=$(read_player)
    read_player_numbers "$PLAYER_FILE" $COUNT $MIN $MAX
    show_numbers "Sinu numbrid:" "$PLAYER_FILE"
    generate_lottery_numbers "$LOTTERY_FILE" $COUNT $MIN $MAX
    show_numbers "Võidunumbrid:" "$LOTTERY_FILE"
    echo
    check_matches "$PLAYER_FILE" "$LOTTERY_FILE"
    matches=$?
    result=$(get_result_text $matches)
    show_result "$name" $matches $COUNT "$result"
    save_result "$RESULTS_FILE" "$name" "$PLAYER_FILE" "$LOTTERY_FILE" $matches "$result"
}

main
