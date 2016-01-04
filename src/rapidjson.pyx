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
    cpdef public libcpp.bool skipkeys
    cpdef public libcpp.bool ensure_ascii
    cpdef public libcpp.bool check_circular
    cpdef public libcpp.bool allow_nan
    cpdef public libcpp.bool sort_keys
    cpdef public object indent
    cpdef public object separators
    cdef object default_

    cdef StringWriter *writer
    cdef Document doc
    cdef MemoryPoolAllocator[CrtAllocator] *allocator
    cdef StringBuffer buffer

    def __cinit__(self):
        self.allocator = &self.doc.GetAllocator()
        self.writer = new StringWriter(self.buffer)

        self.default_ = self.default

    def __init__(self, libcpp.bool skipkeys=False, libcpp.bool ensure_ascii=True,
                 libcpp.bool check_circular=True, libcpp.bool allow_nan=True, libcpp.bool sort_keys=False,
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
            self.default_ = default

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
        elif isinstance(obj, (int, long)):
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
            obj = self.default_(obj)
            self.encode_inner(obj, doc)

cdef JSONEncoder _default_encoder = JSONEncoder()

cpdef dump(obj, fp, skipkeys=False, ensure_ascii=True, check_circular=True,
           allow_nan=True, cls=None, indent=None, separators=None,
           default=None, sort_keys=False):
    pass

cpdef dumps(obj, skipkeys=False, ensure_ascii=True, check_circular=True,
            allow_nan=True, cls=None, indent=None, separators=None,
            default=None, sort_keys=False):
    if (not skipkeys and ensure_ascii and
            check_circular and allow_nan and
            cls is None and indent is None and separators is None and
            default is None and not sort_keys):
        return _default_encoder.encode(obj)
    if cls is None:
        return JSONEncoder(
            skipkeys=skipkeys, ensure_ascii=ensure_ascii,
            check_circular=check_circular, allow_nan=allow_nan, indent=indent,
            separators=separators, default=default, sort_keys=sort_keys).encode(obj)

cpdef load(fp, cls=None, object_hook=None, parse_float=None,
           parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass

cpdef loads(s, encoding=None, cls=None, object_hook=None, parse_float=None,
            parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass

__all__ = ['dump', 'dumps', 'load', 'loads', 'JSONEncoder']