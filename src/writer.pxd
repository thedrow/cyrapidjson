from encodings cimport UTF8
from allocators cimport CrtAllocator
from stringbuffer cimport StringBuffer

cdef extern from "writer.h" namespace "rapidjson":
    cdef cppclass Writer[OutputStream, SourceEncoding, TargetEncoding, StackAllocator]:
        Writer(OutputStream& os)

ctypedef Writer[StringBuffer, UTF8[char], UTF8[char], CrtAllocator] StringWriter