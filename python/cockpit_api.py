import os
import json
import requests
from base64 import b64encode
from decorators import require_auth
from exceptions import (AuthError,
                        UnauthorizedError,
                        ParameterError,
                        MissingParameterError)


class Api(object):

    def __init__(self, api_url=None, token=None):
        if api_url == None:
            raise MissingParameterError
        if token == None:
            raise MissingParameterError

        self._session = requests.Session()
        self.api_url = api_url
        self.headers = {'Content-Type': 'application/json'}
        self.token = token

    def get_collection(self):
        r = self._session.get(self.api_url + f"/get/collection" + f"?token={self.token}", headers=self.headers)
        return r.json()

    def update_collection(self, data=None):
        if data == None:
            raise MissingParameterError
        r = self._session.get(self.api_url + f"/save/collection" + f"?token={self.token}", headers=self.headers, data=data)
        return r.json()
