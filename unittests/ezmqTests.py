import sys, unittest, threading, os, time
sys.path.append("..")
sys.path.append(".")
from build import ezmqcy as ezmq

class callback(ezmq.pyCallbacks):
	def subTopicDataCB(self, topicStr, eventMessage):
		print "subTopicDataCB received"
	def subDataCB(self, eventMessage):
		print "subDataCB received"

def publish(**kwargs):
	port = 5562
	if "port" in kwargs:
		port = kwargs["port"]

	topicName = ""
	if "topic" in kwargs:
		topicName = kwargs["topic"]

	counter = 0
	if "counter" in kwargs:
		counter = kwargs["counter"]

	secure = 1
	if "secure" in kwargs:
		secure = kwargs["secure"]
	apiObj = ezmq.pyEZMQAPI()
	apiObj.initialize()
	publisher = ezmq.pyEZMQPublisher(int(port))
	if secure == 1:
		publisher.setServerPrivateKey("[:X%Q3UfY+kv2A^.wv:(qy2E=bk0L][cm=mS3Hcx")
	publisher.start()

	while counter != 0 :
		event = bytearray([94, 91, 101, 125, 111, 35, 120, 101, 115, 101, 200, 255, 250, 13,])
		length = len(event)
		data = ezmq.pyEZMQByteData()
		data.init(event, len(event))
		d = bytearray(data.getByteData())
		dl = data.getLength()
		print "  DATA : ", list(d[0:dl])
		print "  DATA LENGTH : ", dl
		if topicName == "":
			ret = publisher.publish(data)
		else:
			print "TOPIC ", topicName
			ret = publisher.publish(data, topic=topicName)

		print counter, 'EVENT PUBLISH RESULT :: ', ezmq.errorString(ret)
		counter -= 1
		time.sleep(1)
	publisher.stop()
	apiObj.terminate()

def subscribe(**kwargs):
	ip = "localhost"

	port = 5562
	if "port" in kwargs:
		port = kwargs["port"]

	topicName = ""
	if "topic" in kwargs:
		topicName = kwargs["topic"]

	counter = 0
	if "counter" in kwargs:
		counter = kwargs["counter"]

	secure = 0
	if "secure" in kwargs:
		secure = kwargs["secure"]
	apiObj = ezmq.pyEZMQAPI()
	apiObj.initialize()
	cb = callback()
	subscriber = ezmq.pyEZMQSubscriber(ip, int(port), cb)
	if secure == 1:
		subscriber.setServerPublicKey("tXJx&1^QE2g7WCXbF.$$TVP.wCtxwNhR8?iLi&S<")
		subscriber.setClientKeys("ZB1@RS6Kv^zucova$kH(!o>tZCQ.<!Q)6-0aWFmW", 
			"-QW?Ved(f:<::3d5tJ$[4Er&]6#9yr=vha/caBc(")
	subscriber.start()
	if topicName == "":
		subscriber.subscribe()
	else:
		subscriber.subscribe(topic=topicName)
	while counter != 0 :
		time.sleep(1)
		counter -= 1

	if topicName == "":
		subscriber.unSubscribe()
	else:
		subscriber.unSubscribe(topic=topicName)

	subscriber.stop()
	apiObj.terminate()


