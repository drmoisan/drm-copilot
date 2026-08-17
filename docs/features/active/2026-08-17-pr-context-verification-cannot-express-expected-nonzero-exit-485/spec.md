# 2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit (Spec)

- **Issue:** #485
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-17T16-40
- **Status:** Ready for planning
- **Version:** 1.0
- **Work Mode:** full-bug (`spec.md` is the sole acceptance-criteria source; `user-story.md` is intentionally absent)

## Context
The PR-context Verification evidence parser normalizes every non-zero `EXIT_CODE` to `fail`, and the evidence schema provides no way to declare an expected exit code. Any verification gate whose acceptance condition is a non-zero exit — most commonly a `git grep` whose acceptance is zero matches, which exits 1 — is reported as failed in the PR body even when it passed. Every expected-nonzero gate is mislabeled by construction.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `mcp__drm-copilot__collect_pr_context` (Verification evidence block)
- Data source or fixture: canonical evidence artifacts under `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

The PR body is the primary reviewer-facing verification record. A gate that passed is reported as failed, which either trains reviewers to discount `fail` rows or drives authors to one of three workarounds that all degrade traceability: misrecord `EXIT_CODE: 0`, wrap the command so the process exits 0 and lose the real exit code, or omit the artifact entirely and lose the evidence. The severity is High rather than Blocker because no gate is weakened — the failure mode is a false negative in reporting, not a false pass.


## Repro & Evidence
Steps to Reproduce:
1. Author a canonical evidence artifact for a gate whose acceptance condition is a non-zero exit, for example a `git grep` asserting a forbidden token is absent, which exits 1 when there are zero matches.
2. Record the observed exit code faithfully in the artifact as `EXIT_CODE: 1`.
3. Attempt to declare the expectation, for example by adding an `ExpectedExitCode: 1` line to the artifact.
4. Run `mcp__drm-copilot__collect_pr_context` and read the Verification block in the generated PR context.

Expected:
An evidence artifact can declare the exit code its gate is expected to produce. A gate whose observed exit code equals its declared expectation is normalized to `pass`. The default expectation remains `0`, so every existing artifact keeps its current result.

Actual:
The declared expectation is discarded and the row is reported as `fail`.

The normalization is a total binary partition with no third branch:

- `scripts/dev_tools/pr_context/verification_evidence.py:136`

  ```python
  normalized_result: NormalizedResult = "pass" if exit_code == 0 else "fail"
  ```

- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:146`

  ```typescript
  const normalizedResult: NormalizedResult = exitCode === 0 ? "pass" : "fail";
  ```

The `unparseable` result is reached only when a required field is missing or `EXIT_CODE` is not an integer; it is not an escape hatch for an expected non-zero exit.

The expectation cannot be expressed at all. `scripts/dev_tools/pr_context/verification_evidence.py:22` defines the accepted key set as exactly three fields, and the parse loop at lines 102-108 keeps only those keys:

```python
REQUIRED_FIELDS: tuple[str, str, str] = ("Timestamp", "Command", "EXIT_CODE")
...
    if key in REQUIRED_FIELDS:
        parsed[key] = value.strip()
```

An `ExpectedExitCode:` line is therefore dropped silently, with no warning and no `unparseable` signal. A repository-wide search for `expected_exit`, `expectedExit`, and `expected_nonzero` returns zero matches.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: see the two normalization lines quoted under Actual Behavior.


## Scope & Non-Goals

### In scope

- **One optional, flat, integer-valued evidence-artifact key** declaring the expected exit code, defaulting to `0` when the key is absent. Name: `ExpectedExitCode`. This matches the dominant PascalCase-without-space convention of the evidence schema (research §7.2: 6 of 8 multi-word keys) and is the name already recorded in `issue.md:29`. Research §7.1 verified that `expected_exit`, `expectedExit`, `expected_nonzero`, `ExpectedExit`, and `EXPECTED_EXIT` occur nowhere in the repository outside this feature's own documents, so the namespace is clean.
- **Normalization becomes "observed equals expected"** rather than "observed equals zero", replacing the expressions at `scripts/dev_tools/pr_context/verification_evidence.py:136` and `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:146`.
- **The result vocabulary stays exactly `pass | fail | unparseable`.** No fourth member is added. Research §4.1 records that a fourth member would force both collector filters (`scripts/dev_tools/pr_context/collector.py:147-149`, `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:98-101`) to widen or the row would silently disappear, for no informational gain over `pass` beside a declared expectation.
- **Both legs of the parity pair land in the same change:** `scripts/dev_tools/pr_context/verification_evidence.py` and `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`.
- **Test coverage in both runtimes.** A new dedicated Python test module (none exists today, research §5.2) and an extension of the existing `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`.
- **The documentation update** to `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` and its five sibling copies and mirrors (research §9.5).
- **The rendering layer**, brought into scope by this spec. See "Rendering decision" below for the reason and the boundary.

### Rendering decision — in scope, with an explicit boundary

`scripts/dev_tools/pr_context/collector.py:155-165` and `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:115-124` are **in scope** for one conditional line each.

Reason: with the parser change alone, a reviewer reading the PR body sees `EXIT_CODE: 1` immediately above `Normalized result: pass` with nothing explaining the pair. That row is not self-describing and is indistinguishable from a normalization defect. The defect being fixed is a reviewer-facing reporting defect (`issue.md:79`); a fix that produces an unexplained `pass` on a non-zero exit substitutes one form of reviewer distrust for another, in the more dangerous direction. Research §7.7 reaches the same conclusion.

Boundary, stated so the change cannot grow:

- Exactly one line is added to each row renderer, emitted **only** when the record's parsed expectation is a non-zero integer, inserted between the `EXIT_CODE` line and the `Normalized result` line. Proposed text: `  - Expected EXIT_CODE: <int>`.
- The filters at `collector.py:147-149` and `collector-output.ts:98-101` are **not** touched.
- Section placement (`collector.py:513-514`, `collector-output.ts:236-237`), sort order, and the fallback string `No canonical verification evidence parsed` are **not** touched.
- `scripts/dev_tools/pr_context/collector.py` is already 619 lines, over the 500-line limit in `.claude/rules/general-code-change.md` (research §9.1). This change adds a small number of lines to a pre-existing violation. Extraction or splitting of that file is **out of scope**; the counter-argument is pre-recorded here so a reviewer does not have to rediscover it. The same constraint applies to `tests/scripts/dev_tools/test_collect_pr_context_part4.py` (already over the limit): any new Python collector-level test must go in a new sibling module, not into that file.

### Out of scope — recorded as follow-up work, not fixed here

**Duplicate-`EXIT_CODE` precedence divergence.** The two runtimes already disagree on which occurrence of a duplicated `EXIT_CODE:` line wins:

- Python assigns unconditionally at `verification_evidence.py:108`, so **last occurrence wins** (research §1.4 item 4).
- TypeScript guards with `!parsed.has(key)` at `verification-evidence.ts:110-113`, so **first occurrence wins** (research §2.3). The code comment at `verification-evidence.ts:101-102` claims this "mirrors the Python dict-first-write semantics"; research §2.3 records that this claim is factually incorrect.

Research §3.2 measured the population: of the 968 canonical evidence artifacts containing at least one line-anchored `EXIT_CODE:`, **156 (16.1%) contain two or more** and are therefore reported differently by the two runtimes today. A worked example is `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/other/d1-grep-gates.2026-08-17T00-47.md`, where Python reads line 18 and reports `pass` while TypeScript reads line 9 and reports `fail`.

Converging that divergence changes the reported result for real, existing, git-tracked artifacts. That directly contradicts this fix's additive requirement, whose whole content is that no existing artifact changes its rendered row. It is therefore a **separate defect**, is not fixed here, and is recorded under "Rollout & Follow-up" for separate promotion. Research §3.3 (Option P1 versus P2) is the section that framed the choice; this spec takes **Option P2** — defer and file separately.

