# Research: SubagentStop envelope for the artifact-gate validators (E3, issue #897)

- Timestamp: 2026-10-11T12-05
- Branch: `bug/subagentstop-envelope-artifact-gates-905` (based on `origin/epic/subagentstop-envelope-integration`)
- Mode: preparation only; no production code changed.
- Method: every claim below was read from the worktree with Read/Grep/Glob. No shell was available to this agent, so `git ls-remote`, `git fetch`, `git show` and `git log --grep` were not executed; substitutes are stated where used.

## 1. Upstream contract status (E1)

### 1.1 What was checked

- `origin/bug/subagentstop-envelope-core-897` exists as a local remote-tracking ref (`.git/refs/remotes/origin/bug/subagentstop-envelope-core-897`, value `811a35584855396da45cfa9983e8055cc04258ea`). This is the state at the last fetch, not a live `ls-remote`.
- E1's worktree is `.claude/worktrees/agent-a22ac7fe50b3907af` (`.git/worktrees/agent-a22ac7fe50b3907af/gitdir:1`, HEAD `refs/heads/bug/subagentstop-envelope-core-897`). Its working copy was read directly.

### 1.2 Findings

- E1 `spec.md` is the unfilled bug template (`docs/features/active/subagentstop-envelope-core-897/spec.md:1-100` in the E1 worktree); E1 `plan.2026-10-11T07-59.md` is also the unfilled template (`:15-40`). Neither defines the helper API yet.
- `.claude/hooks/subagentstop-envelope.ps1` does not exist in the E1 worktree (Glob returned no file).
- E1 has recorded a live differential (`evidence/other/subagentstop-live-differential.2026-10-11T12-01.md` in the E1 worktree), Claude Code 2.1.296, headless, one run per mode, agent type `general-purpose` (`:15`, `:69`):
  - Payload arrived as JSON on stdin; `CLAUDE_HOOK_INPUT` was not set in any of 4 invocations (`:7`, `:57`).
  - Root carried `last_assistant_message`; no `output` key (`:8`, `:49`).
  - Exit 1 did not block; exit 2 blocked and the subagent was re-invoked (`:9-10`).
  - On re-invocation the envelope carried `stop_hook_active: true` (`:10`, `:32`); E1 records that the helper should surface this flag (`:65`).
  - `agent_type` carries the subagent type (`:44`, `:64`).
  - Named project agents (pr-author, prd-feature, task-researcher) and frontmatter-registered hooks were not exercised (`:69`).
  - Empty, absent and malformed stdin were not observed and are left to E1's spec (`:70`).

### 1.3 Working assumption for the E3 plan

The epic Shared Design contract is the working assumption (`docs/features/epics/subagentstop-envelope/epic.md:77-90`): dot-sourced `.claude/hooks/subagentstop-envelope.ps1`, `Read-SubagentStopEnvelope` (stdin JSON, assistant text from `last_assistant_message`), `Exit-SubagentStopBlock -Message <text>` (stderr, exit 2), no `CLAUDE_HOOK_INPUT` reads, and test seams as parameters on the validator's pure entry point. E1's evidence confirms the transport and field names, but the function signatures, return shape, empty/malformed handling and `stop_hook_active` exposure are not fixed. **The E3 plan must start with an upstream-merge check:** confirm E1 has merged into `epic/subagentstop-envelope-integration`, read E1's final spec, and stop if the signatures differ from section 6 of this document (`epic.md:89-90`).

## 2. Per-hook current state

Line counts are the number of text lines (the Read tool shows one extra empty line after the final newline). Line numbers in the issue table (`issue.md:46-51`) were re-derived and **all twelve citations match** the integration-branch files.

### 2.1 `.claude/hooks/validate-discovery-artifact-gate.ps1` (264 lines)

