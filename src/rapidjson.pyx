# distutils: language = c++
cimport libcpp
from libcpp.string cimport string
from cython.operator cimport dereference
from document cimport Document, Value
from stringbuffer cimport StringBuffer
from writer cimport StringWriter
from allocators cimport MemoryPoolAllocator, CrtAllocator
from libc.stdint cimport int64_t

cdef class JSONEncoder(object):
    cdef Document doc
    cdef MemoryPoolAllocator[CrtAllocator] *allocator
    cdef StringBuffer buffer
    cdef StringWriter *writer

    def __cinit__(self):
        self.allocator = &self.doc.GetAllocator()
        self.writer = new StringWriter(self.buffer)

    def __init__(self):
        pass

    def __dealloc__(self):
        del self.writer

    cpdef encode(self, obj):
        self.encode_inner(obj, self.doc)

        self.doc.Accept(dereference(self.writer))

        return <str>self.buffer.GetString().decode('UTF-8')


    cdef encode_inner(self, obj, Value &doc):
        cdef Value key
        cdef Value value

        if isinstance(obj, bool):
            doc.SetBool(<libcpp.bool> obj)
        elif obj is None:
            doc.SetNull()
        elif isinstance(obj, float):
            doc.SetDouble(<double> obj)
        elif isinstance(obj, int):
            doc.SetInt64(<int64_t> obj)
        elif isinstance(obj, (str, unicode, bytes)):
            doc.SetString(<string> obj, dereference(self.allocator))
        elif isinstance(obj, (list, tuple)):
            doc.SetArray()

            for item in obj:
                self.encode_inner(item, value)

                doc.PushBack(value, dereference(self.allocator))
        elif isinstance(obj, dict):
            doc.SetObject()

            for k, v in obj.items():
                key.SetString(<string> unicode(k), dereference(self.allocator))
                self.encode_inner(v, value)

                doc.AddMember(key, value, dereference(self.allocator))


cpdef dump(obj, fp, skipkeys=False, ensure_ascii=True, check_circular=True,
           allow_nan=True, cls=None, indent=None, separators=None,
           default=None, sort_keys=False):
    pass

cpdef dumps(obj, skipkeys=False, ensure_ascii=True, check_circular=True,
            allow_nan=True, cls=None, indent=None, separators=None,
            default=None, sort_keys=False):

    return JSONEncoder().encode(obj)

cpdef load(fp, cls=None, object_hook=None, parse_float=None,
           parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass

cpdef loads(s, encoding=None, cls=None, object_hook=None, parse_float=None,
            parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass

__all__ = ['dump', 'dumps', 'load', 'loads', 'JSONEncoder']