**Consequence that must be specified here.** Because `EXIT_CODE` precedence is untouched and asymmetric, the precedence rule for the **new** key must be stated explicitly and identically for both runtimes. See "Duplicate-key rule for the new key" under Proposed Fix. No artifact on disk can carry the new key (research §7.1 verified zero occurrences repository-wide), so specifying one rule for both runtimes is not a behavior change for any existing artifact.

**Reuse, import, or duplication of `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` is prohibited.** Research §8 substantiated a fourfold mismatch: different input type (`PlanModel`-derived `ResolvedTestExpectations` from `scripts/dev_tools/atomic_executor/pytest_expectations.py:89-111` versus a markdown evidence artifact), different granularity (pytest node-id prefixes matched by `str.startswith` at `qc_runner_expectations.py:22-25` versus one process exit code), different side-effect class (that module calls `subprocess.run` at lines 57, 75, 118, 135, whereas `parse_verification_evidence_markdown` declares `Side Effects: None.` at `verification_evidence.py:96-97`), and different lifecycle position (a gate during implementation versus a description after the fact). Research §8 also verified by import-graph search that no file under `scripts/dev_tools/pr_context/` references `qc_runner_expectations` or `pytest_expectations`. That property must hold after this change.

**Per-gate expectations in a multi-gate artifact.** A flat key carries exactly one expectation per file, so an artifact recording several gates still cannot express "gate 1 expects 1, gate 2 expects 0" (research §7.5). Solving that requires a block-scoped or section-scoped schema, a materially larger change to both parsers and to six documentation copies. Out of scope; documented as a known limitation with the practical guidance that a gate needing a non-zero expectation is recorded in its own artifact file, as `docs/features/active/2026-07-17-legacy-discovery-validators-361/evidence/qa-gates/domain-neutrality-grep.2026-07-18T10-20.md` already does.

**List-valued and boolean forms of the key.** `ExpectedExitCodes:` accepting a list and `ExpectedNonZeroExit: true` / `ExpectedResult: pass` are both rejected (research §7.3 Options B and C). The list form has no demonstrated need in the corpus and multiplies the cross-runtime parity surface (separator, empty-element, and ordering semantics must be kept byte-identical across `str.split` and `String.prototype.split`). The boolean and qualitative forms discard the value, so a `git grep` exiting 2 on a bad pathspec would be reported as passing — a false-positive direction, strictly worse than the present false negative. The chosen single-integer key remains a strictly additive base for a future list form, since a bare integer is a valid one-element list.

### Explicitly excluded systems, integrations, and datasets

- The three canonical evidence roots the PR-context parser does **not** discover — `evidence/baseline/`, `evidence/issue-updates/`, `evidence/remediation-baseline/` — are outside `CANONICAL_GLOBS` (`verification_evidence.py:23-27`, `verification-evidence.ts:27-31`) even though `.claude/skills/evidence-and-timestamp-conventions/SKILL.md:14-20` lists them as canonical. Research §1.1 records this as pre-existing. `CANONICAL_GLOBS` is not changed by this fix.
- `scripts/dev_tools/pr_context/feature_docs.py` and `extensions/drm-copilot/src/lib/pr-context/feature-docs.ts` use discovery only and never read the normalized result (research §1.6, §2.5). Not changed.
- `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`, `collector-core.ts`, `index.ts`, and every MCP tool-definition file read no normalized result (research §4.1). Not changed, except that `index.ts:74-80` continues to re-export the record type whose shape grows by one member.
- `.claude/skills/atomic-plan-contract/SKILL.md` names the required field set at lines 34, 45, 87, 102. The new key is optional, so the "MUST include" lists there do not change and that skill's six-copy fan-out is not touched.
- No GitHub Actions workflow, no benchmark baseline, and no branch-protection configuration is touched, so neither `.claude/rules/ci-workflows.md` nor `.claude/rules/benchmark-baselines.md` imposes a green-run requirement on this diff (research, Automation Feasibility item 4).

## Root Cause Analysis
The evidence schema was designed around the assumption that exit code 0 is the only success condition. That assumption holds for the toolchain stages it was built for (format, lint, type-check, test) and fails for absence assertions, which are common in acceptance criteria and in policy gates.

Related but distinct machinery already exists and must not be confused with this defect. The `[expect-fail]` tag in the atomic-plan contract and the expected-fail resolution in `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` operate at test-node granularity inside the atomic-executor QC loop. Neither module is imported by `scripts/dev_tools/pr_context/`, and the two surfaces have different inputs. A fix belongs in the evidence schema and its two parsers; it should not be duplicated from the executor QC path.

Any fix must land in both runtimes. `scripts/dev_tools/pr_context/verification_evidence.py` and `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` are a parity pair, and a change to one without the other produces divergent PR context depending on which surface generated it.


## Proposed Fix

### Design summary (what changes where):

Add one optional, flat, integer-valued key `ExpectedExitCode` to the evidence-artifact schema, defaulting to `0` when absent, and change the normalization in both parsers from a comparison against the literal `0` to a comparison against the parsed expectation.

| Change | File | Anchor from research |
| --- | --- | --- |
| Accept `ExpectedExitCode` without altering `REQUIRED_FIELDS` | `scripts/dev_tools/pr_context/verification_evidence.py` | constant at line 22, parse loop at 99-108 |
| Same | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | constant at line 24, parse loop at 103-116 |
| Add `expected_exit_code` to the record | `scripts/dev_tools/pr_context/verification_evidence.py` | dataclass at 32-54 |
| Add `expectedExitCode` to the record | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | interface at 37-44 |
| Replace `pass if exit_code == 0 else fail` with an equality test against the expectation | `scripts/dev_tools/pr_context/verification_evidence.py` | line 136 |
| Replace `exitCode === 0 ? "pass" : "fail"` with the same equality test | `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` | line 146 |
| One conditional row line, emitted only when the expectation is non-zero | `scripts/dev_tools/pr_context/collector.py` | row rendering at 155-165 |
| Same | `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` | row rendering at 115-124 |
| Document the optional key | `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` and its five siblings/mirrors | research §9.5 |

The parse decision becomes a five-way partition, unchanged in shape and extended in one branch:

```
missing or empty required field       -> unparseable
EXIT_CODE not an integer              -> unparseable
ExpectedExitCode present, not an int  -> unparseable            (new)
observed == expected (default 0)      -> pass                   (was: observed == 0)
otherwise                             -> fail
```

For every artifact carrying no `ExpectedExitCode` line, `expected == 0` and the last two rows collapse to the pre-change expression exactly.

### Boundaries and invariants to preserve:

**Invariant A — the additive guarantee (central invariant).** An evidence artifact that carries no `ExpectedExitCode` line must produce a **byte-identical** Verification row, and therefore a byte-identical Verification section, before and after this change. Research §6.1 measured the population this covers: 968 artifacts under `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md` contain at least one line-anchored `EXIT_CODE:`, and research §7.1 verified that **zero** of them can contain the new key, because the token does not occur anywhere in the repository outside this feature's own documents. The corpus is by construction a pure "no expectation key present" population.

Invariant A is proved in two layers, not asserted:

