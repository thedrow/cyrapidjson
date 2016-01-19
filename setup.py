import os

from Cython.Build import cythonize
from setuptools import setup, Extension

BASE_PATH = os.path.abspath(os.path.dirname(__file__))

extensions = [
    Extension(
        'rapidjson',
        ['src/*.pyx'],
        define_macros=[
            ('RAPIDJSON_HAS_STDSTRING', '1')
        ],
        include_dirs=[os.path.join(BASE_PATH, 'rapidjson/include/rapidjson'),
                      os.path.join(BASE_PATH, 'helpers')],
        language="c++"
    )
]

setup(
    name='cyrapidjson',
    ext_modules=cythonize(extensions),
)
