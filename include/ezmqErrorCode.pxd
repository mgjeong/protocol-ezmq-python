import ezmq

cdef extern from "EZMQErrorCodes.h" namespace "ezmq" :
	ctypedef enum EZMQErrorCode "ezmq::EZMQErrorCode" :
		EZMQ_OK "ezmq::EZMQ_OK",
		EZMQ_ERROR "ezmq::EZMQ_ERROR",
		EZMQ_INVALID_TOPIC "ezmq::EZMQ_INVALID_TOPIC",
		EZMQ_INVALID_CONTENT_TYPE "ezmq::EZMQ_INVALID_CONTENT_TYPE"
	ctypedef enum EZMQStatusCode:
		EZMQ_Unknown "ezmq::EZMQ_Unknown",
		EZMQ_Constructed "ezmq::EZMQ_Constructed",
		EZMQ_Initialized "ezmq::EZMQ_Initialized",
		EZMQ_Terminated "ezmq::EZMQ_Terminated"