- *Layer 1 — hermetic exhaustive assertion over the default path.* Extract the normalization into a named pure helper in each runtime (`normalize_result(exit_code: int, expected_exit_code: int) -> NormalizedResult` and its TypeScript analogue) and assert, over a bounded integer range plus large magnitudes, that `normalize_result(observed, 0) == ("pass" if observed == 0 else "fail")`. This is an exact, deterministic restatement of the pre-change expressions at `verification_evidence.py:136` and `verification-evidence.ts:146` and proves the default path unchanged over the exercised integer domain rather than for a sampled set. It requires no filesystem, no fixture files, and no temporary files (research §6.2).
- *Layer 2 — differential run over the measured real-artifact corpus, recorded as evidence.* A throwaway comparison script computes, for each discovered artifact, the pre-change record and the post-change rendered six-line row, and diffs them. It is run once per runtime and the result is recorded at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` carrying the artifact count and the diff count. The script is deleted before the final toolchain loop, under the temporary-throwaway-script exception in `.claude/rules/general-code-change.md`. It is deliberately **not** committed as a unit test: the corpus mutates whenever a feature lands, which would make a committed test non-deterministic across time and couple the test suite to documentation content (research §6.3).

The pre-change reference side of Layer 2 needs no git manipulation: for an artifact with no expectation key, pre-change output is fully determined by `("pass" if exit_code == 0 else "fail")`, so the script computes the reference inline (research §6.3).

**Invariant B — cross-runtime parity (second invariant).** Both runtimes must accept the same artifact text and produce the same normalized result and the same rendered row for the new key. Verified concretely by three mechanisms:

1. A shared eleven-shape fixture table (research §6.2) transcribed verbatim into both suites so a reviewer can diff them by eye. Every shape in the table carries exactly one `EXIT_CODE:` line, so the deferred duplicate-`EXIT_CODE` divergence cannot confound the comparison.
2. One test per runtime pinning the duplicate-`ExpectedExitCode` precedence rule stated below, mirroring the existing TypeScript test at `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:151-159`.
3. The Layer 2 corpus run executed in both runtimes and compared runtime-to-runtime, **scoped to artifacts containing exactly one `EXIT_CODE:` line**. Because Option P2 defers the duplicate-key divergence, a whole-corpus cross-runtime diff is expected to report the 156 multi-`EXIT_CODE` artifacts as differing (research §3.2, §6.3). Those artifacts are excluded from the parity assertion, and their count is recorded in the evidence artifact as attributable to the deferred defect, so the exclusion is auditable rather than silent.

**Invariant C — the result vocabulary is closed.** `NormalizedResult` remains exactly `pass | fail | unparseable` in both runtimes (`verification_evidence.py:29`, `verification-evidence.ts:34`). Neither collector filter changes.

**Invariant D — `REQUIRED_FIELDS` is byte-identical after the change.** The new key is optional. The Python annotation is arity-bearing (`tuple[str, str, str]`, `verification_evidence.py:22`) so adding a member would force an annotation change and mislabel an optional field as required; the TypeScript constant is `export`ed (`verification-evidence.ts:24`) so its member set is public surface (research §7.6). The parse loop instead consults a private combined accept-list.

**Invariant E — unparseable records carry no partial data.** Every record whose `normalized_result` is `unparseable` carries `exit_code = None` / `exitCode = null` **and** `expected_exit_code = 0` / `expectedExitCode = 0`, in both runtimes and on every unparseable branch including the new one. This preserves the existing contract at `verification_evidence.py:114-134` exactly and gives the new field a single documented value on that path.

**Invariant F — pre-existing unparseable behavior is unchanged.** `EXIT_CODE: SKIPPED` continues to yield `unparseable` and the row continues to be dropped by the collector filter. `.claude/skills/atomic-plan-contract/SKILL.md:135` explicitly contemplates that literal value and forbids treating it as passing; this fix must not change it.

**Invariant G — no import edge to the atomic-executor QC path.** After the change, no file under `scripts/dev_tools/pr_context/` references `qc_runner_expectations` or `pytest_expectations` (research §8).

### Duplicate-key rule for the new key

**Rule: the first occurrence of `ExpectedExitCode:` in an artifact wins, in both runtimes.** A second or later occurrence is ignored.

Justification:

1. **It is free to specify.** No artifact on disk carries the key (research §7.1), so no existing artifact's rendered row changes under either choice. This is exactly the case the orchestrator identified as unconstrained by the additive requirement.
2. **It costs nothing in the runtime that serves the reported surface.** Research §2.6 established that `mcp__drm-copilot__collect_pr_context` is served in-process by the TypeScript implementation (`extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts:27,71-81`), not by a Python subprocess. The TypeScript accept-list guard `!parsed.has(key)` at `verification-evidence.ts:110-113` is already first-wins, so adding the key to the combined accept-list yields first-wins with no per-key special-casing and no new branch.
3. **It is forward-compatible with the deferred fix.** Research §3.3 records that convergence, when it is done separately, should converge on first-wins, because that is what the MCP surface produces today and what the existing test at `verification-evidence.test.ts:151-159` asserts. Choosing first-wins now means the deferred convergence never has to revisit the new key. Choosing last-wins would create a second key requiring a second behavior change later.
4. **The cost is bounded and one-sided.** Python's loop assigns unconditionally at `verification_evidence.py:108`, so first-wins for the new key requires a key-scoped conditional write for the optional key only, leaving the `EXIT_CODE` assignment untouched. Python therefore carries two precedence rules in one loop until the deferred defect is fixed. That asymmetry is documented here, is covered by a named test in each runtime, and is strictly narrower than the alternative, which would require special-casing in the runtime the reporter actually used.

### Dependencies or blocked work:

- No blocking dependency. Research recorded no blocking unknown, and its Automation Feasibility section concluded the fix and its verification are fully automatable with no human interaction required at any step.
- The documentation edit depends on the push-down generators `scripts/dev_tools/push_down_claude_customizations.py`, `scripts/dev_tools/push_down_copilot_customizations.py`, and `scripts/dev_tools/push_down_codex_and_agents_customizations.py`. Editing a canonical skill without regenerating its mirrors fails the push-down contract tests (research §9.5).
- Not blocked by, and does not block, the deferred duplicate-`EXIT_CODE` defect.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production, required:
- `scripts/dev_tools/pr_context/verification_evidence.py` (171 content lines, research §1; ample headroom under the 500-line limit)
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (248 lines, research §2.1)

Production, required by the rendering decision:
- `scripts/dev_tools/pr_context/collector.py:155-165` (619 lines, pre-existing over-limit file)
- `extensions/drm-copilot/src/lib/pr-context/collector-output.ts:115-124` (449 lines, 51 lines of headroom)

Tests, required:
- New `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` plus `tests/scripts/dev_tools/pr_context/__init__.py`. The strict mirror path is chosen over the flat sibling convention of `tests/scripts/dev_tools/test_collect_pr_context*.py` because `.claude/rules/general-unit-test.md` requires a mirroring tree and the repository already has the precedent `tests/scripts/dev_tools/atomic_executor/__init__.py` (research §9.3).
- Extend `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` (219 lines).

Tests, required by the rendering decision:
- Extend `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` (`describe("renderVerificationEvidenceSection")` at line 268).
- Add the Python collector-level case to a **new** sibling module, not to `tests/scripts/dev_tools/test_collect_pr_context_part4.py`, which is already over the 500-line limit (research §9.1).

Documentation, required (research §9.5):
- `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (canonical schema block at lines 106-112)
- `.github/skills/evidence-and-timestamp-conventions/SKILL.md` (block at lines 79-84)
- `.agents/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/claude-customizations/.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/customizations/.github/skills/evidence-and-timestamp-conventions/SKILL.md`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/evidence-and-timestamp-conventions/SKILL.md`

Evidence, required:
- `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md`, plus the standard baseline and final-QC artifacts under `<FEATURE>/evidence/<kind>/`.

#### Functions/classes/CLI commands impacted:

| Symbol | File:lines | Change |
| --- | --- | --- |
| `REQUIRED_FIELDS` | `verification_evidence.py:22`, `verification-evidence.ts:24` | none (Invariant D) |
| new optional-field constant and private combined accept-list | both parsers | added |
| `VerificationEvidenceRecord` | `verification_evidence.py:32-54`, `verification-evidence.ts:37-44` | one member added |
| `parse_verification_evidence_markdown` / `parseVerificationEvidenceMarkdown` | `verification_evidence.py:83-144`, `verification-evidence.ts:93-155` | parse loop and normalization |
| new pure `normalize_result` helper | both parsers | added, to make Layer 1 assertable |
| `parse_verification_evidence_file` / `parseVerificationEvidenceFile` | `verification_evidence.py:147-171`, `verification-evidence.ts:169-184` | unchanged |
| `discover_canonical_evidence_files` / `discoverCanonicalEvidenceFiles` | `verification_evidence.py:57-80`, `verification-evidence.ts:59-80` | unchanged |
| `_render_verification_evidence_section` / `renderVerificationEvidenceSection` | `collector.py:115-166`, `collector-output.ts:69-126` | one conditional line |
| CLI `dev.pr-context` (`pyproject.toml:79`) | — | no flag change; behavior change only via the parser |
| MCP `collect_pr_context` (served by `pr-context-service-call.ts:27,71-81`) | — | no parameter change |

#### Data flow and validation changes:

1. The parse loop keeps `Key: value` rows whose key is in the private combined accept-list. `REQUIRED_FIELDS` keeps its existing per-runtime precedence; `ExpectedExitCode` uses first-wins in both runtimes.
2. Required-field validation is unchanged: missing or empty `Timestamp`, missing or empty `Command`, or absent `EXIT_CODE` yields `unparseable` (`verification_evidence.py:114-122`, `verification-evidence.ts:123-132`).
3. `EXIT_CODE` integer parsing is unchanged (`int()` in `try/except ValueError` at `verification_evidence.py:124-134`; `/^[+-]?\d+$/u` plus `parseInt` at `verification-evidence.ts:196-201`). Research §2.4 records that these differ for exotic inputs Python accepts and the regex rejects, such as `1_0` and Unicode decimal digits; no corpus artifact exercises the difference and this fix does not change either implementation.
4. `ExpectedExitCode` is parsed with the **same** strictness as `EXIT_CODE` in each runtime, so the two fields cannot diverge within a runtime. Absent key ⇒ expectation `0`. Present and integer ⇒ that integer. Present and not an integer ⇒ `unparseable` (see error handling).
5. No range validation is applied to the expectation. A negative value is accepted because both integer parsers accept a leading sign; the field is used for equality comparison only.
6. Normalization: `pass` when the parsed observed code equals the parsed expectation, `fail` otherwise.
7. Rendering: the collector filter set is unchanged (`{"pass", "fail"}`), the six existing row lines are unchanged, and one line is emitted between the `EXIT_CODE` and `Normalized result` lines when and only when the record's expectation is non-zero. Because the record stores an integer that defaults to `0`, an artifact that explicitly writes `ExpectedExitCode: 0` renders identically to one that omits the key. That is intentional: it makes Invariant A a structural property of the renderer rather than a property that has to be established by testing.

#### Error handling and logging updates:

- A present-but-non-integer `ExpectedExitCode` yields `unparseable`, consistent with the existing treatment of a non-integer `EXIT_CODE`. Research §7.4 compared this (sub-option A1) against silently ignoring the value and defaulting to `0` (sub-option A2) and recommended A1 on consistency grounds: A1 is conservative and can never produce a false `pass`, whereas a silent-ignore rule is precisely the mechanism that produced this defect (`issue.md:65`). A1 also matches the unit-coverage area the issue already lists at `issue.md:91`.
- The recorded cost of A1, stated so it is not discovered later: `unparseable` records are **dropped entirely** by both collector filters (`collector.py:147-149`, `collector-output.ts:98-101`), so a typo in the expectation value removes a row that renders today rather than degrading it to `fail`. The trade-off is accepted because the alternative reintroduces silent discarding.
- A1 does not weaken Invariant A. The additive guarantee is scoped to artifacts carrying **no** expectation key, and all 968 measured artifacts satisfy that (research §6.1, §7.4).
- Neither parser logs. `parse_verification_evidence_markdown` declares `Side Effects: None.` (`verification_evidence.py:96-97`) and that contract is preserved. Read failures continue to propagate (`verification_evidence.py:161` raises `OSError`; `verification-evidence.ts:167` throws) and both callers continue to catch them.

#### Rollback/feature-flag considerations (if applicable):

No feature flag. A flag would require a second code path through a pure function whose default path is proved unchanged, and the flag's off-state is already the observable behavior for every existing artifact. Rollback is a revert of the commit; because the change is additive and no artifact on disk carries the key, a revert restores prior behavior for the entire corpus with no data migration and no artifact edits.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

Input, per artifact, unchanged except for one optional line:

```
Timestamp: <ISO-8601 yyyy-MM-ddTHH-mm>
Command: <exact command>
EXIT_CODE: <int>
ExpectedExitCode: <int>        # optional; defaults to 0 when absent
```

Key matching is case-sensitive and exact after `strip`/`trim` of the key, and the value is everything after the first colon, stripped (research §1.4 items 1-2). `ExpectedExitCode` must therefore be written exactly in that casing; `expectedexitcode` or `Expected Exit Code` will not match and will be discarded as an unrecognized row, exactly as any other unrecognized `Key: value` row is today.

Output, per record:

| Python member | TypeScript member | Type | Value |
| --- | --- | --- | --- |
| `feature` | `feature` | `str` / `string` | unchanged |
| `source_file` | `sourceFile` | `str` / `string` | unchanged |
| `timestamp` | `timestamp` | `str \| None` / `string \| null` | unchanged |
| `command` | `command` | `str \| None` / `string \| null` | unchanged |
| `exit_code` | `exitCode` | `int \| None` / `number \| null` | unchanged |
| `expected_exit_code` | `expectedExitCode` | `int` / `number` | **new**; `0` when the key is absent or the record is `unparseable` |
| `normalized_result` | `normalizedResult` | `NormalizedResult` | vocabulary unchanged |

Rendered row output, unchanged except for the conditional line:

```
- Feature: <feature>
  - Source: <source_file>
  - Timestamp: <timestamp>
  - Command: <command>
  - EXIT_CODE: <observed>
  - Expected EXIT_CODE: <expected>      # emitted only when expected != 0
  - Normalized result: <pass|fail>
