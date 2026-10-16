# Remediation Decisions (P1-T4, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T03-03
Source: `FEATURE/remediation-plan.2026-10-16T01-25.md`, section "B1 — retained occurrences and decisions" (D1-D7).

In this artifact, "the AC-1 token" means the lowercase search token defined in `FEATURE/issue.md` line 61. Per the redaction-safe evidence rule item 3, the token itself is not written here outside a recorded search command.

## D1 — AC-1 search token retained (flagged, not redacted)

The AC-1 token remains verbatim in:

- `FEATURE/issue.md` line 61;
- `FEATURE/plan.2026-10-15T17-44.md` lines 71, 90, 160;
- `FEATURE/evidence/baseline/ac1-token-count.2026-10-16T00-12.md` line 4 (`Command:` line);
- `FEATURE/evidence/qa-gates/ac1-token-count.2026-10-16T01-17.md` line 4 (`Command:` line);
- `FEATURE/evidence/other/implementation-workspace-encoding.2026-10-16T00-58.md` line 34;
- `FEATURE/evidence/other/implementation-session-transcript-resolver.2026-10-16T00-59.md` line 38;
- `RESEARCH` line 143;
- `FEATURE/remediation-plan.2026-10-16T01-25.md` search commands (P0-T6, P2-T11, P2-T14) and bare-token prose (D1 entry, N1 item 4).

Decision: flagged and retained. These are executable search commands that must run verbatim to reproduce AC-1; `FEATURE/remediation-inputs.2026-10-16T01-25.md` line 29 permits prose naming the bare token without a path; the issue text is out of edit scope. None of these occurrences holds a path or an encoded name.

## D2 — RESEARCH lines 31 and 56 retained

`RESEARCH` line 31 names the two letter-case forms of the search token; line 56 quotes the public marketplace `publisher` identifier from `package.json`. Neither holds a path or an encoded name. Decision: retained (bare-token prose permitted by the remediation inputs).

## D3 — RESEARCH lines 11, 47, 72, 114, 117 unchanged

These lines contain a drive letter or an encoded prefix with no user segment: an illustrative drive-letter example on line 11, a generic encoded-prefix mention on line 47, the Option C drive-letter examples on line 72 (a `path.win32.join` call with a bare drive argument, its drive-relative result, and the rooted single-letter form), and two elided "Old" literals on lines 114 and 117. None matches HOSTPATH-FOLDER-REGEX and none contains host data. Decision: unchanged, keeping the edit inside the remediation-inputs scope (lines 55 and 107-111 plus the line-125 user segment).

## D4 — No redaction needed outside RESEARCH

The P0-T5 search of B1-PATHS (`FEATURE/evidence/remediation-baseline/b1-host-path-lines.2026-10-16T02-42.md`) found matches only in `RESEARCH` (lines 55, 107-111). `FEATURE/issue.md`, `FEATURE/plan.2026-10-15T17-44.md`, and `FEATURE/evidence/**` need no redaction edit.

## D5 — Declined: visible expected-string comment on the first `encodeWorkspacePath` test

The code-review suggestion to add a comment showing the expected encoded string for test 1 is declined. Such a comment would contain a drive letter followed by `--`, which matches HOSTPATH-REGEX and violates AC-2 ("no string literal or comment holding ... an encoded absolute directory name").

## D6 — N2, N3, N4: no action

N2 (parallel fixture constants), N3 (coverage text log in SCRATCH), and N4 (`test/` directory name) require no change; recorded as no-action per the remediation inputs.

## D7 — N1 WE-TEST edit does not conflict with the B1 scope limit

`FEATURE/remediation-inputs.2026-10-16T01-25.md` line 33 ("Scope limits: do not edit the two test files, any production file, or the AC check-offs in `issue.md`.") is the last bullet of the B1 finding (lines 20-33) and limits the B1 redaction only. N1 (line 37) is a related non-blocking finding fixed inside this item under the run's related-follow-up rule. N1 edits only WE-TEST; STR-TEST, every production file, and the AC check-offs in `FEATURE/issue.md` stay unedited (confirmed for `extensions` by `FEATURE/evidence/other/remediation-n1-verification.2026-10-16T03-02.md`). Decision: the N1 WE-TEST edit is adopted and does not conflict with line 33.

## Review artifacts

The four review artifacts (`policy-audit.2026-10-16T01-25.md`, `code-review.2026-10-16T01-25.md`, `feature-audit.2026-10-16T01-25.md`, `remediation-inputs.2026-10-16T01-25.md`) were not edited in this cycle.
