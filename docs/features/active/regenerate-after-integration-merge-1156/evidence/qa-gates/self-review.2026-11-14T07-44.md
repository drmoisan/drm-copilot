# Self-Review — remediation cycle 2, [P2-T4]

Timestamp: 2026-11-14T07-44
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against git diff <merge base of origin/main and HEAD> HEAD (167 files changed, 14817 insertions, 49 deletions); the cycle 2 code delta outside the feature folder is 8 files (adapter and bundle copy, orchestrate skill and bundle copy, orchestrator-state rule and bundle copy, two test files; 71 insertions, 1 deletion) plus spec.md and evidence
EXIT_CODE: 0
Output Summary: every row PASS or N/A; no FAIL row. C2-1, C2-2, and C2-3 are closed. origin/main has not advanced past the branch (0 commits behind at 07:44 UTC); the working tree is clean. Rows unaffected by this cycle keep the evidence of `self-review.2026-11-14T05-53.md` and are restated with current figures.

## Remediation findings

| Item | Status | Evidence |
|---|---|---|
| C2-1 batch path screen | PASS | `Get-RegenerationProcessStartSpec` refuses a batch `ResolvedPath` matching `["&|<>^%]` after the ComSpec check, message holds `batch file path` and `cmd.exe metacharacter`; one `.DESCRIPTION` line; 7 path rows and the parentheses case pass (`task-check.P1-T1.2026-11-14T06-33.md`); real-process probe `other/process-start-probe.2026-11-14T06-36.md`: `&` and `%` folders Started False, no marker; `p (x86) q` Started True, exit 0, marker present |
| C2-2 execution-rule sentence | PASS | Sentence added at the end of item 2 of `## Merge-Conflict Remediation` and of the `Config rules,` paragraph; pinned by `states the start-time resolution and batch refusal in <Scope> of <Prefix><File>` (4 rows, 0 failed); spec `### Config file` command bullet names the batch-path refusal, 539 lines before and after |
| C2-3 refusal table | PASS | `throws for a batch argument holding <Label>` has 11 rows (space, double quote, `&`, `%`, `^`, `(`, `)`, `<`, `>`, pipe, tab); each refused character has its own row, so removing it from the class fails that row |
| Mirror equality of the three edited pairs | PASS | SHA-256 equal: adapter 957247bc...; orchestrate skill f86eb6fc...; orchestrator-state rule 051e0b00... (`task-check.P1-T1`, `task-check.P1-T2`); push-down contract tests pass in pytest; Codex generator `--check` exit 0 |
| Adapter line count | PASS | 792 logical lines (cap 796, hard limit 800); advisory 700-line Warning tier unchanged in kind |
| No-Python guard and allowlist unchanged | PASS | Neither file in the cycle diff; `enforcement-hooks-no-python-invocation.Tests.ps1` 35/0 in both Pester gates; no new `&` invocation |
| Jest | N/A | No TypeScript change in this cycle |

## Policy audit template

