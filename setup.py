'''
Setup file for building protocol-ezmq-python.'''

print "\n********************** Build Starting ***************************\n"

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy, sys, os

extlibs = "dependencies/"
ezmq = "protocol-ezmq-cpp/"
ezmqcpp = extlibs + ezmq
protobuf = ezmqcpp + "dependencies/protobuf-3.4.0/"

target_os = sys.platform
lib_lang='c++'
inc_dirs = []
extra_objs = []
compile_flags = []
lib_ext = ".so"

inc_dirs.append("include/")
inc_dirs.append(ezmqcpp + "src/")
inc_dirs.append(ezmqcpp + "include")
inc_dirs.append(ezmqcpp + "include/logger")
inc_dirs.append(ezmqcpp + "extlibs/zmq")
inc_dirs.append(ezmqcpp + "protobuf")
inc_dirs.append(protobuf + "src")

if target_os == "linux2":
	
	extra_objs.append(ezmqcpp + "out/linux/x86/release/libezmq.a")
	extra_objs.append("/usr/local/lib/libzmq.a")
	extra_objs.append(protobuf + "src/.libs/libprotobuf.a")
	
	compile_flags.append("-std=c++0x")

elif target_os == "win32":

	inc_dirs.append(ezmqcpp + "dependencies/libzmq/include")
	
	extra_objs.append(ezmqcpp + "out/windows/win32/amd64/release/ezmq.lib")
	extra_objs.append(protobuf + "cmake/build/solution/Release/libprotobuf.lib")
	extra_objs.append(ezmqcpp + "/dependencies/libzmq/bin/x64/Release/v140/static/libzmq.lib")
	extra_objs.append("ws2_32.lib")
	extra_objs.append("wsock32.lib")
	extra_objs.append("Iphlpapi.lib")
	extra_objs.append("Advapi32.lib")
	
	compile_flags = ["-W2", "-MT", "-O2", "-GF"]
	
	lib_ext = ".pyd"
	
else:
	print "TARGET OS :: ", target_os, " NOT SUPPORTED"
	print "Build Errors."
	exit()
	
src = "ezmqcy.pyx"
moduleName = "ezmqpy"
target = "build." + moduleName

ext_modules = [Extension(target, [src],
                     include_dirs = inc_dirs,
					 language = lib_lang,
                     extra_objects = extra_objs,
					 extra_compile_args = compile_flags,
					 )]

setup(
  name = moduleName,
  cmdclass = {'build_ext': build_ext},
  ext_modules = ext_modules,
  include_dirs=[numpy.get_include()]
)
	
if os.path.isfile("build/" + moduleName + lib_ext):
  print "\nSuccessful cython build\n"
else:
  print "\n Cython Build Failed with Errors."
	
print "\n********************** Build Terminated *************************\n"
