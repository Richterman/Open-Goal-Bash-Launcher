#!/bin/bash
#
#### this script is very much a work in progress
###### this is a total rewrite of the first script supporting cmd line arguments
#
echo
echo
distro=unkown
install_location=~/Games/jak-project/		## will update and make user setable later on, not focused on it
version=ntscv1
git_run() {
	distrocheck
		cd ~/Games
		git clone https://github.com/open-goal/jak-project
		cd jak-project/
		if [ $distro = redhat ]
			then
				cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
				cmake --build build -j$(nproc)
		else
			cmake -B build && cmake --build build -j 8
		fi
		
	./test.sh ; echo ; echo "Succesfully installed git and tested"
}
jak1_install() {
python ./scripts/tasks/update-env.py --game jak1
		python ./scripts/tasks/update-env.py --decomp_config $version
	{{.DECOMP_BIN_RELEASE_DIR}}/decompiler \"./decompiler/config/{{.DECOMP_CONFIG}}\" \"./iso_data\" \"./decompiler_out\" --version \"{{.DECOMP_CONFIG_VERSION}}\" --config-override {\"decompile_code\": false, \"levels_extract\": true, \"allowed_objects\": []}
		./goalc --cmd "(mi)"
		clear ; echo "jak1 installed"
		}
jak2_install() {
python ./scripts/tasks/update-env.py --game jak2
		python ./scripts/tasks/update-env.py --decomp_config $version
		{{.DECOMP_BIN_RELEASE_DIR}}/decompiler \"./decompiler/config/{{.DECOMP_CONFIG}}\" \"./iso_data\" \"./decompiler_out\" --version \"{{.DECOMP_CONFIG_VERSION}}\" --config-override {\"decompile_code\": false, \"levels_extract\": true, \"allowed_objects\": []}
		./goalc --cmd "(mi)"
		clear ; echo "Jak2 installed"
		}
Upate() {
	jak1=0
	jak2=0
	if [ -d $install_location ]
	then 
		cd
		if [ -d $install_location/iso_data/jak1 ]
		then
			mv $install_location/iso_data/jak1 ~/
			jak1=1
		else 
			echo
		fi
		if [ -d $install_location/iso_data/jak2 ]
		then
			mv $install_locaiton/iso_data/jak2 ~/
			jak2=1
		else 
			echo
		fi
		rm -rf $install_location
		distrocheck
		cd ~/Games
		git_run	
	if [ $jak1 -eq 1 ]
	then
		mv ~/jak1 $install_location/iso_data
	else
		echo
	fi
	if [ $jak2 = 1 ]
	then
		mv ~/jak2 $install_location/iso_data/
	else
		echo
	fi
	if [ $jak1 = 1 ]
	then
		jak1_install
	else
		echo ; echo "jak1 not installed "
	fi
	if [ $jak2 = 2 ]
	then
		jak2_install
	else
		echo ; echo "Jak2 not installed"
	fi
	else 	
	echo ; echo "Games not installed, please run -install option"
fi
}

Depency_install() {

case $distro in
	arch) 
		pacman -S cmake libpulse base-devel nasm python libx11 libxrandr libxinerama libxcursor libxi;;
	debian)
		apt install gcc make cmake build-essential g++ nasm clang-format libxrandr-dev libxinerama-dev libxcursor-dev libpulse-dev libxi-dev python lld clang;;
	redhat)
	sudo dnf -y install cmake python lld clang nasm libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pulseaudio-libs-devel mesa-libGL-devel;;
	*) :
esac		
}

Distrocheck() {
	local distro
	if ( which apt )
	then
		distro=debian
	elif ( which rpm )
		distro=redhat
	then
		distro=redhat
	elif ( which pacman )
	then
		distro=arch
	else
		echo ; echo "Error!! Unable to identify your package manager to determine distro base."
		exit
	fi
	}
##################################################### command line options The actual program

echo ; while [ -n "$1" ]
do
case "$1" in
	-jak1)						### play jak 1
		if [ -d $insatll_location/jak1 ]
		then
			cd $install_location
			echo ; echo "Booting jak in retail"
			python ./scripts/tasks/update-env.py --game jak1
			{{.GK_BIN_RELEASE_DIR}}/gk -v --game {{.GAME}} -- -boot -fakeiso
			cd
			else
			echo ; echo "Jak1 not installed"
		fi;;

	-jak1debug)
		if [ $install_location/jak1 -d ]
		then
			cd $install_location
			echo ; echo "Booting jak1 in debug"
			python ./scripts/tasks/update-env.py --game jak1
			{{.GK_BIN_RELEASE_DIR}}/gk -v --game {{.GAME}} -- -boot -fakeiso -debug
			cd
		else
			echo ; echo "Jak1 not installed"
		fi;;
			
	-jak2)		### play jak2 in retail
		if [ $install_location/iso_data/jak2 -d ]
		then
			cd $install_location
			echo ; echo "Booting in retail"
			{{.GK_BIN_RELEASE_DIR}}/GK -v --game {{.GAME}} -- -boot -fakeiso
		else 
			echo ; echo "Jak2 not installed"
		fi;;
	-jak2debug)	### play jak 2 in debug
		if [ $install_location/jak2 -d ]
		then
			cd $install_location
			echo ; echo "Booting in debug"
			python ./scripts/tasks/update-env.py --game jak2
			{{.GK_BIN_RELEASE_DIR}}/gk -v --game {{.GAME}} -- -boot -fakeiso -debug
			cd
			break
		else 
			echo ; echo "Jak2 not installed"
		fi;;		
	
	-h)			### help
		echo ; echo -e "\t\t\tcommand list"
		echo ; echo -e "\tjak - jak1 \t = play jak1 in retail"
		echo ; echo -e "\tjak -jak2 \t = play jak2 in retail"
		echo ; echo -e "\t\tAdd jak1debug or jak2debug launches in debug mode"
		echo ; echo -e "\tjak -install = install the game from source"
		echo ; echo -e "\tjak -update = updates the games from source"
		echo ; echo -e "\tjak -h shows this menu"
		break;;
		
	-install)
		SYSTEM_USER_NAME=$(id -un)
		if [[ "${SYSTEM_USER_NAME}" == 'root'  ]]
		then
		Depency_install
				git_run
				if [ ~/Documents/jak1 -d ]
				then
					mv ~/Documents/jak1 $install_location/iso_data
					echo ; echo "Jak1 successfully moved"
					jak1=3
				else
					echo ; echo "Jak1 not found, Please place an extracted jak1 folder in ~/Documents"
				fi
				if [ ~/Documents/jak2 -d ]
				then
					mv ~/Documents/jak2 $install_location/iso_data
					echo ; echo "Jak2 successfully moved"
					jak2=3
				else
				echo ; echo "Jak2 not found. Please plan extracted jak2 folder in ~/Documents"
				fi
				if [ $jak1 = '3' ]
				then
					jak1_install
				else
					echo
				fi
				if [ $jak2 = '3' ]
				then
					jak2_install
				else
					echo
				fi
				cd ; cp ~/Downloads/jak.sh /usr/local/bin

			else
				echo ; echo "Error, this command must be ran as root"
			fi ;;

		*)	echo ; echo "That's not a valid option, please add -h for help";;
#shift
esac
cd
exit
done
