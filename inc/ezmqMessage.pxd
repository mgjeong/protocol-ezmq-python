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

This is a cython header file written over EZMQMessage class in ezmq cpp library.
'''

cdef extern from "EZMQMessage.h" namespace "ezmq" :
	
	#This declaration is mapped to EZMQContentType enum in ezmq cpp library.
	ctypedef enum EZMQContentType "ezmq::EZMQContentType":
		EZMQ_CONTENT_TYPE_PROTOBUF "ezmq::EZMQ_CONTENT_TYPE_PROTOBUF",
		EZMQ_CONTENT_TYPE_BYTEDATA "ezmq::EZMQ_CONTENT_TYPE_BYTEDATA",
		EZMQ_CONTENT_TYPE_AML "ezmq::EZMQ_CONTENT_TYPE_AML",
		EZMQ_CONTENT_TYPE_JSON "ezmq::EZMQ_CONTENT_TYPE_JSON"

	#This class contains cython declarations mapped to EZMQMessage class in ezmq cpp library
	#It contains API declarations for EZMQMessage class.
	cdef cppclass EZMQMessage:
                
		#Declaration of getContentType() API of EZMQMessage class.
		#@return content type.
		EZMQContentType getContentType()

		#Declaration of setContentType() API of EZMQMessage class.
		#@return EZMQErrorCode - EZMQ_OK on success, otherwise appropriate error code.
		int setContentType(EZMQContentType types)
