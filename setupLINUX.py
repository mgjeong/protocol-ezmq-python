from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

ext_modules = [Extension("build.ezmqpy", ["ezmqcy.pyx"],
                     include_dirs=["include/",
			"protocol-ezmq-cpp/src/",
			"protocol-ezmq-cpp/include",
			"protocol-ezmq-cpp/include/logger",
			"protocol-ezmq-cpp/extlibs/zmq",
			"protocol-ezmq-cpp/protobuf",
			 numpy.get_include()],
                     language='c++',
                     extra_objects=["protocol-ezmq-cpp/out/linux/x86/release/libezmq.a",
					 "/usr/local/lib/libzmq.a",
					"protocol-ezmq-cpp/dependencies/protobuf-3.4.0/src/.libs/libprotobuf.a"],
		     extra_compile_args = ["-std=c++0x"],
                     )]

setup(
  name = 'ezmqpy',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  include_dirs=[numpy.get_include()]
)
