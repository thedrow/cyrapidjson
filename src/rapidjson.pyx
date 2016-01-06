# distutils: language = c++
cimport libcpp
from libcpp.string cimport string
from cython.operator cimport dereference, preincrement
from document cimport Document, Value, GenericMember, GenericMemberIterator
from stringbuffer cimport StringBuffer
from writer cimport StringWriter
from encodings cimport UTF8
from allocators cimport MemoryPoolAllocator, CrtAllocator
from error cimport GetParseError_En
from libc.stdint cimport int64_t, uint64_t

try:
    # Starting from Python 3.5 we can expose the same error as the one thrown by the json module
    from json.decoder import JSONDecodeError
except ImportError:
    class JSONDecodeError(ValueError):
        def __init__(self, msg, doc, pos):
            lineno = doc.count('\n', 0, pos) + 1
            colno = pos - doc.rfind('\n', 0, pos)
            errmsg = '%s: line %d column %d (char %d)' % (msg, lineno, colno, pos)
            ValueError.__init__(self, errmsg)
            self.msg = msg
            self.doc = doc
            self.pos = pos
            self.lineno = lineno
            self.colno = colno

        def __reduce__(self):
            return self.__class__, (self.msg, self.doc, self.pos)

cdef class JSONEncoder(object):
    cpdef public libcpp.bool skipkeys
    cpdef public libcpp.bool ensure_ascii
    cpdef public libcpp.bool check_circular
    cpdef public libcpp.bool allow_nan
    cpdef public libcpp.bool sort_keys
    cpdef public int64_t indent
    cpdef public object separators
    cpdef public char* item_separator
    cpdef public char* key_separator
    cdef object default_

    def __cinit__(self):
        self.default_ = self.default

    def __init__(self, libcpp.bool skipkeys=False, libcpp.bool ensure_ascii=True,
                 libcpp.bool check_circular=True, libcpp.bool allow_nan=True, libcpp.bool sort_keys=False,
                 int64_t indent=-1, separators=None, default=None):
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

    def default(self, o):
        raise TypeError(repr(o) + " is not JSON serializable")

    cpdef encode(self, obj):
        cdef StringBuffer buffer
        cdef StringWriter *writer = new StringWriter(buffer)
        cdef Document doc

        self.encode_inner(obj, doc, doc.GetAllocator())

        with nogil:
            doc.Accept(dereference(writer))

            del writer

        return <str>buffer.GetString().decode('UTF-8')


    cdef encode_inner(self, obj, Value &doc, MemoryPoolAllocator[CrtAllocator] &allocator):
        cdef Value key
        cdef Value value
        cdef string s
        cdef libcpp.bool b
        cdef double d
        cdef int64_t i

        if isinstance(obj, bool):
            b = obj
            with nogil:
                doc.SetBool(b)
        elif obj is None:
            with nogil:
                doc.SetNull()
        elif isinstance(obj, float):
            d = obj
            with nogil:
                doc.SetDouble(d)
        elif isinstance(obj, (int, long)):
            i = obj
            with nogil:
                doc.SetInt64(i)
        elif isinstance(obj, (str, unicode, bytes)):
            s = obj
            with nogil:
                doc.SetString(s, allocator)
        elif isinstance(obj, (list, tuple)):
            with nogil:
                doc.SetArray()

            for item in obj:
                self.encode_inner(item, value, allocator)
                with nogil:
                    doc.PushBack(value, allocator)
        elif isinstance(obj, dict):
            with nogil:
                doc.SetObject()

            for k, v in obj.items():
                s = <string> unicode(k)
                with nogil:
                    key.SetString(s, allocator)
                self.encode_inner(v, value, allocator)
                with nogil:
                    doc.AddMember(key, value, allocator)
        else:
            obj = self.default_(obj)
            self.encode_inner(obj, doc, allocator)

