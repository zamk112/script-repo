
#$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"

function Convert-IPUIntToIpStr {    
    param([Parameter(Mandatory=$true)][ValidateScript({($_ -is [Int32] -or $_ -is [UInt32] -or $_ -is [UInt64])})]$IPNum)
    
    $stringBuilder = New-Object -TypeName System.Text.StringBuilder

    for ($i = 0; $i -lt 4; $i++) {
        [void]$stringBuilder.Append(($IPNum -shr (8 * (3 - $i)) -band 0xFF).ToString())

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
        None. You can't pipe objects to Convert-IPUIntToIpStr.

        .OUTPUTS
        System.String. Convert-IPUIntToIpStr returns a string value of IPv4 address format (4 octets with dot notation).

        .EXAMPLE
        PS> Convert-IPUIntToIpStr -IPNum 3232235776
        192.168.1.1
    #>
}

function Convert-IPStrToIPUInt {
    param ([Parameter(Mandatory=$true)][string][ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]$IPStr)
    [byte[]]$splitIp = $IPStr -split "\."
    [uint]$IPNum = 0

    for ($i = 0; $i -lt $splitIp.Length; $i++) {
        [uint]$shifted = [uint]([int]::Parse($splitIp[$i])) -shl (8 * (3 - $i))
        Write-Debug "Octet $($i+1): $($splitIp[$i]) << $(8 * (3 - $i)) = $($shifted)"
        $IPNum += $shifted
    }

    return $IPNum

    <#
        .SYNOPSIS
        Converts String Value of IP Address to Integer presentation of IP Address.

        .DESCRIPTION
        Converts String Value presentation of IP Address which presented by 4 octets of 8 bits to Integer presentation.

        .PARAMETER IPStr
        String value presentation of IP Address.

        .INPUTS
        None. You can't pipe objects to Convert-IPStrToIPUInt.

        .OUTPUTS
        System.UInt32. Convert-IPStrToIPUInt returns a Unsinged Integer value of IPv4 addresss.

        .EXAMPLE
        PS> Convert-IPStrToIPUInt -IPStr "192.168.1.0"
        3232235776
    #>
}

function Get-IPCIDRTranslation {
    param([Parameter(Mandatory=$true)][string][ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}")]$CIDRAddress)
    
    [uint]$IPNum = Convert-IPStrToIPUInt -IPStr $($CIDRAddress -split "\/")[0]
    Write-Debug "IP Integer Value: $IPNum"
    Write-Debug "IP Binary Value: $([Convert]::ToString($IPNum, 2).PadLeft(32, '0'))"

    [int]$hostBits = 32 - [short]::Parse($($CIDRAddress -split "\/")[1])
    Write-Debug "Host Bits Integer Value: $($hostBits)"

    [long]$totalAddresses = [Math]::Pow(2, $hostBits)

    [int]$subnetMaskInt = (0xFFFFFFFF -shl $hostBits) -band 0xFFFFFFFF
    Write-Debug "Subnet Mask Integer Value: $($subnetMaskInt)"
    Write-Debug "Subnet Mask Binary Value: $([Convert]::ToString($subnetMaskInt, 2).PadLeft(32, '0'))"

    [uint]$networkInt = $IPNum -band $subnetMaskInt
    Write-Debug "Network Integer Value: $($networkInt)"
    Write-Debug "Network Binary Value: $([Convert]::ToString($networkInt, 2).PadLeft(32, '0'))"

    [uint]$broadcastInt = $networkInt -bor ($totalAddresses - 1)
    Write-Debug "Broadcast Integer Value: $($broadcastInt)"
    Write-Debug "Broadcast Mask Binary Value: $([Convert]::ToString($broadcastInt, 2).PadLeft(32, '0'))"

    [int]$hostMaskInt = -bnot $subnetMaskInt
    Write-Debug "Host Integer Value: $($hostMaskInt)"
    Write-Debug "Host Binary Value: $([Convert]::ToString($hostMaskInt, 2).PadLeft(32, '0'))"
    if (($IPNum -band $hostMaskInt) -ne 0)
    {
        Write-Warning "Host bit(s) is not valid when comparing to subnet mask, host bit(s) will be zero!"
    }

    return @{
        Network_IP = Convert-IPUIntToIpStr -IPNum $networkInt
        Broadcast_IP = Convert-IPUIntToIpStr -IPNum $broadcastInt
        Subnet_Mask = Convert-IPUIntToIpStr -IPNum $subnetMaskInt
        Total_Addresses = $totalAddresses
        First_Host = Convert-IPUIntToIpStr -IPNum ($networkInt + 1)
        Last_Host = Convert-IPUIntToIpStr -IPNum ($broadcastInt - 1)
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
        Subnet_Mask                    255.255.255.0
        Network_IP                     192.168.1.0
        Broadcast_IP                   192.168.1.255
        Total_Addresses                256
        Last_Host                      192.168.1.254
        First_Host                     192.168.1.1

        .EXAMPLE
        PS> Get-IPCIDRTranslation -CIDRAddress "10.0.1.0/16"
        WARNING: Host bit(s) is not valid when comparing to subnet mask, host bit(s) will be zero!

        Name                           Value
        ----                           -----
        Subnet_Mask                    255.255.0.0
        First_Host                     10.0.0.1
        Last_Host                      10.0.255.254
        Broadcast_IP                   10.0.255.255
        Network_IP                     10.0.0.0
        Total_Addresses                65536
    #>
}

function Compare-Subnets {
    param ([Parameter(Mandatory=$true)][string][ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]$IPStrA,
           [Parameter(Mandatory=$true)][string][ValidatePattern("\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")]$IPStrB
          )
    
    [uint]$ipNumA = Convert-IPStrToIPUInt -IPStr ($IPStrA -split "\/")[0]
    Write-Debug "A: IP Integer Value: $IPNumA"
    Write-Debug "A: IP Binary Value: $([Convert]::ToString($IPNumA, 2).PadLeft(32, '0'))"

    [uint]$ipNumB = Convert-IPStrToIPUInt -IPStr ($IPStrB -split "\/")[0]
    Write-Debug "B: IP Integer Value: $IPNumB"
    Write-Debug "B: IP Binary Value: $([Convert]::ToString($IPNumB, 2).PadLeft(32, '0'))"    

    [short]$prefixNumA = ($IPStrA -split "\/")[1]
    [short]$prefixNumB = ($IPStrB -split "\/")[1]

    [short]$subnetPrefix = [System.Math]::Max($prefixNumA, $prefixNumB)
    Write-Debug "Max Prefix Value: $($subnetPrefix)"

    [int]$subnetMaskInt = (0xFFFFFFFF -shl (32 - $subnetPrefix)) -band 0xFFFFFFFF
    Write-Debug "Subnet Mask Integer Value: $($subnetMaskInt)"
    Write-Debug "Subnet Mask Binary Value: $([Convert]::ToString($subnetMaskInt, 2).PadLeft(32, '0'))"
    
    [uint]$networkIPNumA = $ipNumA -band $subnetMaskInt
    Write-Debug "A: Network Integer Value: $($networkIPNumA)"
    Write-Debug "A: Network Binary Value: $([Convert]::ToString($networkIPNumA, 2).PadLeft(32, '0'))"

    [uint]$networkIpNumB = $ipNumB -band $subnetMaskInt
    Write-Debug "B: Network Integer Value: $($networkIPNumB)"
    Write-Debug "B: Network Binary Value: $([Convert]::ToString($networkIPNumB, 2).PadLeft(32, '0'))"

    if ($networkIPNumA -eq $networkIpNumB)
    {
        return $true
    }

    if ($prefixNumA -ne $prefixNumB)
    {
        [short]$subnetPrefix = [System.Math]::Min($prefixNumA, $prefixNumB)
        Write-Debug "Min Prefix Value: $($subnetPrefix)"

        [int]$subnetMaskInt = (0xFFFFFFFF -shl (32 - $subnetPrefix)) -band 0xFFFFFFFF
        Write-Debug "Subnet Mask Integer Value: $($subnetMaskInt)"
        Write-Debug "Subnet Mask Binary Value: $([Convert]::ToString($subnetMaskInt, 2).PadLeft(32, '0'))"

        [uint]$networkIPNumA = $ipNumA -band $subnetMaskInt
        Write-Debug "A: Network Integer Value: $($networkIPNumA)"
        Write-Debug "A: Network Binary Value: $([Convert]::ToString($networkIPNumA, 2).PadLeft(32, '0'))"  

        [uint]$networkIpNumB = $ipNumB -band $subnetMaskInt
        Write-Debug "B: Network Integer Value: $($networkIPNumB)"
        Write-Debug "B: Network Binary Value: $([Convert]::ToString($networkIPNumB, 2).PadLeft(32, '0'))"  

        return $networkIPNumA -eq $networkIpNumB
    }
    
    return $false

    <#
        .SYNOPSIS
        Compares two subnets for overlaps or if subnet is within IP Address Space.

        .DESCRIPTION
        Compares two subnets for overlaps or if subnet is within the IP Address Space with IP CIDR values, first by taking the max value of the prefix and then comparing the network IP values.
        If network IP comparison returns false then it will take the minimum prefix value if the prefixes do not match and then compare the new network IP values.

        .PARAMETER IPStrA
        Input is IPv4 CIDR Address

        .PARAMETER IPStrB
        Input is IPv4 CIDR Address        

        .INPUTS
        None. You can't pipe objects to Compare-Subnets.

        .OUTPUTS
        Returns a Boolean value.

        .EXAMPLE
        PS> Compare-Subnets -IPStrA "192.168.1.0/24" -IPStrB "192.168.1.128/25"
        True

        .EXAMPLE
        PS> Compare-Subnets -IPStrA "192.168.1.0/25" -IPStrB "192.168.1.128/25"
        False

        .EXAMPLE
        PS> Compare-Subnets -IPStrA "10.0.0.0/24" -IPStrB "10.0.5.0/24"
        False        
        
    #>    
}
