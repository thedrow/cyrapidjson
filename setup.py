import os

from Cython.Build import cythonize
from setuptools import setup, Extension

BASE_PATH = os.path.abspath(os.path.dirname(__file__))

extension = Extension(
    'rapidjson',
    ['src/*.pyx'],
    include_dirs=[os.path.join(BASE_PATH, 'rapidjson/include/rapidjson')],
    language="c++"
)

setup(
    name='cyrapidjson',
    ext_modules=cythonize([extension]),
)