| Item | Status | Evidence |
|---|---|---|
| PowerShell baseline / post-change coverage | PASS | `Phase 0 baseline` 95.94% (`qa-gates/pester-gate.2026-11-14T06-14.md`); final 95.94% (`qa-gates/pester-final.2026-11-14T07-38.md`) |
| Python baseline / post-change coverage | PASS | 97.11% / 94.37% -> 97.13% / 94.42% (`qa-gates/pytest-final.2026-11-14T07-43.md`); no Python change |
| TypeScript coverage | N/A | No TypeScript change |
| Bash and JSON rows | N/A | No bash or JSON file changed in this cycle |
| Independence | PASS | All suites pass in the eight-shard parallel gate twice; new rows call a pure function; leak scan 0 failures |
| Isolation | PASS | One behavior per It; one character per row |
| Fast execution | PASS | ProcessStart suite runs in about a second; no wait or sleep |
| Determinism | PASS | Literal forward-slash paths and a literal ComSpec; no PATH read, process start, file, or environment write in tests |
| Readability and maintainability | PASS | Row labels name the refused character; the contract test reports the scope and file |
| Baseline coverage documented | PASS | As above |
| No coverage regression | PASS | Repo-wide 95.94% = baseline; adapter 91.33% >= 91.28%; pytest totals above baseline |
| Changed files meet thresholds | PASS | Adapter 91.33% >= 85% |
| New code coverage | PASS | Both new adapter lines covered (ci 1 and 2, mi 0) |
| Comprehensive coverage | PASS | Every refused path and argument character has a row; allowed space and parentheses paths have cases. Observation (non-blocking): no case asserts that a non-batch path holding a metacharacter starts directly; the spec states the screen for batch paths only and the code returns for non-batch paths before the screen |
| Positive / negative / edge / error flows | PASS | Clean batch paths route through ComSpec; refused paths and arguments throw; space and parentheses paths kept as one item; the step wrapper returns Started false on the throw (probe) |
| Concurrency / state transitions | N/A | Pure function |
| Clear failure messages / AAA / document intent | PASS | Distinct messages for path and argument refusal; contract assertions use `-Because` with the literal |
| Avoid external dependencies / mocks / environment stability | PASS | No real process in tests; the Windows start is proven by the recorded probe only |
| Pre-submission review | PASS | This self-review |
| Clarify objective / read plans / document plan | PASS | remediation-inputs and remediation-plan of 2026-11-14T06-19; task-check evidence per task |
| Simplicity / reusability / extensibility / separation | PASS | One `if` block next to the existing argument screen; no helper, because the path class differs from the argument class |
| Cohesive modules / 800-line limit / no cycles | PASS | Adapter 792; test files 140 and 350 lines |
| Descriptive names / docs / comment why | PASS | Help line names the path rule; skill and rule state the start-time behavior |
| Formatting / linting / type checking | PASS | `qa-gates/powershell-final-qc.2026-11-14T07-22.md`: 0 differences, 0 findings, leak scan 0 failures; type check N/A |
| Testing / full toolchain loop / explicit reporting | PASS | `qa-gates/phase-gate.P1.2026-11-14T07-21.md` and the final gates, one clean pass each |
| Summarize / design choices / supporting docs / next steps | PASS | Commit messages per task; next step is the feature re-review |
| 3B PowerShell rules | PASS | Advanced function unchanged in shape; explicit throw |
| 3B PowerShell 7 compatibility | PASS | Unchanged |
| 3A Python / 3C Bash / 3D JSON | N/A | No such file changed |
| 4B Pester 6, organization, naming, PoshQC runner | PASS | Rows added to the mirrored suites; gates via Invoke-PoshQCParallelTest |
| Gaps and exceptions | PASS | No test skipped or removed; no existing assertion changed |
| Compliance verdict | PASS | Compliant; one non-blocking 700-line Warning (adapter 792) |

## Code review template

| Check | Status | Evidence |
|---|---|---|
| No secrets | PASS | None in the diff |
| No unsafe subprocess or command construction | PASS | A batch path or argument that cmd.exe would re-parse is refused before the start; the earlier gap (CR-3) is closed and proven by the probe |
| Input validation at boundaries | PASS | Path screen runs before any start |
| Error handling explicit | PASS | Message names the path |
| Configuration / path handling | PASS | Unchanged resolution route |
| Findings table | PASS | Warning (non-blocking): adapter 792 logical lines (advisory tier). Observation (non-blocking): see the comprehensive-coverage row |

## Feature audit template

| Item | Status | Evidence |
|---|---|---|
| AC source (full-feature: spec.md, user-story.md) | PASS | Checked criteria: spec.md 41, user-story.md 8, unchanged by this cycle; no criterion text changed; the 7 unchecked spec items are the Definition of Done list, unchanged |
| AC3 (command runs on the merged tree) on Windows batch files | PASS | Probe and the new rows |
| All other AC rows | PASS | Unchanged from `self-review.2026-11-14T05-53.md`; their suites pass in the final gates (Pester 24744/0, pytest 16729/0) |
| CI-only behavior | PASS | New rows use forward-slash literal paths without a drive letter; the contract suite reads committed text only |
