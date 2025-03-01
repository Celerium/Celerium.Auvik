function Remove-AuvikModuleSetting {
<#
    .SYNOPSIS
        Removes the stored Auvik configuration folder

    .DESCRIPTION
        The Remove-AuvikModuleSetting cmdlet removes the Auvik folder and its files
        This cmdlet also has the option to remove sensitive Auvik variables as well

        By default configuration files are stored in the following location and will be removed:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfPath
        Define the location of the Auvik configuration folder

        By default the configuration folder is located at:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER andVariables
        Define if sensitive Auvik variables should be removed as well

        By default the variables are not removed

    .EXAMPLE
        Remove-AuvikModuleSetting

        Checks to see if the default configuration folder exists and removes it if it does

        The default location of the Auvik configuration folder is:
            $env:USERPROFILE\Celerium.Auvik

    .EXAMPLE
        Remove-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -andVariables

        Checks to see if the defined configuration folder exists and removes it if it does
        If sensitive Auvik variables exist then they are removed as well

        The location of the Auvik configuration folder in this example is:
            C:\Celerium.Auvik

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Remove-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Destroy', SupportsShouldProcess)]
    Param (
        [Parameter(ParameterSetName = 'Destroy')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Destroy')]
        [switch]$andVariables
    )

    begin {}

    process {

        if (Test-Path $AuvikConfPath) {

            Remove-Item -Path $AuvikConfPath -Recurse -Force -WhatIf:$WhatIfPreference

            If ($andVariables) {
                Remove-AuvikAPIKey
                Remove-AuvikBaseURI
            }

            if (!(Test-Path $AuvikConfPath)) {
                Write-Output "The Celerium.Auvik configuration folder has been removed successfully from [ $AuvikConfPath ]"
            }
            else {
                Write-Error "The Celerium.Auvik configuration folder could not be removed from [ $AuvikConfPath ]"
            }

        }
        else {
            Write-Warning "No configuration folder found at [ $AuvikConfPath ]"
        }

    }

    end {}

}