```

#### Required configuration keys and defaults:

None. No entry is added to any file under `config/`, no CLI flag is added to `dev.pr-context`, and no MCP tool parameter changes. The single new key is an evidence-artifact field, defaulting to `0`, documented in the six copies of `evidence-and-timestamp-conventions/SKILL.md`.

#### Backward-compatibility expectations:

- **Artifacts:** fully backward compatible. Every artifact discovered by `CANONICAL_GLOBS` renders a byte-identical row (Invariant A).
- **Python record construction:** `expected_exit_code: int = 0` is appended as the last field of the frozen dataclass. `normalized_result` has no default, so appending a defaulted field last is legal and leaves existing keyword construction valid.
- **TypeScript record construction:** `readonly expectedExitCode: number` is added as a required interface member. `extensions/drm-copilot/src/lib/pr-context/index.ts:74-80` re-exports `VerificationEvidenceRecord`, so this is a public-surface addition on the extension side. Every in-repo construction site must be updated; any test that builds a record as an object literal rather than through the parser must be updated with it.
- **Result vocabulary:** unchanged, so no consumer of `normalizedResult` needs to widen a filter or a switch (research §4 lists all four read sites).
- **Documentation mirrors:** byte-identity across the six copies is enforced by `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, and the copilot-side equivalents.

#### Performance constraints (latency/throughput/memory):

No measurable constraint applies and none is introduced. The change adds at most one accept-list membership test per parsed line and one integer parse per artifact, on a parser that already performs one membership test per line over a single-pass `splitlines`. Memory grows by one integer per record. No benchmark gate covers this path, so `.claude/rules/benchmark-baselines.md` imposes no baseline-capture obligation on this diff.

## Assumptions, Constraints, Dependencies

### Assumptions (environment, data, access)

