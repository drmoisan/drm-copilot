# Gate — Python parser introduces no logging and no new import

Timestamp: 2026-08-20T09-53

Task: [P2-T8]

Command: git grep -n -E "^import logging|^from logging|logging\.|print\(" -- scripts/dev_tools/pr_context/verification_evidence.py
EXIT_CODE: 1

## Passing condition for this gate is a non-zero exit

The search returned ZERO matches, and a search with zero matches exits `1`. Exit code `1` is
therefore the PASSING condition here, not a failure. The observed code is recorded faithfully above
in accordance with SC7, which forbids this artifact from declaring the expectation with the new
evidence key (this feature's own qa-gates artifacts sit inside the corpus over which AC9 asserts zero
rendered-row differences).

## Result

- Matches for `^import logging`, `^from logging`, `logging.`, or `print(`: 0
- Import block of the module after the change (unchanged from baseline):

```
14:from __future__ import annotations
16:from dataclasses import dataclass
17:from typing import TYPE_CHECKING, Literal
```

No import was added by Phase 2. The change uses only the built-in `int()` already present in the
module.

## `Side Effects: None.` contract intact

The contract is written across two lines in the source, so a single-line search for the phrase
`Side Effects: None.` returns nothing whether or not the contract is present; a search anchored to
that phrase would be a gate that cannot discriminate. The check was therefore performed with
`grep -n -A1 "Side Effects:"`, which reports the section header together with its value line:

```
71:    Side Effects:
72-        None.          <- new pure helper normalize_result
--
87:    Side Effects:
88-        Reads filesystem metadata through globbing.   <- discover_canonical_evidence_files (unchanged)
--
116:    Side Effects:
117-        None.          <- parse_verification_evidence_markdown (unchanged contract)
--
207:    Side Effects:
208-        Reads evidence file content from disk.        <- parse_verification_evidence_file (unchanged)
```

`parse_verification_evidence_markdown` still declares `Side Effects:` / `None.` (lines 116-117), and
the new pure helper `normalize_result` declares the same contract (lines 71-72).

Output Summary: Zero matches for logging imports, `logging.` calls, and `print(` in
`scripts/dev_tools/pr_context/verification_evidence.py`; the search exits `1` on zero matches, which
is this gate's passing condition. No import was added by the change. The
`parse_verification_evidence_markdown` `Side Effects:` / `None.` contract is intact at lines 116-117
and the new pure helper carries the same contract at lines 71-72; that check used a two-line-aware
search because the phrase wraps across lines and a single-line search for it could not discriminate.
