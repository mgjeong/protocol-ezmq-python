# Build protocol-ezmq-python for windows[64-bit : amd64]:
	How to build and run ezmq python samples on windows.

# Prerequisites for windows: 
=================
1. Python 2.7.0
2. Cython 0.28.0
3. Visual C++ compiler for python2.7 (CommandPrompt)
4. Visual Studio 15 update 3
   - https://my.visualstudio.com/Downloads?q=visual%20studio%202015&wt.mc_id=o~msft~vscom~older-downloads
   - On launching the installer select custom and in that select Visual C++.
5. Built protocol-ezmq-cpp library(zmq and protobuf)

To Build "protocol-ezmq-cpp" : 
==============================
1. cd ~/protocol-ezmq-python 
2. git clone https://github.sec.samsung.net/RS7-EdgeComputing/protocol-ezmq-cpp.git
3. cd protocol-ezmq-cpp
4. Follow instruction in ~/protocol-ezmq-python/README_windows.txt
	to build protocol-ezmq-cpp for windows.
	
To Build "protocol-ezmq-python" For windows : 
=============================================
1. Open windows command line in admin mode and call vcvarsall.bat.
    (a) $ cd C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
    (b) $ call vcvarsall.bat amd64
        - The above script will turn cmd to visual studio terminal.
2. cd ~/protocol-ezmq-python
3. SET DISTUTILS_USE_SDK=1
4. SET MSSdk=1
5. python setup.py build_ext --inplace
	(This will generate the "ezmqpy.pyd" under ~/protocol-ezmq-python/build directory
		on successfull build).
	(NOTE : PLEASE BUILD "protocol-ezmq-cpp" AND ITS DEPENDENCIES FIRST.)
	
To Build "protocol-ezmq-python" For LINUX : 
===========================================
1. cd ~/protocol-ezmq-python
2. git clone https://github.sec.samsung.net/RS7-EdgeComputing/protocol-ezmq-cpp.git
3. cd protocol-ezmq-cpp
4. Build all using command : $"./build_auto.sh --with_dependencies=true --target_arch=x86"
5. cd ..
6. python setupLINUX.py build_ext -i
	(This will generate the "ezmqpy.so" under ~/protocol-ezmq-python/build directory
		on successfull build).
	(NOTE : PLEASE BUILD "protocol-ezmq-cpp" AND ITS DEPENDENCIES FIRST.)

# Running samples for protocol-ezmq-python : 
============================================
1. cd ~/protocol-ezmq-python/samples
	Run publisher as : $python publisher.py
	Run subscriber as : $python subscriber.py



