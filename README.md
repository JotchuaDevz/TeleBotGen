# TeleBotGen

modo de uso:

añadir una opcion que llame a la siguiente funcion

bot_menu () {

CIDdir=/etc/ADM-db && [[ ! -d ${CIDdir} ]] && mkdir ${CIDdir}
[[ ! -e "${CIDdir}/confbot.sh" ]] && wget -O ${CIDdir}/confbot.sh https://raw.githubusercontent.com/JotchuaDevz/TeleBotGen/master/confbot.sh &> /dev/null && chmod +x ${CIDdir}/confbot.sh

sed -i -e 's/\r$//' ${CIDdir}/confbot.sh

source ${CIDdir}/confbot.sh

bot_conf

}
