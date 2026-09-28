# [P12-T13] Deny-preservation audit

Timestamp: 2026-09-07T16-11

Command:

```
mcp__drm-copilot__run_poshqc_test
  workspace_root = C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a478b73e41951af31
  scan_folders   = ["tests/scripts/claude-hooks", "tests/scripts/codex-hooks"]
```

EXIT_CODE: 2 (folder-wide; decomposed below)

TOOLCHAIN_SUBSTITUTION: `pwsh`, `powershell`, and `cmd` are not invocable in this session from any
context, so the suites could not be run through `Invoke-Pester -Path <suite>`. They were run through
`mcp__drm-copilot__run_poshqc_test` scoped by `scan_folders` to the two hook test folders, and every
per-case status below was read from `artifacts/pester/pester-junit.xml`.

Source of the audit list: the deny-preservation acceptance criterion in
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md`
lines 1488 to 1493 (`**No existing denial is weakened.**`).

## Output Summary

Every existing denial assertion named in the spec's deny-preservation section is recorded below with
its observed result. **All of them pass**, with one exception that is a pre-existing failure unrelated
to this change and is decomposed in section 6.

**The only two assertions whose expected decision changed are the two named in [P1-T12]**: the `It`
called `denies a message-body payload that merely contains the staging literal` at
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`,
and the identically named `It` at
`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`.
No third assertion reversed. This is stated in section 5 with its supporting evidence.

| Named group | Suite(s) | Result |
| --- | --- | --- |
| Existing Claude gate suite denials (spec: lines 112–149) | `enforce-orchestration-preimplementation-gate.Tests.ps1` | 35 tests, **0 failures** |
| Codex `Test-ImplementationCommand` classification table (spec: lines 348–358) | `legacy-codex-hook-contracts.Tests.ps1` | 43 tests, **0 failures** |
| #539 D4 rows 14a–14d chained relocating denials, Claude | `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | 59 tests, **0 failures** |
| #539 D4 rows 14a–14d chained relocating denials, Codex | `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | 59 tests, **0 failures** |
| Absolute-path suite, Claude | `enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 tests, **0 failures** |
| Absolute-path suite, Codex | `codex-preimplementation-gate-absolute-paths.Tests.ps1` | 35 tests, **0 failures** |
| Existing pr-author suites | four suites, see section 4 | 64 tests, **1 failure — pre-existing, see section 6** |

## 1. Existing Claude gate suite denials

`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` — **35 tests, 0
failures, 0 errors**. The denial assertions in the range the spec cites, with their observed results:

| `It` | Denial asserted | Observed |
| --- | --- | --- |
| `blocks implementation writes when route metadata and lifecycle readiness are absent (generalized message)` | `deny` with `PREIMPLEMENTATION_GATE_BLOCKED` | **Passed** |
| `blocks implementation command payloads before readiness (generalized message)` | `deny` for `poetry run pytest tests/scripts/dev_tools/test_validate_orchestrator_state.py` | **Passed** |
| `blocks staging and commit command payloads before readiness` | `deny` for both `git add .` and `git commit -m "test"` | **Passed** |
| `blocks formatter and test command payloads before readiness` | `deny` for `poetry run black … --check`, for `npm --prefix extensions/drm-copilot run test:unit -- --coverage`, and for `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-hooks"` | **Passed** |
| `blocks implementation delegation payloads before readiness (generalized message)` | `deny` on the delegation branch | **Passed** |
| `denies unparseable top-level JSON instead of throwing (exit 1 is non-blocking)` | `deny` on malformed input | **Passed** |
| `blocks an implementation write when the resolved checkpoint is malformed JSON` | `deny` | **Passed** |
| `blocks an implementation write when the checkpoint omits the feature folder` | `deny` | **Passed** |

The third and fourth rows are the load-bearing ones for this change: they assert that `git add .`,
`git commit -m "test"`, the three formatter and test invocations, and in particular the
`pwsh -NoProfile -Command` wrapper form all still deny after the masked-trigger model landed. The
`pwsh` case is the same form as acceptance case AT-6 and is the fail-open canary the specification
names.

No `It` in this suite was modified by this change: the suite does not appear in the [P12-T1]
enumeration.

## 2. Codex `Test-ImplementationCommand` classification table

`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` — **43 tests, 0 failures, 0
errors**. The `-ForEach` classification table the spec cites, one case per row:

| Label | Command | Expected | Observed |
| --- | --- | --- | --- |
| an empty command | `   ` | `$false` | **Passed** |
| an apply_patch add of a script | `*** Add File: scripts/a.ps1` | `$true` | **Passed** |
| an apply_patch add of documentation | `*** Add File: docs/features/active/x/spec.md` | `$false` | **Passed** |
| an apply_patch rename onto a script | `*** Move to: scripts/b.ps1` | `$true` | **Passed** |
| **a git commit** | **`git commit -m "wip"`** | **`$true`** | **Passed** |
| a pytest run | `poetry run pytest` | `$true` | **Passed** |
| an unrelated command | `echo hello` | `$false` | **Passed** |

The `git commit -m "wip"` row is called out by name in the spec's criterion. It returns `$true` after
the change, unmodified. This is the case that would have regressed if the masking model had been
applied indiscriminately: the message body `"wip"` is a quoted span and is masked, but the
`git commit` invocation itself is in the executing portion of the segment and still classifies.

The same suite's `denies an implementation command when the checkpoint is not ready` case also
passes, so the classification reaches the decision.

No `It` in this suite changed its expected decision. The suite appears in the [P12-T1] enumeration
because [P4-T13] appended the two parser siblings to the `$script:SharedModuleNames` array on a single
line; that is a registration edit and not an assertion edit.

## 3. #539 D4 rows 14a–14d chained relocating denials, and the rest of the D4 table

Both CommandExemption suites report **59 tests, 0 failures, 0 errors**. The four rows the spec names,
plus the surrounding D4 rows, all pass on both sides:

| D4 row | `It` (identical on both sides) | Observed, Claude | Observed, Codex |
| --- | --- | --- | --- |
| 14a | `denies D4 row 14a - an environment-style prefix relocating the pathspec base` | **Passed** | **Passed** |
| 14b | `denies D4 row 14b - a directory-relocating option before the subcommand` | **Passed** | **Passed** |
| 14c | `denies D4 row 14c - a git-dir option before the subcommand` | **Passed** | **Passed** |
| 14d | `denies D4 row 14d - a work-tree option before the subcommand` | **Passed** | **Passed** |

The remaining D4 denial rows in the same suites also pass unmodified on both sides: rows 1, 2a–2e,
3a–3b, 4, 5a–5g, 6a–6b, 7, 8, 9a–9e, 10, 11, 12a–12d, 13a–13b, 15a–15c, 16a–16c, 17, and 19 — 45
named denial cases per side. Every one reports **Passed**.

The eight allow-side D4 cases in the same suites also pass unmodified on both sides, so the exemption
layer neither widened nor narrowed: `allows staging an epic document under the epics tree`,
`allows staging a parallel manifest and its kickoff in one two-operand invocation`,
`allows a quoted operand under the active feature tree`,
`allows a backslash-spelled operand after separator normalization (D4 row 18)`,
`allows staging a kickoff markdown file under the orchestration artifacts tree`,
`allows the pathspec-bearing integration form with a message option and a double-dash separator`,
`allows a chained two-segment line whose every segment is independently exempt`, and
`allows staging a lifecycle record under the potential feature tree`.

## 4. The absolute-path suites

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | **0** | 0 |
| `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1` | 35 | **0** | 0 |

Named denial cases observed passing in both suites include
`denies an absolute path whose documentation prefix differs only in letter case`,
`denies a synthetic absolute path ending in a orchestration JSON whose name is not one of the seven literals`,
`denies a synthetic absolute path ending in a checkpoint-named JSON with no preceding artifacts/orchestration segment`, and
`denies a synthetic absolute path ending in a checkpoint name reached only through a parent-directory hop`.
The paired allow case `allows an absolute checkpoint path whose literal differs only in letter case`
also passes in both.

Neither suite appears in the [P12-T1] enumeration, so neither was modified.

## 5. The existing pr-author suites

| Suite | Tests | Failures | Errors |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | 43 | **1 — see section 6** | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.Payload.Tests.ps1` | 9 | **0** | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.OrchestratorStatePreflight.Tests.ps1` | 3 | **0** | 0 |
| `tests/scripts/claude-hooks/enforce-pr-author-skill.epic-base-branch.Tests.ps1` | 9 | **0** | 0 |

Named denial assertions observed passing in `enforce-pr-author-skill.Tests.ps1`:

| `It` | Observed |
| --- | --- |
| `denies an empty payload as an envelope anomaly (fail closed)` | Passed |
| `denies unparseable JSON instead of throwing (exit 1 is non-blocking)` | Passed |
| `blocks gh pr create --body "inline string"` | Passed |
| `blocks gh pr create --body='inline' (equals-sign form)` | Passed |
| `blocks gh pr edit --body "inline text" (no --body-file)` | Passed |
| `blocks gh pr edit --body='inline' (equals-sign form, no --body-file)` | Passed |
| `blocks gh pr create with no body flags` | Passed |
| `blocks gh pr create --title foo with no body flags` | Passed |
| `blocks with PR_AUTHOR_RECEIPT_MISSING when the receipt read seam returns null` | Passed |
| `blocks with PR_AUTHOR_RECEIPT_STALE when created_at is not strictly newer than the context last-write` | Passed |
| `blocks gh pr create with no body flags regardless of context artifact` | Passed |

