<#
    .SYNOPSIS
        Get detailed device information
    .DESCRIPTION
        Accepts Get-LifxDevice to obtain the device's product details (model, version, features/capabilities) and firmware version.
    .EXAMPLE
        Get-LifxDevice | Get-LifxDeviceSetting
#>

function Get-LifxDeviceSetting
{
    param(
        #a discovered Lifx device (use Get-LifxDevice)
        [parameter(
                Position          = 0,
                Mandatory         = $true,
                ValueFromPipeline = $true)]
            [PSCustomObject[]]$Device
    )

    #declare the counters
    [int]$Total = $Input.Count
    [int]$Count = 0

    #process
    $Input | ForEach-Object {
        #constants
        $Port = "56700"
        $localIP = [System.Net.IPAddress]::Parse([System.Net.IPAddress]::Any)
        $RemoteIpEndPoint = New-Object System.Net.IPEndpoint($localIP, $Port)
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    
        #Device packets
        [Byte[]]$getVersionPacket = New-LifxPacket -Type "GetVersion" | Convert-LifxPacketToBuffer
        [Byte[]]$getFirmwarePacket = New-LifxPacket -Type "GetHostFirmware" | Convert-LifxPacketToBuffer

        #send the GetVersion packet
        $send = $receivingUdpClient.SendAsync($getVersionPacket, $getVersionPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

        #get the Version
        start-sleep -Seconds 2
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $itemProduct = [System.BitConverter]::ToUInt32($result, 40) | Get-LifxProduct
        $_ | Add-Member -Name 'Product' -Type NoteProperty -Value $itemProduct -Force

        #send the GetHostFirmware packet
        $send = $receivingUdpClient.SendAsync($getFirmwarePacket, $getFirmwarePacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)

        #get the Firmware
        start-sleep -Seconds 1
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $firmwareVersionMajor = [System.BitConverter]::ToUInt16($result, 54)
        $firmwareVersionMinor = [System.BitConverter]::ToUInt16($result, 52)
        $firmwareVersion = [Version]::new($firmwareVersionMajor, $firmwareVersionMinor)
        $_ | Add-Member -Name 'Version' -Type NoteProperty -Value $firmwareVersion -Force
    
        #shut the udp client down    
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()
    
        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Retrieving Lifx Device setting" -PercentComplete $percentComplete -Status ("Retrieved $($_.Name) - " + $percentComplete + "%")

        return $_
    }
}
