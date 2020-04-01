::/*******************************************************************************
:: * Copyright 2018 Samsung Electronics All Rights Reserved.
:: *
:: * Licensed under the Apache License, Version 2.0 (the "License");
:: * you may not use this file except in compliance with the License.
:: * You may obtain a copy of the License at
:: *
:: * http://www.apache.org/licenses/LICENSE-2.0
:: *
:: * Unless required by applicable law or agreed to in writing, software
:: * distributed under the License is distributed on an "AS IS" BASIS,
:: * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: * See the License for the specific language governing permissions and
:: * limitations under the License.
:: *
:: *******************************************************************************/

@ECHO OFF

	::go to dependency directory
	set home_dir=%cd%
	set dependencies=false
	set buildmode=release
	set secure=false
	
	IF "%~1"=="" GOTO BUILD_EZMQ_PYTHON
	
	:: Dependency flag check
    IF "%~1"=="--with_dependencies" (
		IF "%~2"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~2"=="true" (
		set dependencies=true
		)
	) ELSE IF "%~3"=="--with_dependencies" (
		IF "%~4"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~4"=="true" (
		set dependencies=true
		)
	)ELSE IF "%~5"=="--with_dependencies" (
		IF "%~6"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~6"=="true" (
		set dependencies=true
		)
	)
	
	:: Security flag check
    IF "%~1"=="--with_security" (
		IF "%~2"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~2"=="true" (
		set secure=true
		)
	) ELSE IF "%~3"=="--with_security" (
		IF "%~4"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~4"=="true" (
		set secure=true
		)
	)ELSE IF "%~5"=="--with_security" (
		IF "%~6"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~6"=="true" (
		set secure=true
		)
	)
	
	:: Build mode flag check
    IF "%~1"=="--build_mode" (
		IF "%~2"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~2"=="debug" (
		set buildmode=debug
		)
	) ELSE IF "%~3"=="--build_mode" (
		IF "%~4"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~4"=="debug" (
		set buildmode=debug
		)
	)ELSE IF "%~5"=="--build_mode" (
		IF "%~6"=="" GOTO ERROR_INVALID_PARAM
		
		IF "%~6"=="debug" (
		set buildmode=debug
		)
	)

	if %dependencies%==true (
	GOTO BUILD_DEPENDENCY
	)
	
	GOTO BUILD_EZMQ_PYTHON

:BUILD_DEPENDENCY
	:: Build protocol-ezmq-cpp with its dependencies
	
	CD dependencies

	:: clone protocol-ezmq-cpp if not present. Else skip cloning
	IF EXIST "protocol-ezmq-cpp" (
	ECHO EZMQ-CPP already exists. 
	) ELSE (
	::clone protocol-ezmq-cpp
	git clone git@github.com:edgexfoundry-holding/protocol-ezmq-cpp.git
	)

	cd protocol-ezmq-cpp
	
	IF %secure%==true (
	IF %buildmode%==debug (
	CALL build_auto.bat --with_dependencies=true --with_security=true --build_mode=debug
	) ELSE (
	CALL build_auto.bat --with_dependencies=true --with_security=true
	)
	) ELSE (
	IF %buildmode%==debug (
	CALL build_auto.bat --with_dependencies=true --build_mode=debug
	) ELSE (
	CALL build_auto.bat --with_dependencies=true
	)
	)
	
	GOTO BUILD_EZMQ_PYTHON

:BUILD_EZMQ_PYTHON
	cd %home_dir%
	SET DISTUTILS_USE_SDK=1
	SET MSSdk=1
	
	IF %buildmode%==debug (
		IF EXIST "dependencies/protocol-ezmq-cpp/out/windows/win32/amd64/debug/ezmq.lib" (
			IF %secure%==true (
				python setup.py build_ext --inplace -Ddebug -Dsecured
			) ELSE (
				python setup.py build_ext --inplace -Ddebug
			)
		) ELSE (
		ECHO ezmq.lib not found for debug build. Try again.
		ECHO Error:: PROTOCOl-EZMQ_CPP not built properly or missing dependency.
		ECHO For autobuild run $ build_auto.bat --with_dependencies=true --build_mode=debug
		GOTO END
		)
	) ELSE (
		IF EXIST "dependencies/protocol-ezmq-cpp/out/windows/win32/amd64/release/ezmq.lib" (
			IF %secure%==true (
				python setup.py build_ext --inplace -Dsecured
			) ELSE (
				python setup.py build_ext --inplace
			)
		) ELSE (
		ECHO ezmq.lib not found for release build. Try again.
		ECHO Error:: PROTOCOl-EZMQ_CPP not built properly or missing dependency.
		ECHO For autobuild run $ build_auto.bat --with_dependencies=true --with_security=true
		GOTO END
		)
	)
	
	GOTO END
	
:ERROR_INVALID_PARAM
	ECHO Invalid parameter provided. Please re run the batch file.
	ECHO e.g. build_auto.bat --with_dependencies=true
    ECHO e.g. build_auto.bat --with_dependencies=true --build_mode=debug
	ECHO e.g. build_auto.bat --with_dependencies=true --with_security=true --build_mode=debug
	ECHO e.g. build_auto.bat --with_security=true
	GOTO END
	
:END
