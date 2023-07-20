#!/bin/bash
#
#### this script is very much a work in progress
###### this is a total rewrite of the first script supporting cmd line arguments
#
echo
echo
distro=unkown
install_location=~/Games/jak-project ## will update and make user setable later on, not focused on it
version=none
install_folder=~/Games
jak2_version=none
isRoot=0

						####### Program functions ################################
distrocheck() {
	distro
	if [ which apt ]
	then
		distro=debian
	elif [ which rpm ]
		distro=redhat
	then
		distro=redhat
	elif [ which pacman ]
	then
		distro=arch
	else
		echo ; echo "Error!! Unable to identify your package manager to determine distro base. Exiting script"
		exit
	fi
	}

git_run() {
	distrocheck
	cd $install_folder
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
	cd $install_location
	./build/decompiler/extractor --decompile -f iso_data/jak1
	./build/decompiler/extractor --compile decompiler_out/jak1
	echo "jak1 installed"
		}

jak2_install() {
		if [ -d $install_location/iso_data/jak2_us2 ]
		then
			versionloop=true
			while [ $versionloop = 'true' ]
			do
				clear
				echo -e "\nWhich version of the game do you have?"
				cat $install_location/iso_data/jak2_us2/SYSTEM.CNF
				echo -e "\nit should be either pal or ntsc_v1 or ntsc_v2/tALL LOWER CAPS ONLY"
				echo -e "\nVersion: " ; read jak2_version
				cd $install_location ; echo "version picked. $jak2_version"
				case $jak2_version in
					ntsc_v1)
						./build/decompiler/decompiler --version ntsc_v1 ./decompiler/config/jak2/jak2_config.jsonc version ./iso_data/ ./decompiler_out/
						versionloop=false;;

					ntsc_v2)
						./build/decompiler/decompiler --version ntsc_v2 ./decompiler/config/jak2/jak2_config.jsonc ./iso_data/ ./decompiler_out/
						versionloop=false;;
					pal)
						./build/decompiler/decompiler --version pal ./decompiler/config/jak2/jak2_config.jsonc ./iso_data/ ./decompiler_out/
						versionloop=false;;
					*)
						echo -e "\nIncorrect, the only options are ntsc_v1 ntsc_v2 or pal" ; sleep 5 seconds;;
				esac
			done
			sleep 5 ; echo "decompiled"
			./build/goalc/goalc --game jak2 --cmd "(mi)"
			echo "Jak2 installed"
		else
			echo ; echo "Jak2 folder can not be found in ~/Documents or in $install_location/iso_data"
		fi

		}

Upate() {
	if [ -d $install_folder ]
	then
		cd $install_folder
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

root_check() {
	if [ $(id -un) = 'root' ]
	then
		isRoot=1
	else
		isRoot=0
	fi
}
##################################################### command line options The actual program
root_check
echo ; while [ -n "$1" ]
do
case "$1" in
	-jak1)						### play jak 1
		if [ -d $install_location/out/jak1 ]
		then
			cd $install_location
			./build/game/gk --game jak1 -boot -fakeiso
		else
			echo ; echo "Jak1 not installed"
		fi;;

	-jak1debug)
		if [ -d $install_location/out/jak1 ]
		then
			cd $install_location
			./build/game/gk --game jak1 -debug -fakeiso
			cd
		else
			echo ; echo "Jak1 not installed"
		fi;;
			
	-jak2)		### play jak2 in retail
		if [ -d $install_location/out/jak2 ]
		then
			cd $install_location
			echo ; echo "Booting in retail"
			./build/game/gk --game jak2 -boot -fakeiso
		else 
			echo ; echo "Jak2 not installed"
		fi;;
	-jak1install)
		if [ $isRoot -eq 1 ]
		then
			echo -e "\nOnly command to run as root is dependency install"
		else
			if [ -d $install_location/iso_data/jak1 ]
			then
			echo "if statement executed" ; jak1_install
			elif [ -d ~/Documents/jak1 ]
			then
				cp ~/Documents/jak1 $install_location/iso_data
				echo "elif executed" ; jak1_install
			else 
				echo -e "\nJak1 folder not found in ~/Documents or in jak-project"
			fi
		fi;;

	-jak2debug)	### play jak 2 in debug
		if [ -d $install_location/out/jak2 ]
		then
			cd $install_location
			echo ; echo "Booting in debug"
			./build/game/gk --game jak2 -debug -fakeiso
			cd
			break
		else 
			echo ; echo "Jak2 not installed"
		fi;;		
	-jak2install)
		
		jak2_install
		;;
	-h | --h | --help | -help)			### help
		echo ; echo -e "\t\t\tcommand list"
		echo ; echo -e "\tjak - jak1 \t = play jak1 in retail"
		echo ; echo -e "\tjak -jak2 \t = play jak2 in retail"
		echo ; echo -e "\t\tAdd jak1debug or jak2debug launches in debug mode"
		echo ; echo -e "\tjak -install = install OpenGoal from source"
		echo ; echo -e "\tjak -update = updates the games and OpenGoal from source"
		echo ; echo -e "\tjak -jak1install = installs jak1"
		echo ; echo -e "\tjak - jak2install = installs jak2"
		echo ; echo -e "\tjak -cmd = installs jak in the path that allows run from any directory as jak -YOUR COMMAND"
		echo ; echo -e "\tjak -h shows this menu"
		break;;

	-dependency)
		if [ $isRoot -eq 1  ]
		then
			Depency_install
		else
			echo ; echo "this command must be ran as root to install dependencies"
		fi
		break;;

	-update)
	if [ $isRoot -eq 0 ]
	then
		update
	else
		echo ; echo "This command can not be run as root"
		fi
	break;;
		
	-install)
		if [ $isRoot -eq 0 ]
		then
			git_run
			echo ; echo "Now run -jak1install or jak2install"
		else
			echo ; echo "This command can not be run as root"
		fi;;
	
	-cmd)
		if [ $isRoot -eq 1 ]
		then
			cp $(pwd)/jak.sh /usr/local/sbin
			mv /usr/local/sbin/jak.sh /usr/local/sbin/jak
			sudo chown $(id -un)  /usr/local/sbin/jak
			if [ -e /usr/local/sbin/jak ]
			then
				echo -e "\nJak script has succesffuly been installed and can not be ran from the command line without root"
				echo -e "\nTo do so, Please close this terminal window/tab and open a new terminal"
			else
				echo -e "\n Jak script not installed for unknown reasons Error"
			fi
		else 
			echo -e "\nPlease run this script as root to install this script into the file system"
		fi;;

	*)	echo ; echo "That's not a valid option, please add -h for help";;
#shift
esac
cd
exit
done