- Bootstrap: guard dot-source with flag at `:38`; guarded `DiscoveryValidation.psm1` import at `:39`. No `Set-StrictMode`, no `$ErrorActionPreference = 'Stop'`.
- Pure entry: `Invoke-DiscoveryArtifactGateValidation -RawPayload [-RequiredArtifactReader]` (`:194-248`), returns `@{ Ok; Message }`. Helpers: `Invoke-DiscoveryValidatorExe` (mockable seam, `:41-77`), `Get-DiscoveryArtifactType` (`:79-122`), `Get-RequiredDiscoveryArtifactDeclaration` (`:124-154`), `Find-DiscoveryArtifactReference` (`:156-192`).
- Reads `.output`: `:223-224` (property-presence check then `[string]$payload.output`).
- `$env:CLAUDE_HOOK_INPUT`: passed at `:258`; named in comments/messages at `:8`, `:197`, `:212`, `:219`.
- What it checks: scans the assistant text for tokens resolving to one of eight `discovery/<type>` prefixes (`:104-113`); when a required-artifact declaration is present, runs the in-process validator per reference and blocks on non-zero exit or non-empty output (`:238-244`).
- Allow paths: payload without `output` property (`:222-225` leaves `''`, then `:228-229`); no references (`:228-229`); declaration absent, which is the default reader (`:144`, `:232-236`); all references validate (`:247`).
- Block paths in the decision function: dependency decision (`:208-209`), empty payload (`:211-212`), malformed JSON (`:215-220`), validator failure `DISCOVERY_ARTIFACT_GATE_BLOCKED:` (`:243`).
- Process exits: `exit 2` on guard load failure (`:254`); `exit $dependencyDecision.ExitCode` (2) on a recorded dependency failure (`:256`); `Write-Error` (`:260`, non-terminating here) then `exit 1` (`:261`); `exit 0` (`:264`).
- Beyond the issue table: the two exit-2 dependency paths at `:254` and `:256`.

### 2.2 `.claude/hooks/validate-pr-author-output.ps1` (142 lines)

- Bootstrap: guard at `:30`. No other dependency, no strict mode.
- Pure entry: `Get-PrAuthorOutputDecision -HookInputRaw` (`:72-125`), returns ordered `allowed`/`reason`. Detector: `Test-PrAuthorOutputReportsPr -OutputText` (`:32-70`) matching a GitHub PR URL (`:55`), `PR #<n>` (`:60`), or `gh pr create|edit` plus `#<n>` (`:65`).
- Reads `.output`: `:109` (direct `[string]$parsed.output`, no presence check).
- `$env:CLAUDE_HOOK_INPUT`: passed at `:135`; named in help/messages at `:7`, `:14`, `:40`, `:75`, `:81`, `:96`, `:105`.
- Allow path: detector true (`:117-118`). There is no nothing-to-inspect allow path; empty output blocks.
- Block paths in the decision function: dependency decision (`:90-91`), `PR_AUTHOR_OUTPUT_MISSING` (`:93-98`), `PR_AUTHOR_OUTPUT_MALFORMED` (`:100-107`), `PR_AUTHOR_OUTPUT_EMPTY` (`:110-115`), `PR_AUTHOR_OUTPUT_NO_PR` (`:121-124`).
- Process exits: `exit 2` (`:131`), `exit $dependencyDecision.ExitCode` (`:133`), `Write-Error` + `exit 1` (`:138-139`), `exit 0` (`:142`). The help text documents `exit 1` as the block code (`:13`).

### 2.3 `.claude/hooks/validate-prd-feature-output.ps1` (97 lines)

- Bootstrap: guard at `:8`; `Set-StrictMode -Version Latest` at `:10`; `$ErrorActionPreference = 'Stop'` at `:11`.
- Pure entry: `Invoke-PrdFeatureOutputValidation -RawPayload` (`:71-89`), returns `@{ Ok; Message }`. Helpers: `Get-ArtifactPathFromOutput` (`:13-21`), `Test-NumericDerivationEvidence` (`:23-60`), `Test-SpecNumericCriterion` (`:62-69`).
- Reads `.output`: `:80`. `$env:CLAUDE_HOOK_INPUT`: passed at `:95`; named in messages at `:78-79`.
- What it checks: `spec-path:` label exists on disk (`:82-83`); when the spec's Acceptance Criteria contain a numeric checkbox (`:67-68`), a `research-path:` must exist (`:86-87`) and carry a complete `## Numeric Derivation Evidence` section (`:88`, `:28-59`).
- Allow paths: non-numeric spec (`:85`); valid evidence (`:59`).
- Block paths: dependency decision (`:75-76`), empty (`:78`), malformed (`:79`), empty output (`:81`), spec missing (`:83`), research missing (`:87`), evidence defects (`:29`, `:39`, `:42`, `:45`, `:46`, `:49`, `:51`, `:54`, `:57`, `:58`).
- Process exits: `exit 2` (`:92`), `exit $dependencyDecision.ExitCode` (`:94`), `Write-Error; exit 1` (`:96`), `exit 0` (`:97`).
- Beyond the issue table: because of `:11`, `Write-Error` at `:96` is terminating and `exit 1` is unreachable; the process exits 1 through the terminating error. This is pinned by `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1:42-44`. `Get-Content -ErrorAction Stop` at `:84` and `:88` can also throw out of the function (uncaught; same non-blocking exit 1).

### 2.4 `.claude/hooks/validate-task-researcher-output.ps1` (294 lines)

