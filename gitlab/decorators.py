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


def validate_data(function):
    """
    Wraps API calls in function that ensures data is passed as JSON
    """
    @functools.wraps(function)
    def wrapper(self, *args, **kwargs):
        if self.data is None:
            raise DataError
        else:
            try:
                if isinstance(self.data, dict):
                    self.data = json.dumps(self.data, indent=4)
            except ValueError:
                try:
                    json.loads(self.data)
                except ValueError:
                    raise DataError
        return function(self, *args, **kwargs)
    return wrapper
