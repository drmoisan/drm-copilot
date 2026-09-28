# No Suppression Surface Was Introduced — [P6-T7]

Timestamp: 2026-08-26T13-37
Task: [P6-T7]
Command: `git diff main`, then `git diff main -- scripts tests extensions config .github`, then a case-insensitive search of the added lines of each for the five terms
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Both `git diff` invocations exited 0 and each exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between either `git diff` and its capture. The searches are run against the captured diff text, not against a pipeline whose last stage would mask the diff's own status.

## SearchScope

**SearchScope:** the branch diff against `main` — `git diff main` from the worktree root, covering every added and removed line of every file this branch changes. The captured diff is 7444 lines. A second, narrower capture is taken over `scripts`, `tests`, `extensions`, `config`, and `.github` so the source, test, configuration, and workflow additions can be reported separately from the documentation additions.

## SearchPatterns

**SearchPatterns:** the five terms **grandfather**, **exemption**, **allowlist**, **suppress**, and **toggle**, each matched case-insensitively as a substring of an added line (a diff line beginning `+`). The stems match their inflections, so `grandfather` matches `grandfathering`, and `suppress` matches `suppression`, `suppressed`, and `suppresses`.

## SearchResult

**SearchResult: `none` for every pattern.** No suppression surface was introduced by this change: no grandfathering list, no exemption marker, no per-plan suppression comment, no allowlist file, and no runtime toggle.

That conclusion is reported alongside the raw literal-match counts rather than instead of them, because the raw counts are not zero and a reader must be able to check the classification rather than take it on assertion.

### Raw literal-match counts, both scopes

| Pattern | Added lines matching, whole branch diff | Added lines matching, source / test / config / workflow only |
| --- | --- | --- |
| grandfather | 10 | **0** |
| exemption | 6 | **0** |
| allowlist | 4 | **0** |
| suppress | 15 | **0** |
| toggle | 3 | **0** |
| **Any of the five** | **21 distinct added lines** | **0** |

**Every match in the whole-diff scope is Markdown prose. Not one is a source, test, configuration, hook, or workflow line.** The narrower scope — which is where a suppression surface could exist at all — returns zero for all five patterns.

### Every prose match, classified

The 21 matching added lines fall into three classes. No line in any class is a mechanism; each is text about mechanisms.

**Class A — text that PROHIBITS a suppression surface (13 lines).** These occur in the research document, the specification, the plan, and the [P6-T1] decision-rule artifact. Representative lines, quoted from the diff:

- `- **A grandfathering list, exemption marker, or suppression comment** — prohibited by `.claude/rules/plan-acceptance-gates.md:7-13`; no sweep exists, so there is nothing to protect.`
- `  - **No grandfathering list, exemption marker, per-plan suppression comment, or allowlist file.** With no sweep there is no existing corpus to protect, so the only reachable use of a suppression surface would be to silence a finding on the plan being authored, which is the case the gate exists to report.`
- `No feature flag. The rule set has no runtime toggle by design, consistent with the prohibition on suppression surfaces. Rollback is reversion of the change; because the rules ship at the severity the corpus measurement licenses, an over-firing rule surfaces as a Warning rather than a merge blocker in the interval before reversion.`
- `` `.claude/rules/plan-acceptance-gates.md:7-13` is directly on point and applies unchanged to a newly added rule. No CI job, test, or scheduled task sweeps the committed plan corpus, and this fix must not add one. With no sweep there is nothing to protect, so a grandfathering list, an exemption marker, a per-plan suppression comment, and an allowlist file are all prohibited [...] ``

A line that forbids a suppression surface is the opposite of a suppression surface. Its presence in the diff is evidence for this task's conclusion, not against it.

**Class B — the task's own text and its traceability row (3 lines).** `[P6-T7]` and its acceptance sentence appear in the plan document, and the specification's traceability table carries the row `| AC26 | No suppression surface introduced | [P6-T7] |`. These are the statement of the requirement being verified here.

**Class C — the word used in an unrelated technical sense (5 lines).** These describe tool behaviour and have nothing to do with the gate rule set:

