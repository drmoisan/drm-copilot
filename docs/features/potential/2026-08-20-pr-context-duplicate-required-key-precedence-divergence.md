# pr-context-duplicate-required-key-precedence-divergence (Potential Bug)

- Date captured: 2026-08-20
- Author: Dan Moisan
- Status: Draft

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The Python and TypeScript PR-context verification-evidence parsers disagree on which occurrence of a duplicated **required** key wins: Python takes the last, TypeScript takes the first. The same evidence artifact can therefore produce different parsed records, and in one measured case a different presence outcome, depending on which runtime reads it.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: cross-runtime corpus comparison recorded in `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/evidence/other/additive-corpus-parity.2026-08-20T09-53.md`
- Data source or fixture: canonical evidence artifacts under `docs/features/active/<feature>/evidence/{qa-gates,regression-testing,other}/**/*.md`

## Steps to Reproduce

1. Author (or locate) a canonical evidence artifact that carries a required key twice — for example two `Command:` lines, or two `Timestamp:` lines.
2. Parse it with `scripts/dev_tools/pr_context/verification_evidence.py` (`parse_verification_evidence_markdown`).
3. Parse the same text with `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (`parseVerificationEvidenceMarkdown`).
4. Compare the two parsed records, and compare the rendered Verification rows produced by each runtime's collector.

## Expected Behavior

Both runtimes apply the same precedence rule to a duplicated required key and produce identical parsed records and identical rendered rows for identical input. The intended rule is first-occurrence-wins, matching the documented intent and the rule already applied to the optional `ExpectedExitCode` key.

## Actual Behavior

The two runtimes disagree:

- Python `verification_evidence.py` assigns unconditionally inside the parse loop (`parsed[key] = value.strip()`), so the **last** occurrence wins.
- TypeScript `verification-evidence.ts` guards the assignment (`&& !parsed.has(key)`), so the **first** occurrence wins.

Measured over the 641 evidence artifacts containing exactly one line-anchored `EXIT_CODE:`: **5 content differences plus 1 presence difference**. All six carry a duplicated `Command:` (five) or `Timestamp:` (one). The presence difference is an artifact that renders in TypeScript but is dropped as `unparseable` in Python, because Python takes an empty second `Command:` value.

No difference touches an `EXIT_CODE` row, a `Normalized result` row, or the `Expected EXIT_CODE` row added by issue #485.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet:

Python (`scripts/dev_tools/pr_context/verification_evidence.py`) — unconditional, last wins:

```python
if key in REQUIRED_FIELDS:
    parsed[key] = value.strip()
```

TypeScript (`extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts`) — guarded, first wins:

```typescript
if (
  (REQUIRED_FIELDS as readonly string[]).includes(key) &&
  !parsed.has(key)
) {
  parsed.set(key, value);
}
```

The comment above the TypeScript block states it keeps "only the first occurrence of each required schema field (mirrors the Python dict-first-write semantics)". Python dict assignment is last-write-wins, so that comment documents a mirror that does not exist and should be corrected as part of the fix.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Medium: it affects only artifacts that duplicate a required key, which is itself an authoring defect, but it is a silent cross-runtime disagreement in a mechanism used to evidence quality gates. It is the sole reason AC10 and AC17 of issue #485 remain unmet, so it blocks closing out that feature's acceptance criteria.

## Suspected Cause / Notes

The divergence is pre-existing and predates issue #485. Confirmed by `git diff` against `71aebdb9`: the #485 branch adds only the new `ExpectedExitCode` branches to each parse loop and removes no lines from the required-field precedence logic.

Scope note: the true scope is **any duplicated required key** (`Timestamp`, `Command`, `EXIT_CODE`), which is wider than the duplicate-`EXIT_CODE` framing that issue #485's AC10 exclusion clause assumed. AC10 excludes artifacts with two or more `EXIT_CODE:` lines (165 were excluded on the measured run), so it cannot exclude the six artifacts that duplicate a different required key.

The new `ExpectedExitCode` key is **not** affected: both runtimes take the first occurrence, which is parity-correct.

Files to inspect:

- `scripts/dev_tools/pr_context/verification_evidence.py`
- `extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts` (comment at lines 125-126)

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add a duplicated-required-key precedence test per runtime covering `Timestamp`, `Command`, and `EXIT_CODE`, including the empty-second-value case that currently flips Python to `unparseable`.
- [x] Integration scenario to retest: re-run the cross-runtime corpus comparison from `evidence/other/additive-corpus-parity.2026-08-20T09-53.md`; expect 0 differences over single-`EXIT_CODE` artifacts, which makes issue #485 AC10 and AC17 satisfiable.
- [x] Manual verification notes: converge on **first-occurrence-wins** (the direction recommended by the #485 research, and already the behavior of the TypeScript required-field path and of `ExpectedExitCode` in both runtimes). This means changing the Python parse loop, and it will change the reported result for the six existing artifacts identified above, so the change is deliberately non-additive and needs its own issue rather than riding along with an additive fix.
- [x] Correct the inaccurate "mirrors the Python dict-first-write semantics" comment in the TypeScript parser.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch

Raised by the feature review of issue #485 as finding F1 in `docs/features/active/2026-08-17-pr-context-verification-cannot-express-expected-nonzero-exit-485/remediation-inputs.2026-08-20T11-33.md` (severity Major, explicitly not merge-blocking for that branch).
