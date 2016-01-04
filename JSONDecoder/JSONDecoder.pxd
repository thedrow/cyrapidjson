from libcpp cimport bool
from document cimport Document, Value
from stringbuffer cimport StringBuffer
from writer cimport StringWriter
from allocators cimport MemoryPoolAllocator, CrtAllocator

cdef class JSONDecoder(object):
    cdef Document doc

    cpdef decode(self, s)