#!/usr/bin/env pwsh
#
# install-init-project.ps1
#
# Porta para PowerShell (Windows) do install-init-project.sh: instala (ou
# atualiza) o comando /init-project a partir de uma pasta gerada por
# package-init-project.sh. Nunca sobrescreve um arquivo existente sem
# perguntar, arquivo por arquivo, com opção de ver o diff antes de decidir.
#
# Uso:
#   .\install-init-project.ps1 [caminho\para\pasta-do-pacote]
#
# Sem argumento, usa a pasta dist\init-project\ ao lado deste script (gerada
# por package-init-project.sh).
# Requer PowerShell 5.1+ (Windows) ou PowerShell 7+ (qualquer SO, usado aqui
# só para desenvolvimento/teste deste script — o alvo real é Windows).

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$PackageDir
)

$ErrorActionPreference = 'Stop'

$ClaudeHome = Join-Path $HOME '.claude'
$DefaultPackageDir = Join-Path $PSScriptRoot (Join-Path 'dist' 'init-project')

$UsedDefault = $false
if ([string]::IsNullOrWhiteSpace($PackageDir)) {
    $PackageDir = $DefaultPackageDir
    $UsedDefault = $true
}

# Mesma lista de FILES de install-init-project.sh — manter as duas em sincronia.
# Caminhos relativos sempre com "/": normalizados para o separador do SO ao
# construir caminhos reais, mas exibidos sempre da mesma forma nos dois scripts.
$Files = @(
    'CLAUDE.md',
    'commands/init-project.md',
    'templates/init-project/_scan.sh',
    'templates/init-project/_capacidades.md',
    'templates/init-project/_checklist-entrevista.md',
    'templates/init-project/_varredura-regras.md',
    'templates/init-project/API.md.tpl.md',
    'templates/init-project/Arquitetura.md.tpl.md',
    'templates/init-project/Auth.md.tpl.md',
    'templates/init-project/CLAUDE.md.tpl.md',
    'templates/init-project/Frontend.md.tpl.md',
    'templates/init-project/Harness.md.tpl.md',
    'templates/init-project/Infraestrutura.md.tpl.md',
    'templates/init-project/Memoria.md.tpl.md',
    'templates/init-project/Organograma.md.tpl.md',
    'templates/init-project/Progresso.md.tpl.md',
    'templates/init-project/RAG.md.tpl.md',
    'templates/init-project/RegrasNegocio.md.tpl.md'
)

function ConvertTo-NativePath {
    param([string]$RelativePath)
    return $RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
}

if (-not (Test-Path -LiteralPath $PackageDir -PathType Container)) {
    Write-Host "ERRO: pasta de pacote não encontrada: $PackageDir" -ForegroundColor Red
    Write-Host "Uso: $($MyInvocation.MyCommand.Name) [caminho\para\pasta-do-pacote]" -ForegroundColor Red
    Write-Host "Sem argumento, espera encontrar dist\init-project ao lado deste script: $DefaultPackageDir" -ForegroundColor Red
    Write-Host "Se essa pasta não existir, rode package-init-project.sh primeiro (ou informe outro caminho)." -ForegroundColor Red
    exit 1
}

if ($UsedDefault) {
    Write-Host "==> Nenhuma pasta informada. Usando: $PackageDir"
}

$missing = @()
foreach ($rel in $Files) {
    $src = Join-Path $PackageDir (ConvertTo-NativePath $rel)
    if (-not (Test-Path -LiteralPath $src -PathType Leaf)) {
        $missing += $rel
    }
}

if ($missing.Count -gt 0) {
    Write-Host "ERRO: a pasta não contém todos os $($Files.Count) arquivos esperados:" -ForegroundColor Red
    foreach ($m in $missing) { Write-Host "  - $m" -ForegroundColor Red }
    Write-Host "Abortando. Nada foi copiado para $ClaudeHome." -ForegroundColor Red
    exit 1
}

Write-Host "==> OK: os $($Files.Count) arquivos esperados estão presentes em $PackageDir."

New-Item -ItemType Directory -Force -Path $ClaudeHome | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeHome 'commands') | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path (Join-Path $ClaudeHome 'templates') 'init-project') | Out-Null

$installedNew = 0
$overwritten = 0
$skipped = 0

