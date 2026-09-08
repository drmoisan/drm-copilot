---
name: upstream-flagged-lesson
description: A checked-in source fixture whose manifest record reports tokens_present.
metadata:
  type: feedback
---

The bytes of this file carry no host-identifying token. The refusal the test asserts
originates in the manifest's own host_token_scan.result value, so a pass that ignored
the upstream result and relied only on the local scan would stage this record.
