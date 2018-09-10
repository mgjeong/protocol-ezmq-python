'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over Event class in ezmq cpp library.
'''

cimport ezmqMessage
from libcpp.string cimport string
from ezmqMessage cimport EZMQMessage
from ezmqReading cimport Reading

cdef extern from "Event.pb.h" namespace "ezmq" :
	#This class contains cython declaration mapped to Event class in ezmq cpp library.
	cdef cppclass Event(EZMQMessage):

		#Declaration of id() API of Event class.
		#@return: id field of event as string
		string id()
		
		#Declaration of created() API of Event class.
		#@return: created field of event as Integer
		int created()
		
		#Declaration of modified() API of Event class.
		#@return: modified field of event as Integer
		int modified()

		#Declaration of origin() API of Event class.
		#@return: origin field of event as Integer
		int origin()

		#Declaration of pushed() API of Event class.
		#@return: pushed field of event as Integer
		int pushed()

		#Declaration of device() API of Event class.
		#@return: device field of event as string
		string device()

		#Declaration of reading_size() API of Event class.
		#@return: reading count as Integer
		int reading_size()

		#Declaration of mutable_reading() API of Event class.
		#@param index: index for which reading is required
		#@return: Reading instance
		Reading* mutable_reading(int)

		#Declaration of reading() API of Event class.
		#@param index: index for which reading is required
		#@return: Reading instance
		Reading reading(int)

		#Declaration of add_reading() API of Event class.
		#@return: new Reading instance
		Reading* add_reading()

		#Declaration of constructor of Event class.
		#@return: instance of Event
		Event()

		#Declaration of set_id() API of Event class.
		#@param value: value of ID
		Reading set_id(const char *value)

		#Declaration of set_created() API of Event class.
		#@param value: value of created
		void set_created(int value)

		#Declaration of set_modified() API of Event class.
		#@param value: value of modified
		void set_modified(int value)

		#Declaration of set_origin() API of Event class.
		#@param value: value of origin
		void set_origin(int value)

		#Declaration of set_pushed() API of Event class.
		#@param value: value of pushed
		void set_pushed(int value)

		#Declaration of set_device() API of Event class.
		#@param value: value of device
		void set_device(const char *value)

	#This declaration has been mapped to dynamic_cast call from native.
        #This is provided to cast EZMQMessage object to Event object.
	cdef const Event* dynamic_cast_event "dynamic_cast<const ezmq::Event *>"(const EZMQMessage *)

	#This declaration has been mapped to const-cast call form native for Event object.
	cdef Event* const_cast_event "const_cast<ezmq::Event*>"(const Event*)