- **A1.** No evidence artifact in the repository carries the token `ExpectedExitCode` (or any of `expected_exit`, `expectedExit`, `expected_nonzero`, `ExpectedExit`, `EXPECTED_EXIT`) outside this feature's own documents. Verified by the repository-wide search in research §7.1. Invariant A depends on this; it is re-verified as an acceptance criterion rather than assumed at implementation time.
- **A2.** The corpus the parser reads is `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md` per `CANONICAL_GLOBS` (`verification_evidence.py:23-27`). Research §6.1 measured 968 artifacts with a line-anchored `EXIT_CODE:`, of which 103 carry at least one non-zero-looking value and 156 carry two or more `EXIT_CODE:` lines. These counts are measurements taken on branch `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485` and will drift as features land; the acceptance criteria assert a **diff count of zero over the set discovered at run time**, not a fixed artifact count.
- **A3.** `mcp__drm-copilot__collect_pr_context` is served in-process by the TypeScript implementation, not by a Python subprocess (research §2.6). Both runtimes are nonetheless live: the Python path is reachable through the Poetry console script `dev.pr-context` (`pyproject.toml:79`).
- **A4.** All verification runs offline against the working tree. No GitHub API, credential, runner, or interactive prompt is required (research, Automation Feasibility items 1-3).
- **A5.** Tests run with in-memory filesystems only: `mem_fs_path` (`tests/conftest.py:145-172`) for Python, `SeededFileSystem` (`extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:46-98`) and `TreeFileSystem` (`extensions/drm-copilot/test/lib/pr-context/tree-file-system.ts`) for TypeScript. `tmp_path` is never used.

### Constraints (budget, performance, compatibility)

- **C1 — File size.** `.claude/rules/general-code-change.md`: no production, test, or reusable script file may exceed 500 lines. Both parser files have headroom (171 and 248 lines). `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` has 51 lines of headroom. `scripts/dev_tools/pr_context/collector.py` (619 lines) and `tests/scripts/dev_tools/test_collect_pr_context_part4.py` (at least 684 lines) are **already over the limit** (research §9.1). This change adds a minimal number of lines to `collector.py` and adds **no** lines to the over-limit test file; extraction of either is out of scope.
- **C2 — Coverage.** Line coverage >= 85% and branch coverage >= 75%, uniform across T1-T4, for both Python and TypeScript (`.claude/rules/quality-tiers.md`, `.claude/rules/general-unit-test.md`). Coverage regression on changed lines is a blocking finding (`.claude/rules/python.md:90`, `.claude/rules/typescript.md:52`). Research §5.2 established that `verification_evidence.py` has **no dedicated Python test module** and that its `fail` branch and its non-integer-`EXIT_CODE` branch are untested, so a new Python test module is mandatory to avoid a measurable regression on changed lines.
- **C3 — Coverage flags are load-bearing.** `pyproject.toml:114-117` sets `addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"` with **no** `--cov` and no `fail_under` in `[tool.coverage.report]` (lines 129-140). A pytest run that omits `--cov --cov-branch` measures nothing (research §5.3). The thresholds are policy-enforced, not configuration-enforced.
- **C4 — Test placement and hermeticity.** Tests mirror the production tree; temporary files are prohibited (`.claude/rules/general-unit-test.md`). Arrange-Act-Assert, one behavior per test, `pytest.mark.parametrize` for the boundary matrix.
- **C5 — Determinism.** No clock, randomness, network, or subprocess in any test. The `.claude/rules/general-unit-test.md` "Determinism Infrastructure" section imposes no additional obligation on this change (research §12).
- **C6 — Mirror byte-identity.** The six copies of `evidence-and-timestamp-conventions/SKILL.md` must remain byte-identical; the three canonical copies are edited and the three bundled mirrors regenerated by the push-down scripts (research §9.5).
- **C7 — Both runtimes land together.** A change to one parser without the other produces divergent PR context depending on which surface generated it (`issue.md:87`).

### External dependencies (services, libraries, releases)

- None added. No new Python or npm dependency is introduced; the change uses only `int()` / an existing strict integer helper already present in each parser.
- Existing toolchain only: Poetry (Black, Ruff, Pyright, pytest with coverage) and the extension workspace npm scripts (Prettier, ESLint, tsc, Jest).
- No release, service, or runner dependency.

## Data / API / Config Impact

### User-facing or API changes

- **Evidence-artifact schema (user-facing to agents and authors):** one optional key, `ExpectedExitCode: <int>`, default `0`. Documented in `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` beside the existing `Timestamp` / `Command` / `EXIT_CODE` block at lines 106-112, and in the five sibling copies and mirrors.
- **PR-body output (user-facing to reviewers):** one additional row line, `  - Expected EXIT_CODE: <int>`, emitted only when the parsed expectation is non-zero. No row is added, removed, or reordered for any artifact that omits the key.
- **Library surface, TypeScript:** `VerificationEvidenceRecord` gains a required `readonly expectedExitCode: number`. The interface is re-exported from `extensions/drm-copilot/src/lib/pr-context/index.ts:74-80`, so this is an additive public-surface change for consumers that read records and a breaking change for any consumer that constructs a record as an object literal. No such external consumer exists in-repo.
- **Library surface, Python:** `VerificationEvidenceRecord` gains `expected_exit_code: int = 0`, appended last so existing construction remains valid. The module has no `__all__` and is not re-exported through a package `__init__` (research §1.3, §3.1).
- **No change** to `mcp__drm-copilot__collect_pr_context` parameters, to the `dev.pr-context` CLI flags, or to the artifact path `artifacts/pr_context.summary.txt` (`collector.py:103`, `pr-context-service-call.ts:30`).

### Data or migration considerations

- **No migration.** The default of `0` makes every existing artifact correct as written; no artifact is edited, rewritten, or reformatted by this change.
- **Authoring guidance, forward:** a gate whose acceptance condition is a non-zero exit records the observed code faithfully in `EXIT_CODE:` and declares the expectation in `ExpectedExitCode:`. Because the key is per-file, a gate needing a non-zero expectation belongs in its own artifact file (Invariant, out-of-scope item "Per-gate expectations").
- **Existing workarounds are not migrated automatically.** Research §3.2 identified artifacts whose authors already worked around the missing field by annotating the value inline, for example `docs/features/active/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/evidence/other/cross-cutting-gates.2026-08-17T02-25.md`, whose `EXIT_CODE:` values such as `1 -> **zero matches**. Neither ...` are not integers and therefore render as `unparseable` and are dropped. Those artifacts continue to behave exactly as they do today; rewriting them is not in scope.

### Logging/telemetry updates (if any)

None. Neither parser logs, and the `Side Effects: None.` contract at `verification_evidence.py:96-97` is preserved. No telemetry surface reads the normalized result (research §4 enumerates all four read sites: two production renderers and two test modules).

### Compatibility notes (CLI flags, config schemas, versioning)

- No CLI flag added or changed.
- No config schema touched. There is **no JSON Schema, golden file, or snapshot fixture** keyed on the result vocabulary anywhere in the repository; research §4 verified that the strings `Normalized result` and `No canonical verification evidence parsed` appear in exactly nine files — two production, two test, and five historical feature documents. The evidence schema is prose in the conventions skill, so there is no schema artifact to version.
- No version bump is required by this change on its own.

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: parser acceptance of the new expectation key; default-to-zero behavior when the key is absent; normalization to `pass` when observed equals expected; normalization to `fail` when observed differs from a non-zero expectation; `unparseable` when the expectation value is not an integer.
- [ ] Integration scenario to retest: generate PR context for a feature carrying one absence-assertion gate with a declared non-zero expectation and confirm the Verification row reads `pass` while still displaying the observed exit code.
- [ ] Manual verification notes: confirm byte-identical Verification output for a feature whose artifacts carry no expectation key, so the change is additive. Confirm Python and TypeScript parity across the same artifact set.

### Regression tests to add or update

