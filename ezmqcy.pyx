cimport numpy as cnp, ezmqPublisher, ezmqMessage, ezmqErrorCode, ezmqByteData, ezmqAPI, ezmqSubscriber
from abc import ABCMeta, abstractmethod
from libcpp.list cimport list as clist
from libcpp.string cimport string
from libc.stdio cimport printf
from cython.operator cimport dereference as deref
from ezmqErrorCode cimport  EZMQErrorCode
from ezmqMessage cimport EZMQMessage, EZMQContentType
from ezmqPublisher cimport EZMQPublisher
from ezmqSubscriber cimport EZMQSubscriber
from ezmqByteData cimport EZMQByteData, dynamic_cast
from ezmqAPI cimport EZMQAPI, EZMQAPI_GetInstance

class pyCallbacks(metaclass=ABCMeta):
	@abstractmethod
	def subByteDataCB(self, pyEZMQByteData data):
		raise NotImplementedError("Callback is an abstract class")
	@abstractmethod
	def subTopicByteDataCB(self, topic, pyEZMQByteData data):
		pass

class Singleton(type):
	_instances = {}
	def __call__(cls, *args, **kwargs):
		if cls not in cls._instances:
			cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
		return cls._instances[cls]

class cythonClass(object):
	__metaclass__ = Singleton
	def setCallbacks(self, callbackObj):
		self.callbacks = callbackObj
	def callSubCB(self, pyEZMQByteData data):
		return self.callbacks.subByteDataCB(data)

cdef void cy_subCB(const EZMQMessage &event) with gil:
	ret = event.getContentType()
	if ret is 1:
		byteData = dynamic_cast(&event)
		data = bytearray(byteData.getByteData())
		length = byteData.getLength()
		byteObject = pyEZMQByteData(data, length)
		cythonClass().callSubCB(byteObject)

cdef void cy_subTopicCB(string topic, const EZMQMessage &event):
	ret = event.getContentType()
	print("CONTENT TYPE : ", contentString(ret))
	if ret is 0:
		print("CONTENT TYPE :: EZMQ_CONTENT_TYPE_PROTOBUF")
	else:
		print("CONTENT TYPE :: EZMQ_CONTENT_TYPE_BYTEDATA")

cdef void cy_startCB(EZMQErrorCode code):
	print("I am in Start Callback")

cdef void cy_stopCB(EZMQErrorCode code):
	print("I am in Stop Callback")

cdef void cy_errorCB(EZMQErrorCode code):
	print("I am in ERROR Callback")

def errorString(value):
	return {
		0:"EZMQ_OK",
		1:"EZMQ_ERROR",
		2:"EZMQ_INVALID_TOPIC",
		3:"EZMQ_INVALID_CONTENT_TYPE",
	}[int(value)]

def statusString(value):
	return {
		0:"EZMQ_Unknown",
		1:"EZMQ_Constructed",
		2:"EZMQ_Initialized",
		3:"EZMQ_Terminated",
	}[int(value)]

def contentString(value):
	return {
		0:"EZMQ_CONTENT_TYPE_PROTOBUF",
		1:"EZMQ_CONTENT_TYPE_BYTEDATA",
		2:"EZMQ_CONTENT_TYPE_AML",
		3:"EZMQ_CONTENT_TYPE_JSON",
	}[int(value)]

cdef class pyEZMQAPI:
	cdef EZMQAPI* ezmqApi
	def __cinit__(self):
		self.ezmqApi = EZMQAPI_GetInstance()
		if self.ezmqApi is NULL:
			print("FAILED TO GET EZMQ API INSTANCE")
		else:
			print("EZMQ API GET INSTANCE SUCCESSFULL")
	def initialize(self):
		return self.ezmqApi.initialize()
	def terminate(self):
		return self.ezmqApi.terminate()
	def getStatus(self):
		return self.ezmqApi.getStatus()

cdef class pyEZMQMessage:
	cdef EZMQMessage* msg
	def __cinit__(self):
		self.msg = new EZMQMessage()
		if self.msg is NULL:
			print("ERROR : FAILED TO GET EZMQ MESSAGE OBJECT")
		else:
			print("EZMQ MESSAGE OBJECT CREATED SUCCESSFULLY")
	def getContentType(self):
		return self.msg.getContentType()
	def setContentType(self, types):
		return self.msg.setContentType(types)

cdef class pyEZMQByteData(pyEZMQMessage):
	cdef EZMQByteData* bd
	def __cinit__(self, data, dataLength):
		self.bd = self.msg = new EZMQByteData(data, dataLength)	
		if self.bd is NULL:
			print("ERROR : FAILED TO GET EZMQ BYTEDATA OBJECT")
		else:
			print("EZMQ BYTEDATA OBJECT CREATED SUCCESSFULLY")
	def getLength(self):
		return self.bd.getLength()
	def getByteData(self):
		return self.bd.getByteData()
	def setByteData(self, data, dataLength):
		return self.bd.setByteData(data, dataLength)

cdef class pyEZMQPublisher:
	cdef EZMQPublisher* pub
	def __cinit__(self, port):
		self.pub = new EZMQPublisher(port, cy_startCB, cy_stopCB, cy_errorCB)
		if self.pub is NULL:
			print("ERROR : FAILED TO GET EZMQ PUBLISHER OBJECT")
		else:
			print("EZMQ PUBLISHER OBJECT CREATED SUCCESSFULLY")
	def publish(self, pyEZMQMessage event):
		return self.pub.publish(deref(event.msg))
	def publish(self, topic, pyEZMQMessage event):
		return self.pub.publish(topic, deref(event.msg))
	def start(self):
		return self.pub.start()
	def stop(self):
		return self.pub.stop()
	def getPort(self):
		return self.pub.getPort()

cdef class pyEZMQSubscriber:
	cdef EZMQSubscriber* sub
	def __cinit__(self, ip, port, subCB):
		cythonClass().setCallbacks(subCB)
		self.sub = new EZMQSubscriber(ip, port, cy_subCB, cy_subTopicCB)
		if self.sub is NULL:
			print("ERROR : FAILED TO GET EZMQ SUBSCRIBER OBJECT")
		else:
			print("EZMQ SUBSCRIBER OBJECT CREATED SUCCESSFULLY")
	def start(self):
		return self.sub.start()
	def subscribe(self):
		return self.sub.subscribe()
	def stop(self):
		return self.sub.stop()
	def getPort(self):
		return self.sub.getPort()
	def getIp(self):
		return self.sub.getIp()
