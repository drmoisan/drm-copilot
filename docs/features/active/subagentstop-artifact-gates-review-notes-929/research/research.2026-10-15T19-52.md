# Research: E3 review notes for the SubagentStop artifact-gate validators (Issue #929)

- Issue: #929 (branch `bug/subagentstop-artifact-gates-review-notes-929`)
- Timestamp: 2026-10-15T19-52 (UTC). The research agent has no shell tool; the stamp was read from the UTC time service `timeapi.io` at write time, not from the host clock.
- Source review: `code-review.2026-10-12T04-58.md` in the E3 feature folder `subagentstop-envelope-artifact-gates-905`. Current location: `docs/features/active/subagentstop-envelope-artifact-gates-905/`. Possible later location: `docs/features/archive/subagentstop-envelope-artifact-gates-905/`. Every E3 path below is written against the current `active/` location; resolve the folder at execution time.
- In scope: NB-1, NB-2, NB-3, NB-4, NB-5, NB-7, NB-8, NB-9, NB-10, NB-11. Out of scope: NB-6 (issue #928).
- All `file:line` citations were verified in this worktree on 2026-10-15 with Read and Grep. The review's line numbers still match the current tree for every cited location.

## 1. Current State Summary

| File | Lines (current) | Role |
|---|---|---|
| `.claude/hooks/validate-prd-feature-output.ps1` | 118 | prd-feature SubagentStop validator (R2, R3) |
| `.claude/hooks/validate-task-researcher-output.ps1` | 290 | task-researcher SubagentStop validator (R1, R3) |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | 253 | discovery SubagentStop validator (R4) |
| `.claude/hooks/validate-pr-author-output.ps1` | 129 | pr-author SubagentStop validator |
| `.claude/hooks/hook-dependency-guard.ps1` | 114 | shared #786 guard; byte-identical in four locations (its own `.NOTES`, line 19) |
| `.claude/hooks/subagentstop-envelope.ps1` | n/a (not edited) | E1 helper; `Exit-SubagentStopBlock` at line 171, `exit 2` at line 190 |

Each of the four validators follows the same shape: guard bootstrap (line 16 / 27 / 43 / n/a), guarded `subagentstop-envelope.ps1` dot-source, a decision function whose first two statements are the dependency-decision assignment and `if ($null -ne $dependencyDecision) { return $dependencyDecision }`, a dot-source early return, and an S1 tail that checks the guard flag and the dependency decision before calling the decision function.

## 2. Findings per Note

### NB-1: R3 rejection tests are not exhaustive

R3 implementation (identical at both sites):

- `.claude/hooks/validate-prd-feature-output.ps1:51`
- `.claude/hooks/validate-task-researcher-output.ps1:202-204`

```powershell
if ($values['Exhaustive Search Scope'] -notmatch '(?i)\b(entire|whole|all|complete)\b.*\b(repository|repo|worktree|source tree|tree)\b') { return @{ Ok = $false; Message = '<prefix> numeric derivation evidence does not declare an exhaustive repository search scope.' } }
```

The check has one rejection branch, reached by four distinct input classes. Current tests:

- prd-feature: `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1:198-209` (accept: `entire worktree.`, `the whole worktree, all directories.`, `entire repository`) and `:211-221` (reject: `the hooks folder` only). `:139` also rejects `focused directory` in a combined case without a message assertion.
- task-researcher: `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1:296-307` (same three accepts) and `:309-319` (reject: `the hooks folder` only). `validate-task-researcher-output.Tests.ps1:401-406` rejects `focused directory`.

Untested rejection classes (each is a value the current pattern rejects):

| Class | Value | Source |
|---|---|---|
| Noun present, no quantifier | `those four files on the current worktree.` | E3 `spec.md:280` "Still rejects"; corpus `corpus-prd-feature.2026-10-11T15-03.md:2000` |
| Quantifier present, no noun | `the whole file, lines 1-335.` | E3 `spec.md:280`; corpus `:1949` |
| Neither, path-shaped | `` `.claude/hooks/` `` | E3 `spec.md:280` |
| Word-boundary on quantifier | `the allocated repository subset` (`\ball\b` does not match inside `allocated`) | derived from the pattern |
| Word-boundary on noun | `the entire subtree` (`\btree\b` does not match inside `subtree`) and `the whole worktrees folder` (`\bworktree\b` does not match `worktrees`) | derived from the pattern |

Untested acceptance members of the alternations (positive boundary): quantifier `complete` (`the complete source tree`), noun `repo` (`the whole repo`), upper case (`ENTIRE WORKTREE`), and the two remaining E3 `spec.md:279` examples (`entire worktree root.`, ``the whole repository excluding `docs/` ``).

Recommendation: extend the two existing `-ForEach` tables in place (same Context, same Arrange line, same message assertion) in both suites. No production change.

### NB-2: R3 admits whole-worktree scope values that enumerate a narrower covered set

Logic location: duplicated, not shared. `Test-NumericDerivationEvidence` is defined separately in `.claude/hooks/validate-prd-feature-output.ps1:32-69` and `.claude/hooks/validate-task-researcher-output.ps1:171-231`; the bodies differ only in the message prefix and line wrapping. No module under `.claude/lib` holds it (Grep for `Exhaustive Search Scope` under `.claude/lib` returned no match).

What is admitted: `.*` between the quantifier and noun groups accepts any text in between and after, so the check passes whenever a quantifier word precedes a noun word anywhere in the value. Examples found in tracked research (Grep over `docs/` for scope values that match R3 and also contain `covers|only|restricted to|limited to|scoped to|confined to`; 8 lines returned):

| Path:line | Value (abridged) | Semantic reading |
|---|---|---|
| `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/research/research.2026-10-08T14-00.md:323` | the whole worktree ..., restricted to code by excluding `docs/`; covers `.claude/hooks`, ... | the reviewer's NB-2 example |
| `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/research/research.2026-10-11T10-45.md:214` | the whole worktree excluding `docs/**`. This covers `.claude/`, ... | same semantics as the 565 value |
| `docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/research/research.2026-09-30T01-25.md:259` | the whole worktree excluding `docs/**` (... searched separately ...) | exhaustive with a declared exclusion |
| `docs/features/active/2026-10-08-epic-planner-topology-receipt-gate-543/research/research.2026-10-08T14-00.md:323` | the entire worktree excluding `docs/**` and the test trees ... This covers ... | exhaustive with exclusions |
| `docs/features/active/2026-10-08-bug-burndown-2026-09-29-review-nits-846/research/research.2026-10-08T23-50.md:448` | entire repository tree ..., with docs/** excluded from the content search only because ... | exhaustive |
| same file `:463` and `:478` | the complete file `<one file>` (all N lines) in the repository tree; no other file holds ... | a single-file scope admitted because `complete` and `tree` both occur |
| `docs/features/active/2026-09-29-issue-507-python-push-down-divergence-follow-ups-790/research/2026-10-08T18-00-python-push-down-divergence-research.md:357` | all .gitignore files in the entire repository tree (Glob ... found only the root file) | exhaustive for its family |

Evaluation against the E3 R3 definition (`spec.md:260`, `:277-283`, Risk 5a at `:408`): the documented requirement is that the scope covers the complete family. Whether an exclusion or a `covers` list narrows the scope below the family is not decidable from the scope value alone, because the family is declared in a different field. Candidate rules and their effect on the tracked examples above:

| Candidate | Effect |
|---|---|
| Reject when a whole/entire phrase is followed by `restricted to` or `limited to` | Rejects only the 565 value, while the 902 and 659 values with the same meaning ("whole worktree excluding docs/") stay accepted. The verdict depends on wording, not on scope. |
| Reject when `only` or `covers` follows | Also rejects 846:448, 790:357 and 902:214, which are exhaustive scopes. |
| Require the quantifier to modify the noun directly (adjacency) | Rejects 846:463 and 846:478 (single-file scopes, arguably correct rejections) but still admits the NB-2 example. |
| Reject `excluding` | Contradicts E3 R3 "Accepts" (``the whole repository excluding `docs/` ``) and the pre-R3 behavior for `entire repository excluding ...`. |

Recommendation: no production rule change. Each candidate either misclassifies a tracked exhaustive scope or leaves the NB-2 example accepted. Pin the documented breadth with characterization cases (the NB-2 example value and one `entire repository excluding ...` value are accepted), and record the no-change decision in the #929 spec with the table above, citing E3 Risk 5a. If the spec author nevertheless requires a behavioral change, the least-impact option is the adjacency rule. It must then run under its own corpus false-positive gate, with the same classification method as E3 AC-08. It would also edit both validators and both mirrors. That would put an additional hunk in files that #928 edits. This decision belongs to the spec author or user. It is not settled here.

Note: the issue classifies NB-2 as behavioral ("Fix NB-2 and NB-11 with tests"). The no-change recommendation departs from that classification and should be confirmed when the spec is approved.

### NB-3: R4 has one unit case

R4 implementation: `.claude/hooks/validate-discovery-artifact-gate.ps1:186-195` (`if ($trimmed -and (Get-DiscoveryArtifactType -Path $trimmed)) {` at line 190; trim set at line 189: `` ` ``, `"`, `'`, `,`, `;`, `(`, `)`, `[`, `]`). The early return for blank text is at lines 182-184.

Existing case: `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1:344-357` (`""` plus `discovery/coverage-ledger/coverage-ledger.json` returns that one reference without error).

Missing cases:

1. Lone backtick token, no discovery path (E3 `spec.md:301` second "Accepts" example): returns an empty array and raises no error.
2. Empty-after-trim token (`""`), no discovery path: returns an empty array and raises no error.
3. Lone backtick plus a discovery reference (E3 AC-33 names a lone backtick as an alternative to `""`): returns the reference.
4. Other trim-only tokens (`()`, `[]`, `''`, `,`, `;`) alongside a reference: skipped, reference returned.
5. Gate level: `Invoke-DiscoveryArtifactGateValidation` with a present-declaration reader and a message containing only a lone backtick returns `Ok = $true` and does not invoke `Invoke-DiscoveryValidatorExe`.

Test note: an empty `[string[]]` return is unrolled to `$null` by the pipeline. Assertions must wrap the call in `@( )` and use `Should -HaveCount 0`. The existing case already does this at line 351.

### NB-4: `New-SubagentStopEnvelopeJson` defined in seven suites

Definitions (all under `tests/scripts/claude-hooks/`):

| Suite | Line | Scope of definition | `agent_type` |
|---|---|---|---|
| `validate-prd-feature-output.Tests.ps1` | 32-40 | file-level `BeforeAll` | `prd-feature` |
| `validate-prd-feature-output.Coverage.Tests.ps1` | 24-32 | `Describe` `BeforeAll` | `prd-feature` |
| `validate-task-researcher-output.Tests.ps1` | 41-49 | file-level `BeforeAll` | `task-researcher` |
| `validate-task-researcher-output.Coverage.Tests.ps1` | 24-32 | first `Describe` `BeforeAll` | `task-researcher` |
| `validate-pr-author-output.Tests.ps1` | 15-23 | `Describe` `BeforeAll` | `pr-author` |
| `validate-pr-author-output.Coverage.Tests.ps1` | 18-26 | `Describe` `BeforeAll` | `pr-author` |
| `validate-discovery-artifact-gate.Tests.ps1` | 180-188 | `Context 'script entrypoint'` `BeforeAll` | `general-purpose` |

Body (identical in all seven except `agent_type`):

```powershell
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Builds and returns envelope JSON text only; it changes no system state.')]
param([AllowEmptyString()] [string] $AssistantMessage = '', [switch] $OmitAssistantMessage, [string] $OutputField, [switch] $StopHookActive)
$envelope = [ordered]@{ session_id = 'e3-905'; hook_event_name = 'SubagentStop'; agent_type = '<agent>'; stop_hook_active = [bool]$StopHookActive }
if (-not $OmitAssistantMessage) { $envelope['last_assistant_message'] = $AssistantMessage }
if ($PSBoundParameters.ContainsKey('OutputField')) { $envelope['output'] = $OutputField }
return ($envelope | ConvertTo-Json -Compress)
```

No test asserts on `session_id` or `agent_type`. A Grep for `agent_type` in the E3 suites returned only the builder lines. The function name occurs 68 times across the seven files: 7 definitions and 61 call sites.

Related builder: `validate-discovery-artifact-gate.Tests.ps1:11-16` defines `ConvertTo-DiscoveryEnvelopeJson`. It has no `agent_type`, uses `-Depth 8`, and has no suppression. It can be folded into the shared builder, but this is optional and is not part of NB-4 as written.

Conventions for shared test support in this folder:

- `*.Helpers.ps1` files under `tests/scripts/claude-hooks/` are plain scripts. Suites dot-source them from `BeforeAll` with `. (Join-Path $PSScriptRoot '<Name>.Helpers.ps1')`, for example `WorktreeResolutionFixture.Helpers.ps1` (16 suites, such as `enforce-epic-merge-gate.WorktreeResolution.Tests.ps1:42`) and `validate-feature-review-coverage.E4.Helpers.ps1` (dot-sourced at `validate-feature-review-coverage.Coverage.Tests.ps1:306`).
- The E4 helper defines `ConvertTo-ClaudeEnvelope` (`validate-feature-review-coverage.E4.Helpers.ps1:39-48`) with a `ConvertTo-` verb. That verb is outside PSScriptAnalyzer's state-changing verb set, so no suppression is needed. This is the precedent the reviewer's NB-4 recommendation names.
- The E3 scope rule excluded `tests/scripts/claude-runtime/` (E1-owned, E3 AC-30). The reviewer recommends `tests/scripts/claude-hooks/`.

Coverage and QC treatment of a helper under `tests/`:

- `config/poshqc-coverage.json` roots are `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`, so a file under `tests/` is not in the coverage denominator. The #896 plan recorded the same reasoning for the E4 helper (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/plan.2026-10-11T07-58.md:53`).
- `config/poshqc-scan.json` test scan folders include `tests/scripts`. Pester runs only `*.Tests.ps1`, so a `*.Helpers.ps1` file is not executed as a test container. It is still formatted and analyzed by `Invoke-PoshQCFormat` / `Invoke-PoshQCAnalyze` (`.github/workflows/_poshqc.yml:22-36`).
- `.claude/hooks/check-powershell-test-purity.ps1:64` treats every `tests/**/*.ps1` as test code, so the helper is subject to the test-purity rules (no temporary files).
- The Linux job (`_poshqc.yml:54-82`) runs `tests/scripts/claude-hooks` on a case-sensitive filesystem. The dot-source file name must match the helper's case exactly.

Recommendation: create `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` with one function, `ConvertTo-SubagentStopEnvelopeJson`. It keeps the four current parameters and adds `[string] $AgentType = 'general-purpose'`. Drop the `PSUseShouldProcessForStateChangingFunctions` suppression, because the verb no longer requires it. In each of the seven suites, delete the local definition, dot-source the helper in the same `BeforeAll` that held the definition, and rename the call sites, passing `-AgentType` where the previous value differed from the default. Keep `session_id = 'e3-905'`. The helper is test support only and is not mirrored; `tests/` has no bundle copy.

### NB-5: redundant `agentOutput` alias

`.claude/hooks/validate-task-researcher-output.ps1:243-244`:

```powershell
$assistantMessage = [string]$envelope.AssistantText
$agentOutput = $assistantMessage
```

`$agentOutput` is read at lines 245, 249 and 266 only, all inside `Invoke-TaskResearcherOutputValidation`. The `$AgentOutput` names at lines 49/53 and 137/147 are parameters of `Get-ResearchPathFromOutput` and `Test-AutomationFeasibilitySection`, in separate function scopes. No test reads the variable. The `$agentOutput` locals at `validate-task-researcher-output.Tests.ps1:213-261` are test-local values passed as `-AgentOutput` arguments. The alias is redundant and safe to remove: delete line 244 and replace `$agentOutput` with `$assistantMessage` at lines 245, 249 and 266. No message string changes, so the strings pinned by `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py:53-93` are unaffected. Apply the same edit to the bundle mirror (section 4).

### NB-7: AC-20 literal grep and the `validatorResult` rename

Current code: `.claude/hooks/validate-discovery-artifact-gate.ps1:231-238` reads `$validatorResult['Output']` and `$validatorResult['ExitCode']`. A case-insensitive Grep for `CLAUDE_HOOK_INPUT|\.output\b` over the four validators returns no match today, so E3 AC-20 still passes.

Rationale already recorded: E3 `plan.2026-10-11T07-59.md:79` (RS-2). `Select-String` is case-insensitive, so the AC-20 pattern `\.output\b` would also have matched the validator-result property read `$result.Output`. The executor renamed the local and switched to indexers to keep the AC-20 command verbatim. Every producer returns a hashtable, which `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1:39-88` pins. The change preserves behavior.

Assessment: the defect is in the AC-20 wording, not in the code. The pattern was meant to detect reads of the envelope's `output` field, but as written it also matches an unrelated result key. Reverting the code would make AC-20 fail verbatim. Rewording AC-20 does not change any runtime behavior.

Recommendation: no code change. Append a dated post-review clarification beneath AC-20 in the E3 spec (`docs/features/active/subagentstop-envelope-artifact-gates-905/spec.md:386`, or the `archive/` equivalent). The note should say that `\.output\b` targets envelope-payload reads, and that the discovery validator result's `Output` key is read through the hashtable indexer per plan RS-2. Do not change the checked state of AC-20. This edit is in another feature's folder (E3, issue #905), not in the #929 folder. The #929 spec should list it as a cross-folder documentation edit and record the same resolution in its own text, so the decision survives if the E3 folder is archived or is not edited.

### NB-8: AC-11 wording satisfied by a Before-runs commit

E3 `spec.md:377` (AC-11) reads: "the corpus evidence file records an after-change false-positive count of zero, and the commit adding that evidence file precedes the commit that replaces that validator's final block exit". The commit that *adds* each evidence file is `329dc7b01`, which carries only the Before sections (review `:68`). That commit precedes every switch commit, so the literal check passes without proving that the zero After count was recorded first. The substantive property was verified separately with `git merge-base --is-ancestor <corpus-after-commit> <switch-commit>` (E3 `plan.2026-10-11T07-59.md:70-73`; script `ac11-ordering.ps1` in `evidence/other/corpus-scripts.2026-10-11T15-01.md:299-324`).

Recommendation (documentation only): append a dated post-review clarification beneath AC-11 in the E3 spec, without changing its checked state. Proposed wording: "Ordering is evaluated against the commit that first records the after-change zero count in the evidence file (the first commit in `git log --format=%H --reverse -S 'AFTER-FALSE-POSITIVES: 0' -- <evidence file>`), which must be an ancestor of the switch commit (`git merge-base --is-ancestor <that commit> <switch commit>` exits 0). The plan's `AC11:` lines record this property." Optionally add the same phrasing guidance to a future-facing location. The review recommendation is "for future specs", but changing a skill or agent file would add bundle-mirror and `.github` parity edits and is not recommended for this item. Like NB-7, this edit is in the E3 feature folder.

### NB-9: the discovery corpus did not exercise validator dispatch

E3 AC-09 (`spec.md:375`) required "the pure entry point with the default declaration reader". The default `-RequiredArtifactReader` is `{ Get-RequiredDiscoveryArtifactDeclaration }` (`validate-discovery-artifact-gate.ps1:212`), whose default `-ProfileReader` is `{ $null }` (`:150`). The function therefore returns `@{ Present = $false }`, and the gate allows at `:225-229` before reaching the dispatch loop at `:231-238`. The corpus harness (`corpus-discovery.ps1`, recorded in `evidence/other/corpus-scripts.2026-10-11T15-01.md:217-253`) was a scratchpad script and is not tracked or run in CI.

Seams available:

- `-RequiredArtifactReader [scriptblock]` on `Invoke-DiscoveryArtifactGateValidation` (`:212`). Inject `{ @{ Present = $true; Declaration = ... } }`, as the suite already does with `$script:PresentReader` (`validate-discovery-artifact-gate.Tests.ps1:20`).
- `Invoke-DiscoveryValidatorExe` (`:47-83`), the mockable dispatch seam, called with `-ValidatorArgs @($artifactType, $reference)` at `:233`.
- `Get-RequiredDiscoveryArtifactDeclaration -ProfileReader` (`:146-160`).

A dispatch run against the real validator cannot produce a meaningful false-positive count. Corpus references are repository-relative paths that do not exist as discovery artifacts, so the real validator returns `Artifact not found:` for each one (`validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1:72-80`). The run would also expose the known latent prefix match: `scripts/dev_tools/discovery/profile_cli.py` matches `(^|/)discovery/profile` in `Get-DiscoveryArtifactType` (`:121-123`). E3 records this as an out-of-scope follow-up (`spec.md:440`), and the mapping is owned by `TODO(#9002)` (`:96-99`).

Recommendation: add a deterministic Pester case to `validate-discovery-artifact-gate.Tests.ps1` that is corpus-shaped and exercises dispatch, in place of a CI corpus run. Use a present-declaration reader and a mocked `Invoke-DiscoveryValidatorExe`. The message carries several discovery types, a duplicated reference, punctuation-wrapped references (backticks, a trailing comma) and empty-after-trim tokens. Assert one `Should -Invoke Invoke-DiscoveryValidatorExe -Times 1 -Exactly -ParameterFilter { $ValidatorArgs[0] -eq '<type>' -and $ValidatorArgs[1] -eq '<path>' }` per distinct reference, plus a total count. Add a second case where the mock fails the second reference, to assert first-failure short-circuit and the `DISCOVERY_ARTIFACT_GATE_BLOCKED:` message. Leave `profile_cli.py` out of the assertion set and record the prefix match as an existing out-of-scope follow-up. Pinning it would encode a known defect. Optionally, an evidence-only rerun of the E3 After harness can be made with a present reader and a recording stub, but it is not required. The E3 harness's `Before` mode calls `-RawPayload`, which no longer exists, so only `After` mode is runnable.

### NB-10: canonical coverage XML absent from the review worktree

`/artifacts` is gitignored (`.gitignore:6`), and `artifacts/pester/` does not exist in this worktree (Glob returned no file). The review used the executor's hash-verified copy (`final-full-pester.2026-10-11T23-57.md`). The E3 evidence already records the per-file `sourcefile` LINE counters verbatim (`final-coverage-per-file.2026-10-12T00-10.md`). This is a process note only: no code or test change. Recommendation: the #929 plan should record per-file coverage counters verbatim in its own `evidence/qa-gates/` artifact, using the method E3 used, so a reviewer in another worktree does not depend on the XML.

### NB-11: dependency-decision statement returns `{ExitCode; Reason}` where callers read `Ok`/`Message`

Statement: `.claude/hooks/validate-task-researcher-output.ps1:239-240`. Guard return shape: `.claude/hooks/hook-dependency-guard.ps1:104-106` (`[pscustomobject]@{ ExitCode = 2; Reason = $reason }`). The same statement exists in all four validators: prd-feature `:96-97`, discovery `:214-215`, and pr-author `:96-97`, where callers read `allowed`/`reason`.

Reachability:

- Script execution (`pwsh -File`): unreachable. The tail recomputes the same decision and exits first (`validate-task-researcher-output.ps1:286-287`), and nothing records a failure between that check and the call at `:288`.
- In-process (dot-sourced, as in tests and the corpus harness): reachable. Calling `Add-HookDependencyFailure` and then `Invoke-TaskResearcherOutputValidation` returns the `{ExitCode; Reason}` object. A caller that reads `.Ok` under `Set-StrictMode -Version Latest` raises a property-not-found error.

Why the statement shape cannot change here: guard-completeness rule S6 (`tests/scripts/claude-runtime/HookGuardShape.Helpers.ps1:109-117`) requires the decision function's second statement to be exactly `if ($null -ne $dependencyDecision) { return $dependencyDecision }`. The rule is enforced by `hook-dependency-guard-completeness.Tests.ps1` and the per-hook guard-shape case (`validate-task-researcher-output.Coverage.Tests.ps1:181-190`). The E4 spec (#896) made the same decision and withdrew its own normalization plan for this reason (`docs/features/active/subagentstop-envelope-feature-review-coverage-896/spec.md:110-111`). Changing the guard's return object to also carry `Ok`/`Message` would edit a shared file that is byte-identical in four locations and used by every registered hook, which exceeds the scope of this item.

Recommendation: no production change. Close the shape question as by-design under S6. Pin the reachable in-process behavior with a test, following the precedent `validate-orchestrator-output.WaveBarrier.Tests.ps1:229-249` (H12): dot-source the hook, record a failure with `Add-HookDependencyFailure -Name 'subagentstop-envelope.ps1'`, call `Invoke-TaskResearcherOutputValidation -InputText <envelope>`, and assert `ExitCode` 2 and a `Reason` that starts with `validate-task-researcher-output:` and names the dependency. Reset `$script:HookDependencyFailures` in `finally`, as at `validate-task-researcher-output.Coverage.Tests.ps1:171`. The test covers line 240, which no current test reaches in-process. Equivalent cases for prd-feature, discovery and pr-author are optional and low-cost. They also need test-only edits to suites that NB-4 already touches.

## 3. Overlap Analysis with #928

Constraint: this agent has no shell tool, so `git log origin/main --oneline -5 -- .claude/hooks` and `git ls-remote --heads origin '*928*'` could not be run. The #928 diff is not known. The planner or orchestrator must run both commands before the plan is finalized. Known from the #928 lifecycle record (`docs/features/potential/promoted/2026-10-15-subagentstop-hook-uncaught-error-exits-1.md:54-58`): #928 adds a top-level trap or try/catch in each validator, or in the shared helper's entry contract, adds one test per validator that forces an unhandled error and asserts exit 2, and mirrors the change to the bundled copies.

Production lines this item would touch under the recommendations above:

| File | Lines | Note | Likely #928 region | Overlap |
|---|---|---|---|---|
| `.claude/hooks/validate-task-researcher-output.ps1` | 244 (delete), 245, 249, 266 (rename) | NB-5 | script tail `:282-290`, or a trap/try near `:25-31`, or a try/catch around the body of `Invoke-TaskResearcherOutputValidation` `:239-279` | No textual overlap with a tail or top-level trap. If #928 wraps the function body, the NB-5 hunk falls inside the wrapped region and conflicts. |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` | same | NB-5 mirror | same | same |
| `.claude/hooks/validate-prd-feature-output.ps1` | none | NB-2 and NB-11 recommend no change | tail `:112-118` | none |
| `.claude/hooks/validate-discovery-artifact-gate.ps1` | none | NB-7 and NB-9 recommend no change | tail `:243-253` | none |
| `.claude/hooks/subagentstop-envelope.ps1` | none | not touched | possible shared entry contract | none |

Test-side overlap is larger than production overlap. NB-4 edits all seven E3 suites, including the four entry-point suites (`*.Coverage.Tests.ps1`, `validate-discovery-artifact-gate.Tests.ps1`, `validate-pr-author-output.Tests.ps1`) where #928's per-validator exit-2 tests are likely to be added and to call `New-SubagentStopEnvelopeJson`. If #928 merges first, its new call sites must be converted to `ConvertTo-SubagentStopEnvelopeJson` during the #929 rebase. If #929 merges first, #928 must use the shared helper. Recommendation: schedule the NB-4 extraction after #928 merges, or as the last phase of #929 after a rebase on `main`. Record the decision in the plan.

S1 tail note for #928 (informational): `Get-HookGuardTailFinding` (`HookGuardShape.Helpers.ps1:35-57`) pins the three statements after the dot-source early return. A try/catch that #928 adds around the tail must leave those statements in place.

## 4. Mirrors and Bundled Copies

- Every production hook edited here has exactly one bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`. Glob for the four validators found no `.codex/hooks/` copy. `.claude/hooks/subagentstop-envelope.ps1` also has one bundle mirror.
- Parity is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`, which requires every distributable `.claude/**` file to have text identical to its bundle copy. For NB-5: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-task-researcher-output.ps1` (currently identical at lines 244-266).
- `.claude/hooks/hook-dependency-guard.ps1` is byte-identical in `.claude/hooks`, `.codex/hooks` and both bundles (its `.NOTES`). It is not edited under the recommendations.
- Test files under `tests/` have no mirror. The new helper is test support only.

## 5. Toolchain and Verification (Option A)

- Formatting: `Invoke-PoshQCFormat` (CI fails on any reformatted file, `_poshqc.yml:22-30`). Lint: `Invoke-PoshQCAnalyze` (PSScriptAnalyzer). Tests and coverage: `Invoke-PoshQCTest`, which writes `artifacts/pester/powershell-coverage.xml` over the `config/poshqc-coverage.json` roots. Type checking does not apply to PowerShell.
- CI jobs: `poshqc / PowerShell QC` (windows-latest, format + analyze + test with coverage) and `poshqc / PowerShell hook suites (Linux)` (ubuntu-latest, Pester over `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks`, coverage disabled). Both run every suite changed here.
- Python contract tests that must stay green: `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` (mirror parity) and `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` (pinned message strings).
- Option A local verification uses the PoshQC MCP tools. Team memory records two constraints, not re-verified in this session: PoshQC MCP results may not carry the per-test output or counts, and the MCP test runner may read installed-extension settings rather than repository config. A plan should not assert a count or percentage taken from an MCP result. Per-file coverage should come from the self-hosted module's XML, recorded verbatim (NB-10), with CI as the confirming evidence.
- Registration-driven suites that must stay green if any validator changes: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`, `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`.

## 6. File-Size Status (500-line limit)

| File | Current lines | Expected change | Projected |
|---|---|---|---|
| `.claude/hooks/validate-task-researcher-output.ps1` (+ mirror) | 290 | -1 | 289 |
| `tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1` | 223 | +~14 rows, -9 builder, +1 dot-source | ~229 |
| `tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1` | 201 | -9, +1 | ~193 |
| `tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1` | 418 | -9, +1 | ~410 |
| `tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1` | 320 | +~14 rows, +~20 NB-11 case, -9, +1 | ~346 |
| `tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1` | 114 | -9, +1 | ~106 |
| `tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1` | 140 | -9, +1 | ~132 |
| `tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1` | 358 | +~40 NB-3, +~45 NB-9, -9, +1 | ~435 |
| `tests/scripts/claude-hooks/SubagentStopEnvelope.Helpers.ps1` (new) | 0 | +~30 | ~30 |
| E3 `spec.md` | Markdown | +2 notes | exempt |

`validate-task-researcher-output.Tests.ps1` (~410) and `validate-discovery-artifact-gate.Tests.ps1` (~435) are the closest to the limit. Put the NB-11 case in the Coverage suite, not in `validate-task-researcher-output.Tests.ps1`. If the NB-9 cases push the discovery suite past ~470 lines, place them in a new sibling `validate-discovery-artifact-gate.Dispatch.Tests.ps1`, following the sibling-suite convention of `validate-discovery-artifact-gate.ValidatorDispatch.Tests.ps1`.

## 7. Recommended Approach and Rejected Alternatives

Recommended: a test-centric change set with one production hygiene edit.

- Production: NB-5 only (task-researcher validator and its mirror).
- Tests: NB-1, NB-2 characterization, NB-3, NB-9 and NB-11 cases, plus the NB-4 shared helper.
- Documentation: post-review notes under E3 AC-11 and AC-20 (cross-folder), and the #929 spec decisions for NB-2, NB-10 and NB-11.

Rejected alternatives (brief):

- Normalizing the dependency-decision return to `Ok`/`Message` in each validator. This violates guard-completeness rule S6, and #896 withdrew the same plan.
- Adding `Ok`/`Message` to the guard's SubagentStop object. This edits a shared, four-way byte-identical file used by every hook, and it would not cover pr-author's `allowed`/`reason`.
- A textual NB-2 narrowing rule without a corpus gate. Every candidate misclassifies a tracked exhaustive scope (section 2, NB-2).
- A CI corpus run against the real discovery validator. It produces no meaningful false-positive count and depends on the untracked E3 harness.
- Reverting the `validatorResult` rename (NB-7). This breaks E3 AC-20 verbatim without any behavior gain.

## 8. Test Strategy (no test code)

- NB-1: table rows added to the existing R3 `-ForEach` Contexts in both suites. Each reject row asserts `Ok = $false` and the exact unchanged message. Each accept row asserts `Ok = $true` with the message as the `-Because` text.
- NB-2: two characterization accept rows (the NB-2 example value; an `entire repository excluding ...` value), commented as the documented breadth (E3 Risk 5a).
- NB-3: four unit cases on `Find-DiscoveryArtifactReference` and one gate-level case (section 2, NB-3), each with an explicit `$thrown | Should -BeNullOrEmpty`.
- NB-9: two dispatch cases with a present-declaration reader and `-ParameterFilter` invocation assertions (distinct-reference dispatch; first-failure short-circuit).
- NB-11: one in-process case asserting `ExitCode` 2 and the `Reason` prefix, with `finally` cleanup of `$script:HookDependencyFailures`.
- NB-4: the existing suites pass unchanged in behavior after conversion. A Grep for `function New-SubagentStopEnvelopeJson` and for the suppression justification text over `tests/` returns no match.
- NB-5: the existing task-researcher suites pass unchanged, and the mirror parity pytest passes.
- Regression-first ordering: NB-1, NB-3 and NB-9 cases pass against current code. They are characterization tests and cannot fail first. The NB-11 case also passes against current code. The only behavior change (NB-5) preserves behavior, so no `[expect-fail]` task is available. The plan should say so explicitly rather than invent a failing test.

## Numeric Derivation Evidence

- Numeric spec.md acceptance criterion: 7 suites define the envelope builder (NB-4)
- Complete Family: New-SubagentStopEnvelopeJson
- Exhaustive Search Scope: the entire worktree, all directories and file types, including docs/, tests/, .claude/, .codex/ and extensions/.
- Inclusion Rules: a file counts when it defines a PowerShell function named New-SubagentStopEnvelopeJson in source code.
- Exclusion Rules: documentation files that quote the name (docs/features/**) are excluded because they define no function.
- Primary Search Strategy or Query Expression: Grep regex 'function New-SubagentStopEnvelopeJson' over the entire worktree, output mode files-with-content.
- Primary Member Set: tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1, tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1, tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1, tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1
- Primary Count: 7
- Cross-check Search Strategy or Query Expression: Grep for the suppression justification text 'Builds and returns envelope JSON text only' over the entire worktree (8 files, of which 1 is docs/features/active/subagentstop-envelope-artifact-gates-905/evidence/other/deviations.md and is excluded), intersected with a per-file count of the word-bounded token New-SubagentStopEnvelopeJson over *.ps1, *.psm1, *.psd1, *.sh, *.py and *.ts files (7 files, 68 occurrences).
- Cross-check Member Set: tests/scripts/claude-hooks/validate-discovery-artifact-gate.Tests.ps1, tests/scripts/claude-hooks/validate-pr-author-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-pr-author-output.Tests.ps1, tests/scripts/claude-hooks/validate-prd-feature-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-prd-feature-output.Tests.ps1, tests/scripts/claude-hooks/validate-task-researcher-output.Coverage.Tests.ps1, tests/scripts/claude-hooks/validate-task-researcher-output.Tests.ps1
- Cross-check Count: 7
- Member-set Comparison: the normalized primary and cross-check member sets are identical (same seven paths after lower-casing and sorting); the counts match.

## Automation Feasibility

All steps can be automated. Human interaction is required at only one point:

- The NB-2 decision (no rule change versus the adjacency rule) is a spec-approval decision for the user or spec author. Once the spec records it, every implementation and verification step is automatable.

Steps that are automatable but depend on tooling outside this agent:

- `git log`, `git ls-remote` and rebase sequencing against #928 must be run by an agent with shell access.
- The cross-folder E3 documentation edits (NB-7, NB-8) are plain Markdown edits. The executor must resolve whether the E3 folder is under `active/` or `archive/` at execution time.
