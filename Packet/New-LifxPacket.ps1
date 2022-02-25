<#
    .SYNOPSIS
        Creates a new Lifx packet to send to a device(s)
    .DESCRIPTION
        This cmdlets creates [PSCustomObject] to create a packet to be used with Convert-LifxPacketToBuffer
    .EXAMPLE
        New-LifxPacket -Type "GetColor"
     .EXAMPLE
        New-LifxPacket -Type "Discovery"   
#>

function New-LifxPacket
{
    param (
        [ValidateSet("Discovery", "GetColor", "GetGroup")]
        [string] $Type
    )

    switch ($Type)
    {
        "Discovery" {$packetInt = 2; $size = 36; $ackRequired = $false}
        "GetColor"  {$packetInt = 101; $size = 36; $ackRequired = $false}
        "GetGroup"  {$packetInt = 51; $size = 36; $ackRequired = $false}
    }

    $packet = [PSCustomObject] @{
        packet_type        = [uint16]$packetInt;
        protocol           = [uint16]21504;
        ack_required       = [bool]$ackRequired
        reserved1          = [uint32]0;
        reserved2          = [uint32]0;
        reserved3          = [uint32]0;
        reserved4          = [uint32]0;
        site               = New-Object byte[] 8
        size               = [uint16]$size;
        target_mac_address = New-Object byte[] 8
        timestamp          = [uint64]0
    }
    return $packet
}