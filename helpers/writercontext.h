#include <Python.h>

struct WriterContext {
    const char *buffer;
    Py_ssize_t length;
    PyObject *object;
    bool is_object;
    bool is_list;

    WriterContext(const char* b, const Py_ssize_t l, PyObject *o, const bool isO, const bool isL)
    : buffer(b), length(l), object(o), is_object(isO), is_list(isL)
    {}

    WriterContext(PyObject *o, const bool isO, const bool isL)
    : buffer(NULL), length(0), object(o), is_object(isO), is_list(isL)
    {}
};