- **New Python module** `tests/scripts/dev_tools/pr_context/test_verification_evidence.py` (plus `tests/scripts/dev_tools/pr_context/__init__.py`). This module is the first dedicated Python test for `verification_evidence.py`; research §5.2 verified none exists and that the `fail` branch at line 136 and the non-integer-`EXIT_CODE` branch at 124-134 have no Python test at all. Covering them is required to avoid a coverage regression on changed lines (constraint C2).
- **Extend** `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` (219 lines, 9 tests). Add the eleven-shape table and the duplicate-`ExpectedExitCode` precedence test alongside the existing `describe("parseVerificationEvidenceMarkdown")` block at lines 104-160. Reuse the in-memory `SeededFileSystem` at lines 46-98; add no disk access.
- **Extend** `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts` (`describe("renderVerificationEvidenceSection")` at line 268) with two cases: the conditional line appears when the expectation is non-zero, and it does not appear when the key is absent.
- **New Python collector-level module** (a new sibling of `tests/scripts/dev_tools/test_collect_pr_context_part4.py`, not an edit to it, per constraint C1) with the same two rendering cases.
- **Unchanged and must stay green:** the three existing collector-level Python tests that exercise the module indirectly — `test_collector_includes_canonical_evidence_paths_in_additional_context_files` (`tests/scripts/dev_tools/test_collect_pr_context.py:318`), `test_collector_verification_evidence_section_is_rendered_with_normalized_fields` (`tests/scripts/dev_tools/test_collect_pr_context_part4.py:305`), and `test_collector_reports_unparseable_evidence_without_claiming_completion` (`tests/scripts/dev_tools/test_collect_pr_context_part4.py:500`) — plus the four existing TypeScript `renderVerificationEvidenceSection` tests and the nine existing `verification-evidence.test.ts` tests. None of them may be modified; any edit to them is evidence that Invariant A was broken.

### Unit tests (pytest) for the fixed behavior and boundaries

The eleven-shape fixture table of research §6.2 is transcribed verbatim into both suites (Invariant B mechanism 1). Every shape carries exactly one `EXIT_CODE:` line.

| # | Shape | Expected record |
| --- | --- | --- |
| 1 | all three required fields, `EXIT_CODE: 0` | `pass`, expectation `0` |
| 2 | all three, `EXIT_CODE: 1` | `fail`, expectation `0` |
| 3 | `EXIT_CODE` non-integer (`ok`, `SKIPPED`, `1 -> **zero matches**`) | `unparseable`, `exit_code=None`, expectation `0` |
| 4 | a required field missing | `unparseable` |
| 5 | a required field present but empty | `unparseable` |
| 6 | duplicated `EXIT_CODE` lines | pins each runtime's existing precedence explicitly |
| 7 | an unrelated `Key: value` row (`Output Summary:`) present | ignored; record identical to shape 1 |
| 8 | expectation key absent (the additive case) | identical to the pre-change record |
| 9 | expectation present and equal to the observed code | `pass` |
| 10 | expectation present and different from the observed code | `fail` |
| 11 | expectation present with a non-integer value | `unparseable`, `exit_code=None`, expectation `0` |

Shapes 1-8 must produce records identical to the pre-change parser. Add, in each runtime, the Layer 1 equivalence assertion of Invariant A as a parametrized test over a bounded integer range plus large magnitudes, and one test pinning first-wins for a duplicated `ExpectedExitCode`.

### Edge cases and negative scenarios (invalid inputs, missing data, boundary values)

