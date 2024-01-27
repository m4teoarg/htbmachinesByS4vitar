#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl-c(){
  
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1  # codigo de estado no exitoso
}

# ctrl+c

trap ctrl-c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

# Indicadores
declare -i parameter_conunter=0

# Chivato
declare -i chivato_difficulty=0
declare -i chivato_so=0

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}\n"
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios.${endColour}"
  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por nombre de maquina.${endColour}"
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por dirección IP.${endColour}"
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una máquina.${endColour}"
  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo.${endColour}"
  echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link de la resolucion de la maquina en youtube.${endColour}"
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrat panel de ayuda.\n${endColour}"
}

# Funcion buscar maquina

function searchMachine(){
  machineName="$1"
  
  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | tr -d 's/^ *//')"
  
  if [ "$machineName_checker" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las propiedades de la maquina${endColour}${blueColour} $machineName${endColour}${grayColour}:${endColour}\n"

  cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | tr -d 's/^ *//'
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe!${endColour}\n"
  fi
}

# Buscar por ip

function searchIP(){
  ipAddress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineName" ]; then
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"
  else
    echo -e "\n${redColour}[!] La dirección IP proporcionada no existe${endColour}\n"
  fi  
}

# Buscar link para ir a youtube
function getYoutubeLink(){
#cat bundle.js | awk "/name: \"Tentacle\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | tr -d 's/^ *//' | grep youtube | awk 'NF{print $NF}'
  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | grep youtube | tail -n 1 | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

  if [ "$youtubeLink" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta máquina esta en el siguiente enlace:${endColour}${blueColour} $youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!] La máquina proporcionada no existe${endColour}\n"
  fi  
}

# Buscar máquina por dificultad
function getMachineDifficulty(){
  difficulty="$1"
  result_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$result_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando el nivel de dificultad de:${endColour}${blueColour} $difficulty${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

  else
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi
}

# Buscar por sistema operativo
function getOsMachine(){
  so="$1"

  os_result="$(cat bundle.js | grep "so: \"$so\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$os_result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las máquina cuyo sistema operativo es:${endColour}${blueColour} $so${endColour}\n"
    cat bundle.js | grep "so: \"$so\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] El sistema operativo proporcionado no existe${endColour}\n"
  fi
}

function updateFile(){
  
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[!]${endColour}${greenColour} Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} Todos los archivos han sido descargados.${endColour}"
    tput cnorm
  else

    echo -e "\n${yellowColour}[!]${endColour}${grayColour} Comprobando su hay actualizaciones pendientes...${endColour}"
    sleep 3

    tput civis
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')
    
    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${greenColour} No hay actualizaciones, estas al día.${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[!]${endColour}${redColour} Se han encontrado actualizaciones, procesando...${endColour}"
      sleep 3

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n${greenColour}[!]${endColour}${grayColour} Los archivos han sido actualizados.${endColour}"
    fi

    tput cnorm
  fi
}

# Buscar por dificultad y sistema operativo
function getOSDificultyMachine(){
  difficulty="$1"
  so="$2"
  
  check_result="$(cat bundle.js | grep "so: \"$so\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  if [ "$check_result" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando máquina de dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y de sistema operativo${endColour}${blueColour} $so${endColour}\n" 
    cat bundle.js | grep "so: \"$so\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] La dificultad o el sistema operativo no existe${endColour}\n"
  fi
  #echo -e "\n[+] Se vá aplicar una busqueda por dificultad $difficulty y sistema operativo $so.\n"
}

while getopts "m:ui:y:d:o:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_conunter+=1;;
    u) parameter_conunter+=2;;
    i) ipAddress="$OPTARG"; let parameter_conunter+=3;;
    y) machineName="$OPTARG"; let parameter_conunter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_conunter+=5;;
    o) so="$OPTARG"; chivato_so=1; let parameter_conunter+=6;;
    h) ;;
  esac
done

if [ $parameter_conunter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_conunter -eq 2 ]; then
  updateFile
elif [ $parameter_conunter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_conunter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_conunter -eq 5 ]; then
  getMachineDifficulty $difficulty    
elif [ $parameter_conunter -eq 6 ]; then
  getOsMachine $so   
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_so -eq 1 ]; then
  getOSDificultyMachine $difficulty $so
else
  helpPanel
fi
