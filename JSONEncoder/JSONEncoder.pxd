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

    cpdef public bool skipkeys
    cpdef public bool ensure_ascii
    cpdef public bool check_circular
    cpdef public bool allow_nan
    cpdef public bool sort_keys
    cpdef public object indent
    cpdef public object separators
    cdef object default_

    cpdef encode(self, obj)

    cdef encode_inner(self, obj, Value &doc)