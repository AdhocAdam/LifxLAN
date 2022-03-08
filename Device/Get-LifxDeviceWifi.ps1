function Get-LifxDeviceWifi
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
        [Byte[]]$getWifiPacket = New-LIFXPacket -Type "GetWifi" | Convert-LifxPacketToBuffer
    
        #get the wifi
        $send = $receivingUdpClient.SendAsync($getWifiPacket, $getWifiPacket.Length, $_.IPAddress.Address, $_.IPAddress.Port)
    
        #wait a second
        start-sleep -seconds 1
    
        #parse the GetWIfi result
        #https://lan.developer.lifx.com/docs/information-messages#statewifiinfo---packet-17
        $result = $receivingUdpClient.Receive([ref]$RemoteIpEndPoint)
        $wifiSignal = [System.BitConverter]::ToSingle($result, 36)
        $rssi = [int]([math]::Floor((10 * [math]::Log10($wifiSignal)) + 0.5))
    
        #set the GetWifi value
        if ($rssi -eq 200) {$strength = "No signal"}
        elseif ($rssi -lt -80) {$strength = "Very bad"}
        elseif ($rssi -lt -70) {$strength = "Bad"}
        elseif ($rssi -lt -60) {$strength = "Alright"}
        else {$strength = "Good"}
        $_ | Add-Member -Name 'WifiSignal' -Type NoteProperty -Value $rssi -Force
        $_ | Add-Member -Name 'WifiStrength' -Type NoteProperty -Value $strength -Force

        #shut the udp client down    
        $receivingUdpClient.Dispose()
        $receivingUdpClient.Close()
    
        $Count++
        [int]$percentComplete = ($Count/$Total* 100)
        Write-Progress -Activity "Getting Wifi Strength" -PercentComplete $percentComplete -Status ("$($_.Name) signal $($_.WifiStrength) - " + $percentComplete + "%")

        return $_
    }
}