- **No dependency guard.** There is no `hook-dependency-guard.ps1` bootstrap and no tail dependency check (`:20-24`, `:284-294`). `Set-StrictMode` at `:23`, `$ErrorActionPreference = 'Stop'` at `:24`.
- Pure entry: `Invoke-TaskResearcherOutputValidation -RawPayload` (`:226-282`). Helpers: `Test-ResearchFile` (filesystem seam, `:26-35`), `Get-ResearchPathFromOutput` (`:37-58`), `Test-IsUnderResearchRoot` (`:60-83`), `Test-IsValidResearchFileName` (`:85-99`), `Test-AutomationFeasibilitySection` (`:101-162`, `-ReadFileContent` seam at `:133`), `Test-NumericDerivationEvidence` (`:164-224`).
- Reads `.output`: `:245-246`. `$env:CLAUDE_HOOK_INPUT`: passed at `:288`; named at `:14`, `:234`, `:241`.
- What it checks: `research-path` token (`:45`), root under `docs/features/**/research/` or `docs/research/` (`:76-82`), filename regex `^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-[A-Za-z0-9][A-Za-z0-9-]*-research\.md$` (`:95-98`), file exists (`:265`), Automation Feasibility section when applicable (`:269-272`), numeric derivation evidence (`:274-279`).
- Allow path: all checks pass (`:281`).
- Block paths: `:234`, `:241`, `:249`, `:254`, `:258`, `:262`, `:266`, `:271`, `:277`.
- Process exits: `Write-Error` (`:290`, terminating under `:24`) and unreachable `exit 1` (`:291`); `exit 0` (`:294`).
- Beyond the issue table: `:274-275` re-checks the file with `Test-Path`/`Get-Content` outside the `Test-ResearchFile` seam; a read exception there is uncaught.
- Registration: only in agent frontmatter (`.claude/agents/task-researcher.md:14-19`); not in `.claude/settings.json`. The #786 spec listed it as "present on disk but not registered" (`docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/spec.md:42`), which is why it never received the guard.

### 2.5 Latent shape mismatch (all three guarded hooks)

The decision functions return the guard's SubagentStop object `{ ExitCode; Reason }` (`.claude/hooks/hook-dependency-guard.ps1:104-105`) where callers expect `Ok`/`allowed` and `Message`/`reason`. Today the script tails short-circuit on the same decision first (`validate-discovery-artifact-gate.ps1:255-256`, `validate-pr-author-output.ps1:132-133`, `validate-prd-feature-output.ps1:93-94`), so the mismatch is unreachable. Removing or reordering the tail check would expose it.

## 3. Test suites

No test files are mirrored under `extensions/drm-copilot/resources/` (Glob for the four basenames under that tree returned only the hook copies).

