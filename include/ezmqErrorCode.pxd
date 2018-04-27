import ezmq

cdef extern from "EZMQErrorCodes.h" namespace "ezmq" :
	ctypedef enum EZMQErrorCode:
		EZMQ_OK,
		EZMQ_ERROR,
		EZMQ_INVALID_TOPIC,
		EZMQ_INVALID_CONTENT_TYPE
	ctypedef enum EZMQStatusCode:
		EZMQ_Unknown = 0,
		EZMQ_Constructed,
		EZMQ_Initialized,
		EZMQ_Terminated

