# Build protocol-ezmq-python for windows[64-bit : amd64]:
	How to build and run ezmq python samples on windows.

# Prerequisites for windows: 
=================
1. Python 2.7.0
2. Cython 0.28.0
3. Visual Studio 15 update 3
   - https://my.visualstudio.com/Downloads?q=visual%20studio%202015&wt.mc_id=o~msft~vscom~older-downloads
   - On launching the installer select custom and in that select Visual C++.

To Build "protocol-ezmq-python" For windows (auto build process) :
========================================================================
1. Open windows command line and call vcvarsall.bat.
    (a) $ cd C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
    (b) $ call vcvarsall.bat amd64
        - The above script will turn cmd to visual studio terminal.
2. cd ~/protocol-ezmq-python
3. run build_auto.bat
	(This will generate the "ezmqpy.pyd" under ~/protocol-ezmq-python/build directory
		on successfull build).

To Build "protocol-ezmq-python" For windows (Step-by-step process) : 
====================================================================
1. Open windows command line and call vcvarsall.bat.
    (a) $ cd C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
    (b) $ call vcvarsall.bat amd64
        - The above script will turn cmd to visual studio terminal.
2. Build "protocol-ezmq-cpp" For WINDOWS: 
	a. cd ~/protocol-ezmq-python/dependencies/ 
	b. git clone https://github.com/edgexfoundry-holding/protocol-ezmq-cpp.git
	c. cd protocol-ezmq-cpp
	d. Follow instruction in ~/protocol-ezmq-cpp/README_windows.txt
		to build protocol-ezmq-cpp for windows.
		OR
 	   run $ build_auto.bat --with_dependencies=true
3. cd ~/protocol-ezmq-python
4. SET DISTUTILS_USE_SDK=1
5. SET MSSdk=1
6. python setup.py build_ext --inplace
   or
   python setup.py build_ext --inplace -Dsecured
   or
   python setup.py build_ext --inplace -Ddebug
	(This will generate the "ezmqpy.pyd" under ~/protocol-ezmq-python/build directory
		on successfull build).
	(NOTE : Please build "protocol-ezmq-cpp" and its dependencies under 'dependencies' folder.)


# Prerequisites for linux[32 and 64 bit]:
=================
1. Python 2.7.0
2. Cython
	$ "sudo pip install Cython"
3. numpy
	$ "sudo pip install numpy"

To Build "protocol-ezmq-python" For LINUX (auto build process): 
=================================================================
1. cd ~/protocol-ezmq-python
2. For 32 bit :
    ./build_auto.sh --with_dependencies=true --target_arch=x86
	(This will generate the "ezmqpy.so" under ~/protocol-ezmq-python/build directory
		on successfull build).
3. For 64 bit :
    ./build_auto.sh --with_dependencies=true --target_arch=x86_64
 
To Build "protocol-ezmq-python" For LINUX (Step-by-step process): 
=================================================================
1. cd ~/protocol-ezmq-python/dependencies
2. git clone https://github.com/edgexfoundry-holding/protocol-ezmq-cpp.git
3. cd protocol-ezmq-cpp
4. Build all using command :
     $ "./build_auto.sh --with_dependencies=true --target_arch=x86"
	OR
     $ "./build_auto.sh --with_dependencies=true --target_arch=x86_64"
	(Note : This will build 'protocol-ezmq-cpp' and its dependencies.)
5. cd ../.. (to return to ~/protocol-ezmq-python directory)
6. python setup.py build_ext --inplace
	OR
	python setup.py build_ext --inplace -Dsecured
	OR
	python setup.py build_ext --inplace -Ddebug -Dsecured
	
	(This will generate the "ezmqpy.so" under ~/protocol-ezmq-python/build directory
		on successfull build).

# Running samples for protocol-ezmq-python : 
============================================
1. cd ~/protocol-ezmq-python/samples
	Run publisher as : $python publisher.py
		OR $python publisher.py topic=/home/livingroom
	Run subscriber as : $python subscriber.py
		OR $python subscriber.py topic=/home/livingroom
		OR $python subscriber.py topic=/home/livingroom,/home/kitchen

