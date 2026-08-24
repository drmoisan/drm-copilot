# Gate — the result vocabulary is closed at three members (Invariant C, AC13)

Timestamp: 2026-08-20T09-53

Task: [P7-T9]

Command: git grep -n "unparseable" -- scripts/dev_tools/pr_context/verification_evidence.py extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts
EXIT_CODE: 0

## The two declarations, quoted from the search output

```
scripts/dev_tools/pr_context/verification_evidence.py:30:NormalizedResult = Literal["pass", "fail", "unparseable"]
extensions/drm-copilot/src/lib/pr-context/verification-evidence.ts:37:export type NormalizedResult = "pass" | "fail" | "unparseable";
```

- Python: `Literal["pass", "fail", "unparseable"]` — exactly three members, no fourth.
- TypeScript: `"pass" | "fail" | "unparseable"` — exactly three members, no fourth.

The declarations moved from line 29 to 30 and from line 34 to 37 respectively because of the additions
above them; their CONTENT is byte-identical to baseline.

## Every other match is a use of the existing member, not a new member

| Location | Kind |
| --- | --- |
| `verification_evidence.py:11`, `verification-evidence.ts:13` | module docstring naming the existing three-value vocabulary |
| `verification_evidence.py:47,49,114`, `verification-evidence.ts:49,111,180` | docstrings and comments |
| `verification_evidence.py:144,157,173` | the three `normalized_result="unparseable"` assignments — the two pre-existing branches plus the new non-integer-expectation branch |
| `verification-evidence.ts:161,174,192` | the same three assignments in the TypeScript port |

The new branch reuses the EXISTING `unparseable` member; it introduces no new value. The collector
filters were separately verified unchanged at [P5-T5]: `collector.py:148` still filters on
`{"pass", "fail"}` and `collector-output.ts:100` still tests
`normalizedResult === "pass" || normalizedResult === "fail"`, so no consumer needed to widen a filter
or a switch.

Output Summary: Both `NormalizedResult` declarations carry exactly the three members `pass`, `fail`,
and `unparseable`, with no fourth member added. The nine remaining matches are docstrings, comments,
and the three `unparseable` assignments per runtime — the two pre-existing branches plus the new
non-integer-expectation branch, which reuses the existing member. Invariant C holds and neither
collector filter changed.
