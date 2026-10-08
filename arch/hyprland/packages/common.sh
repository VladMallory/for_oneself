# shellcheck disable=SC2148
ORANGE=$'\033[33m'
NC=$'\033[0m'

log() {
    printf '%b%s%b\n' "$ORANGE" "$*" "$NC"
}
