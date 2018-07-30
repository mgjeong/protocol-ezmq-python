from libcpp.string cimport string

cdef extern from "Event.pb.h" namespace "ezmq" :
	cdef cppclass Reading:
		string id()
		int created()
		int modified()
		int origin()
		int pushed()
		string name()
		string value()
		string device()
		void set_id(const char*)
		void set_created(int)
		void set_modified(int)
		void set_origin(int)
		void set_pushed(int)
		void set_name(const char*)
		void set_value(const char*)
		void set_device(const char*)
