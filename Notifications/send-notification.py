#APi's
# Rest: https://www.parse.com/docs/rest/guide/#push-notifications
# Swift: https://www.parse.com/docs/ios/guide#push-notifications-receiving-pushes

import json,httplib
connection = httplib.HTTPSConnection('api.parse.com', 443)
connection.connect()
connection.request('POST', '/1/push', json.dumps({
       "channels": [
         "Quran-Appen"
       ],
 		"data": {
         "alert": "The first 100 users that reviews the Qur'an Pro app '5 stars', will get the iDu'a Pro app for FREE! plz contanct me via the app.",
         "sound": "default",
         "app-id": "994829561"
       }
     }), {
       "X-Parse-Application-Id": "***************************************",
       "X-Parse-REST-API-Key": "***************************************",
       "Content-Type": "application/json"
     })
result = json.loads(connection.getresponse().read())
print result