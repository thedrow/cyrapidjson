from encodings cimport UTF8
from allocators cimport CrtAllocator
from stringbuffer cimport StringBuffer
from libcpp cimport bool
from libc.stdint cimport int64_t, uint64_t

cdef extern from "writer.h" namespace "rapidjson":
    cdef cppclass Writer[OutputStream, SourceEncoding, TargetEncoding, StackAllocator]:
        Writer(OutputStream& os)

        bool Null()
        bool Bool(bool b)
        bool Int(int i)
        bool Int64(int64_t i64)
        bool Uint64(uint64_t u64)
        bool Double(double d)
        bool String(const char* str, size_t length, bool copy)
        bool StartObject()
        bool Key(const char* str, size_t length, bool copy)
        bool EndObject()
        bool StartArray()
        bool EndArray()

ctypedef Writer[StringBuffer, UTF8[char], UTF8[char], CrtAllocator] StringWriter