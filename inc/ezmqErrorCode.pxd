'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over EZMQErrorCode enum in ezmq cpp library.
'''

cdef extern from "EZMQErrorCodes.h" namespace "ezmq" :

	#This declaration is mapped to EZMQErrorCode enum in ezmq cpp library.
	ctypedef enum EZMQErrorCode "ezmq::EZMQErrorCode" :
		EZMQ_OK "ezmq::EZMQ_OK",
		EZMQ_ERROR "ezmq::EZMQ_ERROR",
		EZMQ_INVALID_TOPIC "ezmq::EZMQ_INVALID_TOPIC",
		EZMQ_INVALID_CONTENT_TYPE "ezmq::EZMQ_INVALID_CONTENT_TYPE"

	#This declaration is mapped to EZMQStatusCode enum in ezmq cpp library.
	ctypedef enum EZMQStatusCode:
		EZMQ_Unknown "ezmq::EZMQ_Unknown",
		EZMQ_Constructed "ezmq::EZMQ_Constructed",
		EZMQ_Initialized "ezmq::EZMQ_Initialized",
		EZMQ_Terminated "ezmq::EZMQ_Terminated"
