## Description
This PowerShell script was created to make life easier regarding adding/removing/deactivating OneLogin users en masse. The script uses [@mattmcnabb's](https://github.com/mattmcnabb) [PowerShell module](https://github.com/mattmcnabb/OneLogin) to interact with OneLogin via its REST API.

## Requirements
* PowerShell v5.0 or greater
* OneLogin API Credentials - you can get the credentials using these [instructions](http://bit.ly/olapi)

## Getting Started
1. Download and extract the [OneLogin Script.zip](https://github.com/atechnextdoor/OneLoginPS/archive/master.zip) file to your Windows machine
1. Double click the **_double click this.lnk** shortcut
1. Enter your OneLogin API Credentials (ID & Secret) when prompted
1. Select an action: **get**, **add**, **deactivate**, **remove**, or **quit**
1. If specified, provide the .csv file path

#### Note
You can use the "users.csv" file as a template for adding/removing/deactivating users via the script.

### Script Run Example
[![OneLogin Script](https://i.imgur.com/NUMD1Vk.png)](https://i.imgur.com/wVJXvDO.mp4)
