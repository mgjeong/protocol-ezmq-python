'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over EZMQAPI class in ezmq cpp library.
'''

from ezmqErrorCode cimport EZMQErrorCode, EZMQStatusCode

cdef extern from "EZMQAPI.h" namespace "ezmq" :
	#This class contains cython declarations mapped to EZMQAPI class in ezmq cpp library.
	#It contains declarations of APIs related to initialization, termination of EZMQ stack
	cdef cppclass EZMQAPI:

		#This is declaration to native EZMQAPI constructor.
		#@return: native instance of EZMQAPI
		EZMQAPI() except +

		#This is declaration to EZMQAPI initialize() API.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode initialize()

		#This is declaration to EZMQAPI terminate() API.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode terminate()

		#This is declaration to EZMQAPI getStatus() API.
		#@return EZMQStatusCode - Current status of EZMQ Service.
		EZMQStatusCode getStatus()

	#This declaration has been mapped to EZMQAPI::getInstance in ezmq library.
	#@return Instance of EZMQAPI(native).
	cdef EZMQAPI* EZMQAPI_GetInstance "ezmq::EZMQAPI::getInstance"()
