cimport numpy as cnp, ezmqMessage

from ezmqMessage cimport EZMQMessage, EZMQContentType

cdef extern from "EZMQByteData.h" namespace "ezmq" :
        cdef cppclass EZMQByteData(EZMQMessage):
                EZMQByteData(cnp.uint8_t *data,  size_t dataLength)
                size_t getLength()
                cnp.uint8_t * getByteData()
                int setByteData(cnp.uint8_t * data, size_t dataLength)
                int setContentType(EZMQContentType types)

        cdef const EZMQByteData* dynamic_cast "dynamic_cast<const ezmq::EZMQByteData *>"(const EZMQMessage *)
