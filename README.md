<h1 align="center">
  <br>
  <img width="400" src="lifxlan.png">
  <br>
    LifxLAN
  <br>
</h1>

## Overview
This is a module aimed at controlling Lifx devices on your LAN right from PowerShell. Cmdlets are not comprehensive in their control but pull requests are welcome! 

## Getting Started
Install from the module from the PowerShell Gallery by using the following at a PowerShell prompt
```powershell
Install-Module LifxLAN
```

## Discovering Lifx devices on your network
To begin to controlling lights on your LAN start a discovery with
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
```
This returns a list of Lifx devices on your network by their IP Address, Name, and Group

## Controlling Power
Devices can be turned on individually or through the pipeline
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDevicePower -Power $true
```
or 
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
Set-LifxDevicePower -Device $devices[0] -Power $false
```

## Changing Color
Just like the app, the HSBK (Hue, Saturation, Brightness, Kelvin) can all be controlled independently.
- Brightness/Saturdation are provided in terms of 0-100 percent, defaults to 0 if not provided.
- RGB 0-255, defaults to 0 if not provided.
- Kelvin 1000-12000

### RGB
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Red 200 -Blue 13 -Brightness 75 -Saturation 100
```

### Predefined white palette as seen in the app (supports tab complete)
```powershell
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White 'Sunset' -SecondsToTransition 1.5
```


### White palette as defined in Kelvin range
```powershell        
$devices = Get-LifxDevice | Initialize-LifxDevice
$devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Kelvin 7500 -Brightness 100
```

## Credits
This PowerShell module is made possible the following GitHub repositories and projects around controlling Lifx devices via .NET as well as examining Lifx packets over [Wireshark](https://www.wireshark.org/).
- [LifxNet](https://github.com/dotMorten/LifxNet)
- [LIFX-Control](https://github.com/PhilWheat/LIFX-Control)
- [WiresharkLIFXDissector](https://github.com/mab5vot9us9a/WiresharkLIFXDissector)

And of course Lifx documentation:
- [Querying the device for data](https://lan.developer.lifx.com/docs/querying-the-device-for-data)
- [Changing a device](https://lan.developer.lifx.com/docs/changing-a-device)
