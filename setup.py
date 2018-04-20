from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy

ext_modules = [Extension("build.ezmq", ["ezmqcy.pyx"],
                     include_dirs=["include/",
			"dependencies/src/",
			"dependencies/include",
			"dependencies/include/logger",
			"dependencies/extlibs/zmq",
			"dependencies/protobuf",
			 numpy.get_include()],
                     language='c++',
                     extra_objects=["dependencies/out/linux/x86/release/libezmq.a",
					 "/usr/local/lib/libzmq.a",
					"dependencies/out/linux/x86/release/libprotobuf.a"],
		     extra_compile_args = ["-std=c++0x"],
                     )]

setup(
  name = 'ezmq',
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  include_dirs=[numpy.get_include()]
)
