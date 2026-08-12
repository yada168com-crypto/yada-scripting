<#
  New-NotionCard.ps1
  Bikin satu kartu script di content calendar Notion lewat API (tanpa klik UI).

  Pakai:
    powershell -File tools\New-NotionCard.ps1 -CardFile "cards\ig-16.json"

  File JSON-nya berisi:
  {
    "db":      "<id-database-notion>",
    "title":   "JUDUL KARTU",
    "date":    "2026-01-31",
    "pillar":  ["news"],
    "author":  ["nama author"],
    "link":    "https://...",
    "status":  "asking for approve",
    "scripID": "isi naskah",
    "scripZH": "isi terjemahan",
    "caption": ["baris 1", "baris 2"],
    "ideas":   ["baris 1", "baris 2"]
  }

  Token disimpan di file teks TERPISAH, di luar repositori ini.
#>
param(
  [Parameter(Mandatory = $true)][string]$CardFile,
  [string]$TokenFile = 'D:\rahasia\notion-token.txt'
)

$ErrorActionPreference = 'Stop'

$token = (Get-Content $TokenFile -Raw).Trim()
$card = Get-Content $CardFile -Raw -Encoding UTF8 | ConvertFrom-Json

function New-RichText([string]$text) {
  # Notion membatasi 2000 karakter per potongan rich_text
  $chunks = @()
  $i = 0
  while ($i -lt $text.Length) {
    $len = [Math]::Min(1900, $text.Length - $i)
    $chunks += @{ type = 'text'; text = @{ content = $text.Substring($i, $len) } }
    $i += $len
  }
  if ($chunks.Count -eq 0) { $chunks = @(@{ type = 'text'; text = @{ content = '' } }) }
  return , $chunks
}

function New-Quote([string]$text) {
  return @{ object = 'block'; type = 'quote'; quote = @{ rich_text = (New-RichText $text) } }
}

function New-Para([string]$text) {
  return @{ object = 'block'; type = 'paragraph'; paragraph = @{ rich_text = (New-RichText $text) } }
}

$children = @()
$children += New-Quote 'Scrip ID'
$children += New-Para $card.scripID
$children += New-Para ''
$children += New-Quote 'Scrip ZH'
$children += New-Para $card.scripZH
$children += New-Para ''
$children += New-Quote 'Caption & Hastag'
foreach ($line in $card.caption) { $children += New-Para $line }
$children += New-Para ''
$children += New-Quote 'IDEAS'
foreach ($line in $card.ideas) { $children += New-Para $line }

$props = @{
  'Name'           = @{ title = @(@{ text = @{ content = $card.title } }) }
  'content pillar' = @{ multi_select = @($card.pillar | ForEach-Object { @{ name = $_ } }) }
  'author'         = @{ multi_select = @($card.author | ForEach-Object { @{ name = $_ } }) }
  'Date'           = @{ date = @{ start = $card.date } }
  ' Links'         = @{ url = $card.link }
  'Status'         = @{ status = @{ name = $card.status } }
}

$payload = @{
  parent     = @{ database_id = $card.db }
  properties = $props
  children   = $children
}

$json = $payload | ConvertTo-Json -Depth 20 -Compress
$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

$headers = @{
  'Authorization'  = "Bearer $token"
  'Notion-Version' = '2022-06-28'
}

try {
  $res = Invoke-RestMethod -Uri 'https://api.notion.com/v1/pages' -Headers $headers -Method Post -Body $bytes -ContentType 'application/json; charset=utf-8'
  "OK  | " + $card.date + " | " + $card.title
  "URL | " + $res.url
}
catch {
  $sr = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
  "GAGAL: " + $sr.ReadToEnd()
}
