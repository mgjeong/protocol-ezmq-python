from libcpp.list cimport list as clist
from libcpp.string cimport string
from cython.operator cimport dereference as deref
from ezmqErrorCode cimport  EZMQErrorCode
from ezmqMessage cimport EZMQMessage, EZMQContentType

ctypedef void (*EZMQSubCB)(const EZMQMessage &event)
ctypedef void (*EZMQSubTopicCB)(string topic, EZMQMessage &event)

cdef extern from "EZMQSubscriber.h" namespace "ezmq" :
	cdef cppclass EZMQSubscriber:
		EZMQSubscriber(string ip, int port, EZMQSubCB subCB, EZMQSubTopicCB subTopicCB)
		EZMQErrorCode start()
		EZMQErrorCode subscribe()
		EZMQErrorCode subscribe(string topic)
		EZMQErrorCode unSubscribe()
		EZMQErrorCode unSubscribe(string topic)
		EZMQErrorCode unSubscribe(clist)
		EZMQErrorCode stop()
		int getPort()
		string& getIp()
