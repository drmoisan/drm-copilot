Timestamp: 2026-11-04T03-44
Command: pwsh -NoProfile -File SCRATCH/issue-1069-coverage-summary.ps1
EXIT_CODE: 0
Output Summary: Comparison base: 01706c697f3ad4a53b4a771d99d851afc7417ea9. Source commit: 96dbe6321. All metrics are measured executable lines; tests excluded. Governing repository floor80%; changed PowerShell/Bash file floor85%; new methods/modules target90%. PowerShell has no branch gate.

| Production population | Baseline | Final | New/changed executable lines | Delta / disposition |
|---|---:|---:|---:|---|
| HostBootstrap.psm1 |155/155=100%|190/190=100%|35 net new lines,35/35=100%|0 percentage points;PASS|
| New container_versions.sh |N/A:new module|16/16=100%|16/16=100%|PASS|
|local verify-container.sh|124/134=92.54%|60/62=96.77%|Diff removed:123/133;added:59/61|+4.24 points;PASS|
New verifier function beginning line14:8/8=100%.
New verifier function beginning line30:12/12=100%.
local verify-container.sh executable lines: 3,5,6,10,15,16,17,20,21,22,23,24,31,32,33,34,36,37,38,40,41,42,44,45,48,49,50,52,54,56,59,60,61,63,64,67,68,72,73,74,79,80,81,83,84,88,89,91,92,95,96,97,98,100,101,104,105,108,109,111,112,114. Uncovered lines: 67,68.
|codespaces verify-container.sh|124/134=92.54%|60/62=96.77%|Diff removed:123/133;added:59/61|+4.24 points;PASS|
New verifier function beginning line14:8/8=100%.
New verifier function beginning line30:12/12=100%.
codespaces verify-container.sh executable lines: 3,5,6,10,15,16,17,20,21,22,23,24,31,32,33,34,36,37,38,40,41,42,44,45,48,49,50,52,54,56,59,60,61,63,64,67,68,72,73,74,79,80,81,83,84,88,89,91,92,95,96,97,98,100,101,104,105,108,109,111,112,114. Uncovered lines: 67,68.
|local post-create.sh|83/128=64.84%|116/129=89.92%|Diff removed:17/55;added:49/55|+25.08 points;PASS|
local post-create.sh executable lines: 2,4,5,6,13,14,16,17,20,23,24,25,36,37,38,39,40,41,44,46,47,48,52,53,55,58,59,60,61,62,65,66,76,77,78,79,80,82,83,84,85,87,88,93,94,96,99,103,104,105,106,150,151,152,157,158,161,164,165,166,169,170,171,173,174,175,179,180,181,182,183,184,185,187,191,192,193,194,195,196,201,202,203,204,205,209,210,211,214,216,217,223,224,225,226,227,228,229,230,231,239,240,241,278,279,280,296,297,298,299,300,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323. Uncovered lines: 38,39,40,52,53,55,94,226,227,228,229,230,231.
|codespaces post-create.sh|83/128=64.84%|116/129=89.92%|Diff removed:17/55;added:49/55|+25.08 points;PASS|
codespaces post-create.sh executable lines: 2,4,5,6,13,14,16,17,20,23,24,25,36,37,38,39,40,41,44,46,47,48,52,53,55,58,59,60,61,62,65,66,76,77,78,79,80,82,83,84,85,87,88,93,94,96,99,103,104,105,106,150,151,152,157,158,161,164,165,166,169,170,171,173,174,175,179,180,181,182,183,184,185,187,191,192,193,194,195,196,201,202,203,204,205,209,210,211,214,216,217,223,224,225,226,227,228,229,230,231,239,240,241,278,279,280,296,297,298,299,300,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323. Uncovered lines: 38,39,40,52,53,55,94,226,227,228,229,230,231.

post-create.sh has formatter-only changes: baseline/current shfmt -mn canonical output is identical. Added physical-line coverage is not new semantic code; existing is_mount_point function is unchanged. Its changed-line proportion improves; no new setup function is introduced. verify-container.sh new parser/check functions cover8/8 and12/12 executable lines. Its two uncovered lines67,68 are the existing absent-/etc/os-release diagnostic. No production file is excluded.

| Unchanged bounded Bash file | Baseline | Final | Delta |
|---|---:|---:|---:|
|coverage_lib.sh|3/3=100%|3/3=100%|0 points|
|coverage_demo.sh|4/4=100%|4/4=100%|0 points|
|kcov_trace_env.sh|2/2=100%|2/2=100%|0 points|
|shell_qc_lib.sh|188/206=91.26%|188/206=91.26%|0 points|
|shell-qc.sh|31/35=88.57%|31/35=88.57%|0 points|

Full configured PowerShell population: serial and merged concurrent coverage21,284/22,733=93.63%; HostBootstrap190/190. Baseline host-only422/22,698=1.86% was a targeted measurement, not whole-repository compliance. No comparable pre-change full-population run is claimed; changed-module baseline100%→100% proves no changed-line regression. Native full serial and concurrent runs both pass13,732 tests,0failures,10existing skips.
Shell-QC bounded baseline228/250=91.20%→244/266=91.73% final after adding the16/16 helper. Including actual changed container entrypoints, baseline435/512=84.96%→420/457=91.90% final. Image populations are reported separately and not double-counted. All changed shell production files exceed85%; new functions/modules exceed90%.
Python runtime files unchanged: selected existing cleanup module34/36=94.44% lines,9/10=90% branches at baseline and final; delta0. Bounded baseline58→final80tests pass. No new Python runtime code, so new-runtime coverageN/A. Full local16,067-test attempt was explicitly interrupted and is not used as compliance evidence.
TypeScript runtime files unchanged: root baseline/final98.21% lines,93.40% branches; extension61,859/63,730=97.06% lines,9,388/10,022=93.67% branches. Both deltas0. Root330suites/5,301tests and extension327suites/5,284tests pass; seeded extension run also passes. New-runtime coverageN/A.

Invariants: both devcontainer JSON configurations and tracked local lock unchanged relative to comparison base; generated Codespaces lock removed. Local mounts/docker-outside-of-docker features, Codespaces resource settings, Python3.11/3.12 matrix legs, consumer engines, unrelated CLI pins, publishing workflows, bootstrap CLI flags and unmanaged-command behavior preserved. Config/workflow/resource contract tests80passed; actionlint0findings. Six execution-environment mirrors byte-identical. No dependency lockfile changes or file-size baseline exceptions added.

| Changed code/script/config file | Logical lines |
|---|---:|
|.devcontainer/codespaces/Dockerfile|190|
|.devcontainer/local/Dockerfile|190|
|.devcontainer/post-create.sh|323|
|.devcontainer/verify-container.sh|114|
|.github/workflows/_build-check.yml|55|
|.github/workflows/_drm-copilot-extension-tests.yml|50|
|.github/workflows/_npm-audit-gate.yml|54|
|.github/workflows/_quality-checks.yml|129|
|.github/workflows/_root-typescript-tests.yml|30|
|.github/workflows/_security-scan.yml|51|
|.github/workflows/_shell-coverage.yml|85|
|scripts/bash/container_versions.sh|28|
|scripts/dev-tools/HostBootstrap.psm1|529|
|scripts/host-tools.manifest.json|73|
|tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1|384|
|tests/scripts/dev-tools/HostBootstrap.Versions.Tests.ps1|178|
|tests/scripts/dev_tools/test_host_environment_contracts.py|165|
|tests/scripts/host-tools.manifest.Tests.ps1|168|
|tests/shell/test_container_versions.bats|62|
