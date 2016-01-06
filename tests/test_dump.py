#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import unicode_literals
from unittest import TestCase
import rapidjson

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


class TestDump(TestCase):
    json = rapidjson
    dumps = rapidjson.dumps

    def test_dump(self):
        sio = StringIO()
        self.json.dump({}, sio)
        self.assertEqual(sio.getvalue(), '{}')

    def test_dumps(self):
        self.assertEqual(self.dumps({}), '{}')

    def test_encode_truefalse(self):
        self.assertEqual(self.dumps(
                 {True: False, False: True}, sort_keys=True),
                 '{"false": true, "true": false}')
        self.assertEqual(self.dumps(
                {2: 3.0, 4.0: 5, False: 1, 6: True}, sort_keys=True),
                '{"false": 1, "2": 3.0, "4.0": 5, "6": true}')

    # Issue 16228: Crash on encoding resized list
    def test_encode_mutated(self):
        a = [object()] * 10
        def crasher(obj):
            del a[-1]
        self.assertEqual(self.dumps(a, default=crasher),
                 '[null, null, null, null, null]')

    # Issue 24094
    def test_encode_evil_dict(self):
        class D(dict):
            def keys(self):
                return L

        class X:
            def __hash__(self):
                del L[0]
                return 1337

            def __lt__(self, o):
                return 0

        L = [X() for i in range(1122)]
        d = D()
        d[1337] = "true.dat"
        self.assertEqual(self.dumps(d, sort_keys=True), '{"1337": "true.dat"}')

    def test_large_list(self):
        N = int(30 * 1024 * 1024 * (1023 / 1024 * 1024))
        l = [1] * N
        encoded = self.dumps(l)
        self.assertEqual(len(encoded), N * 3)
        self.assertEqual(encoded[:1], "[")
        self.assertEqual(encoded[-2:], "1]")
        self.assertEqual(encoded[1:-2], "1, " * (N - 1))
