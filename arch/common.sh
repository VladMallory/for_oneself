# shellcheck disable=SC2148
ORANGE='\033[38;5;214m'
NC='\033[0m'

log() {
    echo -e "${ORANGE}${*}${NC}"
}
