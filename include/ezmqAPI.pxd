cdef extern from "EZMQAPI.h" namespace "ezmq" :
        cdef cppclass EZMQAPI:
                EZMQAPI() except +
                int initialize()
                int terminate()
                int getStatus()

        cdef EZMQAPI* EZMQAPI_GetInstance "ezmq::EZMQAPI::getInstance"()

