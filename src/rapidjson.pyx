# distutils: language = c++

cdef extern from "rapidjson.h" namespace "rapidjson":
    cdef cppclass Document
    cdef cppclass Value


cpdef dump(obj, fp, skipkeys=False, ensure_ascii=True, check_circular=True,
           allow_nan=True, cls=None, indent=None, separators=None,
           default=None, sort_keys=False):
    pass

cpdef dumps(obj, skipkeys=False, ensure_ascii=True, check_circular=True,
            allow_nan=True, cls=None, indent=None, separators=None,
            default=None, sort_keys=False):
    pass

cpdef load(fp, cls=None, object_hook=None, parse_float=None,
           parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass

cpdef loads(s, encoding=None, cls=None, object_hook=None, parse_float=None,
            parse_int=None, parse_constant=None, object_pairs_hook=None):
    pass