# CI Remediation Baseline Run, Cycle 2 (issue #937)

Timestamp: 2026-10-16T10-33
Command: CI job poshqc / PowerShell hook suites (Linux) (Invoke-Pester), run https://github.com/drmoisan/drm-copilot/actions/runs/38885695856
EXIT_CODE: 0
Output Summary: Run 38885695856 (workflow_dispatch, ci.yml) on headSha 1d09122061149af971b5acdff3d2ddb9f53b8fdc (equals the P0-T14 commit and the reported HEAD) concluded success; all 17 jobs concluded success, including poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux). Linux JUnit: TESTCASES=6357, FAILED=0. FM COUNT_MATCHED=56 COUNT_PASSED=56 (wc -l 56); F1 COUNT_MATCHED=68 COUNT_PASSED=68; FOLD COUNT_MATCHED=165 COUNT_FAILED=0; FINV COUNT_MATCHED=27 COUNT_FAILED=0. Baseline failed set: empty.

Task: P0-T15 (remediation-plan.2026-10-16T08-40.md), stage `c2baseline`. The `gh` steps were run by the orchestrator (handoff); the run JSON was saved as `SCRATCH/ci-c2baseline-run.json` and the artifacts were downloaded to `SCRATCH/ci-c2baseline-linux/` and `SCRATCH/ci-c2baseline-windows/`. `J` = `SCRATCH/ci-c2baseline-linux/pester-junit-linux-hooks.xml`.

## Run identity (from SCRATCH/ci-c2baseline-run.json)

Command: poetry run python -I SCRATCH/run_json.py SCRATCH/ci-c2baseline-run.json

- Run URL: https://github.com/drmoisan/drm-copilot/actions/runs/38885695856
- databaseId: 38885695856
- headSha: 1d09122061149af971b5acdff3d2ddb9f53b8fdc
- Reported HEAD (`git rev-parse HEAD` at handoff and at resume): 1d09122061149af971b5acdff3d2ddb9f53b8fdc (match)
- status: completed
- conclusion: success

## Jobs

| Job | Conclusion |
|---|---|
| shell-coverage / Shell Coverage (Bats + kcov) | success |
| security-scan / Security Scanning | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | success |
| quality-checks7 / Code Quality & Tests (3.10) | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | success |
| NPM Audit Gate / npm audit (.) | success |
| poshqc / PowerShell QC | success |
| quality-checks7 / Code Quality & Tests (3.11) | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | success |
| quality-checks7 / Code Quality & Tests (3.13) | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | success |
| quality-checks7 / Code Quality & Tests (3.12) | success |
| docs-validation / Documentation Validation | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | success |
| build-check / Build Package | success |
| poshqc / PowerShell hook suites (Linux) | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | success |

## Command: poetry run python -I SCRATCH/junit_totals.py J

EXIT_CODE: 0