- `` `poetry run ruff check --no-fix .` [...] because `--no-fix` suppressed the configured autofix, that zero is a measurement of the tree as found rather than of a tree the baseline repaired.`` — describes the linter's autofix, in a Phase 0 baseline artifact.
- `The notice is emitted before analysis and does not suppress it` — describes a pyright configuration notice, in a Phase 0 baseline artifact.
- `` `--no-error-on-unmatched-pattern` suppresses a failure when a named pattern matches no file. It does not suppress diagnostics for files that do match `` — describes an ESLint flag, in a Phase 0 baseline artifact.
- `distinguishes an empty result from a suppressed one.` (two occurrences) — describes the G9 `addopts` reader's three-way return, in the [P2-T4] design notes carried in the module docstring's companion evidence.
- `Suppressing the fix makes the invocation genuinely read-only` — appears inside a quoted extract of the issue #502 plan reproduced in the [P5-T5] artifact; it is another repository's plan text, quoted as evidence, not a change to this repository.

**The single exemption in Class A that names something this change actually does** is the G8b severity exemption: G8b is exempt from the two-condition severity decision rule and ships in the warning channel unconditionally. That is a rule about which channel a finding is reported on, not a mechanism for suppressing a finding. Every G8b finding is still produced and still surfaced; the exemption only guarantees it cannot fail a gate. A suppression surface removes a finding from the output. This does the opposite of removing it.

## No configuration file gained a key

Exactly one non-Markdown, non-source file appears in the branch diff: `extensions/drm-copilot/jest.config.cjs`. It gained the per-file coverage-threshold entry added by [P3-T8]:

```
+    // `plan-gate-observability.ts` carries the G7, G8, G8b, and G9 rule group
+    // added by issue #519. It is a new production file under `src/`, and the
+    // coverage-exclusion policy in `.claude/rules/general-unit-test.md` forbids
+    // leaving such a file behind no gate, so it sits behind the same per-file
+    // threshold as the plan-gate modules it was added alongside.
+    "./src/lib/validate/plan-gate-observability.ts": {
+      lines: 85,
+      branches: 75,
+    },
```

**That entry ADDS a gate rather than suppressing one.** It places a new production file behind a line threshold of 85 and a branch threshold of 75, which is the requirement the coverage-exclusion policy imposes on any new file under `src/`. It is a coverage threshold, not a suppression key, and its effect is to make a coverage regression in that file fail rather than pass.

**No file under `config/` appears in the branch diff at all**, so no truth table, routing table, or orchestration configuration gained a key of any kind. **No file under `.github/workflows` appears in the branch diff**, so no sweep, scheduled job, or CI gate was added — the point [P6-T6] records independently against the same span.

The full changed-file list, read from `git diff --name-only main`, is 47 paths: 31 Markdown documents under the feature folder, 9 TypeScript source and test files under `extensions/drm-copilot`, 3 Python modules under `scripts/dev_tools`, 5 Python test modules under `tests/scripts/dev_tools`, and the one `jest.config.cjs` above. There is no other configuration file, and no new file of any kind whose purpose is to hold exclusions.

## Why the absence matters

The scope-of-invocation clause of `.claude/rules/plan-acceptance-gates.md` records that the plan validator only ever runs against the single artifact it is pointed at, and that no CI job, test, or scheduled task sweeps the committed plan corpus. That scope is the argument against a grandfathering list, an exemption marker, a per-plan suppression comment, and an allowlist file: each of those mechanisms exists to protect an existing corpus from a newly added sweep, and with no sweep there is nothing to protect. The mechanism's only reachable use would be to silence a finding on the plan currently being authored — which is precisely the case the gate exists to report.

This change adds four rules and no sweep, so the argument transfers unchanged. It is also why all four rules ship in the warning channel: a rule that surfaces a finding without failing the gate gives the author the information at no cost that would create demand for a suppression mechanism.

## Output Summary

**SearchScope:** the branch diff against `main` (7444 lines), plus a narrower capture over `scripts`, `tests`, `extensions`, `config`, and `.github`. **SearchPatterns:** grandfather, exemption, allowlist, suppress, toggle, matched case-insensitively on added lines. **SearchResult: `none` for every pattern** — no suppression surface was introduced. The raw literal-match counts are recorded in full and are not zero in the whole-diff scope (grandfather 10, exemption 6, allowlist 4, suppress 15, toggle 3; 21 distinct added lines), but **every one of the 21 is Markdown prose** — 13 lines prohibiting a suppression surface, 3 stating the requirement being verified, and 5 using the word in an unrelated technical sense — and the source, test, configuration, and workflow scope returns **0 for all five patterns**. **No configuration file gained a key:** the only non-Markdown, non-source file in the diff is `extensions/drm-copilot/jest.config.cjs`, whose single added entry is a per-file coverage threshold that adds a gate rather than suppressing one. No file under `config/` or `.github/workflows` appears in the diff.
