# Control4 Driver Template Overview

Driver Development Templates are delivered by Control4 to enhance the way device drivers are developed by partners and third parties. Driver Templates provide a pre-defined starting point for the driver developer and offer an opportunity to not only shorten the development lifecycle but offer a level of consistency across the driver community.

At its most basic level a Driver template is a repository of framework files which comprise  a .c4z file. It contains numerous folders and files which, when encapsulated inside a .c4z zip file, represents the beginnings of a device driver. The modularity within the Driver Template structure enables a far more organized approach to device driver architecture. It also provides the ability to include many related development objects within the confines of the driver in an organized manner.

These objects can include items such as custom graphics and icon directories can be displayed on Navigator as well as device driver XML – which is now separated from the driver’s lua code.

The Driver Templates also take advantage of the .c4z structure by delivering libraries of commonly used lua functionality. These now reside in specified directory locations and can be easily referenced.

Additionally, driver documentation can be delivered through the template to support a far superior user assistance model.



Copyright 2023 Snap One, LLC. All rights reserved.
