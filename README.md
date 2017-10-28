# OpenCallBlock

[![Build Status](https://travis-ci.org/chrisballinger/OpenCallBlock.svg?branch=master)](https://travis-ci.org/chrisballinger/OpenCallBlock)

🚨🚧 **Under Construction** 🚧🚨

OpenCallBlock is a very simple iOS app that utilizes CallKit for blocking of NPA-NXX spam. This is a type of phone spam when you receive calls from numbers that look very similar to your own phone number. Spammers spoof those numbers in the hope you think that it's someone from your hometown.

There are a number of free and paid apps that promise to block this kind of spam, but they all seem to want to harvest your contacts and personal information for advertising purposes.

This app simply takes a US phone number like 800-555-5555, extracts the NPA-NXX prefix (e.g. 800-555), and then generates a blocklist of every number from 800-555-0000 to 800-555-9999. You can grant access to your contacts and automatically whitelist people you already know, or enter them manually. **No personal data ever leaves your device.**

For it to work you must enable the extension after installation:

* Settings => Phone => Call Blocking & Identification => Enable OpenCallBlock

Requires iOS 10 or higher.

### License

MPL 2.0 [FAQ](https://www.mozilla.org/en-US/MPL/2.0/FAQ/)
