# cython: linetrace=True
# cython: binding=True
'''
/*******************************************************************************
 * Copyright 2018 Samsung Electronics All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 *******************************************************************************/

Documentation for EZMQ_PYTHON

`ezmqcy` is a cython binding module written over protocol-ezmq-cpp(libezmq) so as to expose ezmq api's to python applications.
Some sample subscriber and publisher are provided to show use of API's.
'''

from inc cimport ezmqPublisher, ezmqMessage, ezmqErrorCode, ezmqByteData, ezmqAPI, ezmqSubscriber, ezmqEvent, ezmqReading
from abc import ABCMeta, abstractmethod
from libcpp.list cimport list as clist
from libcpp.string cimport string
from libc.stdio cimport printf
from cython.operator cimport dereference as deref
from inc.ezmqErrorCode cimport  *
from inc.ezmqMessage cimport * 
from inc.ezmqPublisher cimport EZMQPublisher
from inc.ezmqSubscriber cimport EZMQSubscriber
from inc.ezmqByteData cimport EZMQByteData, dynamic_cast, const_cast
from inc.ezmqAPI cimport EZMQAPI, EZMQAPI_GetInstance 
from inc.ezmqEvent cimport Event, dynamic_cast_event, const_cast_event 
from inc.ezmqReading cimport Reading
import logging as log

if LOG_LEVEL == 'debug':
	log.basicConfig(level=log.DEBUG)

if SECURED:
	print "SECURED ENABLED"
else:
	print "SECURED DISABLED" 
def __invalidInputException(cause):
	log.error("Raising valuErrpr exception for " + cause)
	raise ValueError("ERROR : " + cause)

class pyCallbacks(metaclass=ABCMeta):
	''' 
	Python abstract callback class.
	This class contains two abstract callbacks to be implemented by subscriber.
 	Application must implement and pass instance of this class to constructor of pypyEZMQSubscriber to get callbacks.
		e.g. : subscriber = ezmq.pyEZMQSubscriber(ip, port, cb)
		cb is an instance of callbacks class that implements pyCallbacks.'''

	@abstractmethod
	def subTopicDataCB(self, topic, pyEZMQMessage data):
		'''
		Implement this to get callbacks for subscribed topics only.'''
		raise NotImplementedError("Callback is an abstract class")
	@abstractmethod
	def subDataCB(self, pyEZMQMessage data):
		'''
		Implement this to get general callbacks from publishers.
		This callback is called for both with and without topics.'''
		raise NotImplementedError("Callback is an abstract class")

class _Singleton(type):
	_instances = {}
	def __call__(cls, *args, **kwargs):
		if cls not in cls._instances:
			cls._instances[cls] = super(_Singleton, cls).__call__(*args, **kwargs)
		return cls._instances[cls]

class _cythonClass(object):
	__metaclass__ = _Singleton
	def setCallbacks(self, callbackObj):
		log.debug("_cythonClass :: Setting callbacks here")
		self.callbacks = callbackObj
	def callSubCB(self, pyEZMQMessage data, **kwargs):
		if "topic" in kwargs:
			log.debug("_cythonClass :: Calling callbacks for topic : %s" % kwargs["topic"])
			return self.callbacks.subTopicDataCB(kwargs["topic"], data)
		else:
			log.debug("_cythonClass :: Calling callbacks for no topic")
			return self.callbacks.subDataCB(data)

cdef void _cy_subCB(const EZMQMessage &event) with gil:
	ret = event.getContentType()
	if ret is 1:
		log.debug("_cy_subCB :: calling _pyEZMQByteData_factory")
		data = _pyEZMQByteData_factory(dynamic_cast(&event))
		_cythonClass().callSubCB(data)
	elif ret is 0:
		log.debug("_cy_subCB :: calling _pyEvent_factory")
		data = _pyEvent_factory(dynamic_cast_event(&event))
		_cythonClass().callSubCB(data)
	log.debug("_cy_subCB :: Exiting")

cdef void _cy_subTopicCB(string topicStr, const EZMQMessage &event) with gil:
	ret = event.getContentType()
	if ret is 1:
		log.debug("_cy_subTopicCB:: calling _pyEZMQByteData_factory")
		data = _pyEZMQByteData_factory(dynamic_cast(&event))
		_cythonClass().callSubCB(data, topic=topicStr)
	else:
		log.debug("_cy_subTopicCB:: calling _pyEvent_factory")
		data = _pyEvent_factory(dynamic_cast_event(&event))
		_cythonClass().callSubCB(data, topic=topicStr)
	log.debug("_cy_subTopicCB :: Exiting")

