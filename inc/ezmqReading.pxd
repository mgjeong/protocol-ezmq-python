'''
Copyright 2018 Samsung Electronics All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License")

This is a cython header file written over Reading class in ezmq cpp library.
'''

from libcpp.string cimport string

cdef extern from "Event.pb.h" namespace "ezmq" :

	#This class contains cython declaration mapped to Reading class in ezmq cpp library.
	cdef cppclass Reading:

		#Declaration of id() API of Reading class.
                #@return: id field of reading as string
		string id()

		#Declaration of created() API of Reading class.
                #@return: created field of reading as Integer
		int created()

		#Declaration of modified() API of Reading class.
                #@return: modified field of reading as Integer
		int modified()

		#Declaration of origin() API of Reading class.
                #@return: origin field of reading as Integer
		int origin()

		#Declaration of pushed() API of Reading class.
                #@return: origin field of reading as Integer
		int pushed()

		#Declaration of name() API of Reading class.
                #@return: name field of reading as string
		string name()

		#Declaration of value() API of Reading class.
                #@return: value field of reading as string
		string value()
		
		#Declaration of device() API of Reading class.
                #@return: device field of reading as string
		string device()

		#Declaration of set_id() API of Reading class.
                #@param value: value of ID
		void set_id(const char*)

		#Declaration of set_created() API of Reading class.
                #@param value: value of created
		void set_created(int)

		#Declaration of set_modified() API of Reading class.
                #@param value: value of modified
		void set_modified(int)

		#Declaration of set_origin() API of Reading class.
                #@param value: value of origin
		void set_origin(int)

		#Declaration of set_pushed() API of Reading class.
                #@param value: value of pushed
		void set_pushed(int)

		#Declaration of set_pushed() API of Reading class.
                #@param value: value of name
		void set_name(const char*)

		#Declaration of set_pushed() API of Reading class.
                #@param value: value of value
		void set_value(const char*)

		#Declaration of set_device() API of Reading class.
                #@param value: value of device
		void set_device(const char*)
