# Work-Mode Integrity — [P0-T3]

Timestamp: 2026-08-26T07-50
Task: [P0-T3]
Command: `find . -name 'user-story.md' -print` and `grep -n -F -- "- Work Mode: full-bug" issue.md`, both run from the feature folder
EXIT_CODE: 0

## Negative-evidence record (user-story.md absence)

SearchScope: `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/` — the feature folder, searched recursively, including the `research/` and `evidence/` subtrees. This feature is not versioned, so there is no `v1/`-style current-version scope to search separately; the feature root is the whole scope.

SearchPatterns: `user-story.md`

SearchResult: `none`

```
$ find . -name 'user-story.md' -print
$ echo "exit=$?"
exit=0
```

The command produced no output line and exited 0, which is a completed search that matched nothing, not a failed search.

Corroborating full-folder enumeration, so the absence is auditable against the complete file list rather than against one pattern:

```
$ find . -type f | sort
./evidence/baseline/feature-documents-read.2026-08-24T00-00.md
./evidence/baseline/phase0-instructions-read.2026-08-24T00-00.md
./issue.md
./plan.2026-08-23T23-22.md
./research/2026-08-23T23-45-unobservable-and-ambient-state-gates-research.md
./spec.md
```

Six files. No `user-story.md` among them. The two evidence artifacts listed were written by [P0-T1] and [P0-T2] earlier in this same Phase 0 run.

## spec.md presence

```
$ test -f spec.md && echo "spec.md PRESENT" || echo "spec.md ABSENT"
spec.md PRESENT
```

`spec.md` is present, 54172 bytes, and carries exactly 37 acceptance criteria as recorded by [P0-T2]. It is the sole acceptance-criteria source for this feature.

## Work-mode marker

```
$ grep -n -F -- "- Work Mode: full-bug" issue.md
12:- Work Mode: full-bug
$ echo "exit=$?"
exit=0
```

`issue.md` carries the marker line `- Work Mode: full-bug` at line 12, inside the metadata block.

## Mode resolution

Applying the Mode source precedence of `.claude/skills/atomic-plan-contract/SKILL.md` (lines 185-195): step 1 finds a persisted marker in the `issue.md` metadata block, `- Work Mode: full-bug`. Resolution stops at step 1; the legacy `full` normalization of step 2, the workflow-override path of step 3, and the fail-closed default of step 4 are not reached.

Under the Mode-Specific Mandatory Plan Gates of the same skill (line 204), a `full-bug` plan enforces spec-driven expectations — `spec.md` required, `user-story.md` optional and absent by default — plus full QA loop obligations. Both halves are satisfied: `spec.md` is present and `user-story.md` is absent. The plan's own header records the same mode and the same statement that `user-story.md` is absent by design and must not be created.

The three artifacts agree with each other: the `issue.md` marker, the `spec.md` header (`**Work Mode:** \`full-bug\``), and the plan header (`**Work Mode:** \`full-bug\``). No reconciliation is required and no fail-closed condition is triggered.

## Output Summary

Work-mode integrity confirmed. `issue.md` carries `- Work Mode: full-bug` at line 12; `spec.md` is present and is the sole acceptance-criteria source; `user-story.md` is absent, verified by a recursive pattern search returning `none` and corroborated by a full six-file folder enumeration. Mode resolves at precedence step 1 with no fallback, and the `full-bug` gate conditions are met.
