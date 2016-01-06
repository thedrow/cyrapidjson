#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import pytest
import rapidjson

JSON = [
    '\N{GREEK SMALL LETTER ALPHA}\N{GREEK CAPITAL LETTER OMEGA}',
    '\U0010ffff',
    'asdf \U0010ffff \U0001ffff qwert \uffff \u10ff \u00ff \u0080 \u7fff \b\n\r'
]


@pytest.mark.unit
@pytest.mark.parametrize("u", JSON)
def test_unicode(u):
    s = u.encode('utf-8')
    ju = rapidjson.dumps(u)
    js = rapidjson.dumps(s)
    assert ju == js
    assert ju == json.dumps(u)
    assert rapidjson.dumps(u, ensure_ascii=False) == json.dumps(u, ensure_ascii=False)
