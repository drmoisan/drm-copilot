Timestamp: 2026-07-02T14-18

Command:
`python scripts\dev_tools\validate_evidence_locations.py --root .`

EXIT_CODE: 1

Output Summary:
- Evidence-location validation failed before remediation.
- Reported non-canonical research path: the issue #268 research artifact was under the workspace-level research artifact folder before remediation.
- Validator guidance: use `docs/features/active/<feature>/research/` or `docs/research/` instead.

Output:
```text
VIOLATION: issue #268 research artifact was reported under the workspace-level research artifact folder - use docs/features/active/<feature>/research/ or docs/research/ instead
```
