#!/bin/bash
# backupexec.sh - varukoopia kaustast src kuupäeva, kontrolli ja logimisega
#
# Kasutus: backupexec.sh [-n] [-c zst|gz|xz]
#   -n   "kuiv jooks": näitab, mis läheks arhiivi, uut arhiivi ei tee
#   -c   kompressor (vaikimisi parim saadaolev: zst, siis xz, siis gz)
#
# Teed on täielikud, seega skripti saab käivitada igast kataloogist.

SRC="$HOME/praks2/src"
BACKUP_DIR="$HOME/praks2/backup"
LOG_DIR="$HOME/praks2/logs"
LOG="$LOG_DIR/backup.log"
KEEP=3

DRY=0
COMP=""

# --- Võtmete lugemine ---
while getopts "nc:" opt; do
    case $opt in
        n) DRY=1 ;;
        c) COMP="$OPTARG" ;;
        *) echo "Kasutus: $0 [-n] [-c zst|gz|xz]"; exit 1 ;;
    esac
done

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Teade ekraanile ja logisse
log() {
    echo "$1"
    echo "[ $(date '+%F %T') ] $1" >> "$LOG"
}

# --- Ajutine kaust, mis kustutatakse skripti lõppedes ---
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

log "BACKUP START"

# --- Allika kontroll ---
if [ ! -d "$SRC" ]; then
    log "VIGA: kausta $SRC ei ole."
    exit 1
fi

# --- Kompressori valik ---
if [ -z "$COMP" ]; then
    if command -v zstd > /dev/null; then COMP="zst"
    elif command -v xz > /dev/null; then COMP="xz"
    else COMP="gz"
    fi
fi
case $COMP in
    zst) TAROPT=(-I 'zstd -19 -T0') ;;
    xz)  TAROPT=(-J) ;;
    gz)  TAROPT=(-z) ;;
    *)   log "VIGA: tundmatu kompressor: $COMP"; exit 1 ;;
esac

# --- Välistused: pildid, bin ja .backupignore ---
EXCL=(--exclude='*.jpg' --exclude='bin')
if [ -f "$SRC/.backupignore" ]; then
    # eemaldame lõpust "/", et "imgs/" töötaks samamoodi nagu "imgs"
    sed 's:/*$::' "$SRC/.backupignore" > "$TMP/ignore"
    EXCL+=(--exclude-from="$TMP/ignore")
fi

NAME="src_$(date +%F_%H-%M-%S).tar.$COMP"
ARCHIVE="$BACKUP_DIR/$NAME"

# --- Kuiv jooks ---
if [ $DRY -eq 1 ]; then
    log "KUIV JOOKS: arhiivi ei tehta, failid:"
    tar "${EXCL[@]}" -cf - -C "$(dirname "$SRC")" "$(basename "$SRC")" | tar -tvf -
    exit 0
fi

# --- Juba olemas arhiiv? ---
if [ -e "$ARCHIVE" ]; then
    log "VIGA: arhiiv $NAME on juba olemas."
    exit 1
fi

# --- Vaba ruumi kontroll (baitides) ---
NEED=$(du -sb "$SRC" | awk '{print $1}')
FREE=$(df -B1 "$BACKUP_DIR" | awk 'NR==2{print $4}')
if [ "$FREE" -lt "$NEED" ]; then
    log "VIGA: vaba ruumi on liiga vähe ($FREE < $NEED)."
    exit 1
fi

# --- Arhiveerimine ajutisse kausta ---
if ! tar "${TAROPT[@]}" "${EXCL[@]}" -cf "$TMP/$NAME" -C "$(dirname "$SRC")" "$(basename "$SRC")"; then
    log "VIGA: arhiveerimine ebaõnnestus."
    exit 1
fi

# --- Arhiivi kontroll: avaneb ja sisaldab faile ---
if ! tar "${TAROPT[@]}" -tf "$TMP/$NAME" | head -n 5 | grep -q .; then
    log "VIGA: arhiiv ei avane või on tühi."
    exit 1
fi

# --- SHA-256 kontrollsumma ---
(cd "$TMP" && sha256sum "$NAME" > "$NAME.sha256")
if ! (cd "$TMP" && sha256sum -c "$NAME.sha256" > /dev/null); then
    log "VIGA: kontrollsumma ei klapi."
    exit 1
fi

# --- Kõik OK: tõsta lõppkausta ---
mv "$TMP/$NAME" "$TMP/$NAME.sha256" "$BACKUP_DIR/"
log "OK: loodud $NAME, suurus $(du -h "$ARCHIVE" | awk '{print $1}'), kontrollsumma OK"

# --- Hoia alles ainult $KEEP uusimat arhiivi ---
cd "$BACKUP_DIR" || exit 1
ls -1t src_*.tar.zst src_*.tar.gz src_*.tar.xz 2>/dev/null | tail -n +$((KEEP + 1)) | while read -r old; do
    rm -f "$old" "$old.sha256"
    log "Kustutatud vana koopia: $old"
done

log "BACKUP END"
