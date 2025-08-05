#!/bin/bash
# -------------------------------------------------------------------------
# @Programa 
# 	@name: glpiagentinstall.sh
#	@versao: 1.0.3
#	@Data 28 de Abril de 2025
#	@Copyright: Arco Educação, 2025
# --------------------------------------------------------------------------
# LICENSE
#
# glpiagentinstall.sh is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# glpiagentinstall.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------------

versionDate="Apr 28, 2025"
TITLE="GLPi Agent Installer - Arco Educação"
BANNER="https://www.arcoeducacao.com.br"

GLPI_DEB_AGT_LINK="https://github.com/glpi-project/glpi-agent/releases/download/1.14/glpi-agent_1.14-1_all.deb"
GLPI_DEB_NET_LINK="https://github.com/glpi-project/glpi-agent/releases/download/1.14/glpi-agent-task-network_1.14-1_all.deb"
GLPI_DEB_ESX_LINK="https://github.com/glpi-project/glpi-agent/releases/download/1.14/glpi-agent-task-esx_1.14-1_all.deb"
GLPI_DEB_COL_LINK="https://github.com/glpi-project/glpi-agent/releases/download/1.14/glpi-agent-task-collect_1.14-1_all.deb"
GLPI_DEB_TSK_LINK="https://github.com/glpi-project/glpi-agent/releases/download/1.14/glpi-agent-task-deploy_1.14-1_all.deb"

GLPI_MAC_AGT_AMD64_PKG="https://github.com/glpi-project/glpi-agent/releases/download/1.14/GLPI-Agent-1.14_x86_64.pkg"
GLPI_MAC_AGT_ARM64_PKG="https://github.com/glpi-project/glpi-agent/releases/download/1.14/GLPI-Agent-1.14_arm64.pkg"

function erroDetect(){
	echo -e "
\033[31m
 ----------------------------------------------------------- 
#                    ERRO DETECTADO!                        #
 -----------------------------------------------------------\033[0m
  Ocorreu um erro durante a execução do instalador.
  Descrição:
 
  *\033[31m $erroDescription \033[0m
  - - -
  
  \033[1mEntre em contato com o suporte da Arco Educação\033[0m 
  
 ----------------------------------------------------------
  \033[32mArco Educação - https://www.arcoeducacao.com.br\033[0m 
 ----------------------------------------------------------"
	kill $$
}

function printLine(){
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	sleep 1
}

function soDiscovery(){
	erroDescription="Sistema operacional não suportado"
	SO=$(uname)
	[ $SO != Darwin ] && [ $SO != Linux ] && erroDetect
	echo "Sistema operacional detectado: $SO"
	echo "Pressione V para continuar ou qualquer outra tecla para cancelar"
	read -n1 OPTION
	
	case $OPTION in
		v | V)
			echo "Continuando..."
		;;
		*)
			erroDescription="Instalação cancelada pelo usuário."
			erroDetect
		;;
	esac
}

function archDiscovery(){
	systemArch=$(uname -m)

	case $SO in
		Darwin)
			confPath="/Applications/GLPI-Agent/etc/agent.cfg"
			case $systemArch in
				arm64)
					MAC_AGENT=$GLPI_MAC_AGT_ARM64_PKG
				;;
				x86_64)
					MAC_AGENT=$GLPI_MAC_AGT_AMD64_PKG
				;;
				*)
					erroDescription="Arquitetura $systemArch não suportada"
					erroDetect
				;;
			esac
		;;
		Linux)
			confPath="/etc/glpi-agent/agent.cfg"
			case $systemArch in
				i386 | i686 | x86_64 | armv7l | armhf | aarch64)
					:
				;;
				*)
					erroDescription="Arquitetura $systemArch não suportada"
					erroDetect
				;;
			esac
		;;
	esac
}

function discoveryLinuxDistro(){
	erroDescription="Não foi possível identificar a distribuição Linux."
	source /etc/os-release ; [ $? -ne 0 ] && erroDetect
		
	case $ID in
		debian | ubuntu | linuxmint )
			case $VERSION_ID in
				12 | 11 | 10 | 9 | 8 | "18.04" | "20.04" | "22.04" | "23.04" | "24.04" | "24.10" )
					echo "Distribuição GNU/Linux $ID versão $VERSION_ID detectada."
				;;
				*)
					erroDescription="Versão da distribuição não suportada."
					erroDetect
				;;
			esac
        ;;
		*)
			erroDescription="Distribuição não suportada."
			erroDetect
		;;
	esac
}

