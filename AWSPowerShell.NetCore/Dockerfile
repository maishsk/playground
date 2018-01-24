FROM microsoft/powershell:latest

MAINTAINER Maish Saidel-Keesing (maishsk@gmail.com)

## Install the AWS Powershell module
RUN pwsh -c \
    Install-Package -Name AWSPowerShell.NetCore -Source \
    https://www.powershellgallery.com/api/v2/ -ProviderName \
    NuGet -ExcludeVersion -Force -Destination \
    ~/.local/share/powershell/Modules