class EZMQTests(unittest.TestCase):

	def setUp(self):
		print "\n==========================================="
		print "Starting EZMQ Tests ", self._testMethodName, "\n"		

	def test_errorString_N(self):
		self.assertNotEqual(ezmq.errorString(1), "EZMQ_OK")
		self.assertNotEqual(ezmq.errorString(2), "EZMQ_OK")
		self.assertNotEqual(ezmq.errorString(3), "EZMQ_OK")
		self.assertNotEqual(ezmq.errorString(0), "EZMQ_ERROR")
		self.assertNotEqual(ezmq.errorString(2), "EZMQ_ERROR")
		self.assertNotEqual(ezmq.errorString(0), "EZMQ_INVALID_TOPIC")
		self.assertNotEqual(ezmq.errorString(3), "EZMQ_INVALID_TOPIC")
		self.assertNotEqual(ezmq.errorString(2), "EZMQ_INVALID_CONTENT_TYPE")
		self.assertNotEqual(ezmq.errorString(1), "EZMQ_INVALID_CONTENT_TYPE")
	
	def test_errorString_P(self):
		self.assertEqual(ezmq.errorString(0), "EZMQ_OK")
		self.assertEqual(ezmq.errorString(1), "EZMQ_ERROR")
		self.assertEqual(ezmq.errorString(2), "EZMQ_INVALID_TOPIC")
		self.assertEqual(ezmq.errorString(3), "EZMQ_INVALID_CONTENT_TYPE")

	def test_statusString_N(self):
		self.assertNotEqual(ezmq.statusString(1), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(2), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(3), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(0), "EZMQ_Constructed")
		self.assertNotEqual(ezmq.statusString(2), "EZMQ_Constructed")
		self.assertNotEqual(ezmq.statusString(0), "EZMQ_Initialized")
		self.assertNotEqual(ezmq.statusString(3), "EZMQ_Initialized")
		self.assertNotEqual(ezmq.statusString(2), "EZMQ_Terminated")

	def test_statusString_P(self):
		self.assertEqual(ezmq.statusString(0), "EZMQ_Unknown")
		self.assertEqual(ezmq.statusString(1), "EZMQ_Constructed")
		self.assertEqual(ezmq.statusString(2), "EZMQ_Initialized")
		self.assertEqual(ezmq.statusString(3), "EZMQ_Terminated")
		
	def test_contentString_N(self):
		self.assertNotEqual(ezmq.contentString(1), "EZMQ_CONTENT_TYPE_PROTOBUF")
		self.assertNotEqual(ezmq.contentString(2), "EZMQ_CONTENT_TYPE_PROTOBUF")
		self.assertNotEqual(ezmq.contentString(3), "EZMQ_CONTENT_TYPE_PROTOBUF")
		self.assertNotEqual(ezmq.contentString(0), "EZMQ_CONTENT_TYPE_BYTEDATA")
		self.assertNotEqual(ezmq.contentString(2), "EZMQ_CONTENT_TYPE_BYTEDATA")
		self.assertNotEqual(ezmq.contentString(0), "EZMQ_CONTENT_TYPE_AML")
		self.assertNotEqual(ezmq.contentString(3), "EZMQ_CONTENT_TYPE_AML")
		self.assertNotEqual(ezmq.contentString(2), "EZMQ_CONTENT_TYPE_JSON")
		self.assertNotEqual(ezmq.contentString(1), "EZMQ_CONTENT_TYPE_JSON")

	def test_contentString_P(self):
		self.assertEqual(ezmq.contentString(0), "EZMQ_CONTENT_TYPE_PROTOBUF")
		self.assertEqual(ezmq.contentString(1), "EZMQ_CONTENT_TYPE_BYTEDATA")
		self.assertEqual(ezmq.contentString(2), "EZMQ_CONTENT_TYPE_AML")
		self.assertEqual(ezmq.contentString(3), "EZMQ_CONTENT_TYPE_JSON")
	
	def test_pyEZMQAPI_N(self):
		obj = ezmq.pyEZMQAPI()
		self.assertNotEqual(obj, None)
		status = obj.getStatus()
		self.assertEqual(ezmq.statusString(status), "EZMQ_Constructed")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Terminated")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Initialized")
		
		ret = obj.initialize()
		status = obj.getStatus()
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_ERROR")
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_INVALID_TOPIC")
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_INVALID_CONTENT_TYPE")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Terminated")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Constructed")
		
		ret = obj.terminate()
		status = obj.getStatus()
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_ERROR")
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_INVALID_TOPIC")
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_INVALID_CONTENT_TYPE")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Unknown")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Constructed")
		self.assertNotEqual(ezmq.statusString(status), "EZMQ_Initialized")

	def test_pyEZMQAPI_P(self):
		obj = ezmq.pyEZMQAPI()
		self.assertNotEqual(obj, None)
		status = obj.getStatus()
		self.assertEqual(ezmq.statusString(status), "EZMQ_Terminated")

		ret = obj.initialize()
		status = obj.getStatus()
		self.assertEqual(ezmq.errorString(ret), "EZMQ_OK")
		self.assertEqual(ezmq.statusString(status), "EZMQ_Initialized")

		ret = obj.terminate()
		status = obj.getStatus()
		self.assertEqual(ezmq.errorString(ret), "EZMQ_OK")
		self.assertEqual(ezmq.statusString(status), "EZMQ_Terminated")
	
	def test_pyEZMQByteData_N(self):
		data = bytearray([10, 20, 30, 40, 50])
		obj = ezmq.pyEZMQByteData()
		obj.init(data, len(data))
		self.assertNotEqual(obj, None)
		self.assertIsInstance(obj, ezmq.pyEZMQByteData)

		self.assertNotEqual(obj.getByteData(), None)
		for i in range (0, 10):
			if i is not len(data):
				self.assertNotEqual(obj.getLength(), i)
		
		dataNew = bytearray([15, 99])
		ret = obj.setByteData(dataNew, len(dataNew))
		self.assertNotEqual(ezmq.errorString(ret), "EZMQ_ERROR")	
		self.assertNotEqual(obj.getByteData(), data)
		
		dataNULL = bytearray([])
                ret = obj.setByteData(dataNULL, len(dataNULL))
                self.assertNotEqual(ezmq.errorString(ret), "EZMQ_OK")

	def test_pyEZMQByteData_P(self):
                data = bytearray([10, 20, 30, 40, 50])
		obj = ezmq.pyEZMQByteData()
		obj.init(data, len(data))
                self.assertNotEqual(obj, None)
                self.assertIsInstance(obj, ezmq.pyEZMQByteData)

		d = bytearray(obj.getByteData())
		dl = obj.getLength()
                self.assertEqual(d[0:dl], data[0:len(data)])
                self.assertEqual(dl, len(data))

                dataNew = bytearray([15, 99])
		ret = obj.setByteData(dataNew, len(dataNew))
		d = bytearray(obj.getByteData())
                dl = obj.getLength()
		self.assertEqual(d[0:dl], dataNew[0:len(dataNew)])
		self.assertEqual(obj.getLength(), len(dataNew))
                self.assertEqual(ezmq.errorString(ret), "EZMQ_OK")

	def test_pyEvent_N(self):
		obj = ezmq.pyEvent()
		obj.init()
		self.assertNotEqual(obj, None)
		self.assertEqual(obj.id(), '')
		self.assertEqual(obj.created(), 0)
		self.assertEqual(obj.modified(), 0)
		self.assertEqual(obj.origin(), 0)
		self.assertEqual(obj.pushed(), 0)
		self.assertEqual(obj.device(), '')
		self.assertEqual(obj.reading_size(), 0)
		obj.set_device("DEVICE")
		obj.set_created(10)
		obj.set_modified(20)
		obj.set_id("ID")
		obj.set_pushed(10)
		obj.set_origin(10)
		
		readObj1 = obj.add_reading()
		self.assertNotEqual(obj.reading_size(), 0)
		readObj2 = obj.add_reading()
		self.assertNotEqual(obj.reading_size(), 0)
		self.assertNotEqual(obj.id(), '')
                self.assertNotEqual(obj.created(), 0)
                self.assertNotEqual(obj.modified(), 0)
                self.assertNotEqual(obj.origin(), 0)
                self.assertNotEqual(obj.pushed(), 0)
                self.assertNotEqual(obj.device(), '')

	def test_pyEvent_P(self):
                obj = ezmq.pyEvent()
		obj.init()
                self.assertNotEqual(obj, None)
		obj.set_device("DEVICE")
                obj.set_created(10)
                obj.set_modified(20)
                obj.set_id("ID")
                obj.set_pushed(10)
                obj.set_origin(10)
		for i in range (0, 3):
			obj.add_reading()
			self.assertEqual(obj.reading_size(), i+1)
                self.assertEqual(obj.id(), "ID")
                self.assertEqual(obj.created(), 10)
                self.assertEqual(obj.modified(), 20)
                self.assertEqual(obj.origin(), 10)
                self.assertEqual(obj.pushed(), 10)
                self.assertEqual(obj.device(), "DEVICE")

	def test_pyReading_N(self):
                obj = ezmq.pyEvent()
		obj.init()
                obj.set_device("DEVICE")
                obj.set_created(10)
                obj.set_modified(20)
                obj.set_id("ID")
                obj.set_pushed(10)
                obj.set_origin(10)
		readObj = obj.add_reading()
		self.assertNotEqual(readObj, None)
		self.assertEqual(readObj.id(), '')
		self.assertEqual(readObj.name(), '')
		self.assertEqual(readObj.value(), '')
		self.assertEqual(readObj.device(), '')
		self.assertEqual(readObj.created(), 0)

	def test_pyReading_P(self):
                obj = ezmq.pyEvent()
		obj.init()
                obj.set_device("DEVICE")
                obj.set_created(10)
                obj.set_modified(20)
                obj.set_id("ID")
                obj.set_pushed(10)
                obj.set_origin(10)
                readObj = obj.add_reading()
                readObj.set_name("NAME")
                readObj.set_value("samsung")
                readObj.set_created(25)
                readObj.set_device("DEVICE")
                readObj.set_modified(20)
                readObj.set_id("ID1")
                readObj.set_origin(25)
                readObj.set_pushed(1)

		self.assertNotEqual(readObj, None)
                self.assertEqual(readObj.id(), "ID1")
                self.assertEqual(readObj.name(), "NAME")
                self.assertEqual(readObj.value(), "samsung")
                self.assertEqual(readObj.device(), "DEVICE")
                self.assertEqual(readObj.created(), 25)
	
	def test_pyEZMQPublisher(self):
		port = 5560
		obj = ezmq.pyEZMQPublisher(port)
		self.assertNotEqual(obj, None)

		ret = obj.start()
		self.assertEqual("EZMQ_ERROR", ezmq.errorString(ret))

		apiObj = ezmq.pyEZMQAPI()
		apiObj.initialize()
		obj = ezmq.pyEZMQPublisher(port)
		ret = obj.start()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))	
		ret = obj.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

	def test_pyEZMQPublisher_ByteData(self):
                port = 5562
                apiObj = ezmq.pyEZMQAPI()
                apiObj.initialize()
                obj = ezmq.pyEZMQPublisher(port)
                ret = obj.start()
                
		event = bytearray([12, 24, 36, 48, 60])
		length = len(event)
		data = ezmq.pyEZMQByteData()
		data.init(event, len(event))

		for i in range(0, 5):
			ret = obj.publish(data)
			self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = obj.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

	def test_pyEZMQPublisher_EventData(self):
                port = 5563
                apiObj = ezmq.pyEZMQAPI()
                apiObj.initialize()
                obj = ezmq.pyEZMQPublisher(port)
                ret = obj.start()

		data = ezmq.pyEvent()
		data.init()
		data.set_device("device")
		data.set_created(10)
		data.set_modified(20)
		data.set_id("id")
		data.set_pushed(10)
		data.set_origin(20)
		read1 = data.add_reading()
		read1.set_name("reading1")
		read1.set_value("10")
		read1.set_created(25)
		read1.set_device("device")
		read1.set_modified(20)
		read1.set_id("id1")
		read1.set_origin(25)
		read1.set_pushed(1)

		topic = "arya"
                for i in range(0, 5):
                        ret = obj.publish(data)
                        self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
                ret = obj.stop()
                self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
                ret = apiObj.terminate()
                self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

	def test_pySubscriber_noTopic(self):
		apiObj = ezmq.pyEZMQAPI()
		apiObj.initialize()
		
		subscriber_cb = callback()
		ip = "localhost"
		port = 5562
		subscriber = ezmq.pyEZMQSubscriber(ip, int(port), subscriber_cb)
		self.assertNotEqual(subscriber, None)
		
		self.assertEqual(subscriber.getIp(), ip)
		self.assertEqual(subscriber.getPort(), port)

		ret = subscriber.start()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		ret = subscriber.subscribe()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = subscriber.unSubscribe()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		
		ret = subscriber.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		
		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		del subscriber, subscriber_cb, apiObj

	def test_pySubscriber_withTopicString(self):
		apiObj = ezmq.pyEZMQAPI()
		apiObj.initialize()

		subscriber_cb = callback()
		ip = "localhost"
		port = 5562
		subscriber = ezmq.pyEZMQSubscriber(ip, int(port), subscriber_cb)
		self.assertNotEqual(subscriber, None)

		self.assertEqual(subscriber.getIp(), ip)
		self.assertEqual(subscriber.getPort(), port)

		ret = subscriber.start()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		topicString = "sample/string"
		ret = subscriber.subscribe(topic=topicString)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = subscriber.unSubscribe(topic=topicString)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = subscriber.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		del subscriber, subscriber_cb, apiObj

	def test_pySubscriber_withTopicList(self):
		apiObj = ezmq.pyEZMQAPI()
		apiObj.initialize()

		subscriber_cb = callback()
		ip = "localhost"
		port = 5562
		subscriber = ezmq.pyEZMQSubscriber(ip, int(port), subscriber_cb)
		self.assertNotEqual(subscriber, None)

		self.assertEqual(subscriber.getIp(), ip)
		self.assertEqual(subscriber.getPort(), port)

		ret = subscriber.start()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		topicList = ["sample/topic1", "sample/topic2", "/topic3"]
		ret = subscriber.subscribe(topic=topicList)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = subscriber.unSubscribe(topic=topicList)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = subscriber.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		del subscriber, subscriber_cb, apiObj

	def test_pySubscriber_withInvalidTopic(self):
		apiObj = ezmq.pyEZMQAPI()
		apiObj.initialize()
		subscriber_cb = callback()
		subscriber = ezmq.pyEZMQSubscriber("localhost", int(5562), subscriber_cb)
		self.assertNotEqual(subscriber, None)
		subscriber.start()
		self.assertRaises(ValueError, subscriber.subscribe, topic=4452)	
		self.assertRaises(ValueError, subscriber.subscribe, topic=0)	
		self.assertRaises(ValueError, subscriber.subscribe, topic=1.55)		
		
		topicString = "sample/string"
		ret = subscriber.subscribe(topic=topicString)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		self.assertRaises(ValueError, subscriber.unSubscribe, topic=4452)
		self.assertRaises(ValueError, subscriber.unSubscribe, topic=22)
		self.assertRaises(ValueError, subscriber.unSubscribe, topic=1.2589)

		ret = subscriber.unSubscribe(topic=topicString)
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))
		ret = subscriber.stop()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))

		ret = apiObj.terminate()
		self.assertEqual("EZMQ_OK", ezmq.errorString(ret))	

		del subscriber, subscriber_cb, apiObj

	def test_pyPublishAndSubscribe_NoTopic(self):
		thread1 = threading.Thread(target=publish, kwargs={'port': 5563, 'topic': "/apple", 'counter': 3})
		thread1.start()
		subscribe(port=5563, topic="/apple", counter=5)
		thread1.join()
	def test_pyPublishAndSubscribe_NoTopic_secure(self):
		thread1 = threading.Thread(target=publish, kwargs={'port': 5563, 'topic': "/apple", 'counter': 3, 'secure' : 1})
		thread1.start()
		subscribe(port=5563, topic="/apple", counter=5, secure=1)
		thread1.join()

	def tearDown(self):
		print "Completed EZMQ Test ", self._testMethodName 

suite = unittest.TestLoader().loadTestsFromTestCase(EZMQTests)
unittest.TextTestRunner(verbosity=3).run(suite)