| Suite (lines) | Input feed | Subprocess | Exit-code assertions |
|---|---|---|---|
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` (211) | Dot-sources (`:7`); `-RawPayload` built from `@{ output = ... }` (`:11-16`); end-to-end sets `$env:CLAUDE_HOOK_INPUT` (`:152`, `:163`) | Yes, `& $PwshExe -NoProfile -File` (`:142-146`, `:153`, `:164`) | `$LASTEXITCODE \| Should -Be 0` (`:154`); `$LASTEXITCODE \| Should -Be 1` (`:165`) |
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1` (89) | Calls `Invoke-DiscoveryValidatorExe` directly | No | None (validator `ExitCode` only, `:49`, `:65`, `:77`) |
| `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` (127) | `-HookInputRaw '{"output":...}'` (`:18-90`); end-to-end via env var (`:97`, `:108`, `:119`) | Yes (`:9-13`, `:98`, `:109`, `:120`) | `Should -Be 0` (`:99`); `Should -Be 1` (`:110`, `:121`) |
| `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1` (54) | In-process `& $script:Hook` with env var set and `[Console]::SetError` (`:16-35`) | No | `ExitCode \| Should -Be 1` (`:43`); `Should -Be 0` (`:52`) |
| `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` (135) | Dot-sources (`:4`); `-RawPayload` with `output` (`:77-109`); mocks `Test-Path`/`Get-Content` | No | None |
| `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1` (46) | In-process `&` with env var (`:16-35`) | No | Asserts a thrown error matching `CLAUDE_HOOK_INPUT is empty` (`:43-44`), not an exit code |
| `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` (423) | Dot-sources (`:11-12`); `-RawPayload` with `output` (`:44-291`); mocks `Test-ResearchFile` | No | None; **no entry-point test**, so `:284-294` are not exercised |
| `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (196) | In-process `&` with `[Console]::SetIn(StringReader)` carrying a SubagentStop envelope (`:104-124`) | No | SubagentStop `ExitCode \| Should -Be 2` with stderr prefix and dependency name (`:159-163`, `:188-189`) |
| `tests/scripts/claude-hooks/hook-dependency-failure.SpecialCases.Tests.ps1` (236) | Same stdin redirect (`:60-80`); fresh runspace for strict-mode hooks (`:82-114`) | No | C8 `ExitCode \| Should -Be 2` (`:233-234`) |

Assertions that pin `CLAUDE_HOOK_INPUT` message text and will need updating: `validate-discovery-artifact-gate.Tests.ps1:80`, `:87`; `validate-prd-feature-output.Coverage.Tests.ps1:44`; `validate-task-researcher-output.Tests.ps1:48`, `:66`. Assertions on `PR_AUTHOR_OUTPUT_*` tokens (`validate-pr-author-output.Tests.ps1:47`, `:54`, `:60`, `:66`, `:73`) survive if the tokens are kept.

Discovery-time registration-driven suites that will pick up E3 changes automatically:

- B1 (`hook-dependency-failure.Claude.Tests.ps1:25-32`, `:134-164`) builds one row per direct non-guard edge of every hook registered in `.claude/settings.json` (`tests/scripts/claude-runtime/HookDependencyGraph.Helpers.ps1:64-98`). Adding a guarded dot-source of `subagentstop-envelope.ps1` to the discovery, pr-author and prd-feature hooks adds a row for each, which asserts exit 2, the existing reason prefix, and the dependency name on stderr. The prefix table already holds all three (`:96`, `:100`, `:101`).
- C8 (`hook-dependency-failure.SpecialCases.Tests.ps1:27-33`, `:228-235`) adds a row for any registered hook that sets `$ErrorActionPreference = 'Stop'` and has a non-guard edge. prd-feature has no such edge today, so it gains a row once the helper edge exists; its prefix is already listed (`:57`).
- Structural shape S1/S2/S3/S6 (`tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1:17-28`, `:117-127`) runs over repository and mirror roots. S1 requires the bootstrap flag check to write to `[Console]::Error.WriteLine(` and contain a literal `exit 2`, and the SubagentStop tail to contain `exit $dependencyDecision.ExitCode` (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:44-55`). S2 requires each edge in its own single-statement `try` whose catch calls `Add-HookDependencyFailure -Name '<leaf>'` (`:99-105`). S6 requires the decision function to begin with the dependency-decision assignment and return (`:109-116`), where the decision function is chosen by name (`HookDependencyGraph.Helpers.ps1:298-323`).
- None of these suites discover `validate-task-researcher-output.ps1`, because discovery reads only `.claude/settings.json` and `.codex/config.toml` (`HookDependencyGraph.Helpers.ps1:69`, `:84`, `:104`).

Content-pinning tests outside the claude-hooks folder:

- `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:60-93` asserts literal message fragments in the task-researcher and prd-feature hooks ("narrow named-pattern", "repeats the primary search strategy or query expression", "count does not match its independently enumerated member set", "numeric acceptance criterion requires an existing research-path"). These strings must survive.
- `test_claude_planning_integrity_contracts.py:169-262` and `tests/scripts/claude-runtime/claude-settings.Tests.ps1:7`, `:107-154` pin the exact prd-feature settings command `pwsh -NoProfile -File .claude/hooks/validate-prd-feature-output.ps1` and canonical/bundled settings parity.
- `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1:97-120` pins the pr-author frontmatter `hooks:` block line by line, including `command: pwsh -NoProfile -File .claude/hooks/validate-pr-author-output.ps1` (`:115`).

## 4. Registrations, mirrors and coverage

### 4.1 Registrations (all use `pwsh -NoProfile -File <relative path>`; no Codex equivalents)

| Hook | `.claude/settings.json` (read-only, E1) | Agent frontmatter |
|---|---|---|
| discovery-artifact-gate | `:222`, inside the broad-matcher entry `:213-224` that also holds the inline command `:218` | none |
| pr-author-output | `:253-261` (matcher `pr-author`, `:258`) | `.claude/agents/pr-author.md:23-27` |
| prd-feature-output | `:244-252` (matcher `prd-feature`, `:249`) | `.claude/agents/prd-feature.md:13-20` (line 18 is E2's `validate-required-artifact-output.ps1`, line 20 is E3's) |
| task-researcher-output | none | `.claude/agents/task-researcher.md:14-19` |

The bundled copies carry the same lines: `extensions/drm-copilot/resources/claude-customizations/.claude/settings.json:222`, `:249`, `:258`; bundled `agents/pr-author.md:27`, `agents/prd-feature.md:20`, `agents/task-researcher.md:19`. A Grep of `.codex/` for the four names returned no matches, and the Codex bundle holds only `validate-bash.ps1`, `validate-codex-subagent-routing.ps1` and `validate-feature-review-coverage.ps1` under `.codex/hooks/`.

