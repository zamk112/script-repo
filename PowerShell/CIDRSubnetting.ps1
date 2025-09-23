
#$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"

function Convert-IntIPToIpStr {    
    param([Parameter(Mandatory=$true)][ValidateScript({($_ -is [Int32] -or $_ -is [UInt32] -or $_ -is [UInt64])})]$IPNum)
    
    $stringBuilder = New-Object -TypeName System.Text.StringBuilder

    for ($i = 0; $i -lt 4; $i++) {
        [void]$stringBuilder.Append([string]($IPNum -shr (8 * (3 - $i)) -band 0xFF))

        if ($i -ne 3)
        {
            [void]$stringBuilder.Append(".")
        }
    }

    return $stringBuilder.ToString()

    <#
        .SYNOPSIS
        Converts Integer Value of IP Address to String presentation of IP Address.

        .DESCRIPTION
        Converts Integer Value presentation of IP Address to String presentation of IPv4 Address broken up into 4 set octets with dot notation.

        .PARAMETER IPNum
        Integer value presentation of IP Address. Parameter value needs to be either int, uint or ulong

        .INPUTS
        None. You can't pipe objects to Convert-IntIPToIpStr.

        .OUTPUTS
        System.String. Convert-IntIPToIpStr returns a string value of IPv4 address format (4 octets with dot notation).

        .EXAMPLE
        PS> Convert-IntIPToIpStr -IPNum 3232235776
        192.168.1.1
    #>
}

function Get-IPCIDRTranslation {
    param([Parameter(Mandatory=$true)][string][ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]$CIDRAddress)

    
    $ip = ($CIDRAddress -split "\/")[0]
    $prefix = ($CIDRAddress -split "\/")[1]
    
    [byte[]]$splitIp = $ip -split "\."
    [uint]$IPNum = 0


    for ($i = 0; $i -lt $splitIp.Length; $i++) {
        [uint]$shifted = [uint]([int]::Parse($splitIp[$i])) -shl (8 * (3 - $i))
        Write-Debug "Octet $($i): $($splitIp[$i]) << $(8 * (3 - $i)) = $($shifted)"
        $IPNum += $shifted
    }

    Write-Debug "IP Integer Value: $IPNum"
    Write-Debug "IP Binary Value: $([Convert]::ToString($IPNum, 2).PadLeft(32, '0'))"

    $hostBits = 32 - $prefix
    Write-Debug "Host Bits Integer Value: $($hostBits)"

    $totalAddresses = [Math]::Pow(2, $hostBits)

    $subnetMaskInt = (0xFFFFFFFF -shl $hostBits) -band 0xFFFFFFFF
    Write-Debug "Subnet Mask Integer Value: $($subnetMaskInt)"
    Write-Debug "Subnet Mask Binary Value: $([Convert]::ToString($subnetMaskInt, 2).PadLeft(32, '0'))"

    $networkInt = $IPNum -band $subnetMaskInt
    Write-Debug "Network Integer Value: $($networkInt)"
    Write-Debug "Network Binary Value: $([Convert]::ToString($networkInt, 2).PadLeft(32, '0'))"

    $broadcastInt = $networkInt -bor ($totalAddresses - 1)
    Write-Debug "Broadcast Integer Value: $($broadcastInt)"
    Write-Debug "Broadcast Mask Binary Value: $([Convert]::ToString($broadcastInt, 2).PadLeft(32, '0'))"

    $hostMaskInt = -bnot $subnetMaskInt
    Write-Debug "Host Integer Value: $($hostMaskInt)"
    Write-Debug "Host Binary Value: $([Convert]::ToString($hostMaskInt, 2).PadLeft(32, '0'))"
    if (($IPNum -band $hostMaskInt) -ne 0)
    {
        Write-Warning "Host bit(s) is not valid when comparing to subnet mask, host bit(s) will be zero!"
    }

    return @{
        'Network IP' = Convert-IntIPToIpStr -IPNum $networkInt
        'Broadcast IP' = Convert-IntIPToIpStr -IPNum $broadcastInt
        'Subnet Mask' = Convert-IntIPToIpStr -IPNum $subnetMaskInt
        'Total Addresses' = $totalAddresses
        'First Host' = Convert-IntIPToIpStr -IPNum ($networkInt + 1)
        'Last Host' = Convert-IntIPToIpStr -IPNum ($broadcastInt - 1)
    }

    <#
        .SYNOPSIS
        Translates the IPv4 CIDR address range and breakdowns of IPv4 ranges and Subnets

        .DESCRIPTION
        Translates the IPv4 CIDR address range and breakdowns the CIDR ranges and finds:
        - Subnet Mask
        - Network IP
        - Broadcast IP
        - Total count of IPv4 Addresses
        - First IPv4 Address
        - Last IPv4 Address

        .PARAMETER CIDRAddress
        Input is IPv4 CIDR Address

        .INPUTS
        None. You can't pipe objects to Get-IPCIDRTranslation.

        .OUTPUTS
        Hashtable. Get-IPCIDRTranslation returns a hashtable with the following key-pair values:
        - Subnet Mask
        - Network IP
        - Broadcast IP
        - Total count of IPv4 Addresses
        - First IPv4 Address
        - Last IPv4 Address

        .EXAMPLE
        PS> Get-IPCIDRTranslation -CIDRAddress "192.168.1.0/24"
        Name                           Value
        ----                           -----
        Subnet Mask                    255.255.255.0
        Network IP                     192.168.1.0
        Broadcast IP                   192.168.1.255
        Total Addresses                256
        Last Host                      192.168.1.254
        First Host                     192.168.1.1
    #>
}

