from libcpp cimport bool
from libcpp.string cimport string
from allocators cimport CrtAllocator, MemoryPoolAllocator
from encodings cimport UTF8
from libc.stdint cimport int64_t

cdef extern from "document.h" namespace "rapidjson":
    cdef cppclass GenericValue[Encoding, Allocator]:
        GenericValue& SetString(const string& s, Allocator& allocator)
        GenericValue& SetBool(bool)
        GenericValue& SetNull()
        GenericValue& SetDouble(double)
        GenericValue& SetInt64(int64_t)

        GenericValue& SetArray()
        GenericValue& SetObject()

        GenericValue& PushBack(GenericValue& value, Allocator& allocator)
        GenericValue& AddMember(GenericValue& name, GenericValue& value, Allocator& allocator)

        bool Accept[Handler](Handler&)

    cdef cppclass GenericDocument[Encoding, Allocator, StackAllocator](GenericValue):
        Allocator& GetAllocator()



    ctypedef GenericValue[UTF8[char], MemoryPoolAllocator[CrtAllocator]] Value
    ctypedef GenericDocument[UTF8[char], MemoryPoolAllocator[CrtAllocator], CrtAllocator] Document