cdef class JSONDecoder(object):
    cdef public object object_hook
    cdef public object parse_float
    cdef public object parse_int
    cdef public object parse_constant
    cdef public libcpp.bool strict
    cdef public object object_pairs_hook

    def __init__(self, object_hook=None, parse_float=None,
                parse_int=None, parse_constant=None, libcpp.bool strict=True,
                object_pairs_hook=None):
        self.object_hook = object_hook
        self.parse_float = parse_float
        self.parse_int = parse_int
        self.parse_constant = parse_constant
        self.strict = strict
        self.object_pairs_hook = object_pairs_hook

    cpdef decode(self, const char *s):
        cdef Document doc
        cdef libcpp.bool has_error
        with nogil:
            doc.Parse(s)
            has_error = doc.HasParseError()

        if has_error:
            raise JSONDecodeError(GetParseError_En(doc.GetParseError()), s, self.doc.GetErrorOffset())

        return self.decode_inner(doc)

    cdef decode_inner(self, const Value &doc):
        cdef const Value* it
        cdef GenericMemberIterator it2

        if doc.IsNull():
            return None
        elif doc.IsBool():
            return doc.GetBool()
        elif doc.IsString():
            return doc.GetString().decode('UTF-8')
        elif doc.IsNumber():
            if doc.IsInt():
                return doc.GetInt()
            elif doc.IsUint():
                return doc.GetUint()
            elif doc.IsInt64():
                return doc.GetInt64()
            elif doc.IsUint64():
                return doc.GetUint64()
            elif doc.IsDouble():
                return doc.GetDouble()
        elif doc.IsArray():
            it = doc.Begin()
            l = []
            while it != doc.End():
                l.append(self.decode_inner(dereference(it)))
                preincrement(it)
            return l
        elif doc.IsObject():
            it2 = doc.MemberBegin()
            d = {}
            while it2 != doc.MemberEnd():
                d[dereference(it2).name.GetString().decode('UTF-8')] = self.decode_inner(dereference(it2).value)
                preincrement(it2)
            return d


cdef JSONEncoder _default_encoder = JSONEncoder()
cdef JSONDecoder _default_decoder = JSONDecoder()

cpdef dump(obj, fp, libcpp.bool skipkeys=False, libcpp.bool ensure_ascii=True, libcpp.bool check_circular=True,
           libcpp.bool allow_nan=True, cls=None, int64_t indent=-1, separators=None,
           default=None, libcpp.bool sort_keys=False):
    json_string = dumps(obj, skipkeys=skipkeys, ensure_ascii=ensure_ascii,
                        check_circular=check_circular, allow_nan=allow_nan, indent=indent,
                        separators=separators, default=default, sort_keys=sort_keys)
    fp.write(json_string)

cpdef dumps(obj, libcpp.bool skipkeys=False, libcpp.bool ensure_ascii=True, libcpp.bool check_circular=True,
            libcpp.bool allow_nan=True, cls=None, int64_t indent=-1, separators=None,
            default=None, libcpp.bool sort_keys=False):
    if (not skipkeys and ensure_ascii and
            check_circular and allow_nan and
            cls is None and indent == -1 and separators is None and
            default is None and not sort_keys):
        return _default_encoder.encode(obj)
    elif cls is None:
        return JSONEncoder(
            skipkeys=skipkeys, ensure_ascii=ensure_ascii,
            check_circular=check_circular, allow_nan=allow_nan, indent=indent,
            separators=separators, default=default, sort_keys=sort_keys).encode(obj)
    elif not issubclass(cls, JSONEncoder):
        raise TypeError("cls is not a subclass or an instance of rapidjson.JSONEncoder.\nUse the stdlib json module instead.")
    else:
        return cls(
            skipkeys=skipkeys, ensure_ascii=ensure_ascii,
            check_circular=check_circular, allow_nan=allow_nan, indent=indent,
            separators=separators, default=default, sort_keys=sort_keys).encode(obj)

cpdef load(fp, cls=None, object_hook=None, parse_float=None,
           parse_int=None, parse_constant=None, object_pairs_hook=None):
    return loads(fp.read(), cls=cls, object_hook=object_hook, parse_float=parse_float, parse_int=parse_int,
                 parse_constant=parse_constant, object_pairs_hook=object_pairs_hook)

cpdef loads(const char *s, encoding=None, cls=None, object_hook=None, parse_float=None,
            parse_int=None, parse_constant=None, object_pairs_hook=None):
    if (cls is None and object_hook is None and
            parse_int is None and parse_float is None and
            parse_constant is None and object_pairs_hook is None):
        return _default_decoder.decode(s)
    elif cls is None:
        return JSONDecoder(object_hook=object_hook, parse_float=parse_float, parse_int=parse_int,
                           parse_constant=parse_constant, object_pairs_hook=object_pairs_hook).decode(s)
    elif not issubclass(cls, JSONDecoder):
        raise TypeError("cls is not a subclass or an instance of rapidjson.JSONDecoder.\nUse the stdlib json module instead.")
    else:
        return cls(object_hook=object_hook, parse_float=parse_float, parse_int=parse_int,
                           parse_constant=parse_constant, object_pairs_hook=object_pairs_hook).decode(s)


__all__ = ['dump', 'dumps', 'load', 'loads', 'JSONEncoder', 'JSONDecoder', 'JSONDecodeError']