# Em PowerShell, sessão sem console interativo (ex.: agendador de tarefas,
# pipeline CI) tem a entrada padrão redirecionada — mesmo princípio do teste
# com /dev/tty no .sh.
$HasTty = -not [Console]::IsInputRedirected
if (-not $HasTty) {
    Write-Host 'AVISO: nenhum terminal interativo disponível (entrada padrão redirecionada). Arquivos existentes serão pulados por padrão (sem sobrescrever).' -ForegroundColor Yellow
}

function Show-Diff {
    param([string]$Dest, [string]$Src)
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host '----- diff: existente (esquerda) vs. novo (direita) -----'
        & git diff --no-index -- $Dest $Src
        Write-Host '-----------------------------------------------------------'
    }
    else {
        Write-Host '----- diff aproximado (git não disponível): existente (<) vs. novo (>) -----'
        $destLines = Get-Content -LiteralPath $Dest
        $srcLines = Get-Content -LiteralPath $Src
        Compare-Object -ReferenceObject $destLines -DifferenceObject $srcLines | ForEach-Object {
            $marker = if ($_.SideIndicator -eq '<=') { '<' } else { '>' }
            Write-Host "$marker $($_.InputObject)"
        }
        Write-Host '-----------------------------------------------------------'
    }
}

foreach ($rel in $Files) {
    $relNative = ConvertTo-NativePath $rel
    $src = Join-Path $PackageDir $relNative
    $dest = Join-Path $ClaudeHome $relNative
    $destDir = Split-Path $dest -Parent
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null

    if (-not (Test-Path -LiteralPath $dest)) {
        Copy-Item -LiteralPath $src -Destination $dest -Force
        $installedNew++
        Write-Host "  [novo]         $rel"
        continue
    }

    $srcHash = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash
    $destHash = (Get-FileHash -LiteralPath $dest -Algorithm SHA256).Hash
    $idemNote = if ($srcHash -eq $destHash) { ' (idêntico ao existente)' } else { '' }

    if (-not $HasTty) {
        $skipped++
        Write-Host "  [pulado, sem TTY]$idemNote $rel"
        continue
    }

    $done = $false
    while (-not $done) {
        $answer = Read-Host "  $rel$idemNote já existe. Sobrescrever? [s/N/d=ver diff]"
        if ($answer -match '^[Dd]') {
            Show-Diff -Dest $dest -Src $src
            continue
        }
        elseif ($answer -match '^[Ss]') {
            Copy-Item -LiteralPath $src -Destination $dest -Force
            $overwritten++
            Write-Host "  [sobrescrito]  $rel"
        }
        else {
            $skipped++
            Write-Host "  [mantido]      $rel"
        }
        $done = $true
    }
}

$scanSh = Join-Path (Join-Path (Join-Path $ClaudeHome 'templates') 'init-project') '_scan.sh'
if ((Test-Path -LiteralPath $scanSh) -and (Get-Command chmod -ErrorAction SilentlyContinue)) {
    & chmod 755 $scanSh
}

$total = $installedNew + $overwritten + $skipped

Write-Host ''
Write-Host '==> Resumo da instalação'
Write-Host "    Novos instalados : $installedNew"
Write-Host "    Sobrescritos     : $overwritten"
Write-Host "    Pulados/mantidos : $skipped"
Write-Host "    Total processado : $total / $($Files.Count)"
Write-Host ''
Write-Host "==> Destino: $ClaudeHome"

# --- Verificação de componentes usados pelo /init-project -------------------
# Puramente informativa: nenhuma checagem aqui altera o código de saída do
# script nem impede a conclusão da instalação (mesmo princípio do
# _scan.sh capacidades — "ausência degrada, nunca interrompe").

Write-Host ''
Write-Host '==> Verificação de componentes usados pelo /init-project'
Write-Host ''

Write-Host '-- Agentes, skills, plugins e marketplaces --'

function ConvertTo-WslPath {
    # C:\Users\nome\.claude -> /mnt/c/Users/nome/.claude — só vale para bash do WSL,
    # que não compartilha $HOME nem conversão automática de caminho com o Windows
    # (diferente do Git Bash/MSYS2, que já resolve $HOME certo sozinho).
    # Retorna $null para qualquer caminho que não seja unidade com letra (ex.: UNC
    # \\servidor\compartilhamento, de perfil de rede/roaming) — nesse caso o
    # chamador deve degradar com aviso, nunca montar um /mnt/... adivinhado.
    param([string]$WindowsPath)
    if ($WindowsPath -notmatch '^[A-Za-z]:\\') {
        return $null
    }
    $drive = $WindowsPath.Substring(0, 1).ToLower()
    $rest = $WindowsPath.Substring(2) -replace '\\', '/'
    return "/mnt/$drive$rest"
}