cdef void _cy_startCB(EZMQErrorCode code):
	log.debug("I am in Start Callback")

cdef void _cy_stopCB(EZMQErrorCode code):
	log.debug("I am in Stop Callback")

cdef void _cy_errorCB(EZMQErrorCode code):
	log.debug("I am in ERROR Callback")

def errorString(value):
	'''
	errorString(value)
	This is a method to get Error String value for passed EZMQErrorCode if present.
	@param value: EZMQErrorCode
	@return: String'''
	return {
		EZMQ_OK:"EZMQ_OK",
		EZMQ_ERROR:"EZMQ_ERROR",
		EZMQ_INVALID_TOPIC:"EZMQ_INVALID_TOPIC",
		EZMQ_INVALID_CONTENT_TYPE:"EZMQ_INVALID_CONTENT_TYPE",
	}[value]

def statusString(value):
	'''
        statusString(value)
        This is a method to get Status String value for passed EZMQStatusCode if present.
        @param value: EZMQStatusCode
        @return: String'''
	return {
		EZMQ_Unknown:"EZMQ_Unknown",
		EZMQ_Constructed:"EZMQ_Constructed",
		EZMQ_Initialized:"EZMQ_Initialized",
		EZMQ_Terminated:"EZMQ_Terminated",
	}[value]

def contentString(value):
	'''
        contentString(value)
        This is a method to get Content String value for passed EZMQContentType if present.
        @param value: EZMQContentType
        @return: String'''
	return {
		EZMQ_CONTENT_TYPE_PROTOBUF:"EZMQ_CONTENT_TYPE_PROTOBUF",
		EZMQ_CONTENT_TYPE_BYTEDATA:"EZMQ_CONTENT_TYPE_BYTEDATA",
		EZMQ_CONTENT_TYPE_AML:"EZMQ_CONTENT_TYPE_AML",
		EZMQ_CONTENT_TYPE_JSON:"EZMQ_CONTENT_TYPE_JSON",
	}[value]

cdef class pyEZMQAPI:
	'''
	This class contains APIs related to EZMQ stack.
	e.g. : apiObj = ezmq.pyEZMQAPI()'''

	cdef EZMQAPI* ezmqApi
	
	def __cinit__(self):
		'''
		__cinit__(self)
		Constructor.
		The constructor invokes the instance of native EZMQAPI
		and stores it in a pointer to native object.
		All future API calls are made on this native instance.'''
		log.debug("pyEZMQAPI :: Calling EZMQAPI_GetInstance")
		self.ezmqApi = EZMQAPI_GetInstance()
	
	def initialize(self):
		'''
		Initializes all required EZMQ components.
		This API should be called first, before using any other EZMQ APIs.
		@return: EZMQErrorCode'''
		log.debug("pyEZMQAPI :: Initializing")
		return self.ezmqApi.initialize()
	
	def terminate(self):
		'''
		Terminates all initialized EZMQ components.
		This API should be called to clean up at the end of EZMQ stack use.
		@return: EZMQErrorCode'''
		log.debug("pyEZMQAPI :: Terminating")
		return self.ezmqApi.terminate()
	
	def getStatus(self):
		'''
		Get the current status of EZMQ Service.
		This API can be used to check the status of the EZMQ stack.
		@return: EZMQStatusCode'''
		log.debug("pyEZMQAPI :: getStatus called")
		return self.ezmqApi.getStatus()

cdef class pyEZMQMessage:
	'''
	This class is a parent class for event types.
	It is used for typcasting bytedata/protobuf data for publishing OR
	when receiving callbacks, it is typecasted into bytedata/protobuf data.'''
	cdef  EZMQMessage* msg
	def __cinit__(self):
		log.debug("pyEZMQMessage :: Empty constructor called")
		pass
	def getContentType(self):
		'''
		Get the content-type of EZMQMessage instance.
		@return: integer for EZMQ content type'''
		log.debug("pyEZMQMessage :: Get content type called")
		return self.msg.getContentType()
	def setContentType(self, types):
		'''
		Set content type of EZMQMessage.
		EZMQByteData will set it as EZMQ_CONTENT_TYPE_BYTEDATA.
		and Event will set as EZMQ_CONTENT_TYPE_PROTOBUF by default.
		@param types: content-type to be set
		@return: Integer for EZMQ Error Code'''
		log.debug("pyEZMQMessage :: Set content type called")
		return self.msg.setContentType(types)

