#!/bin/bash

dirb="/etc/ADM-db"
mkdir -p "$dirb"
dirs="${dirb}/sources"
mkdir -p "$dirs"

BRANCH="master"
REQUEST_BASE="https://raw.githubusercontent.com/JotchuaDevz/TeleBotGen/${BRANCH}/sources"
bar="\e[0;36m=====================================================\e[0m"

veryfy_fun () {
    mkdir -p "$dirs"
    unset ARQ
    case "$1" in
        "BotGen.sh") ARQ="${dirb}" ;;
        *) ARQ="${dirs}" ;;
    esac
    mv -f "$HOME/$1" "${ARQ}/$1"
    chmod +x "${ARQ}/$1"
}

update () {
    [[ -d "${dirs}" ]] && rm -rf "${dirs}"
    [[ -e "${dirb}/BotGen.sh" ]] && rm -f "${dirb}/BotGen.sh"
    [[ -e /bin/ShellBot.sh ]] && rm -f /bin/ShellBot.sh

    cd "$HOME" || return 1
    REQUEST="$REQUEST_BASE"

    wget -q -O "$HOME/HexGen" "${REQUEST}/lista-bot"

    if [[ ! -s "$HOME/HexGen" ]]; then
        echo "update.sh: no se pudo descargar lista-bot, abortando update." >&2
        rm -f "$HOME/HexGen"
        return 1
    fi

    fallo=0
    while IFS= read -r arqx; do
        [[ -z "$arqx" ]] && continue
        wget -q -O "$HOME/$arqx" "${REQUEST}/${arqx}"
        if [[ -s "$HOME/$arqx" ]]; then
            veryfy_fun "$arqx"
        else
            echo "update.sh: fallo al descargar $arqx" >&2
            rm -f "$HOME/$arqx"
            fallo=1
        fi
    done < "$HOME/HexGen"

    rm -f "$HOME/HexGen"
    return $fallo
}

mensaje () {
    if [[ "$1" = 1 ]]; then
        MENSAJE="Actualizando BotGen"
    elif [[ "$1" = 2 ]]; then
        MENSAJE="BotGen Actualizado"
    elif [[ "$1" = 3 ]]; then
        MENSAJE="Fallo la actualizacion, se mantiene la version anterior"
    fi
    TOKEN="$(cat "${dirb}/token" 2>/dev/null)"
    ID="$(cat "${dirb}/Admin-ID" 2>/dev/null)"
    [[ -z "$TOKEN" || "$TOKEN" == "null" || -z "$ID" ]] && return
    URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
    curl -s -X POST "$URL" -d chat_id="$ID" -d text="$MENSAJE" >/dev/null 2>&1
}

mensaje 1

if update; then
    chmod +x "${dirb}/BotGen.sh"
    systemctl restart telebotgen.service
    sleep 2
    if systemctl is-active --quiet telebotgen.service; then
        mensaje 2
    else
        mensaje 3
    fi
else
    mensaje 3
fi

rm -f "$HOME/update.sh"