pr-author and prd-feature are each registered twice (settings and frontmatter). Once the hooks block, a refusal may be reported twice per stop. This is not a correctness defect, but the plan should note it and leave it to E1, which owns settings.

No registration command needs to change: `pwsh -NoProfile -File` passes stdin to the script.

### 4.2 Bundled mirrors

- Hook mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-discovery-artifact-gate.ps1`, `validate-pr-author-output.ps1`, `validate-prd-feature-output.ps1`, `validate-task-researcher-output.ps1`.
- Parity enforcement: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110` (`test_bundled_claude_payload_contains_all_repo_runtime_contracts`) requires every distributable `.claude` file, including agents, to exist in the bundle with equal content. #501 used this test as its mirror gate (`docs/features/completed/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/spec.md:202`).
- Sync method: manual file copy. No sync script exists (Grep of `scripts/**` for `claude-customizations` returned no match); #501 required "mirror copy via file-copy command" (`.../501/plan.2026-08-21T17-45.md:85`).
- Pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:69`, `:75`, `:77` list the discovery, prd-feature and task-researcher hooks. `validate-pr-author-output.ps1` and `agents/pr-author.md` are in no manifest, and that absence is pinned as a known exception (`tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py:52-58`, `:162-177`; `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:67-71`). E3 must not add pr-author to a manifest, or the "documented exceptions remain absent" test fails. The new helper's manifest entry belongs to E1.

### 4.3 Coverage measurement

- Population: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:17-27` has no `CodeCoverage.Path` list (issue #527) and derives the population from `config/poshqc-coverage.json`, whose roots include `.claude/hooks` (`config/poshqc-coverage.json:3-9`). Test scan folders come from `config/poshqc-scan.json:4`. Output is `artifacts/pester/powershell-coverage.xml` (`pester.runsettings.psd1:22`), and `CoveragePercentTarget = 0` (`:26`), so the 85% floor needs an explicit per-file comparison.
- MCP runner caveats (from shared project memory, verified 2026-08-25 and 2026-09-13; not re-verified here): `mcp__drm-copilot__run_poshqc_test` reads the installed extension's runsettings, so it may not reflect in-repo settings, and its result carries no counts or percentages. Post-#527 the population comes from workspace config, which should make the first caveat less relevant, but this was not verified. Recommended evidence route: call the MCP tool for route compliance, then invoke the self-hosted module directly (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest ...`) and parse the coverage XML per file, keyed by the enclosing `package` path.
- Pester measures line coverage only; there is no branch gate (`.claude/rules/general-unit-test.md`).
- Last recorded per-file coverage:
  - discovery-artifact-gate 92.65% (63/68)
  - pr-author-output 100.00% (39/39)
  - prd-feature-output 98.15% (53/54)

  All three come from `docs/features/active/2026-09-29-hook-preexisting-imports-fail-open-786/evidence/qa-gates/r2-final-pester-coverage.md:160`, `:170`, `:172` (2026-10-10). task-researcher-output 90.00% (90/100) comes from `docs/features/completed/2026-08-29-claude-planning-integrity-593/evidence/qa-gates/prd-feature-registration-powershell-tests-and-coverage.2026-08-29T13-53.md:10` (2026-08-29). Whether that file changed after 2026-08-29 was not verified (no `git log`).
- The #786 spec records the bootstrap `exit 2` as an expected uncovered line (`.../786/spec.md:224`, `:251`).

## 5. Precedents

### 5.1 #501 (PreToolUse)

`git log --grep=501` was not run. The completed feature folder records the pattern:

- A shared reader module was introduced and every hook migrated to it (`.../501/spec.md:220-225`).
- Anomaly paths were required to block with an emitted decision and to "never exit 1" (`:185`, `:197`).
- Tests were inverted from exit-1 expectations, and a source-scanning guard was added that derives the hook set from `settings.json` and fails if any hook contains `$env:CLAUDE_HOOK_INPUT` (`:179`, `:201`).
- Mirror parity relied on the existing pytest (`:202`).
- Coverage was measured per touched file at >= 85% with no new exclusions (`:204`).
- #501 explicitly excluded the eight SubagentStop validators (`:206`, `:306`).

One recorded deviation is relevant here: the planned tail `exit (Invoke-<Name>EntryPoint)` swallowed output written to stdout. The fix was to write the decision before calling `exit` (`:229-244`). For SubagentStop the block reason goes to stderr, so this exact failure does not apply. The general rule still holds: write the reason before exiting.

### 5.2 #786 / PR #881 (SubagentStop dependency failures)

- PR number confirmed in `.../786/evidence/qa-gates/r2-pr-checks.md:1`, `:4`.
- The "uniform helper-based block" is `hook-dependency-guard.ps1`: `Get-HookDependencyFailureDecision -HookEvent SubagentStop` returns `{ ExitCode = 2; Reason }` (`.claude/hooks/hook-dependency-guard.ps1:79-114`). The hook tail writes the reason with `[Console]::Error.WriteLine` and exits with that code (for example `.claude/hooks/validate-orchestrator-output.ps1:456-458`).
- #786 limited itself to dependency-failure blocks and left the exit-1 validation paths unchanged (`.../786/spec.md:50`, `:235`, `:269`). Its conversion rule is at `:277-278`.
- **E1's helper does not replace the guard; the two are complementary.** The guard must stay import-free and load first (`hook-dependency-guard.ps1:6-19`), and the S1 shape test hard-codes the guard tail text (`HookGuardShape.Helpers.ps1:47`, `:55`). The E1 helper becomes one more guarded edge, and its `Exit-SubagentStopBlock` replaces only the `Write-Error`/`exit 1` validation tail. If E1 also wants the dependency tail to use `Exit-SubagentStopBlock`, that requires changing `HookGuardShape.Helpers.ps1`, which E1 should own.

## 6. Recommended approach

### 6.1 Candidates

- **A (selected): consume the E1 helper in each validator.** Add a guarded dot-source of `subagentstop-envelope.ps1`. Change each pure entry function to take the assistant text, or the parsed envelope, as a parameter instead of raw JSON. Keep each function's existing name and its leading dependency-decision statements (S6). Replace each validation tail with `Read-SubagentStopEnvelope`, then the pure call, then `Exit-SubagentStopBlock -Message`.
  - This follows the epic contract (`epic.md:80-87`) and keeps the #786 shape guarantees.
  - The E3 diff stays small and local to each file.
- **B (rejected): inline stdin parsing in each hook.** This puts four more copies of envelope parsing into the code, contradicts the one-helper decision (`epic.md:44-48`, `:52`), and repeats the drift that #501 fixed with a shared reader.
- **C (rejected): reuse `Read-ClaudeHookRawPayload` from `HookPayload.psm1`.** It falls back to `CLAUDE_HOOK_INPUT` and `CLAUDE_TOOL_INPUT` (`.claude/lib/hook-payload/HookPayload.psm1:154-157`, `:185-191`), which violates the "no CLAUDE_HOOK_INPUT" rule, and it is a PreToolUse module.

### 6.2 Per-file implementation (assumes the section 1.3 contract; adjust to E1's final signatures)

Common to all four files:

- Insert `try { . (Join-Path $PSScriptRoot 'subagentstop-envelope.ps1') } catch { Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1' -ErrorRecord $_ }` directly after the guard bootstrap, and before `Set-StrictMode`/`$ErrorActionPreference` where present (S2 shape).
- Keep the three-statement dependency tail exactly as is (S1).
- After the tail: `$envelope = Read-SubagentStopEnvelope`, call the pure function with the assistant text, and on block call `Exit-SubagentStopBlock -Message <reason>`; otherwise `exit 0`.
- Remove every `CLAUDE_HOOK_INPUT` literal (code, help, messages), and replace "output" wording with "last assistant message" wording. Keep existing reason tokens/prefixes so the prefix tables (`hook-dependency-failure.Claude.Tests.ps1:96-101`) and token assertions stay valid.
- Treat envelope-level anomalies (empty, malformed, missing `last_assistant_message`) exactly as E1 defines them. Map "assistant text missing or blank" to each hook's existing empty-output result.
- Copy each changed hook byte-for-byte into its mirror.

Per file:

1. `validate-discovery-artifact-gate.ps1`: change `Invoke-DiscoveryArtifactGateValidation` from `-RawPayload` to an assistant-text parameter (for example `-AssistantMessage`), keeping `-RequiredArtifactReader`. Keep the current semantics: no text or no references means allow (`:222-229`), because this hook runs for every agent under the broad matcher (`settings.json:214`), and a block on missing text would affect all fifteen agent types. Replace `:258-262`.
2. `validate-pr-author-output.ps1`: change `Get-PrAuthorOutputDecision` to take the assistant text. Keep the four `PR_AUTHOR_OUTPUT_*` tokens. Replace `:135-140`, and update help `:6-17` (exit 2, stdin).
3. `validate-prd-feature-output.ps1`: change `Invoke-PrdFeatureOutputValidation` to take the assistant text, and replace `:95-96`. **Required:** `Write-Error` must not appear on the block path, because under `:11` it terminates before any exit; `Exit-SubagentStopBlock` must write to stderr without `Write-Error`. Recommended: wrap the `Get-Content` calls at `:84` and `:88` so a read exception becomes a block result instead of an uncaught exit 1. Keep every message string pinned by `test_claude_planning_integrity_contracts.py:86-93`.
4. `validate-task-researcher-output.ps1`: add the full #786 guard pattern so a helper load failure blocks, even though no registration-driven suite discovers this hook (section 3): bootstrap after `param()`, the three-statement tail after `:284-286`, and a dependency-decision first statement in `Invoke-TaskResearcherOutputValidation`. Then apply the common changes. The same `Write-Error` rule applies (`:24`). Recommended: catch the read at `:274-275` the same way.

### 6.3 Tests (Pester; no temporary files; no Python)

- Unit tests on the pure functions: change fixtures from `@{ output = ... } | ConvertTo-Json` raw payloads to direct assistant-text arguments. Remove the `-RawPayload ''`/malformed cases from the pure-function tests, because envelope anomalies move to E1's helper suite. Add one test per hook for blank assistant text.
- Entry-point tests, inverted to exit 2 as #501 did:
  - `validate-discovery-artifact-gate.Tests.ps1:160-169`: change to a stdin envelope whose `last_assistant_message` references a failing artifact. This needs a present declaration; the default reader reports absent (`:144`), so the end-to-end block case is only reachable when the reader is injectable at the entry point. Otherwise assert exit 2 on the anomaly path E1 defines.
  - `validate-pr-author-output.Tests.ps1:105-125`: `Should -Be 2` for an envelope without a PR reference.
  - `validate-pr-author-output.Coverage.Tests.ps1:38-44`: `Should -Be 2`.
  - `validate-prd-feature-output.Coverage.Tests.ps1:38-45`: assert `ExitCode` 2 and a stderr reason instead of a thrown error.
  - Add a new task-researcher entry-point suite. The existing file is 423 lines; adding to it risks the 500-line cap, so use a sibling such as `validate-task-researcher-output.Coverage.Tests.ps1`, following the #786 naming.
  - Each changed suite should keep an exit-0 allow case and add a negative case: an envelope carrying only `output` must not satisfy the gate (the issue's step 3, `issue.md:35-40`).
- Input feeding: for coverage, use the in-process `&` route with `[Console]::SetIn([System.IO.StringReader]::new($json))` and `[Console]::SetError(...)`, restored in `finally` (precedent `hook-dependency-failure.Claude.Tests.ps1:104-124`). Subprocess runs (`$json | & $PwshExe -NoProfile -File $hook`) give a true process exit code but add no coverage. Keep at most one subprocess case per hook as the end-to-end check.
- Do not set or rely on `CLAUDE_HOOK_INPUT` in any E3 test, except to clear it in a negative case if E1's spec asks for one.

### 6.4 Acceptance-criteria candidates for spec.md (no numeric counts proposed)

- Each of the four named hooks, given a stdin SubagentStop envelope whose `last_assistant_message` lacks its required artifact, exits 2 with the reason on stderr. The same text supplied only as `output`, or only through `CLAUDE_HOOK_INPUT`, does not satisfy the gate.
- None of the four hook files, or their mirrors, contains `CLAUDE_HOOK_INPUT`, `exit 1`, or a `Write-Error` on a block path.
- `validate-task-researcher-output.ps1` carries the #786 bootstrap, edge guard and tail. A helper load failure exits 2 with its prefix.
- The suites named in 6.3 assert exit 2 where they asserted exit 1.
- Line coverage >= 85% for each changed hook file.
- Mirror parity passes.
- No production or test file exceeds 500 lines.
- The B1, C8 and S1–S6 suites pass with the new edges.
- `test_claude_planning_integrity_contracts.py` passes.

## 7. Conflict boundaries

- E3 must not edit:
  - E1: `.claude/settings.json` and its bundled copy, `.claude/hooks/subagentstop-envelope.ps1` and its mirror and tests, pack manifests.
  - E2: `validate-orchestrator-output.ps1`, `validate-orchestrator-output-resolution.ps1`, `validate-executor-output.ps1`, `validate-planner-output.ps1`, `validate-required-artifact-output.ps1`, and their suites (including `hook-import-failure-exemptions.FailClosed.Tests.ps1:402-470`, which drives the orchestrator hook through `CLAUDE_HOOK_INPUT`).
  - E4: `validate-feature-review-coverage.ps1`, `feature-review-coverage-thresholds.ps1`, the feature-review skills, `.codex/agents/feature-review.toml`, and mirrors.
- Shared files that more than one child may need to edit (avoid where possible, and serialize if needed):
  - `.claude/agents/prd-feature.md`: line 18 is E2's command and line 20 is E3's. E3 needs no edit if the command form stays the same; if either child edits the file, coordinate.
  - `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1` (`ReasonPrefix` table, `:71-102`) and `hook-dependency-failure.SpecialCases.Tests.ps1` (`StopPrefix`, `:53-58`): no E3 edit is needed if prefixes are unchanged. E2/E4 may edit them if they rename prefixes or split files.
  - `tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1`, `HookDependencyGraph.Helpers.ps1` and `HookImportFailureExemptions.Helpers.ps1`: E1 should own any tail-shape change. E3 should not edit them.
  - A SubagentStop analogue of #501's source-scanning guard (no `CLAUDE_HOOK_INPUT` in SubagentStop hooks) does not exist today. If one is added, a single child, preferably E1, should own it, and it must cover agent-frontmatter registrations or it will miss `validate-task-researcher-output.ps1`.
  - `tests/scripts/claude-hooks/enforce-pr-author-command-allowlist.Tests.ps1:97-120` pins the pr-author frontmatter. Only relevant if E3 changes that block, which this plan does not recommend.

## 8. Constraints

- No Python in enforcement hooks (epic NFR, `epic.md:14`; enforced by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`).
- 500-line cap per production and test file (`epic.md:15`). The current maximum among E3 files is 423 lines (task-researcher suite).
- Line coverage >= 85% for each changed PowerShell file (`epic.md:16`). No branch gate for Pester, and no coverage exclusions.
- No temporary files in tests (`.claude/rules/general-unit-test.md`); use `[Console]::SetIn` and seams.
- Bundled mirrors byte-identical (`epic.md:17`; `test_push_down_claude_resource_contracts.py:89-110`).
- Hooks must not write to success or warning streams (#792 guard, `.../786/spec.md:17`, `:245`), so block reasons go to stderr only.

## 9. Risks and open questions

1. **E1 contract not final.** Signatures, return shape and anomaly handling are unspecified (section 1.2). Mitigation: an upstream-merge check as the first plan step, with a stop on mismatch.
2. **In-process stdin injection.** If `Read-SubagentStopEnvelope` gates the read on `[Console]::IsInputRedirected` the way `Read-ClaudeHookRawPayload` does (`HookPayload.psm1:183`, `:196-209`), `[Console]::SetIn` does not change that flag, so in-process entry-point tests would read nothing and coverage of the tail would be lost. E1 should either expose a reader seam or document that `[Console]::SetIn` is honoured. Record this as a question for E1 before planning the tests.
3. **`stop_hook_active` re-entry.** A blocked subagent is re-invoked with `stop_hook_active: true` (E1 evidence `:10`, `:65`). The E3 validators must decide whether to block again. Recommendation: keep validating on re-entry, because a second refusal is the enforcement, but follow whatever loop guard E1 specifies. This is open until E1's spec fixes it.
4. **Research filename convention versus orchestrator practice (high impact).** The live task-researcher gate accepts only `<YYYY-MM-DDTHH-MM>-<name>-research.md` (`validate-task-researcher-output.ps1:95-98`; `.claude/agents/task-researcher.md:30-33`; `.claude/skills/research-issue/SKILL.md:27-29`). The orchestrator-supplied path for this very document, `research/research.2026-10-11T12-05.md`, does not match. A Glob found more than sixty existing `docs/features/**/research/research.<timestamp>.md` files. Once E3 makes this hook live, every task-researcher delegation using that naming will be refused with exit 2. Resolution needs a user decision: align orchestrator naming to the hook, widen the hook regex, or record an explicit exception. Raise this before E3 merges.
5. **Relative-path checks depend on the hook process working directory.** `Test-Path` on `spec-path`/`research-path` (`validate-prd-feature-output.ps1:83`, `:87`; `validate-task-researcher-output.ps1:265`, `:274`) resolves against the hook's cwd. For worktree-isolated subagents this was not verified. A live block could therefore come from a cwd mismatch rather than a missing artifact. Recommend one live smoke run per agent type after E1 merges.
6. **Frontmatter-registered hooks were not measured.** E1's probe used a settings-registered hook and `general-purpose` only (E1 evidence `:69`). That frontmatter hooks receive the same stdin envelope is taken from documentation, not from observation.
7. **Discovery gate blast radius.** It runs for fifteen agent types under the broad matcher (`settings.json:214`). Any change in its allow semantics, especially blocking on blank text or on E1 envelope anomalies, affects all of them. Keep the nothing-to-inspect paths as allow.
8. **Double registration** of pr-author and prd-feature (section 4.1) may produce duplicate refusals. E1 owns this decision.
9. **Coverage tooling.** The MCP runner may not report new rows, and it returns no numbers (section 4.3). Plan an explicit direct-module measurement.
10. **task-researcher coverage baseline is stale** (2026-08-29). Capture a fresh baseline in Phase 0.
11. **Shared feature key.** E1 and E3 both key to #897 (`epic.md:139-143`); checkpoint `issue_num` uniqueness is an open epic decision outside E3's control.
