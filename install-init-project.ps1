#Requires -Version 5.1
<#
.SYNOPSIS
  Instala (ou atualiza) o comando /init-project no Windows 11.

.DESCRIPTION
  Equivalente Windows de install-init-project.sh. Copia os 18 arquivos do
  pacote para %USERPROFILE%\.claude. Nunca sobrescreve um arquivo existente
  sem perguntar, arquivo por arquivo, com opção de ver o diff antes de decidir.

  A verificação final de componentes (scan, RTK, archify, hook) é informativa:
  não altera o código de saída e não impede a conclusão da cópia.

.PARAMETER PackageDir
  Caminho da pasta do pacote. Sem argumento, usa
  %USERPROFILE%\.claude\initProjectsInstall\dist\init-project.
  Se essa pasta padrão não existir, ela é criada e a instalação aborta
  até que os 18 arquivos estejam lá — nada do pacote é copiado nesse caso.

.EXAMPLE
  powershell -NoProfile -ExecutionPolicy Bypass -File .\install-init-project.ps1

.EXAMPLE
  .\install-init-project.cmd D:\pacotes\init-project

.NOTES
  Pode ser chamado por install-init-project.cmd, que aplica ExecutionPolicy
  Bypass só neste processo.
#>
[CmdletBinding()]
param(
  [Parameter(Position = 0)]
  [string]$PackageDir
)

$ErrorActionPreference = 'Continue'

try {
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [Console]::OutputEncoding = $utf8
  [Console]::InputEncoding = $utf8
  $OutputEncoding = $utf8
  if ($env:OS -eq 'Windows_NT') {
    & cmd.exe /c "chcp 65001 > nul"
  }
} catch {
  # Console pode nao existir em host sem TTY; a copia segue mesmo assim.
}

$ClaudeHome = if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) { $env:HOME } else { $env:USERPROFILE }
$ClaudeHome = [System.IO.Path]::Combine($ClaudeHome, '.claude')
$DefaultPackageDir = [System.IO.Path]::Combine($ClaudeHome, 'initProjectsInstall', 'dist', 'init-project')

$Files = @(
  'CLAUDE.md'
  'commands/init-project.md'
  'templates/init-project/_scan.sh'
  'templates/init-project/_capacidades.md'
  'templates/init-project/_checklist-entrevista.md'
  'templates/init-project/_varredura-regras.md'
  'templates/init-project/API.md.tpl.md'
  'templates/init-project/Arquitetura.md.tpl.md'
  'templates/init-project/Auth.md.tpl.md'
  'templates/init-project/CLAUDE.md.tpl.md'
  'templates/init-project/Frontend.md.tpl.md'
  'templates/init-project/Harness.md.tpl.md'
  'templates/init-project/Infraestrutura.md.tpl.md'
  'templates/init-project/Memoria.md.tpl.md'
  'templates/init-project/Organograma.md.tpl.md'
  'templates/init-project/Progresso.md.tpl.md'
  'templates/init-project/RAG.md.tpl.md'
  'templates/init-project/RegrasNegocio.md.tpl.md'
)

function Join-RelPath {
  param(
    [Parameter(Mandatory = $true)][string]$Root,
    [Parameter(Mandatory = $true)][string]$Relative
  )
  $path = $Root
  foreach ($part in ($Relative -split '[\\/]' )) {
    if (-not [string]::IsNullOrWhiteSpace($part)) {
      $path = [System.IO.Path]::Combine($path, $part)
    }
  }
  return $path
}

function Write-ErrLine {
  param([Parameter(Mandatory = $true)][string]$Message)
  [Console]::Error.WriteLine($Message)
}

function Test-FileBytesEqual {
  param(
    [Parameter(Mandatory = $true)][string]$Left,
    [Parameter(Mandatory = $true)][string]$Right
  )
  $leftHash = (Get-FileHash -LiteralPath $Left -Algorithm SHA256).Hash
  $rightHash = (Get-FileHash -LiteralPath $Right -Algorithm SHA256).Hash
  return ($leftHash -eq $rightHash)
}

