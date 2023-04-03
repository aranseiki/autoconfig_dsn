
# PARA GARANTIR A LEITURA DE ACENTUAÇÕES E CODIGOS ESPECIAIS | 1252 ANSI (CP 1252) | 65001 UTF8
chcp 65001

Write-Host `n "Iniciando captura de dados do arquivo ConfigPowerShell.ini para validar ou criar conexão DSN" `n

# $MyInvocation.MyCommand.Path é para referenciar aonde o arquivo está salvo
$ArquivoScript = $MyInvocation.MyCommand.Path
$DiretorioRaiz = Split-Path -Parent $ArquivoScript

$DiretorioConfiguracao = $DiretorioRaiz + '\ConfigDsn.ini'

$ConteudoArquivoConfiguracao = Get-Content $DiretorioConfiguracao

# Coletando [Collections.ArrayList] do C# para realizar a criação de uma lista
[Collections.ArrayList] $ListaParametrosIni = @()
foreach($Linha in $ConteudoArquivoConfiguracao){
    $TextoConvertido = ConvertFrom-StringData -StringData $Linha
    $ListaParametrosIni.Add($TextoConvertido) | Out-Null
}

$ValidarDSN = Get-OdbcDsn * | Where {$_.name -eq $ListaParametrosIni.DsnName} | Select Name
$CriarDsn = [String]::IsNullOrEmpty($ValidarDSN)

if($CriarDsn -eq $true){
    Write-Host `n " Iniciando a criação da conexão via DSN" `n

    $DsnAuthMech = "AuthMech=" + $ListaParametrosIni.DsnAuthMech
    $DsnHost = "Host=" + $ListaParametrosIni.DsnHost
    $DsnPort = "Port=" + $ListaParametrosIni.DsnPort
    $DsnDatabase = "Database=" + $ListaParametrosIni.DsnDatabase
    $DsnThriftTransport = "ThriftTransport=" + $ListaParametrosIni.DsnThriftTransport
    $DsnSSL = "SSL=" + $ListaParametrosIni.DsnSSL
    $DsnDescription = "DESCRIPTION=" + $ListaParametrosIni.DsnDescription

    Add-OdbcDsn -Name $ListaParametrosIni.DsnName `
        -DriverName $ListaParametrosIni.DsnDriverName `
        -DsnType $ListaParametrosIni.DsnType `
        -Platform $ListaParametrosIni.DsnPlatform `
        -SetPropertyValue @(
            $DsnAuthMech, 
            $DsnHost, 
            $DsnPort, 
            $DsnDatabase, 
            $DsnThriftTransport, 
            $DsnSSL, 
            $DsnDescription
        )
}
