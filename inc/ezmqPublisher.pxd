'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over EZMQPublisher class in ezmq cpp library.
'''

cimport ezmqErrorCode
from libcpp.string cimport string
from ezmqErrorCode cimport  EZMQErrorCode
from ezmqMessage cimport EZMQMessage, EZMQContentType

#Callback declarations mapped to callbacks in EZMQPublisher.
#Callbacks to get error codes for start/stop of EZMQ publisher.
#Note: As of now not being used.
ctypedef void (*EZMQStartCB)(EZMQErrorCode code)
ctypedef void (*EZMQStopCB)(EZMQErrorCode code)
ctypedef void (*EZMQErrorCB)(EZMQErrorCode code)

cdef extern from "EZMQPublisher.h" namespace "ezmq" :
        
	#This class contains cython declarations mapped to EZMQPublisher class in ezmq cpp library
	#It contains API declarations for EZMQPublisher class.
	cdef cppclass EZMQPublisher:

		#Declaration of Construtor for EZMQPublisher class.
		#@param port - Port to be used for publisher socket.
		#@param startCB- Start callback.
		#@param stopCB - Stop Callback.
		#@param errorCB - Error Callback.
		EZMQPublisher(int port, EZMQStartCB startCB, EZMQStopCB stopCB, EZMQErrorCB errorCB)

		EZMQErrorCode setServerPrivateKey(const string key)
		
		#Declaration of start() API of EZMQPublisher class.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode start()

		#Declaration of publish() API of EZMQPublisher class.
		#@param event - event to be published.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode publish(EZMQMessage &event)

		#Declaration of publish() API of EZMQPublisher class.
		#@param topic - Topic on which event needs to be published.
		#@param event - event to be published.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode publish(string topic, EZMQMessage &event)

		#Declaration of stop() API of EZMQPublisher class.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		EZMQErrorCode stop()

		#Declaration of getPort() API of EZMQPublisher class.
		#@return port number as integer.
		int getPort()
