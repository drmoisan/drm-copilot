# Final Cross-Cutting Constraint Sweep — [P15-T9]

Timestamp: 2026-08-15T18-45

Command: `pwsh -NoProfile -File <scratchpad>/constraint-sweep.ps1 -Root <worktree>` enumerating the full change set from `git status --porcelain` (directories expanded to files), plus targeted `grep`/`git diff` probes per clause. Change set: **103 files**.

EXIT_CODE: 0

Output Summary: all nine clauses (a)-(i) PASS. One clause (e) observation is recorded as a documented deviation with justification: the deleted symbol name survives in exactly one place — a `<# #>` doc-comment in a test file that explains the deletion — with zero functional references anywhere.

## (a) No test in the change mutates PATH, probes a live `python`, or shadows `python`

Patterns searched across every changed/new `*.ps1`/`*.psm1`/`*.psd1`, skipping lines whose
first non-whitespace character is `#`: `$env:PATH\s*=`, `Get-Command\s+python`,
`function\s+python\b`, `where\.exe\s+python`.

**Result: 1 raw hit, 0 violations.** The single hit is
`tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1:12`, a
continuation line inside a `<# ... #>` block comment whose text is:

> `restores PATH, probes for a live python, or defines a shadow function python.`

That is prose asserting the file does **not** do those things; it matched only because block-
comment continuation lines do not start with `#`. No executable statement in the change
mutates `$env:PATH`, saves/restores PATH, probes for a live interpreter, or defines a shadow
`function python`. The Python-absence criterion is satisfied structurally (SD-3) by AST
analysis, not by runtime probing.

Pre-existing occurrences outside the change (`tests/scripts/dev-tools/run-actionlint.Tests.ps1`
PATH save/restore, `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1:29`
`Get-Command python`) are untouched by this feature and out of scope for this clause, which is
scoped to "no test in the change".

**PASS.**

## (b) No production or test file in the change exceeds 500 lines

Checked every changed/new `*.ps1`, `*.psm1`, `*.psd1`, `*.py`, `*.ts`, `*.json`.

**Result: 0 files over 500 lines.** Three files sit exactly at the 500-line cap:

- `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1` = 500
- `.claude/lib/discovery-validation/DiscoveryValidation.psm1` = 500
- `extensions/.../claude-customizations/.claude/lib/discovery-validation/DiscoveryValidation.psm1` = 500 (byte-identical mirror)

500 is at the cap, not over it. **PASS.**

## (c) No hook logic moved into `.claude/lib/bash/`

**Result: 0 files under `.claude/lib/bash/` were created, modified, or deleted.** The entire
port is PowerShell. The spec's Decision Record records the bash port as declined for this run
and inherited by later work; `.claude/lib/bash/**` is also excluded from the guard's scan
scope by design. **PASS.**

## (d) All four verdict prefixes unchanged; `.claude/settings.json` untouched

| Prefix | Location | Occurrences |
| --- | --- | --- |
| `DISCOVERY_ARTIFACT_GATE_BLOCKED:` | `.claude/hooks/enforce-discovery-artifact-gate.ps1` | 1 |
| `DISCOVERY_ARTIFACT_GATE_BLOCKED:` | `.claude/hooks/validate-discovery-artifact-gate.ps1` | 2 |
| `ROUTING_CONTRACT_BLOCKED:` | `.claude/hooks/validate-orchestrator-output.ps1` | 1 |
| `MODEL_ROUTING_BLOCKED:` | `.claude/hooks/validate-orchestrator-output.ps1` | 1 |
| `ORCHESTRATOR_STATE_PREFLIGHT_FAILED` | `.claude/hooks/enforce-pr-author-skill.ps1:330` | 1 |

Note on the fourth prefix: it is emitted by the **consumer hook**
`.claude/hooks/enforce-pr-author-skill.ps1`, not by `OrchestratorState.psm1` (which supplies
the preflight result the hook formats). `enforce-pr-author-skill.ps1` does not appear in the
change set at all, so the prefix is preserved by virtue of the file being untouched. An
initial probe that searched `OrchestratorState.psm1` for the literal returned 0 and was
resolved to this location.

`.claude/settings.json`: **not in the change set (0 modifications).** The hook wiring command
fragments pinned by `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:119-123`
are therefore unchanged, independently confirmed green by
`test_parallel_orchestrator_surface_contracts.py` in `[P12-T10]` and again in the `[P15-T7]`
full pytest run. **PASS.**

## (e) `Test-PythonOrchestratorValidatorAvailable` absent from `OrchestratorState.psm1` and referenced nowhere in the tree

| Check | Result |
| --- | --- |
| Occurrences in `.claude/lib/orchestrator-state/OrchestratorState.psm1` (definition, export, or prose) | **0** |
| `Mock` registrations of the symbol, repository-wide | **0** |
| `Should -Invoke` assertions on the symbol, repository-wide | **0** |
| Any call site, repository-wide | **0** |
| Textual occurrences outside `docs/features/**` | **1** |

