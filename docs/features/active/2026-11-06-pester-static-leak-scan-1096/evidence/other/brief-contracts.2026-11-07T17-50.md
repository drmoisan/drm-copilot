# Brief and Wording Contracts on the Cycle 2 Merged Tree (Issue #1096)

Timestamp: 2026-11-07T17-50
Command: sha256sum over the six `_BRIEF_COPIES` paths; section and bullet read of `## Test Isolation Checks`; per-line presence check of every line the branch added to and removed from `.claude/skills/execution-environment/SKILL.md`; per-function token read of `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`; sh SCRATCH/issue-1096-c2-wording.sh (AST read of the token lists of `tests/scripts/claude-runtime/parallel-gate-wording.Tests.ps1` and `tests/scripts/claude-runtime/planning-contract-wording.Tests.ps1`, compared with the lines this branch adds to the brief against `origin/main`)
EXIT_CODE: 0
Output Summary: six copies share one SHA-256 hash; the `Invoke-PoshQCLeakScan` bullet is the last of 8 top-level bullets of `## Test Isolation Checks`; all 5 branch-added brief lines are present and both branch-removed lines are absent; the test file has 571 logical lines, 21 `def test_` names each occurring once, every branch assertion and main's `Phase 0 baseline` assertion present; 39 wording-suite token rows, 0 conflicts. No file changed in this task.

## Brief copies

| Path | SHA-256 |
|---|---|
| `.claude/skills/execution-environment/SKILL.md` | `1d9a1f8600684ca1736a4525d219e4bf73ced11189ba8dcdd68c3e3552ffa483` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md` | same |
| `.agents/skills/execution-environment/SKILL.md` | same |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md` | same |
| `.github/skills/execution-environment/SKILL.md` | same |
| `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md` | same |

The copies did not differ, so no resolution or re-copy was needed.

## Bullet order

`## Test Isolation Checks` holds 8 top-level bullets. The last is the bullet that begins "`Invoke-PoshQCLeakScan` is the static check for state that leaks between test files". No main bullet follows it, so no bullet moved.

## Branch passages next to main's text

| Section | Branch line | Result |
|---|---|---|
| `## PowerShell Route and PoshQC MCP Limits` | "No MCP tool exposes `Invoke-PoshQCLeakScan`." bullet | present |
| `## CI Shape and Required Checks` | `_poshqc.yml` bullet naming the leak scan in `poshqc / PowerShell QC static` | present; the pre-branch wording of that bullet is absent |
| `## CI-Only Failure Classes` | "`Invoke-PoshQCLeakScan` is the check for such leaks." bullet | present |
| `## Test Runtime` | pytest `-n auto` bullet naming the `fix_all` pytest step | present; the pre-branch wording of that bullet is absent |
| `## Test Isolation Checks` | scan bullet | present, last |

Main's #1097 lines (concurrent-review merge text and guard, concurrent and light checkpoints, the concurrent-review join, the three contract-test bullets, and the `Phase 0 baseline` coverage sentence) are present in the same copies.

## Test-file assertions

Logical line count of `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`: 571 (at or below 800; below the 700 advisory tier).

| Assertion | Result |
|---|---|
| `test_brief_test_isolation_states_parallel_gates` holds the `Invoke-PoshQCLeakScan` token | PASS (1 occurrence) |
| `test_brief_passages_state_parallel_gate_facts` holds the scan phrases | PASS (2 occurrences) |
| `test_brief_passages_state_parallel_gate_facts` holds the `fix_all` entry | PASS (1 occurrence) |
| `test_brief_ci_section_names_jobs_and_required_contexts` holds the leak-scan token | PASS (1 occurrence) |
| main's `Phase 0 baseline` assertion (replacing `no earlier figure is compared`) | PASS (present; the replaced literal is absent) |
| `test_brief_copies_are_byte_identical` | PASS (defined once) |
| each `def test_` name occurs once | PASS (21 names, 0 duplicates) |

## Wording-suite tokens

Only the class sweep (`SweepToken`, whose `SweepRoot` holds the skill folders) reads the brief copies; every other list governs named rows of other surfaces. The `planning-contract-wording` required tokens are read from their own section of the merged brief.

| Suite | List | Token | Result |
|---|---|---|---|
| parallel-gate-wording | forbidden:ContractForbidden | `no test suite runs` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:ContractForbidden | `no earlier figure` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:QaGateForbidden | `Targeted runs are allowed` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:PowerShellQaGateForbidden | `run_poshqc_test` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:PythonQaGateForbidden | `poetry run pytest --cov` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:ReviewForbidden | `smallest relevant subset` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:ReviewCommandForbidden | `run_poshqc_test` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:ExecutorListForbidden | ``mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test`` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:CopilotPesterForbidden | `mcp_drmcopilotext_run_poshqc_test` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:CopilotFocusedForbidden | `-k slug_extraction` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:AuditForbidden | `Invoke-PoshQCTest` | PASS: list governs other surfaces only, not the brief; token occurs in branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `targeted Pester` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `targeted Pytest` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `targeted xUnit` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `targeted MSTest` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `targeted tests` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `run tests after each` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `relevant tests using` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `running tests frequently` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `smallest applicable subset` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `relevant tests pass` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `repro and regression test` | PASS: absent from branch-added brief text |
| parallel-gate-wording | forbidden:SweepToken | `Run the regression to confirm` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `repo-policy reading` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `phase0-instructions-read` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `captures policy reads` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `Phase 0 tasks that cover` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `Mandatory Policy & Research` | PASS: absent from branch-added brief text |
| planning-contract-wording | forbidden:surfaceForbidden | `Compliance & Context` | PASS: absent from branch-added brief text |
| planning-contract-wording | required:MERGE-GUARD (Hook Execution Context) | `enforce-epic-merge-gate-review.ps1` | PASS: present in merged section |
| planning-contract-wording | required:MERGE-GUARD (Hook Execution Context) | `REVIEW_GATE_NOT_PASSED` | PASS: present in merged section |
| planning-contract-wording | required:MERGE-TEXT (Command-Text Restrictions) | `REVIEW_GATE_HEAD_UNRESOLVED` | PASS: present in merged section |
| planning-contract-wording | required:MERGE-TEXT (Command-Text Restrictions) | `git commit -F` | PASS: present in merged section |
| planning-contract-wording | required:JOIN (CI Shape and Required Checks) | `review_mode` | PASS: present in merged section |
| planning-contract-wording | required:JOIN (CI Shape and Required Checks) | `merge_status: ci_green` | PASS: present in merged section |
| planning-contract-wording | required:CHECKPOINT-ROUTE (MCP Surfaces Run the Installed Extension) | `--require-complete` | PASS: present in merged section |
| planning-contract-wording | required:CONCURRENT-CONTRACT-TEST (Contract Tests That Pin Mirrored Files) | `concurrent-review-skill-contract.Tests.ps1` | PASS: present in merged section |
| planning-contract-wording | required:LIGHT-ROUTE (MCP Surfaces Run the Installed Extension) | `invariant 8` | PASS: present in merged section |
| planning-contract-wording | required:LIGHT-CONTRACT-TEST (Contract Tests That Pin Mirrored Files) | `light-remediation-skill-contract.Tests.ps1` | PASS: present in merged section |

Totals: 39 rows, 0 conflicts. No branch-added text was edited, and no text of `main` or of an `atomic-plan-contract` copy was edited.
