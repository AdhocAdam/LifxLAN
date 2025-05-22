<#
    .SYNOPSIS
        Controls the color of a Lifx device
    .DESCRIPTION
        This cmdlet allows you to set the brightness, saturation, hue, and kelvin of a Lifx device based on different parameters. It also
        supports SecondsToTransition to control how fast the change occurs.
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Red 200 -Blue 13 -Brightness 75 -Saturation 100
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White "Sunset" -SecondsToTransition 1.5
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Brightness 100 -White "Noon Daylight" -SecondsToTransition 4
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -Kelvin 12000 -Brightness 10000
    .EXAMPLE
        $devices = Get-LifxDevice | Initialize-LifxDevice
        $devices | Where-Object {$_.Group -eq "Living Room"} | Set-LifxDeviceColor -White 'Cloudy Daylight' -Brightness 90
#>

function Set-LifxDeviceColor
{
    param(
        #Discovered Lifx device. Accepts input from Get-LifxDevice or Initialize-LifxDevice
        [parameter(
            Position          = 0,
            Mandatory         = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject[]]$Device,

        #Hue: The section of the color spectrum that represents the color of your device. This is taken as RGB values and converted to HSB
        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName="Color")]
        [decimal]$Red = 0,

        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName="Color")]
        [decimal]$Green = 0,

        [ValidateRange(0, 255)]
        [Parameter(ParameterSetName="Color")]
        [decimal]$Blue = 0,

        #Brightness: How bright the light is. Zero brightness is the same as the device is off, while full brightness be just that.
        #This value is taken as a percent value i.e. 1, 27, 43, 100
        [ValidateRange(0, 100)]
        [Parameter(ParameterSetName="Color")]
        [Parameter(ParameterSetName="KelvinByNumber")]
        [Parameter(ParameterSetName="KelvinByName")]
        [decimal]$Brightness,

        #Saturation: How strong the color is. So a Zero saturation is completely white, whilst full saturation is the full color
        [ValidateRange(0, 100)]
        [Parameter(ParameterSetName="Color")]
        [decimal]$Saturation = 0,

        #the number of seconds it will take the light to change color
        [Parameter(ParameterSetName="Color")]
        [Parameter(ParameterSetName="KelvinByNumber")]
        [Parameter(ParameterSetName="KelvinByName")]
        [decimal]$SecondsToTransition = 0,

        #Kelvin: Allowed range aka the "temperature" when the device has zero saturation. A higher value is a
        #cooler white (more blue) whereas a lower value is a warmer white (more yellow)
        [ValidateRange(1000, 12000)]
        [Parameter(ParameterSetName="KelvinByNumber")]
        [decimal]$Kelvin,

        #kelvin values by name as defined by Lifx
        [Parameter(ParameterSetName="KelvinByName")]
        [ValidateSet("Candlelight", "Sunset", "Ultra Warm", "Incandescent", "Warm", "Neutral", "Cool", "Cool Daylight", "Soft Daylight",
            "Daylight", "Noon Daylight", "Bright Daylight", "Cloudy Daylight", "Blue Daylight", "Blue Overcast", "Blue Ice")]
        [string]$White
    )

    #declare the counters
    [int]$Total = $Input.Count
    [int]$Count = 0

    #convert the White value to Kelvin
    switch ($White) {
        "Candlelight" { $Kelvin = 1500 }
        "Sunset" { $Kelvin = 2000 }
        "Ultra Warm" { $Kelvin = 2500 }
        "Incandescent" { $Kelvin = 2700 }
        "Warm" { $Kelvin = 3000 }
        "Neutral" { $Kelvin = 3500 }
        "Cool" { $Kelvin = 4000 }
        "Cool Daylight" { $Kelvin = 4500 }
        "Soft Daylight" { $Kelvin = 5000 }
        "Daylight" { $Kelvin = 5600 }
        "Noon Daylight" { $Kelvin = 6000 }
        "Bright Daylight" { $Kelvin = 6500 }
        "Cloudy Daylight" { $Kelvin = 7000 }
        "Blue Daylight" { $Kelvin = 7500 }
        "Blue Overcast" { $Kelvin = 8000 }
        "Blue Ice" { $Kelvin = 9000 }
    }

    #convert inputs
    #https://lan.developer.lifx.com/docs/representing-color-with-hsbk
    $Brightness = $Brightness/100
    $Saturation = $Saturation/100
    #$hscolor = [System.Drawing.Color]::FromArgb($red, $green, $blue)
    $hscolor = ConvertTo-HSBK -Red $red -Green $green -Blue $blue
    $hsbrightness = [int]([Math]::Round(0xFFFF * $Brightness))
    #$hshue = [int](([Math]::Round(0x10000 * $hscolor.GetHue()) / 360) % 0x10000)
    $hshue = [int](([Math]::Round(0x10000 * $hscolor.Hue) / 360) % 0x10000)
    $hsSaturation = [int]([Math]::Round(0xFFFF * $Saturation))

    #build the packet
    $packet = [PSCustomObject]@{
        size       = 49;
        hue        = [uint16]$hshue
        saturation = [uint16]$hsSaturation #0 #65535
        brightness = [uint16]$hsbrightness
        kelvin     = [uint16]$Kelvin
        duration   = [uint32]($SecondsToTransition * 1000)
        packet_type        = [uint16]102;
        protocol           = [uint16]21504;
        reserved1          = [uint32]0;
        reserved2          = [uint32]0;
        reserved3          = [uint32]0;
        reserved4          = [uint32]0;
        reserved5          = [uint32]0;
        reserved6          = [uint32]0;
        site               = New-Object byte[] 8
        target_mac_address = New-Object byte[] 8
        timestamp          = [uint64]0
    }

    #convert the packet to a byte array
    [Byte[]]$buffer = New-Object byte[] $packet.size;
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.size), 0, $buffer, 0, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.protocol), 0, $buffer, 2, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved1), 0, $buffer, 4, 4);
    [System.Array]::Copy($packet.target_mac_address, 0, $buffer, 8, 6);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved2), 0, $buffer, 14, 2);
    [System.Array]::Copy($packet.site, 0, $buffer, 16, 6);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved3), 0, $buffer, 22, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.timestamp), 0, $buffer, 24, 8);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.packet_type), 0, $buffer, 32, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved4), 0, $buffer, 30, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.reserved6), 0, $buffer, 34, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.hue), 0, $buffer, 37, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.saturation), 0, $buffer, 39, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.brightness), 0, $buffer, 41, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.kelvin), 0, $buffer, 43, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($packet.duration), 0, $buffer, 45, 4);
    [Byte[]]$payload = New-Object byte[] 0 #$packet.GetPayloadBuffer();
    [System.Array]::Copy($payload, 0, $buffer, 36, $payload.Length);

    #Device packets
    [Byte[]]$changeColorPacket = $buffer

    #process
    $Input | ForEach-Object {
        #constants
        $Port = "56700"
        $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
        $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port)
        $receivingUdpClient = $null
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)

        #send the SetColor packet to the device
        $send = $receivingUdpClient.SendAsync($changeColorPacket, $changeColorPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

        #shut the udp client down
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()

        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Changing Lifx Device Color" -PercentComplete $percentComplete -Status ("$($_.Name) color changed - " + $percentComplete + "%")
    }
}
