function Import-AuvikModuleSetting {
<#
    .SYNOPSIS
        Imports the Auvik BaseURI, API, & JSON configuration information to the current session

    .DESCRIPTION
        The Import-AuvikModuleSetting cmdlet imports the Auvik BaseURI, API, & JSON configuration
        information stored in the Auvik configuration file to the users current session

        By default the configuration file is stored in the following location:
            Windows: $env:USERPROFILE\Celerium.Auvik
            Linux & macOS: $HOME/.Celerium.Auvik

        The following environment variables take priority over the configuration file which allows
        automation such as GitHub workflows to configure the module without a configuration file:
            AUVIK_BASE_URI  - The base URI of the API, such as https://auvikapi.us1.my.auvik.com/v1
            AUVIK_USERNAME  - The API username
            AUVIK_API_KEY   - The API key

    .PARAMETER AuvikConfigPath
        Define the location to store the Auvik configuration file

        By default the configuration file is stored in the following location:
            Windows: $env:USERPROFILE\Celerium.Auvik
            Linux & macOS: $HOME/.Celerium.Auvik

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
    param (
        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigPath = $(Join-Path -Path $HOME -ChildPath $(if ($IsWindows -or $PSEdition -eq 'Desktop') { 'Celerium.Auvik' } else { '.Celerium.Auvik' }) ),

        [Parameter(ParameterSetName = 'Set')]
        [string]$AuvikConfigFile = 'config.psd1'
    )

    begin {
        $AuvikConfig = Join-Path -Path $AuvikConfigPath -ChildPath $AuvikConfigFile
    }

    process {

        $ConfigLoaded = $false

        if ( Test-Path -Path $AuvikConfig ) {

            try {

                $TempConfig = Import-LocalizedData -BaseDirectory $AuvikConfigPath -FileName $AuvikConfigFile

                # Send to function to strip potentially superfluous slash (/)
                Add-AuvikBaseURI -BaseUri $TempConfig.AuvikModuleBaseURI

                $SecureKey = ConvertTo-SecureString -String $TempConfig.AuvikModuleApiKey

                Set-Variable -Name 'AuvikModuleUserName' -Value $TempConfig.AuvikModuleUserName -Option ReadOnly -Scope Global -Force
                Set-Variable -Name 'AuvikModuleApiKey' -Value $SecureKey -Option ReadOnly -Scope Global -Force
                Set-Variable -Name 'AuvikJSONConversionDepth' -Value ([int]$TempConfig.AuvikJSONConversionDepth) -Scope Global -Force

                Write-Verbose "Celerium.Auvik Module configuration loaded successfully from [ $AuvikConfig ]"
                $ConfigLoaded = $true

            }
            catch {
                Write-Warning "The Celerium.Auvik configuration file [ $AuvikConfig ] could not be loaded. $($_.Exception.Message)"
            }
            finally { Remove-Variable -Name 'TempConfig' -ErrorAction SilentlyContinue }

        }

        if (-not $ConfigLoaded) {

            Write-Verbose "No configuration file found at [ $AuvikConfig ] run Add-AuvikApiKey to get started."

            Add-AuvikBaseURI
            Set-Variable -Name 'AuvikJSONConversionDepth' -Value 100 -Scope Global -Force

        }

        # Environment variables take priority over the configuration file
        if ($env:AUVIK_BASE_URI) { Add-AuvikBaseURI -BaseUri $env:AUVIK_BASE_URI }

        if ($env:AUVIK_USERNAME -and $env:AUVIK_API_KEY) {
            Add-AuvikAPIKey -Username $env:AUVIK_USERNAME -ApiKey $env:AUVIK_API_KEY
            Write-Verbose 'Celerium.Auvik Module API credentials loaded from the AUVIK_USERNAME & AUVIK_API_KEY environment variables'
        }

    }

    end {}

}
