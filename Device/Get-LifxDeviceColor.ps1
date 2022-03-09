<#
    .SYNOPSIS
        Get the color of a Lifx device
    .DESCRIPTION
        Returns the HSBK values of a device. Hue will be a range between 0-360 degrees and Saturdation/Brightness between 0-100 percent
    .EXAMPLE
        Get-LifxDevice | Initialize-LifxDevice | Get-LifxDeviceColor
     .EXAMPLE
        Get-LifxDevice | Get-LifxDeviceColor  
#>

function Get-LifxDeviceColor
{
    param(
        #a discovered Lifx bulb (use Get-LifxDevice)
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
        $receivingUdpClient = $null
        $receivingUdpClient = New-Object System.Net.Sockets.UDPClient($RemoteIpEndPoint)
        $receivingUdpClient.Client.Blocking = $false
        $receivingUdpClient.DontFragment = $true
        $receivingUdpClient.Client.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress, $true)
    
        #Device packets
        [Byte[]]$getColorPacket = New-LIFXPacket -Type "GetColor" | Convert-LifxPacketToBuffer
    
        #get the color
        $send = $receivingUdpClient.SendAsync($getColorPacket, $getColorPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
    
        #wait a second
        start-sleep -seconds 1
    
        #parse the GetColor result
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $hue = [Math]::Round(([System.BitConverter]::ToUInt16($result, 36) * 360) / 0x10000)
        $saturation = (([System.BitConverter]::ToUInt16($result, 38)) % 0xFFFF) * 100
        $brightness = (([System.BitConverter]::ToUInt16($result, 40)) / 0xFFFF) * 100
        $kelvin = ([System.BitConverter]::ToUInt16($result, 42))
        #$powerState = ([System.BitConverter]::ToUInt16($result, 46)) -gt 0 #on/off
        #$itemName = [System.Text.Encoding]::UTF8.GetString($result, 48, 32) #name
    
        #set the GetColor values
        $_ | Add-Member -Name 'Hue' -Type NoteProperty -Value $hue -Force
        $_ | Add-Member -Name 'Saturation' -Type NoteProperty -Value $saturation -Force
        $_ | Add-Member -Name 'Brightness' -Type NoteProperty -Value $brightness -Force
        $_ | Add-Member -Name 'Kelvin' -Type NoteProperty -Value $kelvin -Force
        #$_ | Add-Member -Name 'Power' -Type NoteProperty -Value $powerState -Force
        #$_ | Add-Member -Name 'Name' -Type NoteProperty -Value $itemName -Force

        #shut the udp client down    
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()
    
        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Retrieving Device Color" -PercentComplete $percentComplete -Status ("$($_.Name) color retrieved - " + $percentComplete + "%")

        return $_
    }
}
