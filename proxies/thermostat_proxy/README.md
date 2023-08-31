# thermostat\_proxy folder


The content of this folder requires no modification by the driver developer. This folder contains .lua files that include template code to handle the Thermostat Proxy.

**thermostat\_apis.lua:** This .lua file contains the APIs functions used to get the current state of the thermostat device. While this file should not need to be modified, it does contain routines that the driver developer may want to call.

**thermostat\_device\_class.lua:** This .lua file contains functions used for Thermostat connections.

**thermostat\_main.lua:** This .lua file contains the functions needed to initialize the Thermostat Proxy.

**thermostat\_proxy\_commands.lua:** This .lua file contains the commands used by the Thermostat Proxy.

**thermostat\_proxy\_notifications.lua:** This .lua file contains the notifications the Thermostat Proxy can receive.

**thermostat\_reports.lua:** This .lua file contains functions which report new states or settings into the template code. The template code saves information as needed and may also generate needed notifications to send to the proxies. While this file should not need to be modified, it does contain routines that the driver developer may want to call.
