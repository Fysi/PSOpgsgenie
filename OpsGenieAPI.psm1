function Set-OpsGenieURI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$APIKey,
        [Parameter(Mandatory = $true)]
        [string]$Type
    )
    $BaseUri = "https://api.opsgenie.com/v2/alerts"
    if ("list" -eq $Type) {
        $TypeUri = $BaseUri
    }
    else {
        $TypeUri = $BaseUri + "/" + $Type
    }    
    return $TypeUri
}

function Get-OpsGenieCount {
  
    [CmdletBinding(DefaultParameterSetName = "Query")]
       
    param (
        # OpsGenie API Key
        [Parameter(Mandatory = $true, ParameterSetName = "Query")]
        [Parameter(Mandatory = $true, ParameterSetName = "SearchIdentifier")]
        [string]$APIKey,

        # Search query to apply while filtering the alerts. You can refer to OpsGenie's doc Alerts Search Query Help for further information about search queries.
        [Parameter(Mandatory = $true, ParameterSetName = "Query")]
        [string]$Query,
        
        # Identifier of the saved search query to apply while filtering the alerts.
        [Parameter(Mandatory = $true, ParameterSetName = "SearchIdentifier")]
        [string]$SearchIdentifier,
        
        # Identifier type of the saved search query. Possible values are id and name. Default value is id. If searchIdentifier is not provided, this value is not valid.
        [Parameter(Mandatory = $false, ParameterSetName = "SearchIdentifier")]
        [string]$SearchIdentifierType
    )
    Add-Type -Assembly System.Web
    $Type = "count"
    $Method = "Get"
    $QueryBase = "?query="
    $SearchIdentifierBase = "?searchIdentifier="
    $SearchIdentifierTypeBase = "&searchIdentifierType="
    $Headers = @{'Authorization' = "GenieKey $APIKey"}

    $TypeUri = Set-OpsGenieURI -APIKey $APIKey -Type $Type

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if ($null -ne $Query) {
        $UrlEncodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
        $Uri = $TypeUri + $QueryBase + $UrlEncodedQuery
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
        $Count = $Response.data.count
        Return $Count
    }
    elseif ($null -ne $SearchIdentifier) {
        if ($null -ne $SearchIdentifierType) {
            $Uri = $TypeUri + $SearchIdentifierBase + $SearchIdentifier + $SearchIdentifierTypeBase + $SearchIdentifierType
        }
        else {
            $Uri = $TypeUri + $SearchIdentifierBase + $SearchIdentifier
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
        $Count = $Response.data.count
        Return $Count
    }

}

function Get-OpsGenieList {
    [CmdletBinding(DefaultParameterSetName = "Query")]
    param (
        # OpsGenie API Key
        [Parameter(Mandatory = $true)]
        [string]$APIKey,

        # Search query to apply while filtering the alerts. You can refer to OpsGenie's doc Alerts Search Query Help for further information about search queries.
        [Parameter(ParameterSetName = "Query")]
        [string]$Query,
     
        # Identifier of the saved search query to apply while filtering the alerts.
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [string]$SearchIdentifier,
     
        # Identifier type of the saved search query. Possible values are id and name. Default value is id. If searchIdentifier is not provided, this value is not valid.
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [string]$SearchIdentifierType,

        # Start index of the result set (to apply pagination). Minimum value (and also default value) is 0.
        [Parameter(ParameterSetName = "Query")]
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [uint64]$Offset,
     
        # Maximum number of items to provide in the result. Must be a positive integer value. Default value is 20 and maximum value is 100.
        [Parameter(ParameterSetName = "Query")]
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [byte]$Limit,
     
        # Name of the field that result set will be sorted by. Default value is createdAt. More values listed in OpsGenie API docs.
        [Parameter(ParameterSetName = "Query")]
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [string]$Sort,

        # Sorting order of the result set. Possible values are desc and asc. Default value is desc.
        [Parameter(ParameterSetName = "Query")]
        [Parameter(ParameterSetName = "SearchIdentifier")]
        [string]$Order
    )
    Add-Type -Assembly System.Web
    $Type = "list"
    $Method = "Get"
    $QueryBase = "?query="
    $SearchIdentifierBase = "?searchIdentifier="
    $SearchIdentifierTypeBase = "&searchIdentifierType="
    $Headers = @{'Authorization' = "GenieKey $APIKey"}

    $TypeUri = Set-OpsGenieURI -APIKey $APIKey -Type $Type

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if ($null -ne $Offset) {
        $OffsetOut = '&' + $Offset
    }
    elseif ($null -eq $Offset) {
        $OffsetOut = ''        
    }

    if ($null -ne $Limit) {
        $LimitOut = '&' + $Limit
    }
    elseif ($null -eq $Limit) {
        $LimitOut = ''        
    }
    
    if ($null -ne $Sort) {
        $SortOut = '&' + $Sort
    }
    elseif ($null -eq $Sort) {
        $SortOut = ''
    }

    if ($null -ne $Order) {
        $OrderOut = '&' + $Order
    }
    elseif ($null -eq $Order) {
        $OrderOut = ''
    }
    
    if ($null -ne $Query) {
        $UrlEncodedQuery = [System.Web.HttpUtility]::UrlEncode($Query)
        $Uri = $TypeUri + $QueryBase + $UrlEncodedQuery + $OffsetOut + $LimitOut + $SortOut + $OrderOut
    }
    elseif ($null -ne $SearchIdentifier) {
        if ($null -ne $SearchIdentifierType) {
            $Uri = $TypeUri + $SearchIdentifierBase + $SearchIdentifier + $SearchIdentifierTypeBase + $SearchIdentifierType + $OffsetOut + $LimitOut + $SortOut + $OrderOut
        }
        else {
            $Uri = $TypeUri + $SearchIdentifierBase + $SearchIdentifier + $OffsetOut + $LimitOut + $SortOut + $OrderOut
        }

    }
    else {
        $Uri = $TypeUri
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $Response = Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
    Return $Response.data

}

Export-ModuleMember -Function Get-OpsGenieCount
Export-ModuleMember -Function Set-OpsGenieURI
Export-ModuleMember -Function Get-OpsGenieList