# Remediation Inputs — cycle 4 entry (Issue #500)

**Authored:** 2026-08-22T17-20 by feature-review, at the exit of remediation cycle 3.
**Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `0610037b`
**Base:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`

## Source audit artifacts

- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T17-20-audit/policy-audit.2026-08-22T17-20.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T17-20-audit/code-review.2026-08-22T17-20.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/2026-08-22T17-20-audit/feature-audit.2026-08-22T17-20.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/qa-gates/reviewer-toolchain-rerun.2026-08-22T17-20.md`
- `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md`

## Status

**Blocking findings: 0.** The shipped correction is sound and every element of it was independently verified by perturbation. This cycle is elective in the same sense cycle 3 was: nothing here prevents the branch from merging, and a decision to accept items R1 through R3 as known residuals and close the issue is defensible provided the acceptance-criteria discrepancy in R2 is resolved one way or the other, because an acceptance criterion whose text is false for the artifact it names cannot be re-verified by a later reader.

Remediation is nonetheless triggered under `feature-review-workflow` because one acceptance criterion is PARTIAL.

## Enumerated fix list

This list is exhaustive. Every instance of every defect class found in this audit is enumerated below; the executor should fix only these and should not search for further instances of the same class outside the paths named.

### R1 — Close or withdraw CR-3 (Major)

**Finding.** Cycle 3's response to CR-3 does not close the silent-pass direction CR-3 named. Adding an unconsumed key to a class constant and to both committed copies passes silently in all three languages.

**Files.**
- `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, `CLASS_TWO_KEYS` at line 109 and `CLASS_THREE_KEYS` at line 113.
- `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, the three membership assertions at lines 249, 278, and 342.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, `$script:ClassTwoKeys` at line 29 and `$script:ClassThreeKeys` at line 32.

**Expected behaviour, option A (close it).** Assert CONSUMPTION rather than membership. For example, declare a per-class registry mapping each class key to the name of the assertion that consumes it, derive the class constant from that registry's key set, and assert that every registered assertion name resolves to a test that exists. A key added to a class constant without a consuming assertion must then fail. Mirror the construct on the PowerShell side, where no binding exists at all today.

**Expected behaviour, option B (withdraw it).** Remove the three membership assertions, which cannot fail independently of the exhaustiveness gate, and record in the support module's docstring that adding an unconsumed name to a class constant is an accepted, unguarded residual requiring a deliberate edit of a commented constant.

**Verification commands.** Whichever option is taken, the acceptance evidence must be a perturbation, not a green run:

```
# fail-before for option A: the residual must now be caught
poetry run python - <<'EOF'   # (use a script FILE; multi-line `poetry run python -c` is a silent no-op)
EOF
# 1. add "invented_key": [] to both config/blast-radius.json and
#    extensions/drm-copilot/resources/claude-customizations/config/blast-radius.json
# 2. append "invented_key" to CLASS_TWO_KEYS and to $script:ClassTwoKeys
# 3. add `invented_key: [],` to SOURCE_BLAST_RADIUS in config-carriage.test-helpers.ts
poetry run pytest -q --no-cov tests/scripts/dev_tools/test_blast_radius_config_parity.py
pwsh -NoProfile -Command "Import-Module Pester; Invoke-Pester tests/scripts/claude-lib/blast-radius"
cd extensions/drm-copilot && node run-jest.cjs test/lib/push-down/
```

Under option A this perturbation must produce at least one failure in Python AND at least one in PowerShell. The baseline it must be compared against is recorded in `evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md` Group D2: Jest `223 passed`, pytest `48 passed`, Pester `383 passed`, all green.

Under option B no perturbation is required, but the docstring change must be visible in the diff and the three now-removed assertions must be gone.

### R2 — Resolve the AC11 discrepancy (Major, and the trigger for this cycle)

**Finding.** `spec.md` line 488 asserts that `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` mirrors "the Class 1 equality, the Class 3 subset, the five-name umbrella denylist applied to both copies, and the separator-free-wildcard-free assertion". After the cycle-3 split the Class 1 equality lives in `BlastRadius.KeyPartition.Tests.ps1:50`. The checkbox is `[x]` and the criterion's text is false for the file it names.

**Files.** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md`, criterion at lines 488 to 491.

**Expected behaviour.** Either:
- amend the criterion text so it names both `BlastRadius.TruthTable.Tests.ps1` and `BlastRadius.KeyPartition.Tests.ps1` and attributes each of the four mirrors to the file that carries it, and states that both files stay under the 500-line limit; or
- move the `declares equal values for the runtime-describing keys in both copies` case back into `BlastRadius.TruthTable.Tests.ps1`, which would put that file at roughly 350 lines and is therefore feasible.

The first is preferred: the split was correct and reversing part of it to satisfy a sentence is the wrong direction.

**Verification commands.**

```
grep -n "BlastRadius" docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md
grep -nE "^\s*It " tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1
grep -nE "^\s*It " tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
wc -l tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
```

Acceptance: every case name the amended criterion attributes to a file is present in that file's `It` list, and both files are under 500 lines.

### R3 — Retire the four stale pointers the cycle-3 split created (Major)

**Finding.** Four pointers name `BlastRadius.TruthTable.Tests.ps1` as the home of two cases that now live in `BlastRadius.KeyPartition.Tests.ps1`. This is a normative rule document and its published copy.

**Files and exact locations (all four instances, exhaustive).**
- `.claude/rules/parallel-orchestration.md` line 310 — the directional-invariant paragraph.
- `.claude/rules/parallel-orchestration.md` line 319 — the exhaustiveness-gate paragraph.
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` line 310 — same paragraph in the published copy.
- `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` line 319 — same paragraph in the published copy.

