function Import-AuvikModuleSetting {
<#
    .SYNOPSIS
        Imports the Auvik BaseURI, API, & JSON configuration information to the current session

    .DESCRIPTION
        The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
        information stored in the Auvik configuration file to the users current session

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            $env:USERPROFILE\Celerium.Auvik

    .PARAMETER AuvikConfigFile
        Define the name of the Auvik configuration file

        By default the configuration file is named:
            config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session

        The default location of the Auvik configuration file is:
            $env:USERPROFILE\Celerium.Auvik\config.psd1

    .EXAMPLE
        Import-AuvikModuleSetting -AuvikConfigPath C:\Celerium.Auvik -AuvikConfigFile MyConfig.psd1

        Validates that the configuration file created with the Export-AuvikModuleSetting cmdlet exists
        then imports the stored data into the current users session

        The location of the Auvik configuration file in this example is:
            C:\Celerium.Auvik\MyConfig.psd1

    .NOTES
        N\A

    .LINK
        https://celerium.github.io/Celerium.Auvik/site/Internal/Import-AuvikModuleSetting.html
#>

    [CmdletBinding(DefaultParameterSetName = 'Set')]
    Param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigPath = $(Join-Path -Path $home -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') {"Celerium.Auvik"}else{".Celerium.Auvik"}) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigFile = 'config.psd1'
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile
    }

    process {

        if ( Test-Path $AuvikConfig ) {
            $TempConfig = Import-LocalizedData -BaseDirectory $AuvikConfigPath -FileName $AuvikConfigFile

            # Send to function to strip potentially superfluous slash (/)
            Add-AuvikBaseURI $TempConfig.AuvikModuleBaseURI

            $TempConfig.AuvikModuleApiKey = ConvertTo-SecureString $TempConfig.AuvikModuleApiKey

            Set-Variable -Name "AuvikModuleUserName" -Value $TempConfig.AuvikModuleUserName -Option ReadOnly -Scope global -Force

            Set-Variable -Name "AuvikModuleApiKey" -Value $TempConfig.AuvikModuleApiKey -Option ReadOnly -Scope global -Force

            Set-Variable -Name "AuvikJSONConversionDepth" -Value $TempConfig.AuvikJSONConversionDepth -Scope global -Force

            Write-Verbose "Celerium.Auvik Module configuration loaded successfully from [ $AuvikConfig ]"

            # Clean things up
            Remove-Variable "TempConfig"
        }
        else {
            Write-Verbose "No configuration file found at [ $AuvikConfig ] run Add-AuvikApiKey to get started."

            Add-AuvikBaseURI

            Set-Variable -Name "AuvikModuleBaseURI" -Value $(Get-AuvikBaseURI) -Option ReadOnly -Scope global -Force
            Set-Variable -Name "AuvikJSONConversionDepth" -Value 100 -Scope global -Force
        }

    }

    end {}

}