cimport ezmqErrorCode
from libcpp.string cimport string
from ezmqErrorCode cimport  EZMQErrorCode
from ezmqMessage cimport EZMQMessage, EZMQContentType

ctypedef void (*EZMQStartCB)(EZMQErrorCode code)
ctypedef void (*EZMQStopCB)(EZMQErrorCode code)
ctypedef void (*EZMQErrorCB)(EZMQErrorCode code)

cdef extern from "EZMQPublisher.h" namespace "ezmq" :
        cdef cppclass EZMQPublisher:
                EZMQPublisher(int port, EZMQStartCB startCB, EZMQStopCB stopCB, EZMQErrorCB errorCB)
                EZMQErrorCode start()
                EZMQErrorCode publish(EZMQMessage &event)
                EZMQErrorCode publish(string topic, EZMQMessage &event)
                EZMQErrorCode stop()
                int getPort()

