# media\_player\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the Media\_Player Proxy.

**media\_player\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the media\_player device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**media\_player\_device\_class.lua:** This .lua file contains functions used for the media player's inputs and outputs.

**media\_player\_main.lua:** This .lua file contains the functions needed to initialize the Media Player Proxy.

**media\_player\_proxy\_commands.lua:** This .lua file contains the commands used by the Media Player Proxy.

**media\_player_proxy\_notifies.lua:** This .lua file contains the notifications the Media Player Proxy can receive.

**media\_player\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.
