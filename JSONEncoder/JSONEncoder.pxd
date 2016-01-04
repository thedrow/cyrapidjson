from libcpp cimport bool
from document cimport Document, Value
from stringbuffer cimport StringBuffer
from writer cimport StringWriter
from allocators cimport MemoryPoolAllocator, CrtAllocator

cdef class JSONEncoder(object):
    cdef Document doc
    cdef MemoryPoolAllocator[CrtAllocator] *allocator
    cdef StringBuffer buffer
    cdef StringWriter *writer

    cpdef bool skipkeys
    cpdef bool ensure_ascii
    cpdef bool check_circular
    cpdef bool allow_nan
    cpdef bool sort_keys
    cpdef object indent
    cpdef object separators
    cpdef object default

    cpdef encode(self, obj)

    cdef encode_inner(self, obj, Value &doc)