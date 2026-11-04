# Epic progress report for #1019 documentation-estate-tooling. Read-only: git, gh and cswap queries only.
param([string]$Mode = 'Full')
$ErrorActionPreference = 'Continue'
$coord   = '/workspaces/drm-copilot'
$integ   = 'origin/epic/documentation-estate-tooling-integration'
$kickRel = 'docs/features/epics/documentation-estate-tooling/epic-kickoff.md'
$startUtc = [datetime]::Parse('2026-11-04T13:55:00Z').ToUniversalTime()  # resume after the Codespace restart; earlier velocity discarded
$baselineDone = 261  # tasks complete at the restart resume
$baselineWeeklyPct = 0
$waveOverheadHours = 1.25
Set-Location $coord
git fetch -q origin 2>$null
$wtOf = @{}; $cur = $null
foreach ($line in (git worktree list --porcelain)) {
  if ($line -like 'worktree *') { $cur = $line.Substring(9) }
  elseif ($line -like 'branch refs/heads/*') { $wtOf[$line.Substring(18)] = $cur }
}
$feat = @{}
$cpPath = Join-Path $coord 'artifacts/orchestration/epic-orchestrator-state.json'
if (Test-Path $cpPath) { foreach ($f in (Get-Content -Raw $cpPath | ConvertFrom-Json).features) { $feat["$($f.issue_num)"] = $f } }
$kick = git show "${integ}:${kickRel}"
$rows = @($kick | Select-String '^\| (10\d\d) \|' | ForEach-Object {
  $c = ($_.Line -split '\|') | ForEach-Object { $_.Trim() }
  [pscustomobject]@{ issue = $c[1]; wave = [int]$c[3]; band = $c[4]; plan = $c[5] }
})
$report = foreach ($r in $rows) {
  $f = $feat[$r.issue]; $branch = if ($f) { $f.branch_name } else { $null }
  $ms = if ($f -and $f.merge_status) { $f.merge_status } else { 'not_started' }
  $prState = ''
  if ($branch) { $prState = (gh pr list --head $branch --state all --json number,state --jq '.[0] | if . then "#\(.number) \(.state)" else "" end' 2>$null) }
  $live = $null
  if ($branch -and $wtOf.ContainsKey($branch)) { $live = Join-Path $wtOf[$branch] $r.plan }
  if ($live -and (Test-Path $live)) { $txt = Get-Content -Raw $live } else { $txt = (git show "${integ}:$($r.plan)") -join "`n" }
  $all = [regex]::Matches($txt, '(?m)^\s*- \[( |x)\] \[P\d+-T\d+\]')
  $done = @($all | Where-Object { $_.Groups[1].Value -eq 'x' }).Count
  $phase = ''
  $first = [regex]::Match($txt, '(?m)^\s*- \[ \] \[P(\d+)-T\d+\]')
  if ($first.Success) {
    $pn = $first.Groups[1].Value
    $h = [regex]::Match($txt, "(?m)^#{2,4}\s+Phase\s+$pn\b[^\r\n]*")
    $phase = if ($h.Success) { ($h.Value -replace '^#+\s+', '').Trim() } else { "Phase $pn" }
  }
  $isMerged = ($ms -eq 'merged') -or ($ms -eq 'worktree_removed') -or ($prState -match 'MERGED')
  $state = if ($isMerged) { 'Completed' } elseif ($done -gt 0 -or $ms -ne 'not_started' -or $prState) { 'Running' } else { 'Pending' }
  [pscustomobject]@{ issue = $r.issue; wave = $r.wave; band = $r.band; total = $all.Count; done = $done; state = $state; phase = $phase; pr = $prState; ms = $ms }
}
$total = ($report | Measure-Object total -Sum).Sum; $doneT = ($report | Measure-Object done -Sum).Sum
$pct = [math]::Round(100 * $doneT / [math]::Max(1, $total), 1)
$now = (Get-Date).ToUniversalTime(); $elapsedH = ($now - $startUtc).TotalHours
$vel = if ($elapsedH -gt 0) { ($doneT - $baselineDone) / $elapsedH } else { 0 }
$remaining = $total - $doneT
$straight = if ($vel -gt 0) { $remaining / $vel } else { [double]::NaN }
$cpTasks = 0; $openWaves = 0
foreach ($g in ($report | Group-Object wave)) {
  $open = @($g.Group | Where-Object { $_.state -ne 'Completed' })
  if ($open.Count -gt 0) { $openWaves++; $cpTasks += ($open | ForEach-Object { $_.total - $_.done } | Measure-Object -Maximum).Maximum }
}
$cpHours = if ($vel -gt 0) { $cpTasks / $vel + $openWaves * $waveOverheadHours } else { [double]::NaN }
$q = (cswap list --json 2>$null | ConvertFrom-Json).accounts | Where-Object { $_.active } | Select-Object -First 1
$wk = if ($q) { [double]$q.usage.sevenDay.pct } else { [double]::NaN }
$wkDelta = $wk - $baselineWeeklyPct
function Fmt-H($h) { if ([double]::IsNaN($h)) { 'n/a' } else { '{0:N0} h {1:00} min' -f [math]::Floor($h), (($h - [math]::Floor($h)) * 60) } }
$completed = @($report | Where-Object state -eq 'Completed'); $running = @($report | Where-Object state -eq 'Running'); $pending = @($report | Where-Object state -eq 'Pending')
$statePath = Join-Path (Split-Path -Parent $PSCommandPath) 'epic-progress-state.json'
$samples = @(); if (Test-Path $statePath) { $samples = @(Get-Content -Raw $statePath | ConvertFrom-Json) }
$lastS = $samples | Select-Object -Last 1
$nowTs = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
if (-not $lastS -or -not ($lastS.PSObject.Properties.Name -contains 'ts') -or (($nowTs - [long]$lastS.ts) -ge 90)) {
  $samples = @($samples | Where-Object { $_.PSObject.Properties.Name -contains 'ts' })
  $samples += [pscustomobject]@{ ts = $nowTs; done = $doneT }
  $samples = @($samples | Select-Object -Last 14)
  ($samples | ConvertTo-Json -Depth 3 -AsArray) | Set-Content $statePath -Encoding utf8
}
$ivl = @()
for ($i = 1; $i -lt $samples.Count; $i++) {
  $dtH = ([long]$samples[$i].ts - [long]$samples[$i-1].ts) / 3600.0
  if ($dtH -ge (2/60)) { $ivl += [math]::Max(0, ($samples[$i].done - $samples[$i-1].done) / $dtH) }
}
$recent = if ($ivl.Count) { $ivl[-1] } else { [double]::NaN }
function Fmt-HM($h) { $m = [math]::Round($h * 60); '{0:00}:{1:00}' -f [math]::Floor($m / 60), ($m % 60) }
$rangeTxt = "$(Fmt-HM $cpHours) hrs (range needs 3 or more check-in intervals)"
$sdTxt = 'n/a'
if ($ivl.Count -ge 3) {
  $mean = ($ivl | Measure-Object -Average).Average
  $sd = [math]::Sqrt((($ivl | ForEach-Object { ($_ - $mean) * ($_ - $mean) } | Measure-Object -Sum).Sum) / ($ivl.Count - 1))
  $sdTxt = [math]::Round($sd, 1)
  $fastV = $vel + 2.05 * $sd; $slowV = $vel - 2.05 * $sd
  $fastH = $cpTasks / $fastV + $openWaves * $waveOverheadHours
  if ($slowV -gt 0.5) { $slowH = $cpTasks / $slowV + $openWaves * $waveOverheadHours; $rangeTxt = "$(Fmt-HM $fastH) hrs to $(Fmt-HM $slowH) hrs" }
  else { $rangeTxt = "$(Fmt-HM $fastH) hrs to no upper bound (average velocity minus 2.05 SD is at or below 0.5 tasks / hr)" }
}
$runSentence = if ($running.Count -eq 0) { 'No feature is running.' } elseif ($running.Count -eq 1) { "#$($running[0].issue) is running ($($running[0].done) of $($running[0].total))." } else { (($running | ForEach-Object { "#$($_.issue) ($($_.done) of $($_.total))" }) -join ', ') + ' are running.' }
$doneSentence = if ($completed.Count -eq 0) { "None of the $($rows.Count) features is done yet." } else { "$($completed.Count) of $($rows.Count) features are done." }
$recentTxt = if ([double]::IsNaN($recent)) { 'n/a' } else { [math]::Round($recent, 1) }
Write-Output "**TL;DR:** Epic #1019 is at $doneT of $total tasks ($pct%). $doneSentence $runSentence"
Write-Output "**Elapsed:** $(Fmt-H $elapsedH), with about $([math]::Round($cpHours)) hours left on the wave-parallel estimate. **Weekly** quota is at $wk%."
Write-Output "**Avg Velocity:** $([math]::Round($vel,1)) tasks / hr. **Recent Velocity:** $recentTxt tasks / hr since last check-in. (SD of recent velocity: $sdTxt, from $($ivl.Count) intervals)"
Write-Output "**Estimated time remaining:** $rangeTxt"
if ($Mode -ne 'TLDR') {
Write-Output ''
Write-Output "## Epic #1019 documentation-estate-tooling: status at $($now.ToString('HH:mm')) UTC, $($now.ToString('MMM d'))"
Write-Output ''
Write-Output "**Elapsed:** $(Fmt-H $elapsedH) since $($startUtc.ToString('HH:mm')) UTC. **Progress:** $doneT of $total tasks complete, **$pct%**."
Write-Output ''
Write-Output '| State | Features |'; Write-Output '|---|---|'
Write-Output ("| Completed | " + $(if ($completed.Count) { ($completed | ForEach-Object { "#$($_.issue)" }) -join ', ' } else { 'None yet' }) + ' |')
foreach ($x in $running) { $p = if ($x.pr) { " PR $($x.pr)." } else { '' }; $ph = if ($x.phase) { " Now at: $($x.phase)." } else { '' }; Write-Output "| Running | #$($x.issue) (wave $($x.wave), $($x.band)): $($x.done) of $($x.total) tasks ($([math]::Round(100*$x.done/[math]::Max(1,$x.total)))%).$ph$p |" }
foreach ($g in ($pending | Group-Object wave | Sort-Object { [int]$_.Name })) { Write-Output ("| Pending, wave $($g.Name) | " + (($g.Group | ForEach-Object { "#$($_.issue) ($($_.total))" }) -join ', ') + ' |') }
Write-Output ''
Write-Output '| Wave | Children | Tasks | Done |'; Write-Output '|---|---|---|---|'
foreach ($g in ($report | Group-Object wave | Sort-Object { [int]$_.Name })) { Write-Output "| $($g.Name) | $($g.Count) | $(($g.Group | Measure-Object total -Sum).Sum) | $(($g.Group | Measure-Object done -Sum).Sum) |" }
Write-Output "| **Total** | **$($rows.Count)** | **$total** | **$doneT** |"
Write-Output ''
Write-Output "**Velocity:** $([math]::Round($vel,1)) tasks per hour (one child's pace). **Remaining:** $remaining tasks."
Write-Output "- Straight line, no parallelism: about $(Fmt-H $straight) (upper bound)."
Write-Output "- Wave-parallel (longest chain $cpTasks tasks plus about $waveOverheadHours h per open wave for review and CI): about **$(Fmt-H $cpHours)**."
Write-Output "**Weekly quota (active account):** $wk% used, $(if ($wkDelta -ge 0) { '+' })$wkDelta points since the epic started. This pool also covers the other runs in this session, so it is not the epic's cost alone."
}