- Expectation equal to the observed code where both are non-zero, including a large value and a negative value.
- Expectation `0` written explicitly: must render identically to an omitted key (structural consequence of the renderer's non-zero emit condition).
- Expectation key present with an empty value (`ExpectedExitCode:`): the value is not an integer, therefore `unparseable`.
- Expectation key in the wrong casing (`expectedexitcode`, `Expected Exit Code`): not on the accept-list, therefore discarded, and the record is identical to shape 8. This documents the case-sensitivity property verified in research §1.4 item 2.
- `EXIT_CODE: SKIPPED` with and without an expectation: `unparseable` in both cases (Invariant F, `.claude/skills/atomic-plan-contract/SKILL.md:135`).
- Duplicated `ExpectedExitCode` with different values: first wins, in both runtimes.
- A value containing colons after the first (verifies the first-colon split at `verification_evidence.py:105` / `verification-evidence.ts:104-109` is unaffected).
- Read failure propagation through `parse_verification_evidence_file` / `parseVerificationEvidenceFile` remains unchanged (`verification_evidence.py:161`, `verification-evidence.ts:167`).

### Error handling and logging verification

- Assert that every `unparseable` record produced by any branch carries `exit_code = None` / `exitCode = null` **and** expectation `0` (Invariant E), including the new non-integer-expectation branch.
- Assert that a record whose expectation is non-integer is dropped by the collector filter and does not appear in the rendered section, matching the existing treatment of a non-integer `EXIT_CODE`.
- Assert no logging is introduced: neither parser gains an import of `logging` or a console call. Verified by the lint and type-check stages plus a grep criterion.

### Coverage impact and targets for changed lines/modules

- Repository thresholds: line >= 85%, branch >= 75% in both Python and TypeScript (constraint C2).
- Every added or changed line in `scripts/dev_tools/pr_context/verification_evidence.py` and `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` must be covered; the module is small (three public functions, one `read_text`, no other I/O), so near-total line and branch coverage is cheap (research §5.3).
- Coverage measurement of the Python module is already configured: `pyproject.toml:119-127` sets `source = ["src", "scripts/dev_tools"]`, and `omit` lists only test, `__pycache__`, and site-packages paths, consistent with the Coverage Exclusion Policy. No `exclude` entry may be added for either changed file.
- The `--cov --cov-branch` flags must be passed explicitly (constraint C3).

### Toolchain commands to run (format → lint → type-check → test)

Run the full loop and restart at step 1 on any failure or any file modification, until all stages pass in a single pass.

**Python** — from the repository root:

```
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest --cov --cov-branch --cov-report=term-missing
```

**TypeScript** — from `extensions/drm-copilot/` (the root workspace scripts do not cover `extensions/drm-copilot/src`):

```
npm run format
npm run lint
npm run typecheck
npm run test:unit
npm run test:coverage
```

**Documentation mirrors** — after editing the three canonical `evidence-and-timestamp-conventions/SKILL.md` copies, regenerate the three bundled mirrors with the push-down scripts and confirm with:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py
```

### Manual validation steps (if required)

None are required; research's Automation Feasibility section concluded that no human interaction is needed at any step and that no `human_interaction` requirement should be recorded in the orchestrator-state checkpoint for this feature. The two runs that are not committed tests — the Layer 2 corpus differential per runtime and the cross-runtime corpus comparison — are agent-executed scripts whose output is recorded as evidence at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md`, not manual steps.


## Acceptance Criteria

Each criterion is verified by a named command or a named test. Test names below are the contract for the implementing plan; a test may be renamed only by amending this list. Where a criterion is verified by an absence grep, note that `git grep` exits `1` on zero matches, so the passing condition is stated as exit `1`.

- [ ] **AC1 — Default-absent behavior, Python.** For an artifact carrying no `ExpectedExitCode` line, the parsed record is identical to the pre-change record for every one of shapes 1-8 in the Test Strategy table. Verified by `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py -k absent_expectation` covering `test_absent_expectation_records_match_pre_change_shapes`.
- [ ] **AC2 — Default-absent behavior, TypeScript.** Same assertion in the other runtime. Verified from `extensions/drm-copilot/` by `npm run test:unit` covering the test `parseVerificationEvidenceMarkdown defaults the expectation to zero and matches pre-change records` in `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`.
- [ ] **AC3 — Layer 1 exhaustive default-path equivalence.** In both runtimes, `normalize_result(observed, 0)` equals `"pass" if observed == 0 else "fail"` over the bounded integer range -8..8 plus at least four large-magnitude values. Verified by `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py -k normalize_default` (`test_normalize_result_with_default_expectation_matches_pre_change_expression`) and by the matching TypeScript test `normalizeResult with a zero expectation matches the pre-change expression`.
- [ ] **AC4 — Observed equals expected passes.** An artifact with `EXIT_CODE: 1` and `ExpectedExitCode: 1` normalizes to `pass` in both runtimes, and the record retains `exit_code == 1`. Verified by `test_observed_equal_to_nonzero_expectation_passes` (Python) and `parseVerificationEvidenceMarkdown normalizes to pass when the observed code equals a non-zero expectation` (TypeScript).
- [ ] **AC5 — Observed differs from a non-zero expectation fails.** An artifact with `EXIT_CODE: 2` and `ExpectedExitCode: 1` normalizes to `fail` in both runtimes; likewise `EXIT_CODE: 0` with `ExpectedExitCode: 1`. Verified by `test_observed_differing_from_nonzero_expectation_fails` (Python) and `parseVerificationEvidenceMarkdown normalizes to fail when the observed code differs from a non-zero expectation` (TypeScript).
- [ ] **AC6 — Non-integer expectation yields `unparseable`.** An artifact with `ExpectedExitCode: banana` (and separately, an empty value) normalizes to `unparseable` in both runtimes, and the record carries `exit_code = None` / `exitCode = null` and expectation `0` per Invariant E. Verified by `test_non_integer_expectation_is_unparseable_and_clears_fields` (Python) and `parseVerificationEvidenceMarkdown reports unparseable for a non-integer expectation` (TypeScript).
- [ ] **AC7 — Duplicate expectation key resolves first-wins in both runtimes.** An artifact with two `ExpectedExitCode:` lines carrying different values resolves to the first. Verified by `test_duplicate_expectation_key_takes_first_occurrence` (Python) and `parseVerificationEvidenceMarkdown takes the first occurrence of a duplicated expectation key` (TypeScript), the latter mirroring the existing test at `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts:151-159`.
- [ ] **AC8 — Cross-runtime parity over the eleven-shape table.** For each of the eleven shapes, the Python and TypeScript records agree on `normalized_result`, on the observed exit code, and on the expectation. Verified by the two transcribed fixture tables passing under `poetry run pytest tests/scripts/dev_tools/pr_context/test_verification_evidence.py` and `npm run test:unit`, and by the tables being textually diffable — the plan records the shape identifiers in both files in the same order.
- [ ] **AC9 — Byte-identical rendered rows on the existing corpus, per runtime.** The Layer 2 differential run reports **0 rendered-row differences** between the pre-change reference and the post-change output across every artifact discovered by `CANONICAL_GLOBS`. Recorded at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` naming the artifact count and the diff count (research-time reference: 968 artifacts).
- [ ] **AC10 — Cross-runtime parity on the existing corpus.** The same corpus run compared runtime-to-runtime reports **0 differences** across artifacts containing exactly one `EXIT_CODE:` line. Artifacts containing two or more are excluded, and their count is recorded in the same evidence artifact together with the statement that the exclusion is attributable to the deferred duplicate-`EXIT_CODE` defect (research §3.2 measured 156 of 968 at research time).
- [ ] **AC11 — No artifact carries the new key before the change.** Re-verification of assumption A1: `git grep -n -E "ExpectedExitCode|expected_exit|expectedExit|expected_nonzero|EXPECTED_EXIT" -- docs/features` returns matches only under `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/`. Recorded in the same evidence artifact.
- [ ] **AC12 — `REQUIRED_FIELDS` is unchanged in both runtimes (Invariant D).** `git diff main -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` contains no changed line matching `REQUIRED_FIELDS`, and `git grep -n "REQUIRED_FIELDS" -- scripts/dev_tools/pr_context extensions/drm-copilot/src` shows the same three members in both files.
- [ ] **AC13 — Result vocabulary is closed (Invariant C).** `git grep -n "unparseable" -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` shows the union still spelled exactly `pass | fail | unparseable`, and `git diff main -- scripts/dev_tools/pr_context/collector.py extensions/drm-copilot/src/lib/pr-context/collector-output.ts` shows no change to the record filters at `collector.py:147-149` and `collector-output.ts:98-101`.
- [ ] **AC14 — `EXIT_CODE: SKIPPED` is still `unparseable` (Invariant F).** Verified by `test_skipped_exit_code_remains_unparseable` (Python) and `parseVerificationEvidenceMarkdown reports unparseable for EXIT_CODE SKIPPED` (TypeScript).
- [ ] **AC15 — Unrecognized rows are still discarded.** An artifact carrying `Output Summary:` and a wrong-cased `expectedexitcode:` produces a record identical to the same artifact without those rows. Verified by `test_unrecognized_rows_are_ignored` (Python) and `parseVerificationEvidenceMarkdown ignores rows outside the accept-list` (TypeScript).
- [ ] **AC16 — Rendering is conditional and additive.** The line `  - Expected EXIT_CODE: <int>` appears between the `EXIT_CODE` and `Normalized result` lines when and only when the parsed expectation is non-zero, and is absent when the key is omitted or written as `0`. Verified by the two new collector-level cases per runtime: the new Python sibling module of `tests/scripts/dev_tools/test_collect_pr_context_part4.py`, and the added cases in `describe("renderVerificationEvidenceSection")` at `extensions/drm-copilot/test/lib/pr-context/collector-output.test.ts:268`.
- [ ] **AC17 — Rendering parity.** For the same artifact text, the Python and TypeScript rendered Verification sections are string-equal, including the conditional line. Verified by the corpus run of AC10 comparing rendered rows, not just normalized results.
- [ ] **AC18 — No import edge to the atomic-executor QC path (Invariant G).** `git grep -n -E "qc_runner_expectations|pytest_expectations" -- scripts/dev_tools/pr_context extensions/drm-copilot/src/lib/pr-context` exits `1` with no output.
- [ ] **AC19 — 500-line limit on both changed parser files.** `(Get-Content scripts/dev_tools/pr_context/verification_evidence.py).Count` and `(Get-Content extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts).Count` are each `<= 500`. The same check applied to `extensions/drm-copilot/src/lib/pr-context/collector-output.ts` and to every new or modified test file is also `<= 500`.
- [ ] **AC20 — Pre-existing over-limit files do not grow materially.** `git diff --numstat main -- scripts/dev_tools/pr_context/collector.py` shows at most 5 added lines, and `git diff --numstat main -- tests/scripts/dev_tools/test_collect_pr_context_part4.py` shows 0 added and 0 deleted lines.
- [ ] **AC21 — Python coverage thresholds.** `poetry run pytest --cov --cov-branch --cov-report=term-missing` reports overall line coverage `>= 85%` and branch coverage `>= 75%`, and reports `scripts/dev_tools/pr_context/verification_evidence.py` with zero uncovered added or changed lines in the `Missing` column. No `omit` or `exclude` entry is added for any production file (`git diff main -- pyproject.toml` shows no change to `[tool.coverage.run]`).
- [ ] **AC22 — TypeScript coverage thresholds.** From `extensions/drm-copilot/`, `npm run test:coverage` reports overall line coverage `>= 85%` and branch coverage `>= 75%`, with `src/lib/pr-context/verification-evidence.ts` showing no uncovered added or changed line.
- [ ] **AC23 — Documentation is updated and the six copies are byte-identical.** The optional key appears in the schema block of `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` (lines 106-112 region) and in all five siblings and mirrors. Verified by `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passing, and by `git grep -c "ExpectedExitCode" -- "*evidence-and-timestamp-conventions/SKILL.md"` reporting a match in six files.
- [ ] **AC24 — Full toolchain pass in a single clean pass, both runtimes.** `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, and `poetry run pytest --cov --cov-branch --cov-report=term-missing` all succeed consecutively with no file modified by the formatter, and from `extensions/drm-copilot/`, `npm run format`, `npm run lint`, `npm run typecheck`, and `npm run test:unit` all succeed consecutively. Recorded under `<FEATURE>/evidence/qa-gates/`.
- [ ] **AC25 — Existing tests are unmodified and green.** `git diff --numstat main -- tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py` shows zero changed lines, and the nine pre-existing tests in `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts` and the four in `describe("renderVerificationEvidenceSection")` pass without edits to their bodies. An edit to any of them is evidence that Invariant A was broken.

## Risks & Mitigations

### Technical or operational risks

- **R1 — A `pass` beside a non-zero `EXIT_CODE` reads as a defect.** Without an explanation in the row, a reviewer cannot distinguish an earned `pass` from a normalization bug, which reproduces the distrust described at `issue.md:79` in the opposite direction.
- **R2 — Sub-option A1 makes a typo invisible.** A non-integer `ExpectedExitCode` yields `unparseable`, and unparseable records are dropped entirely by both collector filters (`collector.py:147-149`, `collector-output.ts:98-101`), so a mistyped expectation removes a row that renders today.
- **R3 — The deferred duplicate-`EXIT_CODE` divergence contaminates the parity claim.** A naive whole-corpus cross-runtime comparison will report roughly 156 differences that have nothing to do with this change, which could be misread either as a regression introduced here or, worse, as noise to be waved through.
- **R4 — File-size limit growth in files that already violate it.** `scripts/dev_tools/pr_context/collector.py` is 619 lines and `tests/scripts/dev_tools/test_collect_pr_context_part4.py` is at least 684 lines (research §9.1). Adding to either deepens a known violation and will be raised in review.
- **R5 — Coverage regression on changed lines.** `verification_evidence.py` has no dedicated Python tests today and its `fail` branch is untested (research §5.2), so adding branches without adding tests would measurably reduce coverage on changed lines, which is a blocking finding under `.claude/rules/python.md:90`.
- **R6 — Documentation mirror drift.** The evidence schema is documented in six copies; editing a canonical copy without regenerating the mirrors fails the push-down contract tests (research §9.5).
- **R7 — The Layer 2 corpus is mutable documentation.** The artifact set changes whenever a feature lands, so a committed test that walked it would be non-deterministic across time and would couple the test suite to documentation content.
- **R8 — The TypeScript record type is public surface.** `VerificationEvidenceRecord` is re-exported from `extensions/drm-copilot/src/lib/pr-context/index.ts:74-80`; adding a required member breaks any construction site that builds it as an object literal.
- **R9 — Scope creep toward per-gate expectations.** 156 of 968 artifacts record more than one gate in one file, so a reader may reasonably assume the new key is per-gate and file a follow-up defect against behavior that was specified out of scope.

### Mitigations and rollbacks

- **R1:** the rendering layer is brought into scope for exactly one conditional line per renderer (see "Rendering decision"), verified by AC16 and AC17.
- **R2:** the trade-off is recorded explicitly under "Error handling and logging updates" with the rejected alternative (A2) and the reason. The new key is documented in all six copies of the conventions skill (AC23) so authors learn the exact casing and value form, and AC6 pins the behavior so it cannot change silently.
- **R3:** AC10 scopes the cross-runtime parity assertion to single-`EXIT_CODE` artifacts, requires the excluded count to be recorded in the evidence artifact, and requires the exclusion to be attributed in writing to the deferred defect. The eleven-shape parity table (AC8) uses only single-`EXIT_CODE` fixtures so the confound cannot reach it.
- **R4:** AC20 caps `collector.py` growth at 5 added lines and requires zero changed lines in the over-limit test module; the Python collector-level cases go in a new sibling module. The counter-argument (a small addition to a pre-existing 619-line violation, with extraction out of scope) is pre-recorded so review does not have to rediscover it.
- **R5:** a dedicated Python test module is mandatory (see Test Strategy), and AC21 requires zero uncovered added or changed lines in the module.
- **R6:** AC23 makes the push-down contract tests the verification, so a mirror omission fails a named test rather than passing silently.
- **R7:** the corpus comparison is a throwaway script deleted before the final toolchain loop, and its output is recorded as evidence at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` (AC9). The durable, committed proof of Invariant A is the Layer 1 exhaustive assertion (AC3), which does not depend on the corpus at all.
- **R8:** every in-repo construction site is updated in the same change, and `npm run typecheck` (`tsc -p ./ --noEmit`) fails the build if one is missed. The Python analogue is avoided entirely by appending a defaulted field last.
- **R9:** the limitation is stated in "Scope & Non-Goals", is documented in the conventions skill update alongside the key, and carries the practical guidance that a gate needing a non-zero expectation is recorded in its own artifact file.
- **Rollback:** revert the commit. No artifact on disk carries the new key, so a revert restores prior behavior for the entire corpus with no data migration and no artifact edits. No feature flag is introduced (see "Rollback/feature-flag considerations").

## Rollout & Follow-up

### Release/rollout steps

1. Land the two parser changes, the two renderer changes, and the tests in a single pull request, so the parity pair never exists in a split state (constraint C7).
2. Edit the three canonical `evidence-and-timestamp-conventions/SKILL.md` copies and regenerate the three bundled mirrors with the push-down scripts in the same pull request.
3. Record the Layer 2 corpus differential and the cross-runtime comparison at `<FEATURE>/evidence/other/additive-corpus-parity.<timestamp>.md` before the final toolchain loop, and delete the throwaway comparison script.
4. Record the final toolchain results under `<FEATURE>/evidence/qa-gates/`.
5. No deployment, migration, workflow change, or configuration rollout is involved. Consumers pick up the behavior the next time PR context is generated, through either `mcp__drm-copilot__collect_pr_context` or the `dev.pr-context` console script.

### Post-fix monitoring or clean-up tasks

- **Follow-up defect, to be promoted separately: duplicate-`EXIT_CODE` precedence divergence.** Python takes the last occurrence (`scripts/dev_tools/pr_context/verification_evidence.py:108`) and TypeScript takes the first (`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:110-113`), while the code comment at `verification-evidence.ts:101-102` incorrectly claims the two match. Research §3.2 measured 156 of 968 canonical artifacts (16.1%) as affected and reported differently by the two runtimes today; research §1.4 item 4, §2.3, and §3.1 record the mechanism, and §3.3 records the recommended convergence direction (first-wins, matching the runtime that serves the MCP tool and the existing test at `verification-evidence.test.ts:151-159`). Converging it changes the reported result for real existing artifacts, so it is a separate behavior change requiring its own before/after evidence and is deliberately not attempted here. Promote as a new bug via the potential-to-issue path.
- **Follow-up enhancement: per-gate expectations in multi-gate artifacts.** Out of scope here (research §7.5). Requires a block-scoped or section-scoped evidence schema and a corresponding change to both parsers and to six documentation copies. Promote only if the one-gate-per-artifact guidance proves insufficient in practice.
- **Follow-up, optional: list-valued expectations.** The chosen single-integer key is a strictly additive base; a future change can teach the same key to accept a comma list, since a bare integer is a valid one-element list (research §7.3 Option B). No demonstrated need in the corpus today.
- **Pre-existing observations, recorded but not scheduled by this fix.** `scripts/dev_tools/pr_context/collector.py` is 619 lines and `tests/scripts/dev_tools/test_collect_pr_context_part4.py` is at least 684 lines, both over the 500-line limit (research §9.1). No root `quality-tiers.yml` exists despite `.claude/rules/quality-tiers.md` naming it as the source of truth (research §9.2); this does not change the uniform coverage thresholds, which apply to every tier. `CANONICAL_GLOBS` discovers only three of the six canonical evidence roots, omitting `evidence/baseline/`, `evidence/issue-updates/`, and `evidence/remediation-baseline/` (research §1.1).
- **Monitoring:** none required. There is no runtime service, telemetry surface, or dashboard associated with this path. The observable signal after the fix is that a Verification row for an absence-assertion gate reads `pass` with an `Expected EXIT_CODE` line beside a non-zero observed code.

### Links

- Issue: [#485](https://github.com/drmoisan/drm-copilot/issues/485)
- Issue record: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/issue.md`
- Research: `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/research/2026-08-17T16-10-expected-nonzero-exit-research.md`
- Branch: `bug/pr-context-verification-cannot-express-expected-nonzero-exit-485`
- Evidence schema: `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`
- Related but explicitly not reused: `scripts/dev_tools/atomic_executor/qc_runner_expectations.py`, `.claude/skills/atomic-plan-contract/SKILL.md`
- PRs: to be added when opened.
