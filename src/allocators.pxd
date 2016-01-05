cdef extern from "allocators.h" namespace "rapidjson" nogil:
    cdef cppclass CrtAllocator:
        pass
    cdef cppclass MemoryPoolAllocator[BaseAllocator]:
        pass