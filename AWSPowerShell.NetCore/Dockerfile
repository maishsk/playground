FROM microsoft/powershell:latest

LABEL maintainer='Maish Saidel-Keesing <maishsk@gmail.com>'' \
      description='This Dockerfile will install the latest release of AWS Powershell'

## Install the AWS Powershell module
RUN pwsh -c \
    Install-Package -Name AWSPowerShell.NetCore -Source \
    https://www.powershellgallery.com/api/v2/ -ProviderName \
    NuGet -ExcludeVersion -Force -Destination \
    ~/.local/share/powershell/Modules
