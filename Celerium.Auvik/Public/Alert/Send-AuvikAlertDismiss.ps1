function Send-AuvikAlertDismiss {
<#
    .SYNOPSIS
        Dismiss an alert

    .DESCRIPTION
        The Send-AuvikAlertDismiss cmdlet invokes the POST method of the /alert/dismiss/{id} endpoint (Dismiss an alert)

        Use the Dismiss Alert API to dismiss a specific alert that Auvik has triggered

        This is a write function. It changes data in Auvik. Use -WhatIf to see the request without sending it

    .PARAMETER Id
        ID of alert

    .EXAMPLE
        Send-AuvikAlertDismiss -Id '1234567890' -WhatIf

        Shows the POST request to the /alert/dismiss/{id} endpoint without sending it

    .INPUTS
        System.String

    .OUTPUTS
        System.Management.Automation.PSCustomObject

    .NOTES
        Endpoint : POST /alert/dismiss/{id}
        The Auvik API user needs the role permissions that are required by the endpoint

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Send-AuvikAlertDismiss.html
#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Id
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = ($FunctionName -replace '-', '') + 'Parameters'
        $QueryParameterName = $ParameterName + 'Query'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/alert/dismiss/$([System.Uri]::EscapeDataString($Id))"
        $NameMap = @{}

        $UriParameters = Get-AuvikUriParameter -BoundParameter $PSBoundParameters -NameMap $NameMap

        $InvokeParams = @{
            Method      = 'POST'
            ResourceUri = $ResourceUri
            UriFilter   = $UriParameters
        }

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false -WhatIf:$false
        Set-Variable -Name $QueryParameterName -Value $UriParameters -Scope Global -Force -Confirm:$false -WhatIf:$false

        if ($PSCmdlet.ShouldProcess($ResourceUri, "$($MyInvocation.MyCommand.Name) (POST)")) {
            return Invoke-AuvikRequest @InvokeParams
        }

    }

    end {}

}

Set-Alias -Name 'Clear-AuvikAlert' -Value 'Send-AuvikAlertDismiss'
