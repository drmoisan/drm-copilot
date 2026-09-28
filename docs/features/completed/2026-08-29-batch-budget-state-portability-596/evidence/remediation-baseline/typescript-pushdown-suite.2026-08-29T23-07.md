# TypeScript push-down suite baseline (remediation cycle 1)

Timestamp: 2026-08-30T00-59

Task: [P0-T15]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Both commands were executed with the working directory set to the absolute path `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/extensions/drm-copilot`. The plan states the `cd` operand worktree-relative; the absolute path above is the form actually used, because each Bash tool call starts fresh and inherits no working directory from a previous call.

EXIT_CODE: 0 (both commands)

ExpectedExitCode: 0

---

## Run 1 — the whole push-down directory

Command (plan command text, quoted verbatim):

```
cd extensions/drm-copilot && npx jest test/lib/push-down/
```

EXIT_CODE: 0

Output tail, verbatim:

```
Test Suites: 17 passed, 17 total
Tests:       234 passed, 234 total
Snapshots:   0 total
Time:        0.853 s, estimated 1 s
Ran all test suites matching test/lib/push-down/.
```

`Tests:` result line, quoted verbatim:

```
Tests:       234 passed, 234 total
```

- Passed: **234**
- Total: 234
- **Failed: 0.** Jest omits the `failed` segment from the `Tests:` line when the failure count is zero; `234 passed, 234 total` with no `failed` segment and `EXIT_CODE: 0` together establish a failed count of 0.

This count is a **baseline capture, not an asserted constant**. The plan records `234 passed, 234 total` as a predicted value from the policy audit's independent re-run of the same command on 2026-08-29, and the observed value matches that prediction. [P3-T5] compares against the value recorded here rather than against the prediction.

---

## Run 2 — the merge suite alone

Command (plan command text, quoted verbatim):

```
cd extensions/drm-copilot && npx jest test/lib/push-down/claude-gitignore-merge.test.ts
```

EXIT_CODE: 0

Output tail, verbatim:

```
Test Suites: 1 passed, 1 total
Tests:       7 passed, 7 total
Snapshots:   0 total
Time:        0.288 s, estimated 1 s
Ran all test suites matching test/lib/push-down/claude-gitignore-merge.test.ts.
```

`Tests:` result line, quoted verbatim:

```
Tests:       7 passed, 7 total
```

- Passed: **7**
- Total: 7
- Failed: 0, on the same reasoning as run 1

**The required count of 7 is met**, so the `BLOCKED: merge-suite baseline count differs from the plan` branch is not taken.

### Cross-check against the tree

The plan states the count of 7 is directly checkable: `extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge.test.ts` contains exactly seven `it(` blocks at lines 21, 39, 55, 66, 97, 120, and 133. That was re-derived against the current file:

```
21:  it("appends a managed block to an absent input", () => {
39:  it("appends a managed block to input without one", () => {
55:  it("returns identical text for input that already carries an up-to-date block", () => {
66:  it("replaces a stale managed block in place", () => {
97:  it("emits one managed block when a managed entry already appears outside it", () => {
120:  it("appends a managed block to input with no trailing newline", () => {
133:  it("normalizes CRLF input to LF in the merged text", () => {
```

Seven blocks at exactly the seven line numbers the plan names. The runtime count and the static count agree.

These are the seven pre-existing tests the plan's sibling-invalidation review covers. Each supplies either no opening sentinel or a well-formed sentinel pair, so `endOffset === -1` is false for every one of them and the D-2 edit cannot change their results. The B-2 fail-before matrix predicts this suite moves to `Tests: 1 failed, 7 passed, 8 total` once the new test is added in Phase 3, and back to `Tests: 8 passed, 8 total` once the D-2 edit lands.

---

## Prohibited flags

The flags `--passWithNoTests`, `--onlyChanged`, and `--lastCommit` are prohibited by the plan in every Jest command, because each converts zero discovered tests into a green run. **None was passed to either command.** Both runs discovered and executed real tests, as the suite and test counts above show.

## Disposition

Both commands exited 0, so the TypeScript push-down test baseline is clean. `ExpectedExitCode: 0` is recorded, which renders identically to omitting the field. No BLOCKED branch taken.

## Output Summary

`npx jest test/lib/push-down/` exited 0 with `Tests: 234 passed, 234 total` across 17 suites, matching the plan's predicted baseline; the value is recorded as a baseline for [P3-T5] rather than asserted as a constant. `npx jest test/lib/push-down/claude-gitignore-merge.test.ts` exited 0 with `Tests: 7 passed, 7 total`, meeting the required count of 7, cross-checked against exactly seven `it(` blocks at lines 21, 39, 55, 66, 97, 120, and 133. Failed count is 0 in both runs. No prohibited Jest flag was used. No BLOCKED branch taken.