cdef class pyEZMQByteData(pyEZMQMessage):
	'''
	This class is derived from pyEZMQMessage for bytedata messages types.
	It contains a pointer to native EZMQByteData instance.
	
	e.g :: data = ezmq.pyEZMQByteData()
	       data.init(event, len(event)) [event is of type  bytearray]'''	
	cdef EZMQByteData* bd
	cdef public int deleteFlag
	'''
	This flag is set when EZMQByteData instance is created in python.
	Thus python knows it has to delete the native instance.
	Destructor not needed to be called explicitly.'''
	def __cinit__(self):
		'''
		This creates an empty pyEZMQByteData object, with no reference to native.
		A reference must be set by calling init API for new and using factory
		APIs to set reference to existing native object.'''
		log.debug("pyEZMQByteData :: Default constructor called")
		self.bd = self.msg = NULL
		self.deleteFlag = 0
	def init(self, data, dataLength):
		'''
                This creates a new EZMQByteData instance in python
                and stores it in a pointer to a native object.
		It also sets the delete flag used by python garbage collector to free it.
		@param data: Byte Data
		@param dataLength : Data length'''
		log.debug("pyEZMQByteData :: Initializing ByteData")
		self.bd = self.msg = new EZMQByteData(data, dataLength)
		self.deleteFlag = 1
	def __dealloc__(self):
		'''
		__dealloc__(self)
		Destructor is invoked id delete flat is set.
		This needs not to be called explicitly.
		It is automatically invoked when it goes out of scope.'''
		if self.bd is not NULL and self.deleteFlag is 1:
			log.debug("pyEZMQByteData :: Deleting native object")
			del self.bd
	def getLength(self):
		'''
		Get length of data.
		@return: Length of data.'''
		log.debug("pyEZMQByteData :: get length called")
		return self.bd.getLength()
	def getByteData(self):
		'''
		Get Byte data object holds.
		@return: byte data'''
		log.debug("pyEZMQByteData :: get byte data called")
		return self.bd.getByteData()
	def setByteData(self, data, dataLength):
		'''
		Set Byte data.
		This API is used to update existing data
		@param data: Byte Data
		@param dataLength: Data Length.
		@return: EZMQErrorCode.''' 
		log.debug("pyEZMQByteData :: set byte data called")
		return self.bd.setByteData(data, dataLength)

cdef object _pyEZMQByteData_factory(const EZMQByteData *ptr):
	''' Factory function for pyEZMQByteData class to store reference of existing
	native object in python object'''
	log.debug("_pyEZMQByteData_factory :: factory method invoked")
	cdef  pyEZMQByteData py_obj = pyEZMQByteData()
	py_obj.bd = py_obj.msg = const_cast(ptr)
	log.debug("_pyEZMQByteData_factory :: factory method exiting")
	return py_obj

