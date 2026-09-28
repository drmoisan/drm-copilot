# Phase 0 Bundled Root Surfaces (P0-T34)

Timestamp: 2026-09-27T15-00

Command: derived from the P0-T31 output (poetry run python `<scratchpad>`/phase0_python_verdicts.py `<scratchpad>`/phase0-cases.json) and the P0-T32 output (sh `<scratchpad>`/run-ps.sh `<scratchpad>`/phase0-powershell-verdicts.ps1 -CasesPath `<scratchpad>`/phase0-cases.json)

EXIT_CODE: 0

Recorded lines (verbatim):

Python (config_root_surfaces):

```
ROOT_SURFACES_SELF_HOSTED=package-lock.json,poetry.lock,quality-tiers.yml
ROOT_SURFACES_BUNDLED=package-lock.json,poetry.lock,quality-tiers.yml
```

PowerShell (Get-ConfigRootSurface, root modules):

```
ROOT_SURFACES_SELF_HOSTED=package-lock.json,poetry.lock,quality-tiers.yml
ROOT_SURFACES_BUNDLED=package-lock.json,poetry.lock,quality-tiers.yml
```

Output Summary: All four values equal package-lock.json,poetry.lock,quality-tiers.yml. The self-hosted and bundled separator-free subsets are equal within each runtime and across runtimes, matching research claims N1 and N2. No inequality is routed to P1-T1.
