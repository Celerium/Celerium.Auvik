function Get-AuvikModuleSetting {
<#
    .SYNOPSIS
        Gets the saved Auvik configuration settings

    .DESCRIPTION
        The Get-AuvikModuleSetting cmdlet gets the saved Auvik configuration settings
        from the local system

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .PARAMETER openConfFile
        Opens the Auvik configuration file

    .EXAMPLE
        Get-AuvikModuleSetting

        Gets the contents of the configuration file that was created with the
        Export-AuvikModuleSetting

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Get-AuvikModuleSetting -AuvikConfPath C:\Celerium.Auvik -AuvikConfFile MyConfig.psd1 -openConfFile

        Opens the configuration file from the defined location in the default editor

        The location of the Auvik configuration file in this example is:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Get-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Index')]
    Param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Index')]
        [string]$AuvikConfPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(Mandatory = $false, ParameterSetName = 'Index')]
        [String]$AuvikConfFile = 'config.psd1',

        [Parameter(Mandatory = $false, ParameterSetName = 'show')]
        [Switch]$openConfFile
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfPath -ChildPath $AuvikConfFile
    }

    process {

        if ( Test-Path -Path $AuvikConfig ) {

            if($openConfFile) {
                Invoke-Item -Path $AuvikConfig
            }
            else{
                Import-LocalizedData -BaseDirectory $AuvikConfPath -FileName $AuvikConfFile
            }

        }
        else{
            Write-Verbose "No configuration file found at [ $AuvikConfig ]"
        }

    }

    end {}

}