cdef class pyEZMQPublisher:
	'''
	This class contains the APIs related to start, stop publish APIs.
	It contains a pointer to native EZMQPublisher instance.
	e.g. : publisher = ezmq.pyEZMQPublisher(int port)
	       publisher.start()
	       publisher.publish(data) [data is of type pyEZMQMessage]'''
	cdef EZMQPublisher* pub
	def __cinit__(self, port):
		'''
                __cinit__(self, port)
                Constructor.
                The constructor creates a new EZMQPublisher instance
                and stores it in a pointer to a native object.
                @param port: Port to be used for publisher socket.
                @param _cy_startCB: start callback
                @param _cy_stopCB: start callback
                @param _cy_errorCB: start callback'''
		log.debug("pyEZMQPublisher :: constructor called with port")
		self.pub = new EZMQPublisher(port, _cy_startCB, _cy_stopCB, _cy_errorCB)
	def __dealloc__(self):
		if self.pub is not NULL:
			log.debug("pyEZMQPublisher :: deleting native object here")
			del self.pub
	def publish(self, pyEZMQMessage event, **kwargs):
		'''
                Publish events on a specific topic  on the socket for subscribers.

		e.g.:: ===>publisher.publish(data)
				for publishing without topic
		       ===>publisher.publish(data, topic=/home/livingroom)
				for publishing with topic 
				
                @param event: event to be published
                @type event: L{pyEZMQMessage}
		@param topic: [Optional] Topic on which event is to be published.
		@type topic: String
		@note: (1) Topic name should be as path format. E.g.'home/livingroom/'
	               (2) Topic name can have letters [a-z, A-z], numerics [0-9] 
				and special characters _ - . and /
                @return: Integer for EZMQ error code.'''
		if "topic" in kwargs:
			log.debug("pyEZMQPublisher :: publish with topic called here. Topic %s" % kwargs["topic"])
			return self.pub.publish(kwargs["topic"], deref(event.msg))
		else:
			log.debug("pyEZMQPublisher :: publish without topic called here")
			return self.pub.publish(deref(event.msg))
	def setServerPrivateKey(self, key):
		'''
		Set the server private/secret key.
		@param key: Server private/Secret key.
		@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		@note: (1) Key should be 40-character string encoded in the Z85 encoding format <br>
			(2) This API should be called before start() API.'''
		if SECURED:
			try:
				log.debug("pyEZMQPublisher :: setServerPrivateKey called here")
				return self.pub.setServerPrivateKey(key)
			except Exception as e:
				__invalidInputException(e)
		else:
			__invalidInputException("Secure API unavailable. Build stack in secure mode.")
	def start(self):
		'''
		Start publisher instance.
		@return: Integer for stack error codes'''
		log.debug("pyEZMQPublisher :: publish start called")
		return self.pub.start()
	def stop(self):
		'''
		Stop publisher instance.
		@return: Integer for stack error codes.'''
		log.debug("pyEZMQPublisher :: publish stop called")
		return self.pub.stop()
	def getPort(self):
		'''
		Get the port of the publisher.
		@return: Integer port number'''
		log.debug("pyEZMQPublisher :: publish get port called")
		return self.pub.getPort()

