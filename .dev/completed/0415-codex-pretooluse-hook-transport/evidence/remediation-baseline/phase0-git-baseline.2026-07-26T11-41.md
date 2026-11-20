# Phase 0 — Git Baseline (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P0-T2]

Timestamp: 2026-07-26T11-41

## Commands and Results

### Command: `git rev-parse --abbrev-ref HEAD`
EXIT_CODE: 0

```
bug/codex-pretooluse-hook-transport-415
```

### Command: `git rev-parse HEAD`
EXIT_CODE: 0

```
fef82fa2f2f1dfc25cf96fad1b1b55e953b75dc5
```

### Command: `git status --porcelain`
EXIT_CODE: 0

```
 M docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/remediation-plan.2026-07-25T21-03.md
?? docs/features/active/2026-07-25-codex-pretooluse-hook-transport-415/evidence/remediation-baseline/
```

### Command: `git diff --stat fb483b8468204e4385b5583c3b3ec4c0a987eede..HEAD`
EXIT_CODE: 0

```
64 files changed, 5432 insertions(+), 1332 deletions(-)
```

Changed production PowerShell surface in the branch delta (root `.codex/hooks`):
`check-powershell-test-purity.ps1`, `check-python-test-purity.ps1`, `codex-pretooluse-file-mapping.ps1` (new, 474 lines), `enforce-checkpoint-monotonic.ps1`, `enforce-completion-consistency.ps1`, `enforce-evidence-locations.ps1`, `enforce-orchestration-preimplementation-gate.ps1`, `enforce-powershell-batch-budget.ps1`, `enforce-python-batch-budget.ps1`. The bundled mirror under `extensions/drm-copilot/resources/.codex/hooks/` carries identical changes.

### Command: `Test-Path .codex/state` (equivalently `ls -d .codex/state`)
EXIT_CODE: 2 (path does not exist)

```
ls: cannot access '.codex/state': No such file or directory
```

## Output Summary

- **Branch:** `bug/codex-pretooluse-hook-transport-415`
- **HEAD SHA:** `fef82fa2f2f1dfc25cf96fad1b1b55e953b75dc5`
- **Anchor reconciliation (deviation recorded):** the plan's recorded anchor `abaa6d51655309843cc51a92cef513dd87d8987a` resolves and is the immediate parent of HEAD. HEAD advanced by exactly one commit — `fef82fa2 docs(415): clear remediation plan preflight after rebase` — which touched only the remediation plan document. For [P6-T9] the remediation delta is therefore computed from `fef82fa2` (the true pre-remediation tip), and both anchors are recorded there. No code or configuration difference exists between `abaa6d51` and `fef82fa2`.
- **Merge-base:** `fb483b8468204e4385b5583c3b3ec4c0a987eede` — confirmed by `git merge-base HEAD main`.
- **Actual dirty-state characterization:** the working tree was CLEAN at the start of Phase 0. The two entries reported above are artifacts of this task sequence itself: the modified `remediation-plan.2026-07-25T21-03.md` is the [P0-T1] checkbox check-off, and the untracked `evidence/remediation-baseline/` directory holds the [P0-T1] artifact. No pre-existing uncommitted change was present.
- **`.codex/state/`:** NOT present on disk. The `.gitignore` entry is added at [P5-T1] regardless, per the binary acceptance condition.