Named allow assertions in the same suite, observed passing, which are the ones a fail-closed
over-correction would have broken:

`allows gh pr edit --title "x" (no body flag remains allowed)`, `allows gh pr edit --add-label bug (no body flag)`,
`allows gh pr view 13`, `allows gh pr list`, `allows gh pr merge`, `allows gh pr checkout 13`,
`allows gh issue create (not guarded by this hook)`, `allows when all six receipt checks pass`, and
`allows when JSON has no command field`.

All nine `Payload` cases pass, including `denies a nested gh pr create carrying an inline --body`,
`allows a nested Bash command outside the gate scope`, and
`allows a well-formed tool_input that carries no command property (scope filter)`.

All three `OrchestratorStatePreflight` cases pass, including
`blocks gh pr create --body-file end-to-end in a real pwsh process (exit 0, deny, ORCHESTRATOR_STATE_PREFLIGHT_FAILED)`.

All nine `epic-base-branch` cases pass, including `denies when --base is absent from the command text`
and `denies EPIC_BASE_BRANCH_MISMATCH end-to-end when epic_mode is true and --base is missing`, and
the allow-side `allows when the checkpoint has epic_mode: false` and
`allows a non-create command regardless of epic_mode (gh pr edit is out of scope)`.

## 6. The only two changed expected decisions, and the one pre-existing failure

### The two changed expected decisions

Exactly two assertions in the whole change reverse their expected decision, and they are the two
named in [P1-T12] at
`evidence/regression-testing/intended-assertion-reversal.2026-09-07T11-52.md`:

| # | File | `It` name (unchanged) | Before | After |
| --- | --- | --- | --- | --- |
| 1 | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1` | `denies a message-body payload that merely contains the staging literal` | `deny` | `allow` |
| 2 | `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1` | `denies a message-body payload that merely contains the staging literal` | `deny` | `allow` |

Both report **Passed** in this run. Both are paired in their own suite with the new sibling `It`
`denies the same heredoc body when it feeds a shell wrapper instead of a file`, which also reports
**Passed** on both sides; that sibling is what keeps the reversal from being a fail-open change,
because it establishes that the same body still denies when it is actually executed.

Supporting evidence that no third assertion reversed: the [P12-T1] enumeration lists only three
existing test files as modified — `enforce-orchestration-preimplementation-gate.CommandExemption.Tests.ps1`,
`enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, and
`legacy-codex-hook-contracts.Tests.ps1`. The third is a registration edit to a single line of the
`$script:SharedModuleNames` array and contains no assertion change, as recorded in section 2. Every
other file in group 4 of that enumeration has status `A`, meaning it is a new file added by this
change and therefore contains no pre-existing assertion that could have been reversed. The two
suites named in this table are therefore the only files in the change that could carry a reversal,
and [P1-T8], [P1-T10], and [P1-T12] together establish that each carries exactly one.

### The pre-existing failure

`tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` reports one failure:

```
enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists
```

This is **not** a deny-preservation failure and is **not** caused by this change. Confirmed cause: the
case does not mock `Get-PrAuthorCheckpointContent`, so it reads this run's real orchestrator-state
checkpoint, which carries `epic_mode: true`, while the fixture command carries no `--base`. The hook
therefore denies, correctly, under the epic-base-branch rule that
`enforce-pr-author-skill.epic-base-branch.ps1` enforces. The failure is an ambient-state artifact of
running the suite inside a live epic orchestration, is documented as such in the execution
delegation, and is not a member of the [P1-T13] known-red inventory.

It is an **allow-side** case, not a denial, so even on the reading that it were in scope it could not
establish a weakened denial: it fails because the hook denied where the fixture expected an allow,
which is the fail-closed direction.

### Folder-wide exit-code decomposition

The MCP runner returned exit code 2 over the two scanned folders. Totals: **2272 tests, 2 failures, 0
errors** across 94 suites. The two failures are the one above and
`tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 :: allows every registered handler for every tool name its own matcher admits`,
which is ambient-state driven by this worktree's epic checkpoint. Neither is a denial assertion and
neither is a member of the known-red inventory. Every other assertion named in this audit is in the
Passed set.
