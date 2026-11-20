# Code Review — collect-pr-context reports ok without writing (Issue #574)

- Timestamp: 2026-08-28T13-48
- Branch: `bug/collect-pr-context-reports-ok-without-writing-574-r2`
- Base: `main` (`origin/main` = `d8b81f81`)
- Scope: full branch diff against the resolved base — 53 paths, of which 23 are non-documentation.
- Work mode: `full-bug`

## Overall Assessment

**The change is sound.** It repairs the reported defect at its actual root cause, and it repairs it
structurally rather than by correcting a value. The read-back verification is a genuine content
comparison proved live by mutation, the path-identity fix removes the second expression that could
drift rather than merely aligning it, the freshness marker is rendered once per invocation so a
mismatched pair is detectable, and the file-size violation the change inherited was repaired by a
behaviour-preserving extraction rather than by relaxing anything.

**Blocking findings: 0. Non-blocking findings: 0. Observations: 6.**

---

## What Changed

### Root-cause repair (`pr-context-service-call.ts`)

Before, the service call evaluated the output location twice by two different expressions: it passed
bare repo-relative constants to `collectAndWrite` (which forwards them verbatim to `node:fs`, where
they resolve against the long-lived MCP server process's cwd) while separately joining those same
constants to `input.workspaceRoot` to build the reported `artifacts` array. It reported a location it
had not written to.

After, each absolute path is evaluated once:

```ts
const summaryOut = normalizeGeneratedPath(join(input.workspaceRoot, SUMMARY_OUT));
const appendixOut = normalizeGeneratedPath(join(input.workspaceRoot, APPENDIX_OUT));
```

and that one variable is the write target, the verification read target, the log-line value, and the
reported artifact entry. **This is the right shape.** The defect class becomes structurally
impossible rather than merely corrected — there is no second expression left to drift. It also brings
the module into line with the sibling `runCollectCommitContext`, which never exhibited the bug for
exactly this reason.

The inline comment at `pr-context-service-call.ts:106-113` explains a non-obvious ordering decision
that would otherwise be a latent regression: normalization must run **before** the write, because
`join` emits backslash separators on Windows, so writing with the raw joined value while reporting
the normalized value would reintroduce two different strings. Node accepts forward slashes on
Windows, so the write is unaffected. This is exactly the kind of decision that deserves a comment,
and the comment states the reason rather than restating the code.

### Read-back verification

`verifyWrittenArtifact` (`pr-context-service-call.ts:47-67`) reads the file back through the injected
`FileSystem` and compares against the exact string this invocation rendered. To make that operand
available without re-rendering, `collectAndWrite` was changed from `void` to returning
`CollectAndWriteResult { summaryText, appendixText }`. That is a minimal, well-motivated signature
change and the docstring records why (`collector-output.ts:353-362`).

Two failure arms, both with actionable messages naming the artifact path:

- read failure — rethrows with `{ cause: error }`, preserving the underlying filesystem error;
- content mismatch — reports expected and actual character counts.

The error propagates to `dispatchRepoAutomationTool`, which converts it to `ok: false` with the
failure text in the result record. This delivers the issue's stated acceptance condition literally:
`ok: true` now holds if and only if both files were written by this invocation and read back equal.

### Freshness marker

One `Context generated` section is rendered **once** per invocation and the same string is passed to
both document builders, in both runtimes:

```ts
const generatedSection = appendGenerationTimestamp(clock, collected.contextResult.headSha);
```

```python
generated_section = append_generation_timestamp(context_result.head_sha)
```

Rendering once rather than twice is the correct call: it makes a pair whose timestamps disagree a
**detectable defect** rather than a rounding artifact, which is what the consumer cross-check depends
on. The section title `Context generated` is reused rather than replaced, so the four pre-existing
substring assertions elsewhere in the suite continue to pass — a deliberate backward-compatibility
choice the spec records and the diff honours.

The header is placed first in both documents, and both documents truncate from the end
(`collector-output.ts:254-258`, `collector_documents.py:292-294`), so the header survives a
budget-exceeded truncation. That interaction is easy to get wrong and is right here.

The `(unknown)` placeholder path is covered and the skill documentation tells consumers what to do
with it: treat the pair as unverified and regenerate.

### Deliberate cross-runtime divergence preserved

The Python helper takes no clock parameter while the TypeScript one does. This is a pre-existing,
justified divergence (`.claude/rules/typescript.md` requires wall-clock reads to flow through an
injected clock; Python has no such rule here). The change preserves it and — better — **documents it
in both files** (`summary-helpers.ts:338-341`, `summary_helpers.py` docstring) so a future maintainer
does not "correct" it in either direction. That is good practice.

### Python module extraction

`scripts/dev_tools/pr_context/collector.py` was 500+ lines at baseline. Two document-assembly blocks
plus the two character budgets and the verification-evidence renderer moved to a new
`collector_documents.py` (345 lines), bringing `collector.py` to 474.

The extraction is careful in two respects worth naming:

1. The new module's docstring states an invariant, not just a description: *"The output-path contract
   is unchanged and is deliberately not expressed here: neither function writes a file and neither
   resolves a path."* That is the constraint that keeps the extraction from becoming a vector for the
   very defect being repaired.
2. `_render_verification_evidence_section` is retained in `collector.py` as an alias with a comment
   naming the specific test module that imports the private name directly. That is a real dangling-
   import hazard, correctly identified and correctly handled — the alternative would have been to
   silently break an unrelated test.

`__all__` is declared, imports are grouped, and every public function carries an Args/Returns
docstring. Consistent with `.claude/rules/python.md`.

---

## Design Principles (`.claude/rules/general-code-change.md`)

- **Simplicity first.** The fix is the smallest change that makes the defect impossible. Three
  alternatives are recorded in the spec with the reason each was rejected: joining inside
  `writeOutput` (breaks the verbatim-port relationship with `collector.py`), `process.chdir` (a race
  in a long-lived process shared by concurrent worktree-isolated agents), and rejecting a relative
  `out` (breaks the CLI's correct documented usage). All three rejections are correct.
- **Separation of concerns.** Path resolution stays at the caller seam; the library keeps its
  cwd-relative contract; the Python surface is untouched on the path axis. The verbatim-port
  relationship survives the change, which was the constraint that made a caller-side fix the only
  correct one.
- **Fail fast and explicitly.** Verification raises with a message naming the artifact path and the
  nature of the mismatch. No broad catch, no silent degradation. The one catch that exists rethrows
  with `cause`.
- **Public API compatibility.** The MCP tool name, input schema, and result schema are unchanged. The
  `artifacts` array values are textually identical to before — what changed is that the files now
  exist at those paths.
- **No new dependency.** None added in either runtime.
- **I/O boundaries.** All I/O flows through the injected `FileSystem` and `CommandRunner`. Every test
  in the change is hermetic.

---

## Test Quality

The test work is the strongest part of this change.

- **The set-equality form is the right assertion.** `pr-context-service-call.test.ts:171-174` compares
  the written set against the reported set *as two observed values*, then compares that single value
  against the expected pair. Two independent literal assertions — which is what the pre-existing
  tests did — are exactly what allowed the two expressions to drift apart while the suite stayed
  green. This form cannot.
- **The stale-file test is the decisive one.** Pre-seeding both paths, asserting `isFile` is true for
  both, then asserting the call still raises, is the precise discrimination between read-back and
  existence. Without it the other negative test would be satisfiable by an existence check.
- **Test doubles were corrected, not weakened.** Three doubles gained a `readTextFile` that serves
  reads from what was written, each with an identical comment explaining that a double which records
  a write but refuses to serve the read would report a false verification failure. The discarding
  double is confined to negative tests. This is the correct split.
- **Pre-existing tests that encoded the defect were corrected in place.** All three named in the
  spec's "Why the defect survived review" were updated to assert the intended behaviour. None was
  deleted, none was weakened, and one (`repo-automation-dispatch.test.ts:129-134`) went from two
  contradictory literals to one consistent pair.
- **The mutation check is real.** Removing the two verification calls fails exactly the three
  negative tests (`readback-mutation-check`), and the restoration was verified byte-exact by
  `git status --porcelain` rather than asserted (`readback-mutation-check-restored`). Splitting the
  two runs into separate artifacts because they declare different `ExpectedExitCode` values is
  correct discipline.
- **The narrow parity test is proportionate.** Rather than building a general pr-context parity
  harness, the change adds one pytest that reads the TypeScript helper's source and asserts the three
  introduced literals appear there. It spawns no process, adds no machinery, and follows an
  established in-repo precedent. The broader harness is recorded as a named follow-up rather than
  silently omitted.
- **No temp files, injected clocks, AAA structure, descriptive names.** All satisfied.

---

## Observations

None of these is blocking. None requires action before merge. They are recorded so a future
maintainer does not have to rediscover them.

### O1 — Builder signatures deviate from the spec's stated permitted set (Observation)

`docs/.../spec.md:123` states: *"The only permitted signature changes are the added clock parameter
on `buildSummaryText`, the added head-SHA input on the timestamp helper, and `collectAndWrite`
returning the rendered strings."*

The implementation instead passes a pre-rendered `generatedSection: string` to `buildSummaryText`
(`collector-output.ts:151`) and **replaces** `buildAppendixText`'s `clock` parameter with
`generatedSection` (`collector-output.ts:272-275`). Neither is on the spec's permitted list.

This is a deviation from the spec's implementation prose, not from any Behaviour Semantics condition.
It is also the better design: threading a clock into both builders would have had each render its own
timestamp, making byte-identity between the pair incidental (two `new Date()` reads that happen to
land in the same second) rather than structural. The shipped shape makes it structural. Behaviour
Semantics condition 3 and the spec's own stated intent ("rendered once per invocation and passed to
both builders", spec line 113) are satisfied — the two statements in the spec are in mild tension
with each other, and the implementation followed the stronger one.

**Recommendation:** none. Optionally amend the spec line at close-out so the record is self-consistent.

### O2 — `.claude` skill copies carry one extra trailing newline (Observation)

The `.claude` self-hosted and bundled copies are 1393-byte blocks; the `.github` and `.agents` copies
are 1392. The difference is a single trailing newline at end-of-file that **pre-dates this change**
(at `origin/main`: 1228 bytes vs 1227). The added wording is byte-identical across all six copies,
and each self-hosted/bundled pair is byte-identical at the whole-file level, so push-down parity
holds. Pre-existing condition, not introduced here.

**Recommendation:** none.

### O3 — The freshness test re-implements the `collectAndWrite` wiring (Observation)

`collector-output-freshness.test.ts` uses a local `renderPair` helper that calls
`appendGenerationTimestamp` once and passes the result to both builders, mirroring what
`collectAndWrite` does. If `collectAndWrite` stopped passing the same string to both builders, this
particular test would still pass.

The property is nevertheless covered elsewhere at the real entry point: the Python
`test_collect_and_write_opens_both_documents_with_an_identical_generated_block` drives the actual
`collect_and_write` and asserts byte-identity of the block between the two written texts, and
`extension.integration.test.ts:348-365` drives the real TypeScript path and asserts both documents
carry the header. So the invariant is not unguarded — only this one test is a level removed from it.

**Recommendation:** if the file is touched again, consider driving `collectAndWrite` with a fixed
clock instead of `renderPair`. Not worth a change on its own.

### O4 — Read-back reads through the same `FileSystem` instance as the write (Observation)

`verifyWrittenArtifact` reads through `input.fileSystem`, the same instance the write went through.
For `RealFileSystem` this is a genuine `node:fs.readFileSync` against the disk, so the verification is
real in production, and the spec records the assumption explicitly (spec line 242). It is worth
recording that a future `FileSystem` implementation with a write-through cache would satisfy the
comparison without the bytes reaching disk. That is a property of the seam, not a defect in this
change.

**Recommendation:** none now. If a caching `FileSystem` is ever introduced, this verification must be
revisited.

### O5 — No architecture-boundary stage is configured in this repository (Observation)

Toolchain stage 4 of `.claude/rules/general-code-change.md` names dependency-cruiser or an
equivalent. Neither `package.json` in this repository defines such a script. This is a pre-existing
repository condition entirely unrelated to this change; it is recorded here only because the audit
must account for every stage.

**Recommendation:** out of scope for this fix.

### O6 — One-hundredth-point discrepancy between two coverage artifacts (Observation)

`evidence/qa-gates/ts-coverage-thresholds.2026-08-28T12-47.md` (Phase 5) records
`summary-helpers.ts` line/statement coverage as 93.54; `final-ts-coverage.2026-08-28T12-47.md`
(Phase 8) records 93.55, and the reviewer's own run reproduces 93.55. The two runs are at different
commits — Phase 8 followed the coverage-repair commit `4f179480` — so the difference is expected
rather than an inconsistency in the record. Both values are far above the 85 threshold.

**Recommendation:** none.

---

## Things Done Well (worth preserving as precedent)

1. **The fix removes the possibility rather than correcting the value.** Single evaluation of each
   path is a structural guarantee; two aligned literals would have been a temporary one.
2. **Normalization placed before the write, with the Windows reason stated in the code.** A later
   maintainer moving that call would reintroduce the divergence; the comment prevents it.
3. **The mutation check on the read-back.** Proving a negative test fails when the production code it
   guards is removed is the difference between a test and a decoration. Both directions were
   recorded, and the restoration was verified byte-exact rather than asserted.
4. **A coverage regression of 0.035 points was treated as a failure and repaired by extending a test
   stub.** `git show --stat 4f179480` touches one test file and no production file. The alternative —
   recording it as a note, or nudging production code to move the number — is the common failure mode
   and was avoided.
5. **Write-mode gates judged by before-and-after tree observation.** The `final-ts-format` artifact
   records an earlier pass where Prettier exited 0 *while rewriting three tracked files*. Only the
   porcelain comparison caught it. That is precisely the class of unfalsifiable acceptance condition
   `.claude/rules/plan-acceptance-gates.md` exists to prevent, and the plan designed around it in
   advance.
6. **Coverage numbers read from the JSON reporter, with the reason the terminal column is wrong
   stated with measured counter-examples.** The plan documents a case where the `BrPart`-derived
   value would have passed a module that genuinely fails by 13.6 points. Every recorded figure was
   independently reproduced by the reviewer.
7. **A deliberate cross-runtime divergence documented in both runtimes** so it is not "fixed" later.
8. **The retained `_render_verification_evidence_section` alias**, with a comment naming the exact
   test that depends on it. A silent break was available and was not taken.

---

## Verdict

**Approve.** No blocking findings. No non-blocking findings. Six observations, none requiring action
before merge. The change repairs the reported defect correctly, the verification it adds is genuine
and proved live, coverage and file-size obligations are met and independently reproduced, and the
test work is of high quality.