**Expected behaviour.** Each of the four names `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`. Both copies stay byte-identical and both edits land in the same commit.

**Verification commands.**

```
grep -rn "BlastRadius.TruthTable.Tests.ps1" .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
grep -rn "BlastRadius.KeyPartition.Tests.ps1" .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
poetry run pytest -q --no-cov tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

Acceptance: the first grep returns no hit, the second returns four, `cmp` exits 0, and the push-down contract suite passes.

### R4 — Correct the KeyPartition header's "verbatim" claim (Minor)

**Files.** `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1`, `.DESCRIPTION` block at lines 5 to 14.

**Expected behaviour.** Replace "carries the 'Cross-copy key partition' Context verbatim" with a statement that three cases moved unchanged and one — `requires the shared-surface lists compared by the directional invariant to be non-empty` — was renamed to `requires a populated shared-surface list and module map in both copies` and rewritten as the CR-1 and CR-2 repair.

**Verification command.** `grep -n "verbatim" tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` returns no hit.

### R5 — Distinguish the two Pester files by `Describe` name (Minor)

**Files.** `tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1` line 35.

**Expected behaviour.** Rename its `Describe` so a failure path identifies the file, for example `Committed blast-radius truth table cross-copy key partition`. `BlastRadius.TruthTable.Tests.ps1` keeps its existing `Describe`.

**Verification command.**

```
grep -n "^Describe " tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1 tests/scripts/claude-lib/blast-radius/BlastRadius.KeyPartition.Tests.ps1
```

Acceptance: the two `Describe` strings differ, and the directory run still reports 383 passed.

### R6 — Record the Python floor's mechanism (Minor)

**Files.** `tests/scripts/dev_tools/test_blast_radius_config_parity.py`, `test_the_gate_compares_non_empty_collections` docstring at line 405.

**Expected behaviour.** State that an absent, null, or renamed `shared_surfaces` in the self-hosted copy and an absent, null, or renamed `modules` in either copy are caught upstream by `require_string_list` and `load_module_globs` raising `TypeError`, six of those at module import, and that only the seven remaining states reach this assertion. Naming the upstream functions makes the coverage claim checkable.

**Verification.** Reading, plus the sixteen-cell table already recorded in `evidence/regression-testing/reviewer-perturbation-battery.2026-08-22T17-20.md` Group B. No new perturbation is required.

## Out of scope for this cycle — file separately

`PRE-1`. `tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_json_cancel_before_validate_returns_canceled_result` failed in 13 of the first 19 iterations of an isolated loop and passed inside the full-suite run. It is a genuine cross-thread ordering race in `scripts/dev_tools/fix_all_runtime.py`, which spawns one `threading.Thread` per branch at line 148 and signals `cancel_event.set()` at line 145. The branch changes no file under `scripts/`, and `grep -rn "blast" scripts/dev_tools/fix_all.py` exits 1, so it is not attributable to issue #500. It does violate the determinism requirement in `.claude/rules/general-unit-test.md`. **File a separate issue against `fix_all_runtime.py` and its tests. Do not fold it into issue #500 and do not touch `scripts/dev_tools/` in this cycle.**

## Do not do

- Do not touch any acceptance criterion other than AC11 under R2, and do not re-check AC11's box without the evidence R2 requires.
- Do not touch `scripts/dev_tools/` or any production Python, TypeScript, or PowerShell file. R1 through R6 are confined to test files, one rule document and its published copy, and `spec.md`.
- Do not weaken, delete, or narrow any existing assertion. R1 option B removes three assertions that cannot fail independently; that is the only permitted removal and it must be accompanied by the docstring statement.
- Do not amend `.claude/rules/` beyond the four pointer strings in R3. No rule amendment is required by R1 through R6.
- Do not rename any existing evidence artifact.
- Do not use multi-line `poetry run python -c "..."` for any perturbation. Under `poetry run` it produces no output and exits 0 without executing, which silently turns a perturbation into a no-op and a fail-before artifact into a fabrication. Use a script FILE and confirm the perturbation landed with `git diff --stat` before running the gate.
- Do not accept a green run as evidence for R1. The acceptance evidence for R1 option A is a perturbation that fails, compared against the recorded all-green baseline.
- Do not restore a perturbed file with `git checkout --` when that file carries uncommitted in-cycle work. Prefer capturing an external `Get-FileHash` or `sha256sum` of the pre-perturbation content and re-comparing it after restore, rather than an in-memory backup verified by `diff` inside the same process that made the perturbation.