$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCmd -or -not (Test-Path -LiteralPath $scanSh)) {
    Write-Host 'AVISO: _scan.sh depende de bash (Git for Windows ou WSL). Sem bash no PATH, não foi possível checar agentes/skills/plugins — e o hook sessionStart também não vai rodar até o bash estar disponível.' -ForegroundColor Yellow
}
else {
    # Git Bash/MSYS2 resolve $HOME sozinho (ex.: /c/Users/nome) e entende os
    # caminhos que passamos como argumento — chama direto, sem variável extra.
    # O bash do WSL tem $HOME próprio do Linux; sem CLAUDE_CONFIG_DIR traduzido
    # para /mnt/<drive>/..., _scan.sh acabaria lendo o perfil errado em vez de
    # avisar — por isso aqui a conversão é explícita. Qualquer outro bash
    # (ex.: Cygwin) é tratado como caso ambíguo e degrada com aviso, em vez de
    # arriscar um relatório incorreto.
    $bashPath = $bashCmd.Source
    if ($bashPath -match '\\System32\\') {
        $claudeHomeWslRaw = ConvertTo-WslPath $ClaudeHome
        $scanShWslRaw = ConvertTo-WslPath $scanSh
        if ($null -eq $claudeHomeWslRaw -or $null -eq $scanShWslRaw) {
            Write-Host "AVISO: bash identificado como WSL, mas $ClaudeHome não é um caminho de unidade com letra (ex.: perfil de rede/UNC) — para evitar um relatório incorreto, a checagem de agentes/skills/plugins foi pulada." -ForegroundColor Yellow
        }
        else {
            # Escapa aspas simples antes de montar a string do -c: um perfil do
            # Windows com aspas simples no caminho (raro, mas válido) não deve
            # quebrar a citação do bash nem virar injeção de comando.
            $claudeHomeWsl = $claudeHomeWslRaw -replace "'", "'\\''"
            $scanShWsl = $scanShWslRaw -replace "'", "'\\''"
            & $bashCmd.Source -c "CLAUDE_CONFIG_DIR='$claudeHomeWsl' '$scanShWsl' capacidades"
        }
    }
    elseif ($bashPath -match '(?i)\\Git\\') {
        & $bashCmd.Source $scanSh capacidades
    }
    else {
        Write-Host "AVISO: bash encontrado em $bashPath não foi identificado como Git Bash nem WSL — para evitar um relatório incorreto, a checagem de agentes/skills/plugins foi pulada." -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host '-- RTK (Rust Token Killer) --'
$rtkCmd = Get-Command rtk -ErrorAction SilentlyContinue
if ($rtkCmd) {
    $rtkVersion = & rtk --version 2>$null
    if (-not $rtkVersion) { $rtkVersion = 'versão indisponível' }
    Write-Host "ok: rtk encontrado em $($rtkCmd.Source) ($rtkVersion)"
}
else {
    Write-Host "ausente: binário 'rtk' não encontrado no PATH."

    if ($HasTty) {
        $answer = Read-Host '  Deseja instalar rtk agora? [s/N]'
        if ($answer -match '^[Ss]') {
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Host '  Instalando rtk via winget...'
                & winget install rtk-ai.rtk
                if ($LASTEXITCODE -eq 0) {
                    Write-Host '  OK: rtk instalado com sucesso'
                }
                else {
                    Write-Host '  ERRO: falha ao instalar rtk via winget'
                }
            }
            else {
                Write-Host '  ERRO: winget não encontrado. Instale manualmente com: winget install rtk-ai.rtk'
            }
        }
    }
    else {
        Write-Host '  Sem terminal interativo. Para instalar, execute manualmente:'
        Write-Host '    winget install rtk-ai.rtk'
    }

    $rtkDoc = Join-Path $ClaudeHome 'RTK.md'
    if (Test-Path -LiteralPath $rtkDoc) {
        Write-Host "  Ver $rtkDoc para instruções de uso."
    }
}

Write-Host ''
Write-Host '-- Skill archify --'
$archifySkill = Join-Path (Join-Path (Join-Path $ClaudeHome 'skills') 'archify') 'SKILL.md'
if (Test-Path -LiteralPath $archifySkill) {
    Write-Host "ok: archify instalado em $(Split-Path $archifySkill -Parent)"
}
else {
    Write-Host "ausente: skill 'archify' não encontrada."

    if ($HasTty) {
        $answer = Read-Host '  Deseja instalar archify agora? [s/N]'
        if ($answer -match '^[Ss]') {
            if (Get-Command npx -ErrorAction SilentlyContinue) {
                Write-Host '  Instalando archify via npx...'
                & npx -y skills add tt-a1i/archify --skill archify --agent claude-code --global --copy --yes
                if (Test-Path -LiteralPath $archifySkill) {
                    Write-Host '  OK: archify instalado com sucesso'
                }
                else {
                    Write-Host '  ERRO: arquivo de skill não encontrado após instalação'
                }
            }
            else {
                Write-Host '  ERRO: npx não encontrado. Instale Node.js (>=18) para usar archify.'
            }
        }
    }
    else {
        Write-Host '  Sem terminal interativo. Para instalar, execute:'
        Write-Host '    npx -y skills add tt-a1i/archify --skill archify --agent claude-code --global --copy --yes'
    }
}

Write-Host ''
Write-Host '-- Hook RTK em settings.json --'
$settingsJson = Join-Path $ClaudeHome 'settings.json'
if (Test-Path -LiteralPath $settingsJson) {
    if (Select-String -LiteralPath $settingsJson -Pattern 'rtk hook claude' -Quiet) {
        Write-Host "ok: hook 'rtk hook claude' encontrado em settings.json"
    }
    else {
        Write-Host 'ausente: nenhum hook RTK encontrado em settings.json'
    }
}
else {
    Write-Host "indisponivel: $settingsJson não encontrado — hook RTK não verificado."
}

# --- Verificação de atualização (GitHub Release) -----------------------------
# Puramente informativa, best-effort: sem rede ou sem release publicada,
# apenas avisa e segue — nunca altera o código de saída.

function Test-VersionGreaterThan {
    param([string]$A, [string]$B)
    $aClean = ($A.TrimStart('v') -split '[-+]')[0]
    $bClean = ($B.TrimStart('v') -split '[-+]')[0]
    # Campo sem dígito (tag_name mal formado) vira 0 em vez de lançar exceção —
    # isto é só uma checagem informativa, nunca pode interromper o script.
    $aParts = $aClean -split '\.' | ForEach-Object { $d = $_ -replace '[^0-9]', ''; if ($d) { [int]$d } else { 0 } }
    $bParts = $bClean -split '\.' | ForEach-Object { $d = $_ -replace '[^0-9]', ''; if ($d) { [int]$d } else { 0 } }
    for ($i = 0; $i -lt 3; $i++) {
        $av = if ($i -lt $aParts.Count) { $aParts[$i] } else { 0 }
        $bv = if ($i -lt $bParts.Count) { $bParts[$i] } else { 0 }
        if ($av -ne $bv) { return $av -gt $bv }
    }
    return $false
}

Write-Host ''
Write-Host '-- Verificação de atualização --'

$repoSlug = 'c3t4r4/Personal-MD-for-Claude'
$versionFile = Join-Path $PackageDir 'VERSION'

if (-not (Test-Path -LiteralPath $versionFile)) {
    Write-Host 'indisponivel: este pacote não traz um arquivo VERSION (gerado antes desta checagem existir) — não foi possível comparar.'
}
else {
    $localVersion = (Get-Content -LiteralPath $versionFile -Raw).Trim()
    try {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$repoSlug/releases/latest" -TimeoutSec 5 -ErrorAction Stop
        $remoteVersion = $release.tag_name
    }
    catch {
        $remoteVersion = $null
    }

    if ([string]::IsNullOrWhiteSpace($remoteVersion)) {
        Write-Host "indisponivel: não foi possível obter a última release de $repoSlug (sem rede, ou nenhuma release publicada ainda)."
    }
    elseif (Test-VersionGreaterThan -A $remoteVersion -B $localVersion) {
        Write-Host "atualizacao disponivel: v$localVersion -> $remoteVersion — https://github.com/$repoSlug/releases/latest"
    }
    else {
        Write-Host "ok: pacote atualizado (v$localVersion, última release: $remoteVersion)"
    }
}
