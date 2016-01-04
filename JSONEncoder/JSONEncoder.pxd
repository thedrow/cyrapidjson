from document cimport Document, Value
from stringbuffer cimport StringBuffer
from writer cimport StringWriter
from allocators cimport MemoryPoolAllocator, CrtAllocator

cdef class JSONEncoder(object):
    cdef Document doc
    cdef MemoryPoolAllocator[CrtAllocator] *allocator
    cdef StringBuffer buffer
    cdef StringWriter *writer

    cpdef encode(self, obj)

    cdef encode_inner(self, obj, Value &doc)