cdef class pyEZMQSubscriber:
	'''
        This class contains the APIs related to start, stop subscriber APIs.
        It contains a pointer to native EZMQSubscriber instance.
	e.g. :: ==> subscriber = ezmq.pyEZMQSubscriber(string ip, int port, cb)
			cb is instance of implementation of ezmq.pyCallbacks class.
		==> subscriber.start()

		==>subscriber.subscribe() or ==>subscriber.subscribe(topic=topicStr)'''
	cdef EZMQSubscriber* sub
	def __cinit__(self, ip, port, subCB):
		'''
                __init__(self, port)
                Constructor.
                The constructor creates a new EZMQSubscriber instance
                and stores it in a pointer to a native object.
                @param ip: IP to be used for subscriber socket.
                @param port: Port to be used for subscriber socket.
                @param _cy_subCB: subscriber callback to receive events
                @param _cy_subTopicCB: subscriber callback to receive events for a particular topi'''
		log.debug("pyEZMQSubscriber :: constructor called here")		
		_cythonClass().setCallbacks(subCB)
		log.debug("pyEZMQSubscriber :: callback objects have been set")
		self.sub = new EZMQSubscriber(ip, port, _cy_subCB, _cy_subTopicCB)
	def __dealloc__(self):
		if self.sub is not NULL:
			log.debug("pyEZMQSubscriber :: Deleting native object here")	
			del self.sub
	def setClientKeys(self, clientPrivateKey, clientPublicKey):
		'''
		Set the security keys of client/its own.
		@param clientPrivateKey - Client private/secret key.
		@param clientPublicKey - Client public key.
		@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		@note
			(1) Key should be 40-character string encoded in the Z85 encoding format <br>
			(2) This API should be called before start() API.'''
		if SECURED:
			try:
				log.debug("pyEZMQSubscriber :: setClientKeys called here")
				return self.sub.setClientKeys(clientPrivateKey, clientPublicKey)
			except Exception as e:
				__invalidInputException(e)
		else:
			__invalidInputException("Secure API unavailable. Build stack in secure mode.")
	def setServerPublicKey(self, key):
		'''
		Set the server public key.
		@param key - Server public key.
		@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		@note
			(1) Key should be 40-character string encoded in the Z85 encoding format <br>
			(2) This API should be called before start() API. <br>
			(3) If using the following API in secured mode: <br>
			   subscribe(const std::string &ip, const int &port, std::string topic);
			   setServerPublicKey API needs to be called before that.'''
		if SECURED:
			try:
				log.debug("pyEZMQSubscriber :: setServerPublicKey called here")
				return self.sub.setServerPublicKey(key)
			except Exception as e:
				__invalidInputException(e)
		else:
			__invalidInputException("Secure API unavailable. Build stack in secure mode.")
	def start(self):
		'''
		Start the subscriber instance.
		@return: EZMQErrorCodes'''
		log.debug("pyEZMQSubscriber :: subscription start called here")
		return self.sub.start()
	def subscribe(self, **kwargs):
		'''
		Subscribe for an event/message on a particular topic or otherwise.
		@param topic: [Optional] Topic on which event is to be subscribed.
                @type topic: L{string}
		@type topic: L{list}
		@note: (1) Topic name should be as path format. E.g.'home/livingroom/'
                       (2) Topic name can have letters [a-z, A-z], numerics [0-9]
                                and special characters _ - . and /.
		@return: EZMQErrorCodes.
		Usage : e.g. subscriber = ezmq.pyEZMQSubscriber(ip, int(port), cb)
			     subscriber.start()
		
				subscriber.subscribe() 
					// Subscribe without topic
				subscriber.subscribe(topic=topicString)
					// Subscribe with topic string
				subscriber.subscribe(topic=topicList)
					// Subscribe with topic List'''
		log.debug("pyEZMQSubscriber :: Subscribe called.")
		if "ip" in kwargs:
			if  "port" in kwargs:
				log.debug("pyEZMQSubscriber :: Subscribing with ip, port and topic %s %s %s" 
					% kwargs["ip"] % kwargs["port"] % kwargs["topic"])
				return self.sub.subscribe(kwargs["ip"], kwargs["port"], kwargs["topic"])
		elif "topic" in kwargs:
			if isinstance(kwargs["topic"], list) :
				log.debug("pyEZMQSubscriber :: Subscribing with topic list")
				return self.sub.subscribe(<clist[string]>kwargs["topic"])
			elif isinstance(kwargs["topic"], str):
				log.debug("pyEZMQSubscriber :: Subscribing with topic string : %s" % kwargs["topic"])
				return self.sub.subscribe(<string>kwargs["topic"])
			else:
				__invalidInputException("INVALID topic type")
		else:
			log.debug("pyEZMQSubscriber :: Subscribing without topic")
			return self.sub.subscribe()
	def unSubscribe(self, **kwargs):
		'''
		Unsubscribe for an event/message on a specific topic 
		or Unsubscribe all the events/message from publishers.
		@param topic: [Optional] Topic on which event is to be unsubscribed.
		@type topic: string
		@type topic: list
		@return: EZMQErrorCode
		Usage : e.g. subscriber = ezmq.pyEZMQSubscriber(ip, int(port), cb)
			     subscriber.start()

                                subscriber.unSubscribe()
                                        // Unsubscribe without topic
                                subscriber.unSubscribe(topic=topicString)
                                        // Unsubscribe with topic string
                                subscriber.unSubscribe(topic=topicList)
                                        // Unsubscribe with topic List'''
		log.debug("pyEZMQSubscriber :: unSubscribe called here")
		if "topic" in kwargs:
			if isinstance(kwargs["topic"], list) :
				log.debug("pyEZMQSubscriber :: unSubscribing with topic list")
				return self.sub.unSubscribe(<clist[string]>kwargs["topic"])
			elif isinstance(kwargs["topic"], str):
				log.debug("pyEZMQSubscriber :: unSubscribing with topic string%s" % kwargs["topic"])
				return self.sub.unSubscribe(<string>kwargs["topic"])
			else:
				__invalidInputException("INVALID topic type")
		else:
			log.debug("pyEZMQSubscriber :: unSubscribing without topic")
			return self.sub.unSubscribe()
	def stop(self):
		'''
                Stop the subscriber instance.
                @return: EZMQErrorCodes'''
		log.debug("pyEZMQSubscriber :: subscription stop called")
		return self.sub.stop()
	def getPort(self):
		'''
		Get port of subscriber.
		@return: Integer of port.'''
		log.debug("pyEZMQSubscriber :: subscribe get port called")
		return self.sub.getPort()
	def getIp(self):
		'''
		Get IP address
		@return: IP address as string.
		'''
		log.debug("pyEZMQSubscriber :: subscribe get ip called")
		return self.sub.getIp()

