function Clear-AuvikAlert {
<#
    .SYNOPSIS
        Clear an Auvik alert

    .DESCRIPTION
        The Clear-AuvikAlert cmdlet allows you to dismiss an
        alert that Auvik has triggered

    .PARAMETER ID
        ID of alert

    .EXAMPLE
        Clear-AuvikAlert -ID 123456789

        Clears the defined alert

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Alert/Clear-AuvikAlert.html
#>

    [CmdletBinding(DefaultParameterSetName = 'ClearByAlert', SupportsShouldProcess, ConfirmImpact = 'Low')]
    Param (
        [Parameter( Mandatory = $true, ValueFromPipeline = $true )]
        [ValidateNotNullOrEmpty()]
        [string]$ID
    )

    begin {

        $FunctionName       = $MyInvocation.InvocationName
        $ParameterName      = $functionName + '_Parameters'      -replace '-','_'

    }

    process {

        Write-Verbose "[ $($MyInvocation.MyCommand.Name) ] - Running the [ $($PSCmdlet.ParameterSetName) ] ParameterSet"

        $ResourceUri = "/alert/dismiss/$ID"

        Set-Variable -Name $ParameterName -Value $PSBoundParameters -Scope Global -Force -Confirm:$false

        return Invoke-AuvikRequest -Method POST -ResourceUri $ResourceUri

    }

    end {}

}
