import sys, time, struct, thread
sys.path.append("..") 
from build import ezmq
from abc import ABCMeta, abstractmethod

class callback(ezmq.pyCallbacks):
	def subByteDataCB(self, eventMessage):
		print("CALLBACK RECEIVED IN PYTHON")
		ret = eventMessage.getContentType()
		print("CONTENT TYPE :: ", ezmq.contentString(ret))
		data = bytearray(eventMessage.getByteData())
		dataLength = eventMessage.getLength()
		print("BYTE DATA ", list(data[0:dataLength]))
		print("BYTE DATA LENGTH ", dataLength)

	def subTopicByteDataCB(self, topic, event):
		print("INSIDE CALLBACK 1 in PYTHON")

print("Running subscriber sample.")
port = 5562
ip = "localhost"
topic = ""
print("Creating ezmq API object")
apiObj = ezmq.pyEZMQAPI()
print("Python ezmqApi object created successfully")
print("EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus()))
print("Initializing ezmqApi object")
ret = apiObj.initialize()
print("Initializing API RESULT", ezmq.errorString(ret))
print("EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus()))
print("Creating ezmq Subscriber object")
cb = callback()
subscriber = ezmq.pyEZMQSubscriber(ip, port, cb)
if subscriber is None:
	print("FAILED TO GET Subscription object for ", ip, port)
	exit()

print("Python ezmqSubscriber object created successfully")
print("SUBCRIPTION IP   :", subscriber.getIp())
print("SUBCRIPTION PORT : ", subscriber.getPort())

print("Starting Subscription")
ret = subscriber.start()
print("Subscription started with no topic :: ", ezmq.errorString(ret))
subscriber.subscribe()

while 1:
	time.sleep(2)
