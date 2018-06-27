cimport ezmqMessage
from libcpp.string cimport string
from ezmqMessage cimport EZMQMessage
from ezmqReading cimport Reading

cdef extern from "Event.pb.h" namespace "ezmq" :
	cdef cppclass Event(EZMQMessage):
		string id()
		int created()
		int modified()
		int origin()
		int pushed()
		string device()
		int reading_size()
		Reading* mutable_reading(int)
		Reading reading(int)
		Reading* add_reading()
		Event()
		void set_id(const char *value)
		void set_created(int value)
		void set_modified(int value)
		void set_origin(int value)
		void set_pushed(int value)
		void set_device(const char *value)

	cdef const Event* dynamic_cast_event "dynamic_cast<const ezmq::Event *>"(const EZMQMessage *)

	cdef Event* const_cast_event "const_cast<ezmq::Event*>"(const Event*)