function Copy-PackageFile {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination
  )
  $destParent = Split-Path -Parent $Destination
  if (-not (Test-Path -LiteralPath $destParent)) {
    New-Item -ItemType Directory -Path $destParent -Force | Out-Null
  }
  [System.IO.File]::Copy($Source, $Destination, $true)
  $srcItem = Get-Item -LiteralPath $Source
  $dstItem = Get-Item -LiteralPath $Destination
  $dstItem.LastWriteTimeUtc = $srcItem.LastWriteTimeUtc
  if (Get-Command Unblock-File -ErrorAction SilentlyContinue) {
    Unblock-File -LiteralPath $Destination -ErrorAction SilentlyContinue
  }
}

function Show-FileDiff {
  param(
    [Parameter(Mandatory = $true)][string]$Existing,
    [Parameter(Mandatory = $true)][string]$New
  )
  Write-Host '----- diff: existente (esquerda) vs. novo (direita) -----'
  $git = Get-Command git -ErrorAction SilentlyContinue
  $showed = $false
  if ($git) {
    & $git.Source --no-pager diff --no-index --unified -- $Existing $New
    if ($LASTEXITCODE -le 1) {
      $showed = $true
    } else {
      Write-Host "(git diff falhou com código $LASTEXITCODE; tentando fc.exe)"
    }
  }
  if (-not $showed) {
    $fc = Join-Path $env:SystemRoot 'System32\fc.exe'
    if (Test-Path -LiteralPath $fc) {
      & $fc /N $Existing $New
    } else {
      Write-Host 'AVISO: nem git nem fc.exe disponíveis para mostrar o diff.'
    }
  }
  Write-Host '-----------------------------------------------------------'
}

function Convert-ToBashPath {
  param(
    [Parameter(Mandatory = $true)][string]$WindowsPath,
    [Parameter(Mandatory = $true)][ValidateSet('git', 'wsl')][string]$Kind
  )
  $full = [System.IO.Path]::GetFullPath($WindowsPath)
  if ($full -match '^([A-Za-z]):\\(.*)$') {
    $drive = $Matches[1].ToLowerInvariant()
    $rest = ($Matches[2] -replace '\\', '/')
    if ($Kind -eq 'wsl') {
      return "/mnt/$drive/$rest"
    }
    return "/$drive/$rest"
  }
  return ($full -replace '\\', '/')
}

function Find-BashHost {
  $candidates = New-Object System.Collections.Generic.List[string]
  $roots = New-Object System.Collections.Generic.List[string]
  foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
    if (-not [string]::IsNullOrWhiteSpace($root)) {
      [void]$roots.Add($root)
    }
  }
  if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    [void]$roots.Add((Join-Path $env:LOCALAPPDATA 'Programs'))
  }
  foreach ($root in $roots) {
    [void]$candidates.Add((Join-Path $root 'Git\bin\bash.exe'))
  }
  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return @{ Exe = $candidate; Kind = 'git' }
    }
  }

  $bash = Get-Command bash.exe -ErrorAction SilentlyContinue
  if ($bash -and ($bash.Source -notmatch '\\(System32|Sysnative)\\bash\.exe$')) {
    return @{ Exe = $bash.Source; Kind = 'git' }
  }

  $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
  if ($wsl) {
    return @{ Exe = $wsl.Source; Kind = 'wsl' }
  }
  if ($bash) {
    return @{ Exe = $bash.Source; Kind = 'wsl' }
  }
  return $null
}

function Update-SessionPath {
  $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
  $user = [Environment]::GetEnvironmentVariable('Path', 'User')
  $parts = @($machine, $user) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  if ($parts) {
    $env:Path = $parts -join ';'
  }
}

