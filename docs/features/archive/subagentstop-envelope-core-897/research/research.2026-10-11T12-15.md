# Research: SubagentStop envelope core helper and inline command (issue #897, epic child E1)

- Timestamp: 2026-10-11T12-15
- Feature folder: `docs/features/active/subagentstop-envelope-core-897`
- Epic: `docs/features/epics/subagentstop-envelope/epic.md` (epic issue #904), child E1, band C4
- Primary evidence: `evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` (live run, Claude Code 2.1.296)
- Scope of this document: the contract E2, E3 and E4 consume (`Read-SubagentStopEnvelope`, `Exit-SubagentStopBlock`), the inline SubagentStop command at `.claude/settings.json:218`, mirrors, tests, and coverage. No production code was changed.

## R1. Prior evidence (#786 / PR #881 and #787 / PR #856)

### What #786 measured

- #786 (PR #881) did not run Claude Code. Its "fail-closed proofs" are in-process Pester runs through the `&` route plus code inspection. Example: `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/other/fail-closed-proof.H7.md:7` records that the hook "threw the RESOLVER_IMPORT_FAILED block raised by Write-Error under $ErrorActionPreference = 'Stop' instead of exiting 2; neither file contains an exit 2 statement", classified `PROOF_RESULT: FAIL-OPEN` (`:21`).
- The exit-code rule came from vendor documentation read during #786 research: `spec.md:213` "exit 2 blocks with stderr as the reason on both surfaces for PreToolUse and SubagentStop; other non-zero exits are non-blocking", and decision D1 (`spec.md:50`) "Dependency-failure blocks on SubagentStop use exit 2 with the reason on stderr on both surfaces. Existing exit-1 SubagentStop block paths stay out of scope (NG1)." `spec.md:277` adds "a block that reaches the process only through `Write-Error` followed by `exit 1` is not blocking."
- Converted handlers: H7 and H8 in `validate-orchestrator-output.ps1` (`evidence/other/handler-conversions.md:11-12,26`). Six other handlers were exempted as already fail-closed (`:5-10`).
- #786 NG4 (`spec.md:42`) records that `validate-executor-output.ps1`, `validate-required-artifact-output.ps1` and `validate-task-researcher-output.ps1` are "present on disk but not registered" in `.claude/settings.json`; they are registered only in agent frontmatter, so the #786 guard tests do not enumerate them.

### What #787 measured

- #787 research (`docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787/research/research.2026-10-08T14-00.md:80-81`) lists the documented payload fields and states the transport claim as "inference from code plus documentation". `spec.md:45` puts the transport and exit-code defect out of scope. `research.2026-10-08T14-00.md:305` notes that a Layer 2 wave-barrier violation is unrecoverable, so once exit 2 blocks the message must instruct report-and-halt.

### Contradictions with the live differential

None. Both prior features relied on documentation and test-level proof. The live differential is the first runtime measurement and agrees with both: stdin JSON, `last_assistant_message`, no `output`, no `CLAUDE_HOOK_INPUT`, exit 1 does not block, exit 2 blocks with stderr fed back and re-entry carries `stop_hook_active: true` (`subagentstop-live-differential.2026-10-11T12-01.md:7-11,28-32`).

### The "uniform helper-based block" from #881

- File: `.claude/hooks/hook-dependency-guard.ps1` (114 lines; byte-identical at `.codex/hooks` and both bundle mirrors per `:19`).
- Functions:
  - `Add-HookDependencyFailure -Name <string> [-ErrorRecord <ErrorRecord>]` (`:24-46`)
  - `Test-HookDependencyFailure` returns `[bool]` (`:48-59`)
  - `Get-HookDependencyFailureReason -ReasonPrefix <string>` (`:61-77`)
  - `Get-HookDependencyFailureDecision -HookEvent PreToolUse|SubagentStop -ReasonPrefix <string>` (`:79-114`); for SubagentStop it returns `[pscustomobject]@{ ExitCode = 2; Reason = $reason }` (`:104-106`).
- The helper returns a result; it does not write or exit. Each hook writes and exits inline in its tail, for example `validate-orchestrator-output.ps1:456-458`:
  `if ($script:HookDependencyGuardLoadFailed) { [Console]::Error.WriteLine('...'); exit 2 }` and `if ($null -ne $dependencyDecision) { [Console]::Error.WriteLine($dependencyDecision.Reason); exit $dependencyDecision.ExitCode }`.

### Existing stdin readers and exit-2 paths the new helper must align with

| Existing code | Behavior | Consequence for E1 |
| --- | --- | --- |
| `.claude/lib/hook-payload/HookPayload.psm1:148-224` `Read-ClaudeHookRawPayload` (#501, PreToolUse) | stdin behind an `[Console]::IsInputRedirected` probe, then falls back to `CLAUDE_HOOK_INPUT` and `CLAUDE_TOOL_INPUT` (`:185-191`) | Not reusable as-is: the env fallback contradicts the epic rule "No reads of `CLAUDE_HOOK_INPUT` for a SubagentStop decision" (`epic.md:86-87`). The module is 496 lines, so adding SubagentStop functions to it would exceed the 500-line cap. |
| `HookPayload.psm1:226-274` `ConvertFrom-ClaudeHookEnvelope` | BOM strip, CRLF normalize, typed `{IsValid, Value, Anomaly}` result | Align the result shape and anomaly-code style; do not import (see Shared design below). |
| `.claude/hooks/persist-session-id.ps1:131-154` `Read-HookPayload` (SessionStart) | Scriptblock seam `-ReadStandardInput`, env fallback | Precedent for a seam; env fallback not applicable. |
| `.codex/hooks/validate-feature-review-coverage.ps1:237-304` (Codex SubagentStop) | Unguarded `[Console]::In.ReadToEnd()`; empty or malformed input throws and exits 2 (`:239-246,302-303`); on `stop_hook_active` true it emits `continue=false` (`:217-223`) | Precedent for an unguarded stdin read and for fail-closed malformed input on SubagentStop. |
| `hook-dependency-guard.ps1:104-106` plus inline tails | `{ExitCode=2; Reason}` then `[Console]::Error.WriteLine` and `exit 2` | `Exit-SubagentStopBlock` must have the same process effect. The S1 shape check requires the dependency tail to stay inline (see R5), so the new function replaces only the final `Write-Error ...; exit 1` of each validator. |

## R2. Official documentation (verbatim)

Source: https://code.claude.com/docs/en/hooks, fetched 2026-10-11.

- Transport: "Command hooks receive JSON data via stdin and communicate results through exit codes, stdout, and stderr." and "For command hooks, input arrives on stdin."
- SubagentStop input: "In addition to the common input fields, SubagentStop hooks receive `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, and `last_assistant_message`. The `agent_type` field is the value used for matcher filtering. ... The `last_assistant_message` field contains the text content of the subagent's final response, so hooks can access it without parsing the transcript file."
- Exit codes: "**Success**: your hook exits 0. ..."; "**Blocking error**: your hook exits 2. On events that can block, Claude Code stops the action."; "**Non-blocking error**: your hook exits with any other code, or fails in some other way, such as not starting or printing invalid JSON. The action goes ahead, ..."
- Exit 2 table row: "| `SubagentStop` | Yes | Prevents the subagent from stopping |". Preceding text: "The message that comes with the block is your hook's stderr. If your hook also printed JSON that makes a blocking decision, Claude Code uses that decision's reason instead."
- Feedback to the subagent: "Returning `decision: "block"` with a `reason` keeps the subagent running and delivers `reason` to the subagent as its next instruction. A hook that blocks by exiting 2 delivers its stderr message the same way."
- JSON alternative (Stop decision control, which SubagentStop shares): "`decision` | `"block"` prevents Claude from stopping. Omit to allow Claude to stop"; "`reason` | Required when `decision` is `"block"`. Tells Claude why it should continue".
- Loop guidance: "The `stop_hook_active` field is `true` when Claude Code is already continuing as a result of a stop hook. Check this value or process the transcript to avoid blocking on a condition that will never resolve." and (Stop input) "Claude Code applies an 8-consecutive-continuation cap: after stop hooks have continued the turn eight times in a row, Claude Code overrides the next block and ends the turn." The cap is stated in the Stop section; the page does not state explicitly that it applies to SubagentStop (unverified).
- Matcher: "Runs when a Claude Code subagent has finished responding. Matches on agent type, same values as SubagentStart." Matcher table: "Only letters, digits, `_`, `-`, spaces, `,`, and `|` | Exact string, or list of exact strings separated by `|` or `,` ... `code-reviewer` matches only that agent type". So the matcher at `settings.json:214` is an exact-name list; `orchestrator` does not match `epic-orchestrator` or `parallel-orchestrator`.
- Empty `agent_type`: "SubagentStop fires when one of those [internal agents] finishes too. For those events, `agent_type` is the agent name the session itself runs as, such as one set with `--agent` ... and an empty string when the session runs without one." and "A `matcher` that names agent types doesn't match an empty `agent_type`."
- stdout: "For most events, Claude Code writes stdout to the debug log and doesn't show it in the transcript." SubagentStop is not among the listed exceptions.
- `onFailure: "block"` has no effect here: "**`Stop`, `SubagentStop`, `TaskCompleted`, and `TeammateIdle` hooks**: exit code 2 on these events sends Claude back to keep working, and Claude can't repair a hook that won't run".
- Handback caveat: "On Claude Code v2.1.271 or later, a subagent that runs with the `SubagentHandback` tool delivers its report through that tool before it stops. The `last_assistant_message` field then holds the subagent's closing text, if any, which is not the delivered report." No file in the repository references `SubagentHandback` (grep, 0 matches).

Subagent frontmatter (https://code.claude.com/docs/en/sub-agents): "When the agent is invoked as a subagent, `Stop` hooks in frontmatter are automatically converted to `SubagentStop` events." and settings hooks "all apply inside subagents". The agents in this repository declare `SubagentStop` (not `Stop`) in frontmatter; whether that key fires was not verified.

Differences from the live capture: none in substance. The capture observed additional root keys (`prompt_id`, `effort`, `background_tasks`, `session_crons`) consistent with the docs. The docs say exit-2 stderr reaches the subagent; the capture confirms it (the subagent obeyed the stderr instruction).

## R3. The inline SubagentStop command

### Exact text (`.claude/settings.json:212-219`, identical in the bundle at the same lines)

Matcher (`:214`):

```text
atomic-planner|atomic-executor|feature-review|task-researcher|prd-feature|staged-review|epic-review|status-updater|python-typed-engineer|powershell-typed-engineer|csharp-typed-engineer|typescript-engineer|orchestrator|epic-orchestrator|epic-planner
```

Command (`:218`, JSON-unescaped):

```text
pwsh -NoProfile -Command "$input = $env:CLAUDE_HOOK_INPUT | ConvertFrom-Json; $output = $input.output; if (-not ($output -match '(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)')) { Write-Error 'Subagent stopped without required completion artifact path'; exit 1 }; exit 0"
```

The same group also carries `validate-discovery-artifact-gate.ps1` (`:220-223`).

Regex: `(plan-path|research-path|review-artifact|PREFLIGHT|evidence/)`. PowerShell `-match` is case-insensitive, so `PREFLIGHT` also matches `preflight` and `evidence/` matches any mention of an evidence path; the gate is over-permissive as well as transport-broken.

Current runtime effect (inferred from code plus the live capture, not observed for this command): `CLAUDE_HOOK_INPUT` is unset, so `$output` is null, the `if` condition is true, and the command exits 1 on every matched stop. Exit 1 is non-blocking, so the gate has never blocked. The command also reassigns the `$input` automatic variable.

### Per-agent analysis

Frontmatter hooks are cited from the agent file; "settings" means an additional dedicated group in `.claude/settings.json`.

| # | Agent | (a) Final-report contract | (b) Token always present? | (c) Existing dedicated SubagentStop hooks | (d) Recommendation |
| --- | --- | --- | --- | --- | --- |
| 1 | atomic-planner | `.claude/agents/atomic-planner.md:58-66` (bounded record ending with `PREFLIGHT:`; "Return the plan path and final preflight signal"); skill `atomic-plan-contract` | Yes (`PREFLIGHT`, `plan-path`) | frontmatter `validate-planner-output.ps1` (`atomic-planner.md:18-23`); settings `:235-243`. It requires `plan-path`, an exact preflight signal, and an existing plan file (`validate-planner-output.ps1:69,372-386`) | Drop. Correct but redundant with a stricter validator. |
| 2 | atomic-executor | `atomic-executor.md:85-90` (preflight returns `PREFLIGHT: ...`), `:121-128` (completion report) | Yes when its own validator passes: `validate-executor-output.ps1:11,66,201-211` requires `plan-path` | frontmatter `validate-executor-output.ps1` (`atomic-executor.md:31-36`) | Drop. Redundant. |
| 3 | feature-review | `feature-review.md:45-53`: `policy-audit-path:`, `code-review-path:`, `feature-audit-path:`, optional `remediation-inputs-path:` | No. None of these contains a pattern token; `review-artifact` is not part of the contract | frontmatter `validate-feature-review-coverage.ps1` (`feature-review.md:17-22`); settings `:226-233` | Drop. Pattern is wrong; a correct return would be refused. |
| 4 | task-researcher | `task-researcher.md:26-31`; `research-path:` required by `validate-task-researcher-output.ps1:45,249-266` | Yes (`research-path`) | frontmatter `validate-task-researcher-output.ps1` (`task-researcher.md:14-19`) | Drop. Redundant. |
| 5 | prd-feature | `prd-feature.md:34-40`: `spec-path:`, `user-story-path:`, and `research-path:` only "when numeric acceptance criteria are present" | No (absent in the non-numeric case) | frontmatter `validate-required-artifact-output.ps1` (spec-path, user-story-path) and `validate-prd-feature-output.ps1` (`prd-feature.md:13-20`); settings `:244-251` | Drop. Pattern is wrong for the common case. |
| 6 | staged-review | `staged-review.md:30-34`: `staged-review-path:` | No | frontmatter `validate-required-artifact-output.ps1` (`staged-review.md:14-19`) | Drop. Pattern is wrong. |
| 7 | epic-review | `epic-review.md:29-33`: `epic-audit-path:` | No | frontmatter `validate-required-artifact-output.ps1` (`epic-review.md:13-18`) | Drop. Pattern is wrong. |
| 8 | status-updater | `status-updater.md:30-34`: `status-sync-path:` | No | frontmatter `validate-required-artifact-output.ps1` (`status-updater.md:14-19`) | Drop. Pattern is wrong. |
| 9 | python-typed-engineer | No final-token contract; qa-gate skills `.claude/skills/{python,powershell,csharp}-qa-gate/SKILL.md` contain no `evidence/` or `-path:` token (grep count 0) | No | none | Drop. |
| 10 | powershell-typed-engineer | `powershell-typed-engineer.md:63-72` stop conditions return without artifacts; no frontmatter hooks (`:1-24`) | No | none | Drop. |
| 11 | csharp-typed-engineer | Same as row 9 | No | none | Drop. |
| 12 | typescript-engineer | Same as row 9 | No | none | Drop. |
| 13 | orchestrator | `orchestrator.md:187-194` (no token requirement). Preparation mode reports `plan-path` (`.claude/skills/orchestrate/SKILL.md:142`). Epic mode: "your final report must be exactly this eight-field shape and nothing else: `issue_num`, `feature_folder`, `merge_status`, `pr_number`, `merge_commit_sha`, `blocked_reason`, `branch_name`, `worktree_path`" (`SKILL.md:144-148`) | No. The eight-field epic return contains no pattern token, so every epic child return would be refused | frontmatter `validate-orchestrator-output.ps1` (`orchestrator.md:37-42`); settings `:262-269` | Drop. |
| 14 | epic-orchestrator | `epic-orchestrator.md:158-168` (no token requirement); long-running with background children, so interim stops occur | No | frontmatter `validate-orchestrator-output.ps1 -CheckpointPath ... -ArtifactType epic-orchestrator-state` (`epic-orchestrator.md:24-29`); settings `:271-278` | Drop. |
| 15 | epic-planner | `epic-planner.md:123-124` "The final report lists each feature's `plan-path:`"; the epic-worthiness early stop (`:70-77`) reports a finding with no token | Only on successful completion | none (`epic-planner.md:1-27`) | Drop (see rejected alternative below). |

Not matched by the inline matcher: `parallel-orchestrator` and `parallel-planner` (parallel-orchestrator has its own settings group `:280-287` and frontmatter `parallel-orchestrator.md:37-42`), `commit-message`, and `pr-author` (settings `:253-260`, frontmatter `pr-author.md:22-27`).

Additional risk if the inline gate were enabled with exit 2: a session started with `--agent orchestrator` (or `epic-planner`) would give internal agents (prompt suggestions, `/btw`) that `agent_type`, and the gate would refuse them. `claude-settings.Tests.ps1:55-57` keeps the `agent` settings key absent, which limits but does not remove this case.

Observation for E2-E4 (out of E1 scope): the validator for orchestrator, epic-orchestrator, parallel-orchestrator, feature-review, atomic-planner, prd-feature and pr-author is registered in both settings and agent frontmatter. If both fire, each validator runs twice per stop once exit 2 is live. The validators are read-only, so the effect is a duplicated reason, not a state change.

### Recommendation for the inline command

Delete the inline command object (`settings.json:216-219`) in both copies and keep the group, its matcher, and the `validate-discovery-artifact-gate.ps1` entry unchanged. Rationale:

1. For 11 of the 15 agents the pattern is wrong or not part of the contract, so an exit-2 gate would refuse correct returns and push subagents to fabricate tokens.
2. For atomic-planner, atomic-executor and task-researcher the dedicated validators already check the same token more strictly, including file existence.
3. For epic-planner the pattern holds only on success; refusing its worthiness-gate stop or an interim stop would be incorrect, and making the gate state-aware is a new validation rule, which the epic lists as a non-goal (`epic.md:72-73`).
4. Keeping the group matcher unchanged keeps `claude-settings.Tests.ps1:66-79` (eight worker names must appear) and the prd-feature broad-matcher assertions (`claude-settings.Tests.ps1:126-128`, `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:198-199`) green. No test depends on the inline command (grep for `INLINE` and for the command text returns only discovery helpers and the two settings files).

Rejected alternative: convert the inline command to a file-based hook that uses the new helper and narrow its matcher to `atomic-planner|atomic-executor|task-researcher|epic-planner`. It duplicates three stricter validators, is unsafe for epic-planner as described, and adds a registered hook that must satisfy guard tests S1-S6, B1-B4 (including a new reason-prefix entry at `hook-dependency-failure.Claude.Tests.ps1:71-102`), a mirror, and a manifest entry.

## R4. Bundled mirrors and parity tests

| Source | Mirror | Transform |
| --- | --- | --- |
| `.claude/hooks/*.ps1` | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/*.ps1` | Verbatim |
| `.claude/settings.json` | `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | Verbatim (both 295 lines; line 218 identical) |
| `.codex/hooks/*.ps1` | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/*.ps1` | Verbatim (not needed for E1) |

Enforcing tests:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` `test_bundled_claude_payload_contains_all_repo_runtime_contracts`: `rglob("*")` over repo `.claude/` (`:55-64`), minus local-only paths, asserts each file exists in the bundle with equal text.
- `tests/scripts/claude-runtime/claude-settings.Tests.ps1:107-114` and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:48`: canonical and bundled settings must be byte-identical.
- `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:199-214` (enumerates bundled `hooks/*.ps1` at `:88-93`) and `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:139-159` (enumerates every file in bundled `hooks/` at `:86-91`): every bundled hook must appear in some `pack-manifests/*.json` `paths` array. Pre-existing exceptions: `pr-author.md`, `enforce-completion-helpers.ps1`, `validate-pr-author-output.ps1` (`.test.ts:67-71`, `.py:52-58`).
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1:17-29` and `hook-imported-modules-no-stdout.Tests.ps1:30-54` check repository and mirror roots for every registered hook and its closure (registered hooks discovered from settings; `INLINE` excluded).

Required updates when E1 adds `.claude/hooks/subagentstop-envelope.ps1`:

1. Create the byte-identical bundle copy under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`.
2. Add `".claude/hooks/subagentstop-envelope.ps1"` to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (hook entries are at `:25-77`; `persist-session-id.ps1` is at `:67`, `validate-bash.ps1` at `:68`).
3. Do not register the helper in `settings.json`; it is dot-sourced, not a hook, so it does not enter B4's reason-prefix table.
4. No change to `config/poshqc-coverage.json`: its roots are directories (`.claude/hooks`, `.claude/lib`, ...; `:3-9`), so the new file is in the denominator automatically. No change to `config/poshqc-scan.json` (`tests/scripts` is already scanned, `:4`).
5. If `settings.json` changes, edit both copies identically.
6. No `.codex` copy unless a Codex hook dot-sources the helper (none does; `.codex/config.toml:236-251` registers only `.codex/hooks` scripts).

Constraints on consumers (E2-E4), from the guard tests:

- `HookGuardShape.Helpers.ps1:99-105` (S2): every direct dot-source in a registered hook must be in its own single-statement `try` whose `catch` calls `Add-HookDependencyFailure -Name '<leaf>'`. Each validator therefore needs `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }`, and B1 (`hook-dependency-failure.Claude.Tests.ps1:134-164`) will then fail that edge and expect exit 2 with a stderr reason naming it.
- `HookGuardShape.Helpers.ps1:35-55` (S1): the tail after the dot-source early return must keep the literal `[Console]::Error.WriteLine(...)`/`exit 2` and `exit $dependencyDecision.ExitCode` lines. `Exit-SubagentStopBlock` replaces only the final validation-failure exit.
- S4 (`hook-dependency-guard-completeness.Tests.ps1:51-58`): transitive edges must be covered or terminating, so the helper should import nothing.
- FR-11.2 (`HookGuardShape.Helpers.ps1:120-155`): closure files must not write to the success or warning streams; `[Console]::Error.WriteLine` is permitted.

Pre-existing gap noted, not in E1 scope: `.claude/hooks/validate-pr-author-output.ps1` is in no pack manifest, so a manifest-scoped push-down ships a settings registration for a hook file it does not deliver.

## R5. Testing conventions and the proposed seam

Location convention: hook tests live in `tests/scripts/claude-hooks/<hook>.Tests.ps1` (for example `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1`), library tests in `tests/scripts/claude-lib/<area>/`. The new suite belongs at `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1`.

Exemplars:

1. Pure-function tests by dot-sourcing the helper: `tests/scripts/claude-hooks/hook-dependency-guard.Tests.ps1:14-50` dot-sources `.claude/hooks/hook-dependency-guard.ps1` and calls the functions directly, resetting script-scope state in `finally`.
2. #501 stdin seam: `tests/scripts/claude-lib/hook-payload/HookPayload.Tests.ps1:30-136` drive `Read-ClaudeHookRawPayload` through `-ReadStandardInput { ... }` and `-TestStandardInputRedirected { $true }` scriptblock parameters; no process is spawned.
3. In-process entry-point (`&` route) with redirected console: `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1:104-124` (`Invoke-HookProcess`) and `tests/scripts/claude-hooks/enforce-epic-merge-gate.Coverage.Tests.ps1:25-42` call `[System.Console]::SetIn([System.IO.StringReader]::new($payload))` and `SetError([System.IO.StringWriter])`, invoke the script with `&`, read `$LASTEXITCODE`, and restore both in `finally`. A script-level `exit` inside an `&`-invoked script ends only that script and sets `$LASTEXITCODE`.

Seam recommendation for `Read-SubagentStopEnvelope`:

- Signature: `Read-SubagentStopEnvelope [-InputText <string>]` with `[AllowNull()][AllowEmptyString()]`. When `$PSBoundParameters.ContainsKey('InputText')`, parse that text (including an empty string). Otherwise read `[Console]::In.ReadToEnd()` inside `try`/`catch`, treating a read failure as empty input.
- No `[Console]::IsInputRedirected` probe. The Codex SubagentStop precedent reads stdin unguarded (`.codex/hooks/validate-feature-review-coverage.ps1:238`), a real SubagentStop always has stdin redirected, and per .NET semantics (not verified by a tool in this research) `IsInputRedirected` reports the OS handle and is not changed by `Console.SetIn`, so a probe would make `SetIn`-based entry-point tests depend on how the test host was launched. Cost: a manual run without redirected stdin waits for end-of-input; document this in the help text.
- No environment variable is read. This satisfies `epic.md:86-87` ("Any test seam is a parameter on the validator's pure entry point, not an environment variable").
- Validators (E2/E3) should expose the same parameter on their pure entry point (for example `-InputText` on `Invoke-<X>Validation`, replacing `-RawPayload $env:CLAUDE_HOOK_INPUT`) and pass it through.

Seam recommendation for `Exit-SubagentStopBlock -Message <string>`:

- Body: `[Console]::Error.WriteLine($Message)` then `exit 2`. Same effect as the existing tails.
- Testing: a direct call from a Pester `It` would execute `exit` in the test runner. Two in-process options, both without temporary files: (a) cover it through the `&` route over a checked-in fixture script under `tests/fixtures/` that dot-sources the helper and calls the function, capturing stderr with `SetError` and the code with `$LASTEXITCODE`; or (b) add a `[scriptblock] $ExitAction = { param($Code) exit $Code }` parameter that a test replaces. Option (a) keeps the production signature to the epic's single parameter and covers the real `exit 2` line. The plan should include an early task that verifies `exit` inside a function from a dot-sourced file, called from an `&`-invoked script, ends only that script and sets `$LASTEXITCODE` to 2 (this was not executed during research).
- `Mock` cannot intercept `exit`; spawning `pwsh` would be an external process in a unit test and its coverage would not be measured.

Temporary files: prohibited (`.claude/rules/general-unit-test.md`, "Creation and use of temporary files in tests is strictly prohibited."). All input is supplied through `-InputText` or `Console.SetIn`.

Coverage measurement for `.claude/hooks/*.ps1`:

- Command: `Invoke-PoshQCTest -Root <repo> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (or the `mcp__drm-copilot__run_poshqc_test` wrapper), as recorded in `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/final-pester-coverage.md:5`.
- Config: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` (CoverageGutters XML at `artifacts/pester/powershell-coverage.xml`, `CoveragePercentTarget = 0`); population from `config/poshqc-coverage.json:3-9`.
- Threshold: 85% line per changed file (`.claude/rules/quality-tiers.md`, `epic.md:16`); no branch gate for PowerShell.
- Baseline source: the most recent recorded run is `final-pester-coverage.md:11` ("Covered 87.07% / 0%. 25,713 analyzed Commands in 192 Files."). The new helper has no prior baseline; E1 should capture its own Phase 0 baseline. Memory notes indicate the MCP PoshQC wrapper returns no output body; record figures from the coverage XML or the self-hosted module run.

## R6. Behavior on empty, absent and malformed input

Current validator behavior: every validator treats an empty payload or invalid JSON as a block (for example `validate-orchestrator-output.ps1:350-358`, `validate-discovery-artifact-gate.ps1:211-220`, `validate-pr-author-output.ps1:96,105`), but the block exits 1, so it is fail-open in practice. The discovery gate is deliberately fail-open when no required-artifact declaration exists (`validate-discovery-artifact-gate.ps1:135-151,232-236`). Repository precedents for envelope anomalies are fail-closed: `HookPayload.psm1:30-34` ("an envelope-level anomaly is a deny") and the Codex SubagentStop hook (`.codex/hooks/validate-feature-review-coverage.ps1:33-36`, "Malformed input fails closed with exit 2"). `.claude/rules/` has no general SubagentStop fail-open rule.

Recommended return shape: always an object, never `$null` and never a throw.

| Field | Type | Meaning |
| --- | --- | --- |
| `IsValid` | bool | `$true` only for a JSON object with a string `last_assistant_message` |
| `Anomaly` | string or `$null` | One of the codes below |
| `Envelope` | object or `$null` | Parsed root when it is an object |
| `AssistantText` | string | `last_assistant_message`; `''` when invalid |
| `StopHookActive` | bool | Root `stop_hook_active` when it is a boolean, else `$false` |
| `AgentType` | string | Root `agent_type`, else `''` |
| `HookEventName` | string | Root `hook_event_name`, else `''` |

Anomaly codes and inputs:

| Input | IsValid | Anomaly |
| --- | --- | --- |
| Empty string, `$null`, or whitespace (after BOM strip) | false | `EmptyPayload` |
| Not parseable as JSON | false | `UnparseableJson` |
| JSON array, scalar, or `null` | false | `NonObjectEnvelope` |
| Object without `last_assistant_message` | false | `MissingAssistantMessage` |
| `last_assistant_message` is `null` | false | `NullAssistantMessage` |
| `last_assistant_message` is not a string (number, bool, object, array) | false | `NonStringAssistantMessage` |
| `last_assistant_message` is `""` | true | `$null` (validators already block on empty text) |

Also provide `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <code>` returning a distinct clause per code (the `HookPayload.psm1:58-64,87-111` pattern), so each validator writes `<PREFIX> payload anomaly - <clause>` without duplicating text.

Decision policy for the spec (consumed by E2-E4):

- The helper never exits. Validators decide.
- An invalid envelope blocks through `Exit-SubagentStopBlock` (fail closed). The live capture shows a real hook always receives a well-formed envelope (`subagentstop-live-differential.2026-10-11T12-01.md:7-8`), so this path is reached only by manual runs, tests, or a runtime contract change, which is the case fail-closed is meant to surface. The loop risk is bounded: the subagent cannot repair the envelope, and the documented continuation cap applies to Stop (applicability to SubagentStop is not stated explicitly).
- Re-entry (`StopHookActive` true): the helper surfaces the flag and `Exit-SubagentStopBlock` stays unconditional. Each validator states its policy. Conditions the subagent can repair (a missing path token or file) may block again; conditions it cannot repair (for example the Layer 2 wave-barrier history noted in #787 research `:305`) should block once with report-and-halt wording.
- Codex does not invoke `.claude/hooks` validators (`.codex/config.toml:236-251`), so the Codex envelope does not constrain this contract.
- `SubagentHandback` risk: if a future agent uses it, `last_assistant_message` may carry only closing text. Not used in this repository today; record as a known limit.

## R7. Python-free constraint and file sizes

No Python leg is needed. The helper, its tests and the settings change are PowerShell and JSON. Existing Python and TypeScript parity tests (R4) only read files; they are not enforcement legs and need no edits for this change.

Line counts of files E1 is expected to touch (counted with a line-anchored grep):

| File | Lines now | Expected change |
| --- | --- | --- |
| `.claude/settings.json` | 295 | about -4 (delete inline command object) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json` | 295 | same as above |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | 222 | +1 |
| `tests/scripts/claude-runtime/claude-settings.Tests.ps1` | 155 | small addition for a regression assertion |
| `.claude/hooks/subagentstop-envelope.ps1` and bundle copy | new | target well under 500 |
| `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` | new | under 500 |
| Optional fixture under `tests/fixtures/` for the `&`-route exit test | new | a few lines |

Referenced but not edited by E1: `hook-dependency-guard.ps1` (114), `HookPayload.psm1` (496, reason the helper is not added there), `validate-orchestrator-output.ps1` (466), `validate-feature-review-coverage.ps1` (477 per `epic.md:116-117`).

Do not edit `.claude/agents/epic-orchestrator.md` in E1: its SHA-256 is pinned in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169`. Its transport caveat (`epic-orchestrator.md:133-135`) and the matching comment in `enforce-epic-wave-barrier.ps1` belong to E2 with a re-baseline.

## Numeric Derivation Evidence

### Claim: the inline SubagentStop matcher lists fifteen agents

- Complete Family: every agent name in the matcher string at `.claude/settings.json:214`.
- Exhaustive Search Scope: the full matcher string at `.claude/settings.json:214` and all 24 agent definition files in `.claude/agents/*.md`.
- Inclusion Rules: a name is a member when it appears as one `|`-delimited element of the matcher (the docs evaluate such a matcher as a list of exact names).
- Exclusion Rules: substrings of other names do not count (for example `orchestrator` inside `epic-orchestrator` is a separate element only where it appears on its own).
- Primary Search Strategy or Query Expression: split the matcher string at `.claude/settings.json:214` on `|`.
- Primary Member Set: atomic-planner, atomic-executor, feature-review, task-researcher, prd-feature, staged-review, epic-review, status-updater, python-typed-engineer, powershell-typed-engineer, csharp-typed-engineer, typescript-engineer, orchestrator, epic-orchestrator, epic-planner.
- Primary Count: 15.
- Cross-check Search Strategy or Query Expression: enumerate `.claude/agents/*.md` (Glob, 24 files) and test each file's base name for exact membership in the matcher list; then confirm no matcher element lacks an agent file.
- Cross-check Member Set: in the matcher: atomic-executor, atomic-planner, csharp-typed-engineer, epic-orchestrator, epic-planner, epic-review, feature-review, orchestrator, powershell-typed-engineer, prd-feature, python-typed-engineer, staged-review, status-updater, task-researcher, typescript-engineer. Not in the matcher (9): commit-message, human-exception-runbook, legacy-parity-analyst, migration-coverage-reviewer, parallel-orchestrator, parallel-planner, pr-author, requirements-reconciler, runtime-characterization-analyst. Matcher elements without an agent file: none.
- Cross-check Count: 15 (24 - 9).
- Member-set Comparison: the normalized primary and cross-check sets are identical (same 15 names; order differs only). The count may be asserted. Spec acceptance criteria should name the agents rather than state a count where possible.

## Automation Feasibility

No human interaction is required for E1. The runtime measurement is complete (live differential, headless `claude -p`, scratch settings). Implementation, Pester tests, mirror copies, manifest edits and coverage runs are all unattended. If the spec wants a post-change confirmation that the deleted inline command no longer produces a hook-error notice, the same headless `claude -p --settings` method is automatable. The open epic decision about E1 and E3 sharing issue key #897 (`epic.md:139-143`) is a planning decision for the epic owner, not a manual step in E1.

## Recommendations for the Spec

1. Contract file: `.claude/hooks/subagentstop-envelope.ps1`, dot-sourced, import-free, no stdout writes, no environment reads; bundle copy byte-identical; add to `pack-manifests/core.json`. Not registered in `settings.json`.
2. `Read-SubagentStopEnvelope [-InputText <string>]`: parses `-InputText` when bound, else an unguarded `[Console]::In.ReadToEnd()` in try/catch; strips BOM and normalizes CRLF; returns `{IsValid, Anomaly, Envelope, AssistantText, StopHookActive, AgentType, HookEventName}` with anomaly codes `EmptyPayload`, `UnparseableJson`, `NonObjectEnvelope`, `MissingAssistantMessage`, `NullAssistantMessage`, `NonStringAssistantMessage`. Never throws, never exits.
3. `Get-SubagentStopEnvelopeAnomalyReason -Anomaly <code>`: one distinct clause per code.
4. `Exit-SubagentStopBlock -Message <text>`: `[Console]::Error.WriteLine($Message)` then `exit 2`. Consumers keep the S1 dependency tail inline and use this function only for the final validation-failure exit.
5. Consumer policy (E2-E4): invalid envelope blocks (fail closed); re-entry policy is per validator, with report-and-halt wording for unrepairable conditions; validator pure entry points take `-InputText` instead of `-RawPayload $env:CLAUDE_HOOK_INPUT`; each validator guards the helper dot-source with its own single-statement `try` recording `subagentstop-envelope.ps1`.
6. Inline command: delete the command object at `.claude/settings.json:216-219` in both copies; keep the group matcher and the discovery-gate entry. Record the per-agent table above in the spec. Add a regression assertion (for example in `claude-settings.Tests.ps1`) that no SubagentStop command in either settings copy contains `CLAUDE_HOOK_INPUT` or `exit 1`.
7. Tests: `tests/scripts/claude-hooks/subagentstop-envelope.Tests.ps1` covering every anomaly row, the valid case, the empty-string message, BOM/CRLF input, the stdin default via `Console.SetIn` with restore in `finally`, the anomaly reason map, and `Exit-SubagentStopBlock` through the `&` route over a checked-in fixture (stderr text and exit code 2). Include an early plan task that verifies function-level `exit` behavior under the `&` route. No temporary files; no child processes.
8. Gates: line coverage at or above 85% for the new helper; mirror parity (`test_push_down_claude_resource_contracts.py:89`), manifest completeness (TS and Python twins), settings parity (`claude-settings.Tests.ps1:107`), guard suites unchanged and green.
9. Do not edit `epic-orchestrator.md` or validator files in E1; those belong to E2-E4.
