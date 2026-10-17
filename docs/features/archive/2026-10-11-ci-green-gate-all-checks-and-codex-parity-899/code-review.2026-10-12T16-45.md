# Code Review: ci-green-gate-all-checks-and-codex-parity (Issue #899, also #891)

- Timestamp: 2026-10-12T16-45
- Reviewer: feature-review agent (reduced minor-audit review)
- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `a14899f7b059f0059866c0a67216475ceecf0a94`
- Base: `origin/main` @ `9338ed463c63a039cadbe4f0548af7151f43f687`; diff `git diff origin/main...HEAD`
- Companion artifacts: `policy-audit.2026-10-12T16-45.md`, `feature-audit.2026-10-12T16-45.md`

## Executive Summary

The change is coherent and narrowly scoped. Every surface that defined or restated the CI gate population now states "every check on the PR head SHA", and the Codex gate reaches parity with the Claude S9 procedure (parser invocation, `-RequireWorkflow CI` epic-child guard, no-checks rule) plus an added parser-absent fail-closed rule. No parser behavior, `ci_gate` schema, validator, or hook changed. All 13 edited surfaces are byte-identical to their bundle mirrors. The parallel-orchestrate edit is confined to Merge-on-Green steps 1-2 and does not touch the passages owned by #890.

Tests: the new Python contract module pins each requirement over both the source and the mirror, and includes two detector self-tests (line-wrap detection and false-positive guard). The two new Pester tests execute both default `NowProvider` delegates under a mocked `Get-Date`.

No Blocking code finding. Two Minor findings and two Info findings are recorded below. The Blocking item in this review cycle is the Python coverage-evidence gap recorded in the policy audit (PA-1); it is not a code defect.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/parallel-orchestrate/SKILL.md`; `.agents/skills/orchestrate/SKILL.md` (and mirrors) | Merge-on-Green step 2; `## CI Green Gate` steps 3 and 5 | CR-1: Both surfaces run the parser without `-RequireWorkflow CI` on a non-epic PR and address only the `no checks reported` error. If `gh pr checks --json` ever returns an empty array instead of that error, the parser returns `success` for the empty set. S9 closes this with "The parser is never run with `-ChecksJson '[]'` without `-RequireWorkflow CI`"; the other two surfaces carry no equivalent sentence. | Add one sentence to each surface stating that an empty check list is not green (keep polling or treat as `pending`), mirroring the S9 sentence; extend the contract module to pin it. | Parser help states that an empty set is `success` (vacuous). Current `gh` behavior emits the error for zero checks, so the risk depends on CLI behavior that is not pinned by any test. | `Invoke-CiGateParser.ps1` help lines 17-25; S9 No-checks rule; Merge-on-Green step 2 text in diff |
| Minor | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | lines 104 and 338 (pre-existing) | CR-2: The default delegate formats with `'yyyy-MM-ddTHH:mm:ssZ'`. In .NET custom format strings `:` is the culture time separator, so on a culture with a different separator `verified_at` is not ISO-8601. The new tests accommodate this with `?` wildcards instead of pinning the invariant form. | Follow-up: pass `[System.Globalization.CultureInfo]::InvariantCulture` (or escape the separators) in both defaults and tighten the assertions to the exact string. | Pre-existing; out of scope for this item. Recorded so the test accommodation is not read as the intended contract. | Diff lines of `Invoke-CiGateParser.Tests.ps1:420-423` comment "each '?' matches the culture time separator" |
| Info | `scripts/dev_tools/generate_codex_agent_variants.py` (not changed) | write path | CR-3: The generator writes CRLF on Windows, which made six pack manifests appear modified. The executor stripped CR from 18 files; the reviewer confirmed 0 CR bytes in all 12 TOML files and no pack-manifest path in the diff. | Follow-up candidate: write generator output with `newline="\n"`. | Pre-existing tooling behavior; the committed result is correct. | `evidence/other/codex-variants-regenerate.2026-10-11T09-44.md`; reviewer CR byte count |
| Info | `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | fragment constants, lines 48-101 | CR-4: The contract module pins exact sentence fragments, so future rewording requires a test update. Whitespace collapsing limits this to wording changes. | None required; this is the established pattern in the sibling `test_ci_gate_epic_child_contracts.py`. | Consistent with repository convention for documentation contracts. | Module docstring lines 12-14 |

## Detailed Notes

### Correctness of the population change

- S9 step 2 drops `--required` and states the query covers every check whether or not branch protection marks it as required. Step 3 restates the derivation "over the queried checks (every check on the PR head SHA, for every PR)". The epic-child rule is retained with its pinned wording; `test_ci_gate_epic_child_contracts.py` passes.
- The new No-checks rule correctly distinguishes the non-epic path (stay `pending`, continue the bounded poll) from the epic-child path (`-ChecksJson '[]'` with `-RequireWorkflow CI`, which returns `pending`).
- Merge-on-Green step 2 now requires an unconditional re-read through the parser and records `ci_green` only on `success`. The existing head-SHA equality and pending-CI-AC checks that follow are unchanged.

### Codex parity

- The Codex gate resolves `baseRefName` alongside `headRefOid`, so the epic-child decision is keyed directly on the PR base branch, as issue.md Implementation Intent specifies, rather than on a checkpoint field.
- The parser-absent rule fails closed, consistent with issue.md Dependencies/Risks (Codex-only consumers do not receive `.claude/lib/`).

### Tests

- The Pester tests use `Should -Invoke -CommandName Get-Date -Times 1 -Exactly`, which proves the default delegate ran rather than an injected one. Local JUnit records both as Passed; local coverage records lines 104 and 338 executed.
- The Python module covers source and mirror for each assertion (parametrized), and the population test spans 22 surfaces. The detector self-tests guard against both a false negative (wrapped text) and a false positive (`required keys`).

### Scope discipline

- `git diff -U0` on `parallel-orchestrate/SKILL.md` shows hunks only at lines 376 and 378-384.
- No change to `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`, `.claude/rules/`, or `.github/instructions/`.

## Verdict

No Blocking code finding. Non-blocking: 2 Minor (CR-1, CR-2) and 2 Info (CR-3, CR-4).
