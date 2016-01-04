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

    cpdef libcpp.bool skipkeys
    cpdef libcpp.bool ensure_ascii
    cpdef libcpp.bool check_circular
    cpdef libcpp.bool allow_nan
    cpdef libcpp.bool sort_keys
    cpdef object indent
    cpdef object separators
    cpdef object default

    def __cinit__(self):
        self.allocator = &self.doc.GetAllocator()
        self.writer = new StringWriter(self.buffer)

    def __init__(self, skipkeys=False, ensure_ascii=True,
                 check_circular=True, allow_nan=True, sort_keys=False,
                 indent=None, separators=None, default=None):
        self.skipkeys = skipkeys
        self.ensure_ascii = ensure_ascii
        self.check_circular = check_circular
        self.allow_nan = allow_nan
        self.sort_keys = sort_keys
        self.indent = indent
        if separators is not None:
            self.item_separator, self.key_separator = separators
        elif indent is not None:
            self.item_separator = ','
        if default is not None:
            self.default = default

    def __dealloc__(self):
        del self.writer

    def default(self, o):
        raise TypeError(repr(o) + " is not JSON serializable")

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
        else:
            obj = self.default(obj)
            self.encode_inner(obj, doc)


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