function Invoke-Npx {
  param([Parameter(Mandatory = $true)][string[]]$NpxArgs)
  $script:NpxExit = 127
  $npxCmd = Get-Command npx.cmd -ErrorAction SilentlyContinue
  if (-not $npxCmd) {
    $npxCmd = Get-Command npx -ErrorAction SilentlyContinue
  }
  if (-not $npxCmd) {
    return
  }
  if ($npxCmd.Source -like '*.cmd' -or $npxCmd.Source -like '*.bat') {
    $argLine = ($NpxArgs | ForEach-Object { $_ }) -join ' '
    & cmd.exe /c "`"$($npxCmd.Source)`" $argLine"
  } else {
    & $npxCmd.Source @NpxArgs
  }
  $script:NpxExit = [int]$LASTEXITCODE
}

$usedDefault = $false
if ([string]::IsNullOrWhiteSpace($PackageDir)) {
  $PackageDir = $DefaultPackageDir
  $usedDefault = $true
}

try {
  $PackageDir = [System.IO.Path]::GetFullPath($PackageDir)
} catch {
  Write-ErrLine "ERRO: caminho de pacote inválido: $PackageDir"
  Write-ErrLine "Uso: $($MyInvocation.MyCommand.Name) [caminho\para\pasta-do-pacote]"
  exit 1
}

if ($usedDefault) {
  Write-Host "==> Nenhuma pasta informada. Usando: $PackageDir"
  if (-not (Test-Path -LiteralPath $PackageDir)) {
    New-Item -ItemType Directory -Path $PackageDir -Force | Out-Null
    Write-Host "==> Criada pasta padrão de pacote: $PackageDir"
  }
}

if (-not (Test-Path -LiteralPath $PackageDir -PathType Container)) {
  Write-ErrLine "ERRO: pasta de pacote não encontrada: $PackageDir"
  Write-ErrLine "Uso: $($MyInvocation.MyCommand.Name) [caminho\para\pasta-do-pacote]"
  Write-ErrLine "Sem argumento, espera encontrar: $DefaultPackageDir"
  exit 1
}

$missing = New-Object System.Collections.Generic.List[string]
foreach ($rel in $Files) {
  $src = Join-RelPath -Root $PackageDir -Relative $rel
  if (-not (Test-Path -LiteralPath $src -PathType Leaf)) {
    [void]$missing.Add($rel)
  }
}

if ($missing.Count -gt 0) {
  Write-ErrLine "ERRO: a pasta não contém todos os $($Files.Count) arquivos esperados:"
  foreach ($item in $missing) {
    Write-ErrLine "  - $item"
  }
  Write-ErrLine "Abortando. Nada foi copiado para $ClaudeHome."
  exit 1
}

Write-Host "==> OK: os $($Files.Count) arquivos esperados estão presentes em ${PackageDir}."

foreach ($dir in @(
    $ClaudeHome
    ([System.IO.Path]::Combine($ClaudeHome, 'commands'))
    ([System.IO.Path]::Combine($ClaudeHome, 'templates', 'init-project'))
  )) {
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
}

$installedNew = 0
$overwritten = 0
$skipped = 0

$HasTty = $false
try {
  if ([Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    $HasTty = $true
  }
} catch {
  $HasTty = $false
}

if (-not $HasTty) {
  Write-ErrLine 'AVISO: nenhum terminal interativo disponível. Arquivos existentes serão pulados por padrão (sem sobrescrever).'
}

foreach ($rel in $Files) {
  $src = Join-RelPath -Root $PackageDir -Relative $rel
  $dest = Join-RelPath -Root $ClaudeHome -Relative $rel

  $srcFull = [System.IO.Path]::GetFullPath($src)
  $destFull = [System.IO.Path]::GetFullPath($dest)
  if ([string]::Equals($srcFull, $destFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    $skipped++
    Write-Host "  [já no destino] $rel"
    continue
  }

  if ((Test-Path -LiteralPath $dest) -and -not (Test-Path -LiteralPath $dest -PathType Leaf)) {
    $skipped++
    Write-ErrLine "  [pulado, destino é pasta] $rel"
    continue
  }

  if (-not (Test-Path -LiteralPath $dest)) {
    Copy-PackageFile -Source $src -Destination $dest
    $installedNew++
    Write-Host "  [novo]         $rel"
    continue
  }

  $idemNote = ''
  if (Test-FileBytesEqual -Left $src -Right $dest) {
    $idemNote = ' (idêntico ao existente)'
  }

  if (-not $HasTty) {
    $skipped++
    Write-Host "  [pulado, sem TTY]$idemNote $rel"
    continue
  }

  while ($true) {
    $answer = $null
    try {
      $answer = Read-Host -Prompt "  $rel$idemNote já existe. Sobrescrever? [s/N/d=ver diff]"
    } catch {
      $skipped++
      Write-Host "  [pulado, leitura falhou] $rel"
      break
    }
    if ($null -eq $answer) {
      $skipped++
      Write-Host "  [pulado, leitura falhou] $rel"
      break
    }
    if ($answer -match '^[Dd]') {
      Show-FileDiff -Existing $dest -New $src
      continue
    }
    if ($answer -match '^[Ss]') {
      Copy-PackageFile -Source $src -Destination $dest
      $overwritten++
      Write-Host "  [sobrescrito]  $rel"
      break
    }
    $skipped++
    Write-Host "  [mantido]      $rel"
    break
  }
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

Write-Host ''
Write-Host '==> Verificação de componentes usados pelo /init-project'
Write-Host ''

$ScanSh = [System.IO.Path]::Combine($ClaudeHome, 'templates', 'init-project', '_scan.sh')

Write-Host '-- Agentes, skills, plugins e marketplaces --'
if (Test-Path -LiteralPath $ScanSh -PathType Leaf) {
  $bashHost = Find-BashHost
  if ($null -eq $bashHost) {
    Write-ErrLine "AVISO: $ScanSh está instalado, mas não há Git Bash nem WSL para executá-lo."
    Write-ErrLine '  Instale Git for Windows e rode: bash templates\init-project\_scan.sh capacidades'
  } else {
    $bashKind = [string]$bashHost.Kind
    $savedConfig = $env:CLAUDE_CONFIG_DIR
    $env:CLAUDE_CONFIG_DIR = Convert-ToBashPath -WindowsPath $ClaudeHome -Kind $bashKind
    $scanArg = Convert-ToBashPath -WindowsPath $ScanSh -Kind $bashKind
    try {
      if ($bashKind -eq 'wsl') {
        & $bashHost.Exe -e env "CLAUDE_CONFIG_DIR=$($env:CLAUDE_CONFIG_DIR)" bash -- $scanArg capacidades
      } else {
        & $bashHost.Exe -- $scanArg capacidades
      }
    } finally {
      if ($null -eq $savedConfig) {
        Remove-Item Env:\CLAUDE_CONFIG_DIR -ErrorAction SilentlyContinue
      } else {
        $env:CLAUDE_CONFIG_DIR = $savedConfig
      }
    }
  }
} else {
  Write-ErrLine "AVISO: $ScanSh não encontrado — não foi possível checar agentes/skills/plugins."
}

Write-Host ''
Write-Host '-- RTK (Rust Token Killer) --'
$rtk = Get-Command rtk -ErrorAction SilentlyContinue
if ($rtk) {
  $rtkVersion = 'versão indisponível'
  try {
    $rawVersion = & $rtk.Source --version 2>&1 | Out-String
    if (-not [string]::IsNullOrWhiteSpace($rawVersion)) {
      $rtkVersion = $rawVersion.Trim()
    }
  } catch {
    $rtkVersion = 'versão indisponível'
  }
  Write-Host "ok: rtk encontrado em $($rtk.Source) ($rtkVersion)"
} else {
  Write-Host "ausente: binário 'rtk' não encontrado no PATH."
  if ($HasTty) {
    $answer = $null
    try {
      $answer = Read-Host -Prompt '  Deseja instalar rtk agora? [s/N]'
    } catch {
      $answer = $null
    }
    if ($answer -match '^[Ss]') {
      $winget = Get-Command winget.exe -ErrorAction SilentlyContinue
      if (-not $winget) {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
      }
      if ($winget) {
        Write-Host '  Instalando rtk via winget...'
        & $winget.Source install --id rtk-ai.rtk --exact --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
          Update-SessionPath
          Write-Host '  ✓ rtk instalado com sucesso'
          Write-Host '  Abra um terminal novo se o comando rtk ainda não for encontrado.'
        } else {
          Write-Host '  ✗ Falha ao instalar rtk via winget'
        }
      } else {
        Write-Host '  ✗ winget não encontrado. Instale manualmente com: winget install rtk-ai.rtk'
      }
    }
  } else {
    Write-Host '  ℹ Sem terminal interativo. Para instalar, execute manualmente:'
    Write-Host '    winget install rtk-ai.rtk'
  }

  $rtkDoc = [System.IO.Path]::Combine($ClaudeHome, 'RTK.md')
  if (Test-Path -LiteralPath $rtkDoc -PathType Leaf) {
    Write-Host "  Ver $rtkDoc para instruções de uso."
  }
}

Write-Host ''
Write-Host '-- Skill archify --'
$archifySkill = [System.IO.Path]::Combine($ClaudeHome, 'skills', 'archify', 'SKILL.md')
if (Test-Path -LiteralPath $archifySkill -PathType Leaf) {
  Write-Host "ok: archify instalado em $([System.IO.Path]::Combine($ClaudeHome, 'skills', 'archify'))"
} else {
  Write-Host "ausente: skill 'archify' não encontrada."
  if ($HasTty) {
    $answer = $null
    try {
      $answer = Read-Host -Prompt '  Deseja instalar archify agora? [s/N]'
    } catch {
      $answer = $null
    }
    if ($answer -match '^[Ss]') {
      $npx = Get-Command npx -ErrorAction SilentlyContinue
      if (-not $npx) {
        $npx = Get-Command npx.cmd -ErrorAction SilentlyContinue
      }
      if ($npx) {
        Write-Host '  Instalando archify via npx...'
        Invoke-Npx -NpxArgs @(
          '-y', 'skills', 'add', 'tt-a1i/archify',
          '--skill', 'archify', '--agent', 'claude-code',
          '--global', '--copy', '--yes'
        )
        if (($script:NpxExit -eq 0) -and (Test-Path -LiteralPath $archifySkill -PathType Leaf)) {
          Write-Host '  ✓ archify instalado com sucesso'
        } elseif ($script:NpxExit -eq 0) {
          Write-Host '  ✗ Arquivo de skill não encontrado após instalação'
        } else {
          Write-Host '  ✗ Falha ao instalar archify'
        }
      } else {
        Write-Host '  ✗ npx não encontrado. Instale Node.js (≥18) para usar archify.'
      }
    }
  } else {
    Write-Host '  ℹ Sem terminal interativo. Para instalar, execute:'
    Write-Host '    npx -y skills add tt-a1i/archify --skill archify --agent claude-code --global --copy --yes'
  }
}

$settingsJson = [System.IO.Path]::Combine($ClaudeHome, 'settings.json')
if (Test-Path -LiteralPath $settingsJson -PathType Leaf) {
  $hookFound = $false
  try {
    $hookFound = [bool](Select-String -LiteralPath $settingsJson -Pattern 'rtk hook claude' -SimpleMatch -Quiet)
  } catch {
    $hookFound = $false
  }
  if ($hookFound) {
    Write-Host "ok: hook 'rtk hook claude' encontrado em settings.json"
  } else {
    Write-Host 'ausente: nenhum hook RTK encontrado em settings.json'
  }
} else {
  Write-Host "indisponivel: $settingsJson não encontrado — hook RTK não verificado."
}

exit 0