**Documented deviation.** The single remaining textual occurrence is
`tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1:281`, inside a
`<# ... #>` doc-comment block introduced by `[P11-T3]` that explains why the context was
rewritten:

> `Rewritten for issue #475. The capability-detection probe`
> `Test-PythonOrchestratorValidatorAvailable has been deleted, so there is no`
> `probe to mock and no Python-CLI branch to select. A Pester Mock of a removed`
> `command fails at mock-registration time, so no probe mock may survive here.`

Justification for leaving it: the clause's purpose is that nothing **references** the deleted
command — no definition, no export, no mock, no call — because a Pester `Mock` of a removed
command fails at mock-registration time and a call site would raise
`CommandNotFoundException`. All four functional checks return 0. The surviving occurrence is
explanatory prose recording the deletion, which is the documentation `[P11-T3]` and `[P11-T4]`
were directed to write; removing the symbol name from that comment would make the comment
unable to say what was deleted. Occurrences inside `docs/features/**` (the plan, spec,
research, and evidence artifacts of this feature) are likewise intentional historical record.

**PASS with the deviation recorded above.**

## (f) The six incidental hooks are byte-unchanged

`git status --porcelain` and `git diff --stat b1a86fd3 --` both return empty for:

- `.claude/hooks/check-python-test-purity.ps1`
- `.claude/hooks/enforce-evidence-locations.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.claude/hooks/enforce-python-batch-budget.ps1`
- `.claude/hooks/validate-executor-output.ps1`
- `.claude/hooks/validate-feature-review-coverage.ps1`

Independently corroborated in `[P14-T1]`, where the guard reports zero findings against all
six (the no-false-positive proof: each references Python only in string literals, comments, or
`Invoke-Python*` function names, none of which produce a Python `CommandAst`). **PASS.**

## (g) No artifact uses deferral language; the spec's Decision Record is preserved intact

Case-insensitive search for `defer|deferred|deferral` across every evidence artifact of this
feature and the new potential entry returns only **negations**:

- `potential entry:25` — "No artifact of this feature describes the epic/parallel structural check, or any check family, as deferred."
- `potential entry:27` — "Neither is a deferred check family."
- `potential entry:102` — "no check family is deferred."
- `parity-coverage` artifact — "Deferred rows: 0", "It is not an unmapped row and it is not a deferral", "PD-3 ... is a design decision, not a deferral".

No artifact asserts that any check family, the epic/parallel structural check, or PD-3 is
deferred.

Spec Decision Record: the section `## Decision Record — Language Selection for the
Completion-Validator Port (HI-1)` is present at `spec.md:113` and intact, together with its
cross-references at `spec.md:39`, `:129`, `:200`, and `:245`. `spec.md` carries git status
`??` (untracked — the whole feature folder is new in this run); it has not been truncated or
had the section removed. **PASS.**

## (h) All evidence resides under the canonical feature evidence path

Every artifact produced by this plan is under
`docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/evidence/`
in the sub-paths `baseline/`, `regression-testing/`, `qa-gates/`, and `other/`.

Forbidden `artifacts/` sub-paths verified **absent**: `artifacts/baselines/`,
`artifacts/baseline/`, `artifacts/qa/`, `artifacts/qa-gates/`, `artifacts/evidence/`,
`artifacts/coverage/`, `artifacts/regression-testing/`, `artifacts/post-change/`. The
`artifacts/` tree contains only `orchestration/` (the checkpoint, not evidence), `pester/`
and `python/` (tool-native outputs written by the toolchain itself, not evidence artifacts of
this plan), and `potential-backup/`. **PASS.**

## (i) `scripts/dev_tools/*.py` and the MCP TypeScript validator surface are unmodified

| Surface | Changed files |
| --- | --- |
| `scripts/dev_tools/**/*.py` | **0** |
| `extensions/drm-copilot/src/lib/validate/**` | **0** |

No Python production code was added or modified, and the TypeScript validator parity port was
not touched. **PASS.**

## Summary

| Clause | Result |
| --- | --- |
| (a) no PATH mutation / live probe / shadow function in the change | PASS |
| (b) 500-line cap | PASS (0 over; 3 exactly at 500) |
| (c) no hook logic in `.claude/lib/bash/` | PASS |
| (d) four verdict prefixes unchanged; `settings.json` untouched | PASS |
| (e) deleted probe referenced nowhere | PASS with documented deviation (1 explanatory comment; 0 functional references) |
| (f) six incidental hooks byte-unchanged | PASS |
| (g) no deferral language; Decision Record preserved | PASS |
| (h) evidence under the canonical path only | PASS |
| (i) `scripts/dev_tools/*.py` and MCP TS validator unmodified | PASS |
