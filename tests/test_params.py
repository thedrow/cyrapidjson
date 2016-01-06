#!/usr/bin/env python
# -*- coding: utf-8 -*-

import math
import pytest
import rapidjson


@pytest.mark.unit
def test_skipkeys():
    o = {True: False, 1: 1, 1.1: 1.1, (1, 2): "foo", b"asdf": 1, None: None}

    with pytest.raises(TypeError):
        rapidjson.dumps(o)

    with pytest.raises(TypeError):
        rapidjson.dumps(o, skipkeys=False)

    assert rapidjson.dumps(o, skipkeys=True) == '{}'


@pytest.mark.unit
def test_ensure_ascii():
    s = '\N{GREEK SMALL LETTER ALPHA}\N{GREEK CAPITAL LETTER OMEGA}'
    assert rapidjson.dumps(s) == '"\\u03b1\\u03a9"'
    assert rapidjson.dumps(s, ensure_ascii=True) == '"\\u03b1\\u03a9"'
    assert rapidjson.dumps(s, ensure_ascii=False) == '"%s"' % s


@pytest.mark.unit
def test_allow_nan():
    f = [1.1, float("inf"), 2.2, float("nan"), 3.3, float("-inf"), 4.4]
    expected = '[1.1,Infinity,2.2,NaN,3.3,-Infinity,4.4]'
    assert rapidjson.dumps(f) == expected
    assert rapidjson.dumps(f, allow_nan=True) == expected

    with pytest.raises(ValueError):
        rapidjson.dumps(f, allow_nan=False)

    s = "NaN"
    assert math.isnan(rapidjson.loads(s))
    assert math.isnan(rapidjson.loads(s, allow_nan=True))

    with pytest.raises(ValueError):
        rapidjson.loads(s, allow_nan=False)

    s = "Infinity"
    assert rapidjson.loads(s) == float("inf")
    assert rapidjson.loads(s, allow_nan=True) == float("inf")

    with pytest.raises(ValueError):
        rapidjson.loads(s, allow_nan=False)

    s = "-Infinity"
    assert rapidjson.loads(s) == float("-inf")
    assert rapidjson.loads(s, allow_nan=True) == float("-inf")

    with pytest.raises(ValueError):
        rapidjson.loads(s, allow_nan=False)


@pytest.mark.unit
def test_indent():
    o = {"a": 1, "z": 2, "b": 3}
    expected1 = '{\n    "a": 1,\n    "z": 2,\n    "b": 3\n}'
    expected2 = '{\n    "a": 1,\n    "b": 3,\n    "z": 2\n}'
    expected3 = '{\n    "b": 3,\n    "a": 1,\n    "z": 2\n}'
    expected4 = '{\n    "b": 3,\n    "z": 2,\n    "a": 1\n}'
    expected5 = '{\n    "z": 2,\n    "a": 1,\n    "b": 3\n}'
    expected6 = '{\n    "z": 2,\n    "b": 3,\n    "a": 1\n}'
    expected = (
        expected1,
        expected2,
        expected3,
        expected4,
        expected5,
        expected6)

    assert rapidjson.dumps(o, indent=4) in expected

    with pytest.raises(TypeError):
        rapidjson.dumps(o, indent="\t")


@pytest.mark.unit
def test_sort_keys():
    o = {"a": 1, "z": 2, "b": 3}
    expected1 = '{"a":1,"b":3,"z":2}'
    expected2 = '{\n    "a": 1,\n    "b": 3,\n    "z": 2\n}'

    assert rapidjson.dumps(o, sort_keys=True) == expected1
    assert rapidjson.dumps(o, sort_keys=True, indent=4) == expected2


@pytest.mark.unit
def test_default():
    class Bar:
        pass

    class Foo:
        def __init__(self):
            self.foo = "bar"

    def default(obj):
        if isinstance(obj, Foo):
            return {"foo": obj.foo}

        raise TypeError("default error")

    o = {"asdf": Foo()}
    assert rapidjson.dumps(o, default=default) == '{"asdf":{"foo":"bar"}}'

    o = {"asdf": Foo(), "qwer": Bar()}
    with pytest.raises(TypeError):
        rapidjson.dumps(o, default=default)

    with pytest.raises(TypeError):
        rapidjson.dumps(o)


@pytest.mark.unit
def test_use_decimal():
    import math
    from decimal import Decimal

    dstr = "2.7182818284590452353602874713527"
    d = Decimal(dstr)

    with pytest.raises(TypeError):
        rapidjson.dumps(d)

    assert rapidjson.dumps(float(dstr)) == str(math.e)
    assert rapidjson.dumps(d, use_decimal=True) == dstr
    assert rapidjson.dumps({"foo": d}, use_decimal=True) == '{"foo":%s}' % dstr

    assert rapidjson.loads(
            rapidjson.dumps(d, use_decimal=True),
            use_decimal=True) == d

    assert rapidjson.loads(rapidjson.dumps(d, use_decimal=True)) == float(dstr)


@pytest.mark.unit
def test_object_hook():
    class Foo:
        def __init__(self, foo):
            self.foo = foo

    def hook(d):
        if 'foo' in d:
            return Foo(d['foo'])

        return d

    def default(obj):
        return {'foo': obj.foo}

    res = rapidjson.loads('{"foo": 1}', object_hook=hook)
    assert isinstance(res, Foo)
    assert res.foo == 1

    assert rapidjson.dumps(rapidjson.loads('{"foo": 1}', object_hook=hook),
                           default=default) == '{"foo":1}'
    res = rapidjson.loads(rapidjson.dumps(Foo(foo="bar"), default=default),
                          object_hook=hook)
    assert isinstance(res, Foo)
    assert res.foo == "bar"