```text
ROOT_TAG=testsuites
ROOT_TESTS=6357
ROOT_FAILURES=0
ROOT_ERRORS=0
TESTCASES=6357
FAILED=0
SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J (no filters)

EXIT_CODE: 0

```text
COUNT_MATCHED=6357
COUNT_PASSED=6357
COUNT_FAILED=0
COUNT_SKIPPED=0
```

No `FAILED` or `MESSAGE` lines were printed by the unfiltered run.

## Command: poetry run python -I SCRATCH/junit_status.py J "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" "U32 keeps" "(issue #937)" "(issue #937 RI-" (F1)

EXIT_CODE: 0

```text
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a UNC path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to an extended-length path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a drive-relative path in epic scope (issue #937)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a file: URI path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a home-relative path in epic scope (issue #937 RI-4)
PASSED	enforce-orchestration-preimplementation-gate.ps1 epic-scope targets (issue #738).denies a Write to a root-relative backslash path in epic scope (issue #937 RI-5)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch UNC file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch extended-length file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch drive-relative file marker in epic scope (issue #937)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch file: URI marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch home-relative marker in epic scope (issue #937 RI-4)
PASSED	Codex preimplementation gate epic-scope targets (issue #738).denies an apply_patch root-relative backslash marker in epic scope (issue #937 RI-5)
COUNT_MATCHED=68
COUNT_PASSED=68
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "gate-targets.Tests.ps1" (FOLD)

EXIT_CODE: 0

```text
PASSED	discovery guard (both hook surfaces).AC-4 tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-targets.Tests.ps1 complies with the baseline isolation form for every closure seam
PASSED	preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.claude/hooks).U06 denies an unbalanced segment
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for cd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for pushd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for popd
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for chdir
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Set-Location
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for sl
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Push-Location
PASSED	preimplementation gate targets (.claude/hooks).U07 gives directory-change for Pop-Location
PASSED	preimplementation gate targets (.claude/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED	preimplementation gate targets (.claude/hooks).U09 denies a substitution-bearing git segment
PASSED	preimplementation gate targets (.claude/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.claude/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.claude/hooks).U11c gives git-relocation for an env-drive assignment
PASSED	preimplementation gate targets (.claude/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED	preimplementation gate targets (.claude/hooks).U13 collects every value of a repeated -C selector
PASSED	preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.claude/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED	preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.claude/hooks).U17 gives selector-missing-value for a trailing -C
PASSED	preimplementation gate targets (.claude/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED	preimplementation gate targets (.claude/hooks).U19 resolves a chained command to the session root and the selector
PASSED	preimplementation gate targets (.claude/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED	preimplementation gate targets (.claude/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED	preimplementation gate targets (.claude/hooks).U22 gives none for no epic scope
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved target result
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an ambiguous target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for an unresolved selector target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives deny for a non-epic target
PASSED	preimplementation gate targets (.claude/hooks).U22 gives evaluate for all-epic targets
PASSED	preimplementation gate targets (.claude/hooks).U23 resolves a target equal to the session root once
PASSED	preimplementation gate targets (.claude/hooks).U24 gives git-command-word-missing for a token array without git
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome none for a none verdict
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a deny verdict
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a failing session-root scope
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome deny for a failing non-session-root target
PASSED	preimplementation gate targets (.claude/hooks).U25 gives outcome allow for an evaluation with no failure
PASSED	preimplementation gate targets (.claude/hooks).U26 gives the exact deny reason for target-ambiguous
PASSED	preimplementation gate targets (.claude/hooks).U26 gives the exact deny reason for target-unresolvable (fall-through)
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.codex/hooks).U06 denies an unbalanced segment
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for cd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for pushd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for popd
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for chdir
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Set-Location
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for sl
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Push-Location
PASSED	preimplementation gate targets (.codex/hooks).U07 gives directory-change for Pop-Location
PASSED	preimplementation gate targets (.codex/hooks).U08 denies a wrapper-led git segment without reading its -C value
PASSED	preimplementation gate targets (.codex/hooks).U09 denies a substitution-bearing git segment
PASSED	preimplementation gate targets (.codex/hooks).U10 resolves a wrapper-led non-git segment to the session root
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_WORK_TREE=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_COMMON_DIR=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for GIT_INDEX_FILE=/x git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11 gives git-relocation for export GIT_DIR=/x && git add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U11b resolves git add docs/legit_dir-notes.md to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.codex/hooks).U11b resolves MY_GIT_DIR=1 git add a.ps1 to the session root (identifier-embedded name)
PASSED	preimplementation gate targets (.codex/hooks).U11c gives git-relocation for an env-drive assignment
PASSED	preimplementation gate targets (.codex/hooks).U11d still denies a standalone-word mention of a relocation name (recorded fail-closed residual)
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir=/x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --git-dir /x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git --work-tree /x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U12 gives git-relocation for git -c core.worktree=/x add a.ps1
PASSED	preimplementation gate targets (.codex/hooks).U13 collects every value of a repeated -C selector
PASSED	preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.codex/hooks).U15 gives selector-dot-segment for a dot and a dot-dot selector
PASSED	preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.codex/hooks).U17 gives selector-missing-value for a trailing -C
PASSED	preimplementation gate targets (.codex/hooks).U18 gives git-option-unmodeled for an unknown global option
PASSED	preimplementation gate targets (.codex/hooks).U19 resolves a chained command to the session root and the selector
PASSED	preimplementation gate targets (.codex/hooks).U20 rejects a relative session root and normalizes a backslash session root
PASSED	preimplementation gate targets (.codex/hooks).U21 returns the four patch-marker paths and nothing for a plain command
PASSED	preimplementation gate targets (.codex/hooks).U22 gives none for no epic scope
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved target result
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an ambiguous target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for an unresolved selector target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives deny for a non-epic target
PASSED	preimplementation gate targets (.codex/hooks).U22 gives evaluate for all-epic targets
PASSED	preimplementation gate targets (.codex/hooks).U23 resolves a target equal to the session root once
PASSED	preimplementation gate targets (.codex/hooks).U24 gives git-command-word-missing for a token array without git
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome none for a none verdict
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a deny verdict
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a failing session-root scope
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome deny for a failing non-session-root target
PASSED	preimplementation gate targets (.codex/hooks).U25 gives outcome allow for an evaluation with no failure
PASSED	preimplementation gate targets (.codex/hooks).U26 gives the exact deny reason for target-ambiguous
PASSED	preimplementation gate targets (.codex/hooks).U26 gives the exact deny reason for target-unresolvable (fall-through)
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
COUNT_MATCHED=165
COUNT_PASSED=165
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U01 " "U02 " "U03 " "U04 " "U05 " "U14 " "U16 " "coverage remediation (" "surface parity (issue #738)" (FINV)

EXIT_CODE: 0

```text
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps all four surface copies of the targets module byte-identical by SHA256 hash
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every surface copy of the targets module under the 500-line cap
PASSED	enforce-orchestration-preimplementation-gate-targets.ps1 surface parity (issue #738).keeps every line of every surface copy at or under 120 characters (issue #903, #732 CR-4)
PASSED	preimplementation gate targets (.claude/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.claude/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.claude/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.claude/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.claude/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.claude/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.claude/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets (.codex/hooks).U01 resolves an absolute path-leg input to itself
PASSED	preimplementation gate targets (.codex/hooks).U02 resolves a relative path-leg input to the session root
PASSED	preimplementation gate targets (.codex/hooks).U03 denies an absolute path-leg input with a dot segment
PASSED	preimplementation gate targets (.codex/hooks).U04 normalizes a backslash path-leg input
PASSED	preimplementation gate targets (.codex/hooks).U05 resolves two patch-marker paths in order
PASSED	preimplementation gate targets (.codex/hooks).U14 gives selector-not-absolute for a relative and a UNC selector
PASSED	preimplementation gate targets (.codex/hooks).U16 gives selector-backslash for a backslash selector
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).removes one trailing slash from a rooted path
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).removes one trailing slash from a backslash-spelled drive path
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).keeps the bare POSIX root unchanged
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).keeps a bare drive root unchanged
PASSED	preimplementation gate targets coverage remediation (.claude/hooks).resolves a segment without -C to a session root given with a trailing slash
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).removes one trailing slash from a rooted path
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).removes one trailing slash from a backslash-spelled drive path
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).keeps the bare POSIX root unchanged
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).keeps a bare drive root unchanged
PASSED	preimplementation gate targets coverage remediation (.codex/hooks).resolves a segment without -C to a session root given with a trailing slash
COUNT_MATCHED=27
COUNT_PASSED=27
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: poetry run python -I SCRATCH/junit_status.py J "U27 gives" "U28 keeps" "U29 denies" "U30 reports" "U31 gives" > SCRATCH/fm-c2baseline-raw.txt (FM)

