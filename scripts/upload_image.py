#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import requests
import json
import jwt
import time

if len(sys.argv) < 2:
    print "ファイル名が指定されていません"
    sys.exit(1)

time.sleep(5) # 画像ファイルが出来上がるまで、５秒待つ

# 引数から画像ファイルをオープン
image = open(sys.argv[1], 'rb')
# Endorse Tokenの取得
print "- SORACOM Endorse にアクセスして token を取得中 ..."
response=json.loads(requests.get('https://endorse.soracom.io/').text)
token = response['token']
decoded = jwt.decode(token, verify = False)
print json.dumps(decoded, indent=4)

# 画像のアップロード
base_url = 'https://soracom-handson.s3.amazonaws.com/incoming/camera/'
print "- Amazon S3 にファイルをアップロード中 ..."
print "PUT %s" % base_url+decoded['jti']
r = requests.put(base_url+decoded['jti'], data=image, headers={'user-agent': 'soracom-handson-client', 'x-amz-acl': 'bucket-owner-full-control','x-amz-meta-jwt':token, 'content-type': 'image/jpg'})
print "status: %s" % r.status_code
