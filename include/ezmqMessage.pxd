cdef extern from "EZMQMessage.h" namespace "ezmq" :
        ctypedef enum EZMQContentType:
                EZMQ_CONTENT_TYPE_PROTOBUF,
                EZMQ_CONTENT_TYPE_BYTEDATA,
                EZMQ_CONTENT_TYPE_AML,
                EZMQ_CONTENT_TYPE_JSON

        cdef cppclass EZMQMessage:
                EZMQContentType getContentType()
                int setContentType(EZMQContentType types)
