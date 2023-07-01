#!/bin/bash
#
#this install script will support all 3 major linux distrubtions
#
#This program was written by Damon
#
$arch=3
clear ; echo "This install script has more features planned and is currently in beta, I plan to make it playable from the command line without ever locating it"
echo ; echo "This program was written by Richerman, If you have any issues please let me know on discord"
echo ; echo "This program looks for a jak2 folder at ~/Documents and installs at ~/Games/jak-project"
$jakiso = 0 
while ( $jakiso -eq 0 )
	do
		if ( test ~/Documents/jak2 || test ~/Documents/Jak2 )
		then 
			echo ; echo "Jak2 folder has been found."
			$jakiso=1
		else
			echo ; echo "jak2 folder not found."
		read -p "\nProgram will now pause, please extract your jak2.iso into a folder named jak2 at ~/Documents and press enter when ready to continue" enter

	fi
done
$dependstrue = 1 ; while ( $dependstrue -eq 1 )
do
	read -p "\nDo you need dependencies installed as well?\nenter y or n" depends
		if ( depends = y )
			then
				echo "\ninstalling depencies for your distrubtion based on your package manager"
				$dependstrue = 2
	
		elif ( depends = n )
			then
				echo "\nWill not install dependencies"
				
		else 
			then
				echo "\nSorry that is not a valid option. Please enter y for yes and n for no"

		fi
done
if ( test cd Games/jak-project/ )			### test for /Games/jak-project
	then 
		cd Games/ ; rm -rf jak-project/
		git clone https://github.com/open-goal/jak-project
		test cp ~/Documents/Jak2 ~/Games/jak-project/iso_data
		test cp ~/Documents/jak2 ~/Games/jak-project/iso_data
elif
	then
		if ( test cd Games/ )
			then
				echo
		elif
		then
			mkdir Games/ ; cd Games/
		fi
fi


#####						install depencies packages
if ( $dependstrue -eq 2 )
	then

		if ( test which apt )
		then
			sudo apt install clang lld gcc make cmake build-essential g++ nasm clang-format libxrandr-dev libxinerama-dev libxcursor-dev libpulse-dev libxi-dev python
			sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
			##echo ; echo "Debian based depencies installed"
			##cmake -B build && cmake --build build -j 8
			#./test.sh
			cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ ..
			./test.sh
		elif ( test which pacman )			### arch based
		then
			sudo pacman -S cmake libpulse base-devel nasm python libx11 libxrandr libxinerama libxcursor libxi
			yay -S go-task
			cmake -B build && cmake --build build -j 8
			./test.sh
			$arch = 1
		elif ( test which dnf )
		then
			sudo dnf install cmake python lld clang nasm libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pulseaudio-libs-devel mesa-libGL-devel
sudo sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin
			cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
cmake --build build -j$(nproc)
			./test.sh
		elif 
		then
			echo ; echo "couldn't identify your package manager. No dependencies installed"
			
		fi
	elif			##### install game without dependencies 
	then	
		if ( test which apt )
		then
			cmake -B build && cmake --build build -j 8
			./test.sh
				
		elif ( test which pacman )
		then
			cmake -B build && cmake --build build -j 8
			./test.sh
			$arch = 1
		elif ( test which dnf )
		then
			cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
cmake --build build -j$(nproc)
			./test.sh
		else 
		then
			echo "couldn't identify your package manager"
		fi
fi
if ( $arch -eq 1 )
then
	go-task set-game-jak2
	go-task set-decomp-ntscv1			####  which label version of the game it is \\\\\\\\\ more work needed here
	go-task extract
	clear ; echo "on the next screen, type (mi) to build the game."
	task repl
elif
then 
task set-game-jak2
task set-decomp-ntscv1
task extract
clear ; echo ; echo "on the next screen, type (mi) to build the game."
task repl
fi
