#!/bin/bash
r="\033[1;31m"
g="\033[1;32m"
c="\033[1;36m"
b="\033[1;34m"
n="\033[0m"


banner() {
    echo -en "\n${g}░█████╗░██████╗░███╗░░░███╗██╗███╗░░██╗\n██╔══██╗██╔══██╗████╗░████║██║████╗░██║\n███████║██║░░██║██╔████╔██║██║██╔██╗██║\n██╔══██║██║░░██║██║╚██╔╝██║██║██║╚████║\n██║░░██║██████╔╝██║░╚═╝░██║██║██║░╚███║\n╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝\n\n███████╗██╗███╗░░██╗██████╗░███████╗██████╗░\n██╔════╝██║████╗░██║██╔══██╗██╔════╝██╔══██╗\n█████╗░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝\n██╔══╝░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗\n██║░░░░░██║██║░╚███║██████╔╝███████╗██║░░██║\n╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝\n${c}by ${g}Hasib Hossen\n\n${n}"
}
banner


final() {
    clear; banner
    if [ -f .ok.txt ];
    then
    echo -e "\n\n${n}[${g}*${n}] ${g}All Found Admin Panel URL${n}\n"
    while read -r result; do
    echo -en "\n${n}[${g}*${n}] ${g}FOUND${n}: ${g} ${result}${n}\n"
    done < ".ok.txt"
    if [ -f .redirect.txt ];
    then
    echo -e "\n\n${n}[${g}*${n}] ${g}All Found REDIRECT URL${n}\n"
    while read -r result; do
    echo -en "\n${n}[${b}+${n}] ${b}REDIRECT${n}: ${b} ${result}${n}\n"
    done < ".redirect.txt"
    else
    echo ""
    fi
    else
    echo -en "${n}[${r}!${n}] ${r} No Found Admin Panel Site"
    fi
}



trap ctrl_c INT

ctrl_c() {
    echo -en "\n${n}[${g}*${n}] ${g}Stop Finding...${n}"
    sleep 3
    final
    exit
}

find() {
    clear; banner
    echo -en "${n}\n\n[${g}*${n}] ${c}TARGET${n}:${g} ${link}\n\n\n${n}[${g}*${n}]${b} Press CTRL+C For Stop Finding...\n${n}"
    while read -r list; do
    result=$(curl --write-out '%{http_code}' --silent  --output /dev/null "${link}/${list}")
    if [[ ${result} -ge 200 && ${result} -le 299 ]];
    then
    echo -en "\n${n}[${g}*${n}] ${g}FOUND${n}: ${g}${link}/${list}\n${n}"
    echo "${link}/${list}" >> .ok.txt 
    fi
    if [[ ${result} -ge 300 && ${result} -le 399 ]];
    then
    echo -en "\n${n}[${b}+${n}] ${b}REDIRECT${n}: ${b}${link}/${list}\n${n}"
    echo "${link}/${list}" >> .redirect.txt 
    fi
    if [[ ${result} -ge 400 && ${result} -le 499 ]];
    then
    echo -en "\n${n}[${r}!${n}] ${r}ERROR${n}: ${r}${link}/${list}${n}\n"
    fi
    done < "${wlist}"
    final
    if [ -f .ok.txt ];
    then
    echo ""
    else
    echo -en "\n${n}[${g}*${n}] ${g}Type y For Try Custom Wordlist ${b}"
    read yn
    echo -en "${n}"
    case $yn in
    y) echo -en "\n${n}[${g}*${n}] ${g}Custom Wordlist Path${n}: ${b}"
    read path
    echo -en "${n}"
    wlist="${path}"
    find
    ;;
    Y) echo -en "\n${n}[${g}*${n}] ${g}Custom Wordlist Path${n}: ${b}"
    read path
    echo -en "${n}"
    wlist="${path}"
    find
    ;;
    *) echo -en "\n${n}[${r}!${n}]${r} Wrong Type"
    ;;
    esac
    fi
    exit
}


main() {
    wlist="list.txt"
    rm -rf .ok.txt
    if [[ $(command -v curl) ]];
    then
    echo ""
    else
    echo -en "${n}[${r}!${n}] ${r}curl ${c}Not Installed. \n${g} Wait For Installing curl${n}"
    pkg install curl -y
    fi
    if [ -f list.txt ];
    then
    echo ""
    else
    echo -en "${n}[${r}!${n}] ${r}Not Found File\n${n}[${g}*${n}] ${g} Wait Downloading List File...\n${n}"
    curl -s -o list.txt https://raw.githubusercontent.com/DH-Alamin/AdminFinder/main/list.txt
    fi
    clear; banner
    echo -en "\n${n}[${g}*${n}] ${g}Enter Site Link${n}: ${b}"
    read url
    link=$(echo ${url} | sed 's!http[s]*://!!g' | cut -d '/' -f1)
    if [[ -n ${url} ]];
    then
    echo -en ""
    else
    echo -en "\n${n}[${r}-${n}] ${r}You Didn't Type Anything!!!\n\n${c}"
    echo -en "${n}[${g}*${n}]${g} Press Enter To Continue...\n${n}"
    read -r -s -p $""
    main
    fi
    if curl --output /dev/null --silent --head --fail "${url}";
    then
    find
    else
    echo -en "\n\n${n}[${r}!${n}] ${c}Site: ${r}${url} Site Not Found\n\n\n${n}[${g}+${n}] ${g}Check URL & Try Again\n\n${c}"
    echo -en "${n}[${g}*${n}]${g} Press Enter To Continue...\n${n}"
    read -r -s -p $""
    main
    fi
}


main
rm -rf .ok.txt redirect.txt
