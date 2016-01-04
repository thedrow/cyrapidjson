cdef extern from "rapidjson.h" namespace "rapidjson" nogil:
    cdef cppclass CrtAllocator:
        pass
    cdef cppclass MemoryPoolAllocator[BaseAllocator]:
        pass