cdef class pyReading:
	'''
        An instance of this class is returned for the add_event API of pyEvent class. 
        It contains a pointer to native Reading instance.'''
	cdef Reading* reading
	def __cinit__(self):
		log.debug("pyReading:: empty constructor called")
		pass
	def id(self):
		'''
		Get id field of reading instance.
		@return: ID as string'''
		log.debug("pyReading:: get id called")
		return self.reading.id()
	def name(self):
		'''
                Get name(key-value) field of reading instance.
                @return: name as string'''
		log.debug("pyReading:: get name called")
		return self.reading.name()
	def value(self):
		'''
                Get value(key-value) field of reading instance.
                @return: value as string'''
		log.debug("pyReading:: get value called")
		return self.reading.value()
	def device(self):
		'''
                Get device field of reading instance.
                @return: device as string'''
		log.debug("pyReading:: get device called")
		return self.reading.device()
	def created(self):
		'''
                Get created field of reading instance.
                @return: created as Integer'''
		log.debug("pyReading:: get created called")
		return self.reading.created()
	def modified(self):
		'''
                Get modified field of reading instance.
                @return: modified as Integer'''
		log.debug("pyReading:: get modified called")
		return self.reading.modified()
	def origin(self):
		'''
                Get origin field of reading instance.
                @return: origin as Integer'''
		log.debug("pyReading:: get origin called")
		return self.reading.origin()
	def pushed(self):
		'''
                Get pushed field of reading instance.
                @return: pushed as Integer'''
		log.debug("pyReading:: get pushed called")
		return self.reading.pushed()
	def set_id(self, value):
		'''
                Set ID field of reading instance.
                @param value: value of ID
		@type value: const char*'''
		log.debug("pyReading:: set id called")
		self.reading.set_id(value)
	def set_created(self, value):
		'''
                Set created field of reading instance.
                @param value: value of created
                @type value: Integer'''
		log.debug("pyReading:: set created called")
		self.reading.set_created(value)
	def set_modified(self, value):
		'''
                Set modified field of reading instance.
                @param value: value of modified
                @type value: Integer'''
		log.debug("pyReading:: set modified called")
		self.reading.set_modified(value)
	def set_origin(self, value):
		'''
                Set origin field of reading instance.
                @param value: value of origin
                @type value: Integer'''
		log.debug("pyReading:: set origin called")
		self.reading.set_origin(value)
	def set_pushed(self, value):
		'''
                Set pushed field of reading instance.
                @param value: value of pushed
                @type value: Integer'''
		log.debug("pyReading:: set pushed called")
		self.reading.set_pushed(value)
	def set_device(self, value):
		'''
                Set device field of reading instance.
                @param value: value of device.
                @type value: const char*'''
		log.debug("pyReading:: set device called")
		self.reading.set_device(value)
	def set_name(self, value):
		'''
                Set name of reading instance.
                @param value: value of name(key-value).
                @type value: const char*'''
		log.debug("pyReading:: set name called")
		self.reading.set_name(value)
	def set_value(self, value):
		'''
                Set ID field of reading instance.
                @param value: value of value(key-value).
                @type value: const char*'''
		log.debug("pyReading:: set value called")
		self.reading.set_value(value)

