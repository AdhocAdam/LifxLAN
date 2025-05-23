<#
    .SYNOPSIS
        Get the power state of a Lifx device
    .DESCRIPTION
        Get the current power state of a Lifx device.
    .EXAMPLE
        Get-LifxDevice | Initialize-LifxDevice | Get-LifxDevicePower
     .EXAMPLE
        Get-LifxDevice | Get-LifxDevicePower  
#>

function Get-LifxDevicePower
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
        [Byte[]]$getPowerPacket = New-LifxPacket -Type "GetPower" | Convert-LifxPacketToBuffer
    
        #get the power
        $send = $receivingUdpClient.SendAsync($getPowerPacket, $getPowerPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
    
        #wait a second
        start-sleep -seconds 1
    
        #parse the GetPower result
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $powerState = [System.BitConverter]::ToUInt16($result, 36)
        switch ($powerState)
        {
            65535 {$powerBool = $true}
            0  {$powerBool = $false}
        }

        #set the power value
        $_ | Add-Member -Name 'Power' -Type NoteProperty -Value $powerBool -Force

        #shut the udp client down    
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()
    
        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Getting Device Power" -PercentComplete $percentComplete -Status ("$($_.Name) $($_.Power) - " + $percentComplete + "%")

        return $_
    }
}
