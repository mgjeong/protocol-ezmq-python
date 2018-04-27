@ECHO OFF

	::go to dependency directory
	set home_dir=%cd%

	IF "%~1"=="" GOTO WITH_NO_FLAG	
	IF "%~1"=="--with_dependencies" GOTO WITH_FLAG
	GOTO ERROR_INVALID_PARAM

:BUILD_DEPENDENCY
	:: Build protocol-ezmq-cpp with its dependencies
	
	CD dependencies

	:: clone protocol-ezmq-cpp if not present. Else skip cloning
	IF EXIST "protocol-ezmq-cpp" (
	ECHO EZMQ-CPP already exists. 
	) ELSE (
	::clone protocol-ezmq-cpp
	git clone git@github.sec.samsung.net:RS7-EdgeComputing/protocol-ezmq-cpp.git
	)

	cd protocol-ezmq-cpp
	CALL build_auto.bat --with_dependencies=true
	
	GOTO BUILD_EZMQ_PYTHON
	
:WITH_FLAG
	IF "%~2"=="" GOTO ERROR_INVALID_PARAM_VALUE
	IF "%~2"=="true" GOTO BUILD_DEPENDENCY
	IF "%~2"=="True" GOTO BUILD_DEPENDENCY
	GOTO ERROR_INVALID_PARAM_VALUE
	
:WITH_NO_FLAG
    ECHO Dependency option not provided. Building with --with_dependencies=false.
    GOTO BUILD_EZMQ_PYTHON	

:BUILD_EZMQ_PYTHON
	cd %home_dir%
	
	IF EXIST "dependencies/protocol-ezmq-cpp/out/windows/win32/amd64/release/ezmq.lib" (
	:: Found protocol-ezmq-cpp library. Building Cycthon now.
	SET DISTUTILS_USE_SDK=1
	SET MSSdk=1
	python setup.py build_ext --inplace
	) else ( 
	ECHO ezmq.lib not found. Try again.
	ECHO Error:: PROTOCOl-EZMQ_CPP not built properly or missing dependency.
	ECHO For Autobuild run $ build_auto.bat --with_dependencies=true
	)
	
	GOTO END
	
:ERROR_INVALID_PARAM
	ECHO Invalid parameter provided. Please re run the batch file.
	ECHO e.g. build_auto.bat --with_dependencies=true
	GOTO END
	
:END