EXIT_CODE: 0

```text
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.claude/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.claude/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.claude/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.claude/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.claude/hooks).U31 gives path-not-local for a non-local apply_patch marker path
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-backslash-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for unc-mixed-forward-first
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-double-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for extended-length-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for device-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for nt-object-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for drive-relative
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for bare-drive-letter
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for leading-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for trailing-space-absolute
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-drive
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for file-uri-unc
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-forward
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for tilde-backslash
PASSED	preimplementation gate targets (.codex/hooks).U27 gives path-not-local for root-relative-backslash
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-backslash)
PASSED	preimplementation gate targets (.codex/hooks).U28 keeps a bare drive root path-leg input as its own target (drive-root-forward)
PASSED	preimplementation gate targets (.codex/hooks).U29 denies a non-local path-leg input even when a sibling path is valid
PASSED	preimplementation gate targets (.codex/hooks).U30 reports path-not-local before path-dot-segment for a UNC dot-dot path
PASSED	preimplementation gate targets (.codex/hooks).U31 gives path-not-local for a non-local apply_patch marker path
COUNT_MATCHED=56
COUNT_PASSED=56
COUNT_FAILED=0
COUNT_SKIPPED=0
```

## Command: grep "^PASSED" SCRATCH/fm-c2baseline-raw.txt | cut -f2 | tr -d '\r' | sort > SCRATCH/fm-c2baseline.txt; wc -l < SCRATCH/fm-c2baseline.txt

EXIT_CODE: 0

```text
56
```

## Baseline values carried forward

- T (Linux `TESTCASES=`): 6357
- X (FOLD `COUNT_MATCHED`): 165
- I (FINV `COUNT_MATCHED`): 27
- Baseline failed set (for P2-T14 and P4-T11): empty (unfiltered `COUNT_FAILED=0`).
- Jobs not concluding success at the c2 baseline: none.
- FM name set for the RI-8 proof: `SCRATCH/fm-c2baseline.txt` (56 sorted names).

## Acceptance

- headSha equals the P0-T14 commit: met.
- Both poshqc job conclusions recorded (success, success); baseline failed set recorded (empty): met.
- FM `COUNT_MATCHED=56`, `COUNT_PASSED=56`, `wc -l` 56: met.
- F1 `COUNT_MATCHED=68`, `COUNT_PASSED=68`: met.
- FOLD `COUNT_FAILED=0` (X = 165, as expected): met.
- FINV `COUNT_FAILED=0` (I = 27, as expected): met.
