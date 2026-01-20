# Script para obtener la IP local de la PC para configurar MQTT
Write-Host "=== Configuracion MQTT ESP32 ===" -ForegroundColor Cyan
Write-Host ""

# Obtener la IP de la interfaz de red activa (excluye loopback, VMs y Docker)
$ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.IPAddress -notlike "127.*" -and 
    $_.IPAddress -notlike "169.254.*" -and
    $_.InterfaceAlias -notlike "*Loopback*" -and 
    $_.InterfaceAlias -notlike "*VirtualBox*" -and 
    $_.InterfaceAlias -notlike "*VMware*" -and 
    $_.InterfaceAlias -notlike "*WSL*" -and 
    $_.InterfaceAlias -notlike "*vEthernet*" 
} | Sort-Object -Property @{Expression={if ($_.IPAddress -like "192.168.*") {0} elseif ($_.IPAddress -like "10.*") {1} else {2}}} | Select-Object -First 1

if ($ip) {
    $ipAddress = $ip.IPAddress
    Write-Host "Tu IP local es: " -NoNewline
    Write-Host $ipAddress -ForegroundColor Green
    Write-Host ""
    
    # Actualizar automaticamente el archivo secrets.yaml
    $secretsPath = ".\esphome\secrets.yaml"
    if (Test-Path $secretsPath) {
        $content = Get-Content $secretsPath -Raw
        $content = $content -replace "mqtt_broker_ip:.*", "mqtt_broker_ip: $ipAddress"
        Set-Content $secretsPath $content
        
        Write-Host "OK Archivo actualizado:" -ForegroundColor Green
        Write-Host "  - esphome\secrets.yaml" -ForegroundColor Gray
        Write-Host "  - mqtt_broker_ip: $ipAddress" -ForegroundColor Gray
    } else {
        Write-Host "! No se encontro el archivo secrets.yaml" -ForegroundColor Yellow
        Write-Host "  Configura manualmente esta IP:" -ForegroundColor Yellow
        Write-Host "  - Variable: mqtt_broker_ip" -ForegroundColor Gray
    }
    
    Write-Host ""
    # Copiar al portapapeles
    $ipAddress | Set-Clipboard
    Write-Host "OK IP copiada al portapapeles" -ForegroundColor Green
} else {
    Write-Host "X No se pudo detectar la IP de red" -ForegroundColor Red
    Write-Host "  Verifica tu conexion de red" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para salir"
