from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

ext_modules = [Extension("build.ezmqpy", ["ezmqcy.pyx"],
                     include_dirs=["include/",
			"protocol-ezmq-cpp/src/",
			"protocol-ezmq-cpp/include",
			"protocol-ezmq-cpp/include/logger",
			"protocol-ezmq-cpp/extlibs/zmq/",
			"protocol-ezmq-cpp/dependencies/libzmq/include",
			"protocol-ezmq-cpp/dependencies/protobuf-3.4.0/src",
			 numpy.get_include()],
                     language='c++',
                     extra_objects=["protocol-ezmq-cpp/out/windows/win32/amd64/release/ezmq.lib",
					 "protocol-ezmq-cpp/dependencies/protobuf-3.4.0/cmake/build/solution/Release/libprotobuf.lib",
					"protocol-ezmq-cpp/dependencies/libzmq/bin/x64/Release/v140/static/libzmq.lib",
					"ws2_32.lib",
					"wsock32.lib",
					"Iphlpapi.lib",
					"Advapi32.lib"],
		     extra_compile_args = ["-Wall", "-static", "-MT", "-O2", "-GF"],
                     )]

setup(
  name = 'ezmqpy',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  include_dirs=[numpy.get_include()]
)