cdef class pyEvent(pyEZMQMessage):
	'''
        This class is derived from pyEZMQMessage class for protobuf messages.
        It contains a pointer to native Event instance.

	e.g. :: event = ezmq.pyEvent()
		event.init()

	Attributes :
		deleteFlag : This flag is set when native instance is created in python'''

	cdef Event* event
	cdef public int deleteFlag
	'''
        This flag is set when Event instance is created in python.
        Thus python knows it has to delete the native instance.
        Destructor need not to be called explicitly.'''
	def __cinit__(self):
		'''This creates an empty pyEvent object, with no reference to native.
                A reference must be set by calling init API for new or by using factory
                APIs to set the reference to existing native object.'''
		log.debug("pyEvent:: constructor called")
		self.event = self.msg = NULL
		self.deleteFlag = 0
		pass
	def init(self):
		'''This creates a new Event instance in python and stores it
		 in a pointer to a native object. It also sets the delete flag, 
		used by python garbage collector to free it.'''
		log.debug("pyEvent:: initialize event native object called")
		self.event = self.msg = new Event()
		self.deleteFlag = 1
	def __dealloc__(self):
		'''
                Destructor is invoked if delete flag is set.
                This need not to be called explicitly.
                It is automatically invoked when object goes out of scope.'''
		if self.event is not NULL and self.deleteFlag is 1:
			log.debug("pyEvent:: delete native object called")
			del self.event
	def id(self):
		'''
		Get ID field of the event
		@return: id as string'''
		log.debug("pyEvent:: get id called")
		return self.event.id()
	def created(self):
		'''
                Get created field of the event
                @return: created as Integer'''
		log.debug("pyEvent:: get created called")
		return self.event.created()
	def modified(self):
		'''
                Get modified field of the event
                @return: modified as Integer'''
		log.debug("pyEvent:: get modified called")
		return self.event.modified()
	def origin(self):
		'''
                Get origin field of the event
                @return: origin as Integer'''
		log.debug("pyEvent:: get origin called")
		return self.event.origin()
	def pushed(self):
		'''
                Get pushed field of the event
                @return: pushed as Integer'''
		log.debug("pyEvent:: get pushed called")
		return self.event.pushed()
	def device(self):
		'''
                Get device field of the event
                @return: device as string'''
		log.debug("pyEvent:: get device called")
		return self.event.device()
	def reading_size(self):
		'''
                Get reading count of the event
                @return: reading count as Integer'''
		log.debug("pyEvent:: get reading size called")
		return self.event.reading_size()
	def reading(self, index):
		pass
	def mutable_reading(self, index):
		'''
                Get reading for a given index of the event
		@param index: index for which reading is required
                @return: instance of pyReading containing pointer to Reading instance'''
		log.debug("pyEvent:: mutable reading called")
		read = pyReading()
		read.reading = self.event.mutable_reading(index)
		log.debug("pyEvent:: returning pyReading object here")
		return read
	def add_reading(self):
		'''
		Initialize pyReading instance for pyEvent and stores their native pointers.
		All Reading APIs are to be called on this instance.
                @return: instance of pyReading containing pointer to new Reading instance'''
		log.debug("pyEvent:: add reading called")
		read = pyReading()
		read.reading = self.event.add_reading()
		log.debug("pyEvent:: returning pyReading object here")
		return read
	def set_id(self, value):
		'''
		Set ID field of the event.
		@param value: value of ID
		@type value: Integer'''
		log.debug("pyEvent:: set id called")
		self.event.set_id(value)
	def set_created(self, value):
		'''
                Set created field of the event.
                @param value: value of created
                @type value: Integer'''
		log.debug("pyEvent:: set created called")
		self.event.set_created(value)
	def set_modified(self, value):
		'''
                Set modified field of the event.
                @param value: value of modified
                @type value: Integer'''
		log.debug("pyEvent:: set modified called")
		self.event.set_modified(value)
	def set_origin(self, value):
		'''
                Set origin field of the event.
                @param value: value of origin
                @type value: Integer'''
		log.debug("pyEvent:: set origin called")
		self.event.set_origin(value)
	def set_pushed(self, value):
		'''
                Set pushed field of the event.
                @param value: value of pushed
                @type value: Integer'''
		log.debug("pyEvent:: set pushed called")
		self.event.set_pushed(value)
	def set_device(self, value):
		'''
                Set device field of the event.
                @param value: value of device
                @type value: const char*'''
		log.debug("pyEvent:: set device called")
		self.event.set_device(value)

cdef object _pyEvent_factory(const Event *ptr):
	'''Factory method for pyEvent class to store an existing native reference
	into the python object.'''
	log.debug("_pyEvent_factory:: factory method of Event class called here")
	cdef pyEvent py_obj = pyEvent()
	py_obj.event = py_obj.msg = const_cast_event(ptr)
	log.debug("_pyEvent_factory:: factory method of Event exiting")
	return py_obj
