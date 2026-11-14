# Code Review: Owner-Directive Relay (#1139)

---

**Review Date:** 2026-11-08
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-08-owner-directive-relay-1139`
**Feature Folder Selection Rule:** Named by the caller; matches issue #1139 and branch `feature/owner-directive-relay`.
**Base Branch:** `main` (`origin/main` at merge base `5c81af727`)
**Head Branch:** `feature/owner-directive-relay` at `21eee3f40`
**Review Type:** Initial review

---

## Executive Summary

The branch adds a key-gated owner-directive check. A new pure module, `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` (372 lines), parses the checkpoint text with System.Text.Json and applies rules B1-B8 to `owner_directives` and R1-R10 to `owner_directive_records`, returning the exact spec strings. `.claude/hooks/validate-orchestrator-output.ps1` imports the module with the guarded fail-closed pattern and calls it after the routing dispatch, only when the hook's existing parse has a top-level `owner_directives` or `owner_directive_records` property (ordinal). A new `owner-directives` skill (six byte-identical copies), pointer sentences, a rule section, a brief bullet, and a one-line digest re-pin complete the change. Evidence reviewed: the PR context artifacts at 21eee3f40, the four QA-gate artifacts, the baselines, the self-review, both main-merge records, the coverage artifacts (parsed independently), and direct probes of the module.

**What changed:**
One new PowerShell module and one new hook helper plus a 6-line call site; documentation across 26 skill, agent, rule, and brief files (including mirrors and bundle copies); four new and two edited Pester files; one Python literal.

**Top 3 risks:**
1. The date parser accepts non-ISO strings that the documentation describes as ISO 8601 (Minor finding below).
2. The final local gates predate the second `origin/main` merge; the post-merge full suites rely on CI.
3. Same-session forgery and the Codex/Python/TypeScript enforcement gaps are inherent and disclosed; origin rests on the coordinator procedure.

**PR readiness recommendation:** **Go** — no Blocker or Major finding; the remaining items are a Minor parser-strictness observation and the normal CI gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/orchestrator-state/OrchestratorStateOwnerDirectives.psm1` | `ConvertFrom-OwnerDirectiveDateText`, lines 92-106 | `[datetime]::TryParse` with the invariant culture accepts non-ISO values such as `11/08/2026`, `Monday, 09 November 2026`, and `8 Nov 2026 3pm`; spec.md (Data & State), the skill, and the rule section describe these fields as ISO 8601 date-times. | Optionally add an ISO 8601 shape check (for example a `\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}` prefix test) before `TryParse`, with B7 and R9 rows for a non-ISO value, and copy the module to its bundle copy. | The validator under-enforces a documented writer obligation; comparisons stay deterministic and no gate is weakened, and no AC requires rejection (B7 and R9 name unparseable values). | Reviewer probe `od1139-probe.sh` at 21eee3f40: all three values returned 0 errors; existing B7/R9 rows use only `not-a-date`, `tomorrow`, `yesterday afternoon`. |
| Info | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` | line 342 | D1: `('Start-' + 'Process')` in the AST forbidden-command list. | None. | A string in an assertion list launches no process; the identical construct exists on main in three suites and in the purity hook's own tests. Accepted as a false-positive workaround, not a bypass. | grep of `tests/scripts` at head |
| Info | `.claude/rules/orchestrator-state.md` | new section and Enforcement bullet | D2: additions to a rules-folder file. | None. | Contract document with no `.github/instructions/` counterpart, not in the `CLAUDE.md` canonical list, edited by many prior features; additions only; bundle copy identical. | `git log -- .claude/rules/orchestrator-state.md`; `cmp` with bundle copy |
| Info | `.claude/hooks/validate-orchestrator-output.ps1` | lines 373-380 | Back-compat confirmed: the module is reached only inside `if (Test-OrchestratorOutputOwnerDirectiveKey -PropertyName $checkpointProps)`; no added `Ok = $true` line. | None. | A checkpoint without either top-level key takes exactly the pre-branch path. | hook diff; U6 call-count rows |
| Info | branch | second `origin/main` merge 21eee3f40 | Final local gates ran at 9c824ca93; the merge brought PR #1142 (#1138) and a digest conflict resolution. | Rely on CI at the PR head for the S9 gate. | The branch's module and hook bytes are unchanged by the merge; overlap surfaces re-tested post-merge (103 pytest, 56 Pester by the executor; 227 Pester by the reviewer). | evidence/other/main-sync-merge.2026-11-08T19-59.md |

No Blockers or Major findings. No covered file is at or above 700 logical lines, so no file-size Warning applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The single Python edit is the epic-orchestrate digest in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (numstat 1/1); the reviewer confirmed the pinned value `facef971...` equals the SHA-256 of the head `.claude/skills/epic-orchestrate/SKILL.md`, and the agent digest equals the head `epic-orchestrator.md`.

#### Typing and API notes

- No new public Python API surface was added.

#### Error handling and logging

- Not applicable; no Python logic changed.

### PowerShell implementation audit

#### What changed well

- Parsing with `JsonDocument` avoids the JSON-to-object cmdlet's ISO date coercion and case-insensitive names; property reads are ordinal and last-definition-wins, matching the hook's key gate.
- Error ordering follows the spec (block rules, then record rules, entry order); the directive index takes the first entry per id so a B4 duplicate does not shadow the record checks.
- R7 counts honored records per `extra_planner_revision` directive and emits once at the second record.
- `JsonDocument` is disposed in `finally`; the parse failure is rethrown with the stable `OWNER_DIRECTIVE_UNEVALUABLE:` token, which the hook turns into a repairable block.

#### API and safety notes

- One exported function; all helpers carry `[CmdletBinding()]` and `[OutputType()]`; no state-changing function, so ShouldProcess does not apply.
- The hook import uses the same `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` line as its siblings; FailClosed H9 proves exit 2.
- Scope check: under `.claude/hooks/` and `.codex/hooks/` only `validate-orchestrator-output.ps1` and its bundle copy changed; `.claude/settings.json`, `.github/copilot-instructions.md`, `.github/instructions/`, `.claude/agents/epic-orchestrator.md`, and `OrchestratorStateUnconditional.psm1` are unchanged (reviewer `git diff --stat` empty).

#### Error handling and logging

- Every error path returns a block with `Repairable = $true`; no silent catch.

---

## Test Quality Audit

The four new suites assert each B and R rule against its exact spec string, cover all refused classes for R6, the three artifact types in the hook, keyless back-compat with call-count assertions, and skill byte identity across six copies. Coverage of the new module is 100% (148/148) from the merged gate artifact, reproduced by the reviewer. The tests do not include a non-ISO but parseable date (see the Minor finding).

### Reviewed test and QA artifacts

- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Tests.ps1` — B1-B8, purity AST row; 61 tests.
- `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateOwnerDirectives.Records.Tests.ps1` — R1-R10 including expiry boundaries; 50 tests.
- `tests/scripts/claude-hooks/validate-orchestrator-output.OwnerDirectives.Tests.ps1` — per-type block, eligibility, placement; 22 tests.
- `tests/scripts/claude-runtime/owner-directives-skill-contract.Tests.ps1` — copy identity and pointers; 56 tests.
- `evidence/qa-gates/pester.2026-11-08T19-51.md` — full parallel gate, 0 failures, coverage figures.
- `evidence/qa-gates/pytest.2026-11-08T19-55.md` — full pytest gate, no coverage drop.

