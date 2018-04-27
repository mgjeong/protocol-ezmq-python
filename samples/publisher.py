import sys, time, struct
sys.path.append("..") 
from build import ezmqpy as ezmq

print("Running publisher sample ")
port = 5562
topic = ""
print("Creating ezmq API object")
apiObj = ezmq.pyEZMQAPI()
print("Python ezmqApi object created successfully")
print("EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus()))
print("Initializing ezmqApi object")
ret = apiObj.initialize()
print("Initializing API RESULT", ezmq.errorString(ret))

print("EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus()))
print("Creating Byte data object")
event = bytearray([94, 91, 101, 125, 111, 35, 120, 101, 115, 101, 200, 255, 
			250, 13,])
length = len(event)
print("CREATED DATA : ", list(event))
print("CREATED DATA LENGTH : ", length)
byteData = ezmq.pyEZMQByteData(event, length)
print("ByteData event Object created successfully")

print("Creating ezmq Publisher object")
publisher = ezmq.pyEZMQPublisher(port)
print("Python ezmqPublisher object created successfully")
print("Starting ezmq publisher")
ret = publisher.start()
print("Starting Publisher RESULT", ezmq.errorString(ret))
i = 1
while(i<10):
	time.sleep(2)
	ret = publisher.publish(byteData)
	print(i, ' EVENT Published :: ', ezmq.errorString(ret))
	print(" DATA : ", list(event))
	print("DATA LENGTH : ", length)
	i += 1

print("PUBLISHER TERMINATED")
