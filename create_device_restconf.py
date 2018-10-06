#!/usr/bin/env python

import json
import requests

TheDevice = {
    "device": {
        "name": "ios3",
        "address": "127.0.0.1",
        "port": 10022,
        "state": {
            "admin-state": "unlocked"
        },
        "authgroup": "default",
        "device-type": {
            "cli": {
                "ned-id": "tailf-ned-cisco-ios-id:cisco-ios"
            }
        }
    }
}

def main():
    baseUri = "http://localhost:8080/restconf/data"
    auth = ('admin', 'admin')
    headers = {'Content-Type': 'application/yang-data+json'}
    resp = requests.put(baseUri + '/devices/device=ios3', auth=auth, headers=headers, data=json.dumps(TheDevice))
    print(resp)

    baseUriOper = "http://localhost:8080/restconf/operations"
    resp = requests.post(baseUriOper + "/devices/device=ios3/ssh/fetch-host-keys", auth=auth, headers=headers)
    print(resp)

    resp = requests.post(baseUriOper + "/devices/device=ios3/sync-from", auth=auth, headers=headers)
    print(resp)


if __name__ == "__main__":
    main()
