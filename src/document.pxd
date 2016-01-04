from libcpp cimport bool
from libcpp.string cimport string
from allocators cimport CrtAllocator, MemoryPoolAllocator
from encodings cimport UTF8
from libc.stdint cimport int64_t, uint64_t

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

        bool IsNull()   const
        bool IsFalse()  const
        bool IsTrue()   const
        bool IsBool()   const
        bool IsObject() const
        bool IsArray()  const
        bool IsNumber() const
        bool IsInt()    const
        bool IsUint()   const
        bool IsInt64()  const
        bool IsUint64() const
        bool IsDouble() const
        bool IsString() const

        bool GetBool() const
        const char* GetString() const
        int GetInt() const
        unsigned GetUint() const
        int64_t GetInt64() const
        uint64_t GetUint64() const
        double GetDouble() const


        bool Accept[Handler](Handler&)

    cdef cppclass GenericDocument[Encoding, Allocator, StackAllocator](GenericValue):
        Allocator& GetAllocator()

        GenericDocument& Parse(const char* str)



    ctypedef GenericValue[UTF8[char], MemoryPoolAllocator[CrtAllocator]] Value
    ctypedef GenericDocument[UTF8[char], MemoryPoolAllocator[CrtAllocator], CrtAllocator] Document