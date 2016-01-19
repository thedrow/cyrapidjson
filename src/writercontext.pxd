from cpython cimport PyObject
from libcpp cimport bool

cdef extern from "writercontext.h":
    cdef cppclass WriterContext:
        const char *buffer
        const Py_ssize_t length
        PyObject *object
        const bool is_object
        const bool is_list

        WriterContext(const char* b, const Py_ssize_t l, PyObject *o, const bool isO, const bool isL)
        WriterContext(PyObject *o, const bool isO, const bool isL)