function checkAgentExist(){
	case $SO in
		Darwin)
			[ -e $confPath ] && confRequired=0 || confRequired=1
			egrep ^"server =" $confPath > /dev/null 2>&1
		;;
		Linux)
			[ -e $confPath ] && confRequired=0 || confRequired=1
		;;
	esac

	if [ $confRequired -eq 0 ]; then
		echo "Arquivo de configuração encontrado..."
		sleep 1
		echo "Verificando servidor configurado..."
		sleep 1
		egrep ^"server =" $confPath > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			SERVER=$(egrep ^"server =" $confPath | cut -d"=" -f2)
			CONFIGURATION_OPTION=$(whiptail --title "${TITLE}" --backtitle "${BANNER}" --radiolist \
			"O instalador encontrou um arquivo de configuração apontando para: $SERVER. Deseja criar uma nova configuração?" 10 80 2 \
			"yes" "Nova configuração" ON \
			"no" "Manter configuração existente" OFF 3>&1 1>&2 2>&3)

			if [ $CONFIGURATION_OPTION == yes ]; then
				confRequired=1
			else
				confRequired=0
			fi
		else
			confRequired=1
		fi
	fi
}

function createNewConf(){
	if [ $SO == Linux ]; then
		erroDescription="Erro ao definir o servidor GLPi!"
		GLPI_SERVER=$(whiptail --title "${TITLE}" --backtitle "${BANNER}" --inputbox "Informe o endereço do servidor GLPi:" --fb 10 60 3>&1 1>&2 2>&3); [ $? -ne 0 ] && erroDetect

		erroDescription="Erro ao definir o Asset TAG!"
		ASSET_TAG=$(whiptail --title "${TITLE}" --backtitle "${BANNER}" --inputbox "Informe o Asset TAG." --fb 10 60 3>&1 1>&2 2>&3); [ $? -ne 0 ] && erroDetect

		erroDescription="Erro ao definir HTTP TRUSTED HOST!"
		HTTPD_TRUST=$(whiptail --title "${TITLE}" --backtitle "${BANNER}" --inputbox "Informe os hosts confiáveis. Ex: 127.0.0.1/32 192.168.1.0/24." --fb 10 60 3>&1 1>&2 2>&3); [ $? -ne 0 ] && erroDetect
	else
		read -p "Informe o endereço do servidor GLPi: " GLPI_SERVER
		read -p "Informe o Asset TAG: " ASSET_TAG
		read -p "Informe os hosts confiáveis: " HTTPD_TRUST
	fi

erroDescription="Erro ao criar arquivo de configuração"
cat > $confPath << EOF ; [ $? -ne 0 ] && erroDetect
server = $GLPI_SERVER
local = /tmp
tasks = inventory,deploy,inventory
delaytime = 3600
lazy = 0
scan-homedirs = 1
scan-profiles = 1
html = 0
json = 0
backend-collect-timeout = 180
force = 0
assetname-support = 1
httpd-trust = $HTTPD_TRUST
logger = syslog
logfile = /var/log/glpi-agent.log
logfile-maxsize = 1
logfacility = LOG_DAEMON
tag = $ASSET_TAG
debug = 0
conf-reload-interval = 0
include "conf.d/"
EOF
}

function startInstall() {
	case $SO in
		Linux)
			case $ID in
				debian | ubuntu | linuxmint )
					printLine
					OPCOES=$(whiptail --title "Selecione as opções" --checklist \
					"Use a barra de espaço para selecionar as opções:" 15 60 5 \
					"1" "Inventory" OFF \
					"2" "NetInventory" OFF \
					"3" "ESX" OFF \
					"4" "Collect" OFF \
					"5" "Deploy" OFF 3>&1 1>&2 2>&3)

					[ $? -ne 0 ] && erroDetect

					for i in $(echo $OPCOES | tr "\"" " "); do
						case $i in
							1) wget -O glpi-agent.deb $GLPI_DEB_AGT_LINK || erroDetect; dpkg -i glpi-agent.deb > /dev/null 2>&1; apt-get -f install -y || erroDetect ;;
							2) wget -O glpi-net.deb $GLPI_DEB_NET_LINK || erroDetect; dpkg -i glpi-net.deb > /dev/null 2>&1; apt-get -f install -y || erroDetect ;;
							3) wget -O glpi-esx.deb $GLPI_DEB_ESX_LINK || erroDetect; dpkg -i glpi-esx.deb > /dev/null 2>&1; apt-get -f install -y || erroDetect ;;
							4) wget -O glpi-collect.deb $GLPI_DEB_COL_LINK || erroDetect; dpkg -i glpi-collect.deb > /dev/null 2>&1; apt-get -f install -y || erroDetect ;;
							5) wget -O glpi-task.deb $GLPI_DEB_TSK_LINK || erroDetect; dpkg -i glpi-task.deb > /dev/null 2>&1; apt-get -f install -y || erroDetect ;;
						esac
					done
				;;
			esac
		;;
		Darwin)
			curl -L -k -o GLPI-Agent.pkg -O -# $MAC_AGENT || erroDetect
			installer -pkg GLPI-Agent.pkg -target /Applications || erroDetect
		;;
	esac
}

# =======================
#       EXECUÇÃO
# =======================
clear
cd /tmp
soDiscovery
archDiscovery
[ "$SO" == "Linux" ] && discoveryLinuxDistro
checkAgentExist
[ $confRequired -eq 1 ] && createNewConf
startInstall

echo -e "\n\033[32mInstalação finalizada com sucesso pela Arco Educação!\033[0m"
exit 0
