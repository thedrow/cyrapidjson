from document cimport Document, Value

cdef class JSONDecoder(object):
    cdef Document doc

    cpdef decode(self, const char *)
    cdef decode_inner(self, const Value &)