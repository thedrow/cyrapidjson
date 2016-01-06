from encodings cimport UTF8
from allocators cimport CrtAllocator

cdef extern from "stringbuffer.h" namespace "rapidjson" nogil:
    cdef cppclass GenericStringBuffer[Encoding, Allocator]:
        const char* GetString() const

    ctypedef GenericStringBuffer[UTF8[char], CrtAllocator] StringBuffer