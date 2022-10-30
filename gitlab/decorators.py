#!/usr/bin/python

import json
import functools
from exceptions import LoginRequiredError, DataError


def require_auth(function):
    """
    Wraps API calls in function that ensures headers are passed
    with a token
    """
    @functools.wraps(function)
    def wrapper(self, *args, **kwargs):
        if not self.headers:
            raise LoginRequiredError
        return function(self, *args, **kwargs)
    return wrapper
