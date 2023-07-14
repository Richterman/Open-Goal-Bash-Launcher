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
Upate() {
	jak1=0
	jak2=0
	if [ cd $install_location ]
	then 
		cd ~/
		if [ cd $install_location/iso_data/jak1 ]
		then
			mv $install_location/iso_data/jak1 ~/
			jak1=1
		else 
			echo
		fi
		if [ cd $install_location/iso_data/jak2 ]
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
	if [ $jak1 = 1 ]
	then
		mv ~/jak1 $install_location/iso_data
	elif
		echo
	fi
	if [ $jak2 = 1 ]
	then
		mv ~/jak2 $install_location/iso_data/
	elif
		echo
	fi
	if [ $jak1 = 1 ]
	then
		python ./scripts/tasks/update-env.py --game jak1
		python ./scripts/tasks/update-env.py --decomp_config $version
	{{.DECOMP_BIN_RELEASE_DIR}}/decompiler ; ./decompiler/config/{{.DECOMP_CONFIG}} ; ./iso_data ; ./decompiler_out ; --version ; {{.DECOMP_CONFIG_VERSION}} ;  --config-override ; {\"decompile_code\": false, \"levels_extract\": true, \"allowed_objects\": []}'"	
		./goalc --cmd "(mi)"
		clear ; echo "jak1 installed"
	else
		echo ; echo "jak1 not installed "
	fi
	if [ $jak2 = 2 ]
	then
		python ./scripts/tasks/update-env.py --game jak2
		python ./scripts/tasks/update-env.py --decomp_config $version
		"{{.DECOMP_BIN_RELEASE_DIR}}/decompiler \"./decompiler/config/{{.DECOMP_CONFIG}}\" \"./iso_data\" \"./decompiler_out\" --version \"{{.DECOMP_CONFIG_VERSION}}\" --config-override '{\"decompile_code\": false, \"levels_extract\": true, \"allowed_objects\": []}'"
		./goalc --cmd "(mi)"
		clear ; echo "Jak2 installed"
	else
		echo ; echo "Jak2 not installed"
	fi
	else 	
	echo ; echo "Games not installed, please run -install option"
	fi	
}

Depency_install() {
local distro
case $distro in
	arch) 
		pacman -S cmake libpulse base-devel nasm python libx11 libxrandr libxinerama libxcursor libxi
		sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin ;;
	debian)
		apt install gcc make cmake build-essential g++ nasm clang-format libxrandr-dev libxinerama-dev libxcursor-dev libpulse-dev libxi-dev python lld clang
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin;;
	redhat)
	sudo dnf -y install cmake python lld clang nasm libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pulseaudio-libs-devel mesa-libGL-devel
sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin;;
esac		
}
##################################################### command line options The actual program

echo ; while [ -n "$1" ]
do
case "$1" in
	-jak1)						### play jak 1
		if [ cd $insatll_location/jak1 ]
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
		if [ cd $install_location/jak1 ]
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
		if [ cd $install_location/iso_data/jak2 ]
		then
			cd $install_location
			echo ; echo "Booting in retail"
			{{.GK_BIN_RELEASE_DIR}}/GK -v --game {{.GAME}} -- -boot -fakeiso
		else 
			echo ; echo "Jak2 not installed"
		fi;;
	-jak2debug)	### play jak 2 in debug
		if [ cd $install_location/jak2 ]
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
	
	-h || -help)			### help
		echo ; echo -e "\t\t\tcommand list"
		echo ; echo -e "\tjak - jak1 \t = play jak1 in retail"
		echo ; echo -e "\tjak -jak2 \t = play jak2 in retail"
		echo ; echo -e "\t\tAdd jak1debug or jak2debug launches in debug mode"
		echo ; echo -e "\tjak -install = install the game from source"
		echo ; echo -e "\tjak -update = updates the games from source"
		echo ; echo -e "\tjak -h shows this menu"
		break;;
		
	-install)
		Depency_install


	

	*)	echo ; echo "That's not a valid option, please add -h for help";;
#shift
esac
exit
done
