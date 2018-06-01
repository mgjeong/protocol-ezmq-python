import sys, time, struct
sys.path.append("..") 
from build import ezmqpy as ezmq

def getEventData():
	event = ezmq.pyEvent()
	event.init()
	event.set_device("device")
	event.set_created(10)
	event.set_modified(20)
	event.set_id("id")
	event.set_pushed(10)
	event.set_origin(20)

	read1 = event.add_reading()
	read1.set_name("reading1")
	read1.set_value("10")
	read1.set_created(25)
	read1.set_device("device")
	read1.set_modified(20)
	read1.set_id("id1")
	read1.set_origin(25)
	read1.set_pushed(1)

	read2=event.add_reading()
	read2.set_name("reading2")
	read2.set_value("20")
	read2.set_created(30)
	read2.set_device("device")
	read2.set_modified(20)
	read2.set_id("id2")
	read2.set_origin(25)
	read2.set_pushed(1)
	
	print "CRETAED EVENT DATA DEVICE ", event.device()
	size = event.reading_size()
	print "Reading size :: ", size
	loop = 0
	while loop < size:
		print "   KEY :: ", event.mutable_reading(loop).name()
		print "   VALUE :: ", event.mutable_reading(loop).value()
		loop += 1
	return event

def getDataType():
	print "======================================================="
	dataType = int(input("WHAT DATA TO PUBLISH ?  PLEASE ENTER(1 OR 2)\n"
                        "1 : PROTOBUF      2 : BYTEDATA\n"))
	return dataType

def getArgs():
	port = 0
	topicStr = ""
	for elem in sys.argv:
		argName = elem.split("=")[0].lower()
		if(argName == 'topic'):
			topicStr = elem.split("=")[1]
		elif(argName == 'port'):
			port = elem.split("=")[1]
		
	return port, topicStr
print "Running publisher sample\n"
port, topicStr = getArgs()
print "-----------------------------------------------------------"
if port is 0:
        port = 5562
        print "USING DEFAULT PORT :: ", port
else:
        print "USING PORT :: ", port

if topicStr is "":
        print "========>SUBSCRIBING WITH NO TOPIC"
        print "========>TO USE TOPIC run subscriber topic=topicName"
else:
        print "USING TOPIC :: ", topicStr
print "-----------------------------------------------------------"

print "Creating ezmq API object"
apiObj = ezmq.pyEZMQAPI()
print "Python ezmqApi object created successfully"
print "EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus())
print "\nInitializing ezmqApi object"
ret = apiObj.initialize()
print "Initializing API RESULT", ezmq.errorString(ret)
print "EZMQAPI Status : ", ezmq.statusString(apiObj.getStatus())
print "Creating ezmq Publisher object"
publisher = ezmq.pyEZMQPublisher(int(port))
print "Python ezmqPublisher object created successfully"
print "Starting ezmq publisher"
ret = publisher.start()
print "Starting Publisher RESULT", ezmq.errorString(ret)
i = 1
try:
	dataType = getDataType()
	while i < 11 :
		print "=========================================================\n"
		if dataType is 1 :
			data = getEventData()
		elif dataType is 2 :
			event = bytearray([94, 91, 101, 125, 111, 35, 120, 101, 115, 101, 200, 255, 250, 13,])
			length = len(event)
			data = ezmq.pyEZMQByteData()
			data.init(event, len(event))
			d = bytearray(data.getByteData())
			dl = data.getLength()
			print "  DATA : ", list(d[0:dl])
			print "  DATA LENGTH : ", dl
		else :
			print " INVALID DATATYPE INPUT"
			break
	
		if topicStr == "":
			ret = publisher.publish(data)
		else:
			print "PUBLISHING DATA ON TOPIC :: ", topicStr 
			ret = publisher.publish(data, topic=topicStr)
		print i, 'EVENT PUBLISH RESULT :: ', ezmq.errorString(ret)
		i += 1
		time.sleep(2)
except (KeyboardInterrupt):
	print "Keyboard Interrupt has been encountered. Stopping publisher"

ret = publisher.stop()
print "Stopping Publisher RESULT", ezmq.errorString(ret)
ret = apiObj.terminate()
print "Terminating API RESULT", ezmq.errorString(ret)
print "=========================================================\n"
print "PUBLISHER TERMINATED"
