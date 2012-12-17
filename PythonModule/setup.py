#!/usr/bin/env python2.7

from distutils.core import setup

setup(name='geflight',
      version='0.1.0',
      description='GE Flight Quest Scripts',
      author = 'Ben Hamner',
      author_email = 'ben@benhamner.com',
      packages = ['geflight', 'geflight.transform', 'geflight.summarize', 'geflight.benchmark'])