# Acceptance-criteria Check-off Verification (P18-T5)

Timestamp: 2026-09-27T18-18
Command: git grep -c -F -e "- [x]" -- docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md ; git grep -c -F -e "- [ ]" -- docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md
EXIT_CODE: 0
Output Summary: PASS. The checked-box count is 37 and the open-box count is 1, both exit 0, at HEAD e7ca41d7 (after the P18-T4 push). The single open criterion is AC-38 (spec line 700, CI green on the pull request including the windows-latest Pester job), which P18-T7 checks off after CI; the stop condition is not reached.

## Command outputs

```text
$ git grep -c -F -e "- [x]" -- docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md
docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md:37
(exit 0)

$ git grep -c -F -e "- [ ]" -- docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md
docs/features/active/blast-radius-over-reports-and-zero-overlap-tolerance-722/spec.md:1
(exit 0)
```

Remaining unchecked criterion (git grep -n over the same pattern):

```text
spec.md:700:- [ ] CI is green on the pull request, including the windows-latest Pester job (checked off by the
```

| ID | Status |
| --- | --- |
| AC-01 through AC-37 | checked (37) |
| AC-38 | open (P18-T7, after CI) |
