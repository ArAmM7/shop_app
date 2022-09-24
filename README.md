# shop_app

An app that shows items in a shop, with cart and order functionality, and the ability to modify the
products currently present in the shop. My fourth app using Flutter, multiple screens with more
complex navigation, routing and passing arguments, using Material widgets of Flutter.

The [Provider package](https://pub.dev/packages/provider) is used which is a better state management
method compared to my previous apps. The [http package](https://pub.dev/packages/http) is used to
communicate with [Firebase Realtime Database](https://firebase.google.com/docs/database)
and [Firebase Auth](https://firebase.google.com/docs/auth) through REST API to synchronise items and
orders data and to authenticate users
respectively, [shared_preferences](https://pub.dev/packages/shared_preferences) is used for storing
user id, token and, login expiry datetime.