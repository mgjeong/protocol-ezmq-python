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
'''

import sys, time, struct, thread
sys.path.append("..") 
from build import ezmqcy as ezmq
from abc import ABCMeta, abstractmethod

counter=1
gServerPublicKey = "tXJx&1^QE2g7WCXbF.$$TVP.wCtxwNhR8?iLi&S<"
gClientPublicKey = "-QW?Ved(f:<::3d5tJ$[4Er&]6#9yr=vha/caBc("
gClientSecretKey = "ZB1@RS6Kv^zucova$kH(!o>tZCQ.<!Q)6-0aWFmW"

def printData(eventMessage, **kwargs):
	print "CALLBACK COUNTER :: ", globals()["counter"]
	globals()["counter"] += 1
	dataType = eventMessage.getContentType()
        print "CONTENT TYPE :: ", ezmq.contentString(dataType)
	if "topic" in kwargs:
		print "CALLBACK IS FOR TOPIC :: ", kwargs["topic"]
	if dataType is 0:
		print "DEVICE :: ", eventMessage.device()
		size = eventMessage.reading_size()
		print "Reading size :: ", size
		loop = 0
		while loop < size:
			print "  KEY :: ", eventMessage.mutable_reading(loop).name()
			print "  VALUE :: ", eventMessage.mutable_reading(loop).value()
			loop += 1
	
	elif dataType is 1:
		data = bytearray(eventMessage.getByteData())
		dataLength = eventMessage.getLength()
		print "BYTE DATA ", list(data[0:dataLength])
		print "BYTE DATA LENGTH ", dataLength
	
	print "==========================================================="

class callback(ezmq.pyCallbacks):
	def subTopicDataCB(self, topicStr, eventMessage):
		printData(eventMessage, topic=topicStr)
	
	def subDataCB(self, eventMessage):
		printData(eventMessage)

def printError():
	print "Re-Run subscriber samples with option as follows:\n"
	print "\t1. Subscribing without topic :\n\t python subscriber.py ip=localhost port=5562\n"
	print "\t2. Subscribing without topic [SECURED] :\n\t python subscriber.py ip=localhost port=5562 secured=1\n"
	print "\t3. Subscribing with topic :\n\t python subscriber.py ip=localhost port=5562 topic=topicName\n"
	print "\t4. Subscribing with topic [SECURED] :\n\t python subscriber.py ip=localhost port=5562 topic=topicName secured=1\n"
	exit()
def getArgs():
	if len(sys.argv) == 1:
		printError()
	ip = ""
	port = 0
	topic = ""
	secured = 0
	for elem in sys.argv:
		argName = elem.split("=")[0].lower()
		if(argName == "ip"):
			ip=elem.split("=")[1]
		elif(argName == "port"):
			port=elem.split("=")[1]
		elif(argName == "topic"):
			topic=elem.split("=")[1]
		elif(argName == "secured"):
			if elem.split("=")[1] is "1":
				secured = 1
	return ip, port, topic, secured

print "Running subscriber sample.\n"
# Getting args
ip, port, topicStr, secured = getArgs()
print "-----------------------------------------------------------"
if(ip is ""):
	ip = "localhost"
	print "USING DEFAULT IP :: ", ip
else:
	print "USING IP :: ", ip

if(port is 0):
	port = 5562
	print "USING DEFAULT PORT :: ", port
else:
	print "USING PORT :: ", port

topicSub = ""
if(topicStr is ""):
	print "========>SUBSCRIBING WITH NO TOPIC"
	print "========>TO USE TOPIC run subscriber topic=topicName"
else:
	if ',' in topicStr:
		topicSub = [str(elem) for elem in topicStr.split(",")]
	else:
		topicSub = topicStr
	print "USING TOPIC :: ", topicStr
if secured == 1:
	print "SECURITY ENABLED FOR SAMPLE."
print "-----------------------------------------------------------"

print "\nCreating ezmq API object"
apiObj = ezmq.pyEZMQAPI()
print "Python ezmqApi object created successfully"
print "EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus())
print "Initializing ezmqApi object"
ret = apiObj.initialize()
print "Initializing API RESULT", ezmq.errorString(ret)
print "EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus())
print "Creating ezmq Subscriber object"
cb = callback()
subscriber = ezmq.pyEZMQSubscriber(ip, int(port), cb)
if subscriber is None:
	print "FAILED TO GET Subscription object for ", ip, port
	print "RERUN Subscriber as :: \"$python subscriber.py ip=\'Publisher IP\' port=5562\""
	exit()

print "Python ezmqSubscriber object created successfully"
print "\nSUBCRIPTION IP   :", subscriber.getIp()
print "SUBCRIPTION PORT : ", subscriber.getPort()
if secured == 1:
	print "Setting Server and Client Keys"
	try:
		subscriber.setServerPublicKey(gServerPublicKey)
		subscriber.setClientKeys(gClientSecretKey, gClientPublicKey)
	except Exception as e:
		print "Exception caught for Settings server And client keys\n", e
		exit()
	print "Successfully set server and client keys."

print "Starting Subscription"
ret = subscriber.start()
print "Subscription started ::", ezmq.errorString(ret) 
if topicSub == "":
	print "SUBSCRIBING without TOPIC." 
	ret = subscriber.subscribe()
else:
	print "SUBSCRIBING with topic :: ", topicSub
	ret = subscriber.subscribe(topic=topicSub) 

print "Subscription result :: ", ezmq.errorString(ret)

print "==================================================="
try :
	while 1:
		time.sleep(2)
except(KeyboardInterrupt):
	print "Keyboard interupt has been encountered. Stopping Subscriber"

if topicSub == "":
        print "UNSUBSCRIBING without TOPIC."
        ret = subscriber.unSubscribe()
else:
        print "UNSUBSCRIBING with topic :: ", topicSub
        ret = subscriber.unSubscribe(topic=topicSub)

print "UnSubscription result :: ", ezmq.errorString(ret)
ret = subscriber.stop()
print "Subscription stopped with no topic :: ", ezmq.errorString(ret)
ret = apiObj.terminate()
print "Terminating API. RESULT ::", ezmq.errorString(ret)
