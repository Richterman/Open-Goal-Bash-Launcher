#!/bin/bash
#
#### this script is very much a work in progress
###### this is a total rewrite of the first script supporting cmd line arguments
#
echo
echo
distro=unkown

Git_install() {
if ( cd ~/Games/jak-project )
then
	if ( cd ~/Games/jak-project/iso_data/jak1 )
	then
		cp ~/Games/jak-project/iso_data/jak1 ~/Documents
	fi
	if ( cd ~/Games/jak-project/iso_data/jak2 )
	then
		cp ~/Games/jak-project/iso_data/jak2 ~/Documents
	fi
	cd ~/Games/ ; git clone https://github.com/open-goal/jak-project
	Distrocheck
	cd jak-project/
	if [[ $distro = debian || $distro = arch ]]
	then
	cmake -B build && cmake --build build -j 8
	./test.sh
	else
	cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
	cmake --build build -j$(nproc)
	./test.sh
	fi
	cp ~/Documents/jak1/ ~/Games/jak-project/iso_data/ ; cp ~/Documents/jak2/ ~/Games/jak-project/iso_data/
elif ( cd ~/Games )
then
	cd ~/Games/ ; git clone https://github.com/open-goal/jak-project
	Distrocheck
	cd jak-project/
	if ( $distro = debian || $distro = arch )
	then
	cmake -B build && cmake --build build -j 8
	./test.sh
	else
	cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
	cmake --build build -j$(nproc)
	./test.sh
	fi

	cp ~/Documents/jak1/ ~/Games/jak-project/iso_data/ ; cp ~/Documents/jak2/ ~/Games/jak-project/iso_data/
	echo ; echo "Jak1 folder and Jak2 folder copied from ~/Documents"
else
mkdir ~/Games
cd ~/Games/ ; git clone https://github.com/open-goal/jak-project
	Distrocheck
	cd jak-project/
	if [ $distro = debian || $distro = arch ]
	then
	cmake -B build && cmake --build build -j 8
	./test.sh
	else
	cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
	cmake --build build -j$(nproc)
	./test.sh
	fi

	cp ~/Documents/jak1/ ~/Games/jak-project/iso_data/ ; cp ~/Documents/jak2/ ~/Games/jak-project/iso_data/
	echo ; echo "Jak1 folder and Jak2 folder copied from ~/Documents"
fi

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
	-1)						### play jak 1
		cd ~/Games/jak-project
		if [ $distro != arch ]
		then
			task set-game-jak1
			task boot-game-retail
		else 
			go-task set-game-jak1
			go-task boot-game-retail
		fi;;
	-2)						### play jak 2
		cd ~/Games/jak-project
		if [ $distro != arch ]
		then
			echo ; echo "Warning!! Jak2 can only be played in debug mode" ; task set-game-jak2
			task boot-game
		else 
			echo ; echo "Warning!! Jak2 can only be played in debug mode" ; go-task set-game-jak2
			go-task boot-game
		fi;;
	-h)			### help
		echo ; echo "-1 = play jak1, -2 = play jak2, -jak1i = install jak1, jak2i = install jak2, build = install jak 1 and jak 2"
		echo ; echo "please press -h to show this again"
		echo ; echo "run the depencdy check to add this script to /usr/local/bin so you can run directly from cmd line"
		break;;
	-d) 				## install depencies
	if [ whoami = root ]
	then
			Distrocheck
			Depency_install
			cp $( pwd ) /usr/local/bin
			mv /usr/local/bin/jak.sh /usr/local/bin/jak
	else
		echo ; echo "Error!! Please run this script as root to install depencies"
		exit
		fi;;

	-build)									## build both games
	echo ; echo "This command will also rebuild from source"
			Git_install
			cd ~/Games/jak-project
			if [ $distro != arch ]
			then
				task set-game-jak1 ; task set-decomp-ntscv1 ; task extract
				echo ; echo "build game"
				./goalc --cmd "(mi)"
			else
				go-task set-game-jak1 ; go-task set-decomp-ntscv1 ; go-task extract
				./goalc --cmd "(mi)"
				fi
				cd ~/Games/jak-project/
			if [ $distro != arch ]
			then
				task set-game-jak2 ; task set-decomp-ntscv1 ; task extract
				./goalc --cmd "(mi)"
				exit
			else
				go-task set-game-jak2 ; go-task set-decomp-ntscv1 ; go-task extract
				./goalc --cmd "(mi)"
				exit
				fi ;;

	-jak1i)				## install jak1 and source
			echo ; echo "This command will also rebuild from source"
			Git_install
			cd ~/Games/jak-project
			if [ $distro != arch ]
			then
				task set-game-jak1 ; task set-decomp-ntscv1 ; task extract
				./goalc --cmd "(mi)"
			else
				go-task set-game-jak1 ; go-task set-decomp-ntscv1 ; go-task extract
				./goalc --cmd "(mi)"
				fi ;;
	-jak2i)					## install jak2 and source
					echo ; echo "This command will also rebuild from source"
			Git_install
			cd ~/Games/jak-project/
			if [ $distro != arch ]
			then
				task set-game-jak2 ; task set-decomp-ntscv1 ; task extract
				task repl
			else
				go-task set-game-jak2 ; go-task set-decomp-ntscv1 ; go-task extract
				go-task replace
				fi ;;

	*)	echo ; echo "That's not a valid option, please add -h for help";;
#shift
esac
exit
done
