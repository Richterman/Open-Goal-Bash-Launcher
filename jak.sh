#!/bin/bash
#
#### this script is very much a work in progress
###### this is a total rewrite of the first script supporting cmd line arguments
#
echo
echo
distro=unkown
install_location=/Shared/Games/jak-project/		## will update and make user setable later on, not focused on it
version=none


						####### Program functions ################################
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

git_run() {
	distrocheck
		cd Shared/Games
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
	./build/decompiler/extract -d --folder iso_data/jak1
	./build/decompiler/extract --compile --folder decompile_out/jak1
	clear ; echo "jak1 installed"
		}

jak2_install() {

		./build/decompiler/decompiler ./decompiler/config/jak2/jak2_config.jsonc ./iso_data/ ./decompiler_out/ --version ntsc_v2
		./goalc --cmd "(mi)"
		clear ; echo "Jak2 installed"
		}

Upate() {
	if [ -d $install_location ]
	then
		cd $install_location
		git pull https://github.com/open-goal/jak-project
		distrocheck
		if [ $distro = redhat ]
			then
				cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
				cmake --build build -j$(nproc)
		else
			cmake -B build && cmake --build build -j 8
		fi
	else
		echo ; echo "Opengoal is not installed. Please view the help menu for more information"
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


##################################################### command line options The actual program

echo ; while [ -n "$1" ]
do
case "$1" in
	-jak1)						### play jak 1
		if [ -d $insatll_location/jak1 ]
		then
			cd $install_location
			./build/game/gk --game jak1 -boot -fakeiso
		else
			echo ; echo "Jak1 not installed"
		fi;;

	-jak1debug)
		if [ -d $install_location/jak1 ]
		then
			cd $install_location
			./build/game/gk --game jak1 -debug -fakeiso
			cd
		else
			echo ; echo "Jak1 not installed"
		fi;;
			
	-jak2)		### play jak2 in retail
		if [ -d $install_location/iso_data/jak2 ]
		then
			cd $install_location
			echo ; echo "Booting in retail"
			./build/game/gk --game jak2 -boot -fakeiso
		else 
			echo ; echo "Jak2 not installed"
		fi;;
	-jak2debug)	### play jak 2 in debug
		if [ -d $install_location/jak2 ]
		then
			cd $install_location
			echo ; echo "Booting in debug"
			./bulid/game/gk --game jak2 -debug -fakeiso
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

	-dependency)
		SYSTEM_USER_NAME=$(id -un)
		if [[ "${SYSTEM_USER_NAME}" == 'root'  ]]
		then
			Depency_install
		else
			echo ; echo "this command must be ran as root to install dependencies"
		fi
		break;;

	-update)
		update
		break;;
		
	-install)
		git_run

		;;
		*)	echo ; echo "That's not a valid option, please add -h for help";;
#shift
esac
cd
exit
done
