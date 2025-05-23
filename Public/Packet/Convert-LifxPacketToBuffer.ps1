<#
    .SYNOPSIS
        Converts a Lifx packet to a Byte Array
    .DESCRIPTION
        This cmdlets takes the result of New-LifxPacket and converts it to a byte array to be
        sent to a device(s) on a LAN.
    .EXAMPLE
        New-LifxPacket -Type "GetColor" | Convert-LifxPacketToBuffer
    .EXAMPLE
        New-LifxPacket -Type "Discovery" | Convert-LifxPacketToBuffer
#>

function Convert-LifxPacketToBuffer
{
    param(
        [parameter(
            Mandatory         = $true,
            ValueFromPipeline = $true
        )]
        $encodePacket
    )

    [Byte[]]$buffer = New-Object byte[] $encodePacket.size;
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.size), 0, $buffer, 0, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.protocol), 0, $buffer, 2, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.reserved1), 0, $buffer, 4, 4);
    [System.Array]::Copy($encodePacket.target_mac_address, 0, $buffer, 8, 6);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.reserved2), 0, $buffer, 14, 2);
    [System.Array]::Copy($encodePacket.site, 0, $buffer, 16, 6);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.reserved3), 0, $buffer, 22, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.timestamp), 0, $buffer, 24, 8);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.packet_type), 0, $buffer, 32, 2);
    [System.Array]::Copy([System.BitConverter]::GetBytes($encodePacket.reserved4), 0, $buffer, 34, 2);
    [Byte[]]$payload = New-Object byte[] 0
    [System.Array]::Copy($payload, 0, $buffer, 36, $payload.Length);

    return $buffer
}