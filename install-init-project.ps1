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
# Sem argumento, usa $HOME\.claude\initProjectsInstall\dist\init-project\.
# Requer PowerShell 5.1+ (Windows) ou PowerShell 7+ (qualquer SO, usado aqui
# só para desenvolvimento/teste deste script — o alvo real é Windows).

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$PackageDir
)

$ErrorActionPreference = 'Stop'

$ClaudeHome = Join-Path $HOME '.claude'
$DistDir = Join-Path (Join-Path $ClaudeHome 'initProjectsInstall') 'dist'
$DefaultPackageDir = Join-Path $DistDir 'init-project'

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

if ($UsedDefault -and -not (Test-Path -LiteralPath $PackageDir)) {
    New-Item -ItemType Directory -Force -Path $PackageDir | Out-Null
    Write-Host "==> Criada pasta padrão de pacote: $PackageDir"
}

if (-not (Test-Path -LiteralPath $PackageDir -PathType Container)) {
    Write-Host "ERRO: pasta de pacote não encontrada: $PackageDir" -ForegroundColor Red
    Write-Host "Uso: $($MyInvocation.MyCommand.Name) [caminho\para\pasta-do-pacote]" -ForegroundColor Red
    Write-Host "Sem argumento, espera encontrar: $DefaultPackageDir" -ForegroundColor Red
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
$bashCmd = Get-Command bash -ErrorAction SilentlyContinue
if ($bashCmd -and (Test-Path -LiteralPath $scanSh)) {
    & $bashCmd.Source $scanSh capacidades
}
else {
    Write-Host 'AVISO: _scan.sh depende de bash (Git for Windows ou WSL). Sem bash no PATH, não foi possível checar agentes/skills/plugins — e o hook sessionStart também não vai rodar até o bash estar disponível.' -ForegroundColor Yellow
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
