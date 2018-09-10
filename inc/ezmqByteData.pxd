'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over EZMQByteData class in ezmq cpp library.
'''

cimport numpy as cnp, ezmqMessage

from ezmqMessage cimport EZMQMessage, EZMQContentType
from ezmqErrorCode cimport EZMQErrorCode

cdef extern from "EZMQByteData.h" namespace "ezmq" :
	#This class contains cython declarations mapped to EZMQByteData class in ezmq cpp library
	#It contains API declarations for EZMQByteData class.
        cdef cppclass EZMQByteData(EZMQMessage):

		#Declaration of Construtor for EZMQByteData.
		#@param data - Byte data.
		#@param dataLength - Data length.
		#@return: native instance of EZMQByteData
                EZMQByteData(cnp.uint8_t *data,  size_t dataLength)

		#Declaration of getLength() API of EZMQByteData class.
		#@return Length of data.
                size_t getLength()

		#Declaration of getByteData() API of EZMQByteData class.
		#@return data - byte data.
                cnp.uint8_t * getByteData()

		#Declaration of setByteData() API of EZMQByteData class.
		#return: EZMQErrorCode 
                EZMQErrorCode setByteData(cnp.uint8_t * data, size_t dataLength)

	#This declaration has been mapped to dynamic_cast call from native.
	#This is provided to cast EZMQMessage object to EZMQByteData object.
        cdef const EZMQByteData* dynamic_cast "dynamic_cast<const ezmq::EZMQByteData *>"(const EZMQMessage *)

	#This declaration has been mapped to const-cast call form native for EZMQByteData object. 
        cdef EZMQByteData* const_cast "const_cast<ezmq::EZMQByteData*>"(const EZMQByteData*)