### Quality assessment prompts

- **Determinism:** fixed literals, no clock, culture restored in `finally`.
- **Isolation:** one rule or decision per `It`.
- **Speed:** 227 targeted tests in under two minutes; full gate 532.68 s.
- **Diagnostics:** exact-string assertions with `-Because` text.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspected; fixture texts and session ids are synthetic. |
| No unsafe subprocess or command construction | ✅ PASS | The module starts no process and calls no clock, file, or import command (AST row). |
| Input validation at boundaries | ✅ PASS | Ordinal top-level key gate in both hook and module; ValueKind checks for every shape. Parser leniency noted as Minor. |
| Error handling remains explicit | ✅ PASS | Throw converted to a repairable block; import failure fails closed. |
| Configuration / path handling is safe | ✅ PASS | Import path built from `$PSScriptRoot`. |
| No directive-based allow path | ✅ PASS | No added `Ok = $true` line; the new branch can only return a block. Docs state the block conveys recorded owner intent and grants no approval, consent, or elevated permission (skill Framing section). |

---

## Research Log

No external research was required. Repository precedents (the split-token construct on main, the commit history of the rules file) were checked locally.

---

## Verdict

The change is ready for normal PR flow. The implementation matches the spec's error strings and placement, keeps keyless checkpoints on the pre-branch path, and changes no other hook or gate. The Minor date-parser observation can be addressed in this item at the owner's discretion; it does not block. The S9 CI green gate on the post-merge head remains the authoritative confirmation of the full suites.
