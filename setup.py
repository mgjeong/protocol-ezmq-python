'''
Setup file for building protocol-ezmq-python.'''

print "\n********************** Build Starting ***************************\n"

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize
import numpy, sys, os, platform

DEBUG=False
SECURE=False

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
compiler_directives = {}
define_macros = []
log_level='warn'

if '--debug' in sys.argv:
	DEBUG=True
if '-Dsecured' in sys.argv:
	SECURE=True

if DEBUG:
	print "Building in DEBUG mode."
	log_level='debug'
	compiler_directives['linetrace'] = True
	define_macros.append(('CYTHON_TRACE', '1'))
	define_macros.append(('CYTHON_TRACE_NOGIL', '1'))

inc_dirs.append("include/")
inc_dirs.append(ezmqcpp + "src/")
inc_dirs.append(ezmqcpp + "include")
inc_dirs.append(ezmqcpp + "include/logger")
inc_dirs.append(ezmqcpp + "extlibs/zmq")
inc_dirs.append(ezmqcpp + "protobuf")
inc_dirs.append(protobuf + "src")

if target_os == "linux2":
	
	target_arch = platform.machine()
	extra_objs.append("-fprofile-arcs")
	compile_flags.append("-fprofile-arcs")
	compile_flags.append("-ftest-coverage")

	if target_arch in ['i686', 'x86']:
		if DEBUG:
			extra_objs.append(ezmqcpp + "out/linux/x86/debug/libezmq.a")
		else:
			extra_objs.append(ezmqcpp + "out/linux/x86/release/libezmq.a")
		extra_objs.append("/usr/local/lib/libzmq.a")
		extra_objs.append(protobuf + "src/.libs/libprotobuf.a")
		if SECURE:
			extra_objs.append("/usr/lib/i386-linux-gnu/libsodium.a")
	elif target_arch in ['x86_64']:
		if DEBUG:
			extra_objs.append(ezmqcpp + "out/linux/x86_64/debug/libezmq.a")
		else:
			extra_objs.append(ezmqcpp + "out/linux/x86_64/release/libezmq.a")
		extra_objs.append("/usr/local/lib/libzmq.so")
		extra_objs.append(protobuf + "src/.libs/libprotobuf.so")
	
	compile_flags.append("-std=c++0x")

elif target_os == "win32":

	inc_dirs.append(ezmqcpp + "dependencies/libzmq/include")

	if SECURE:
		extra_objs.append(ezmqcpp + "dependencies/libsodium/bin/x64/Release/v140/static/libsodium.lib")
	
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
moduleName = "ezmqcy"
target = "build." + moduleName

ext_modules = [Extension(target, [src],
                     include_dirs = inc_dirs,
					 language = lib_lang,
                     extra_objects = extra_objs,
					 extra_compile_args = compile_flags,
					define_macros=define_macros,
					 )]

setup(
  name = moduleName,
  cmdclass = {'build_ext': build_ext},
  ext_modules = cythonize(ext_modules, compiler_directives=compiler_directives,
		compile_time_env={'LOG_LEVEL':log_level, 'SECURED':SECURE}),
  include_dirs=[numpy.get_include()]
)
	
if os.path.isfile("build/" + moduleName + lib_ext):
  print "\nSuccessful cython build\n"
else:
  print "\n Cython Build Failed with Errors."
	
print "\n********************** Build Terminated *************************\n"
