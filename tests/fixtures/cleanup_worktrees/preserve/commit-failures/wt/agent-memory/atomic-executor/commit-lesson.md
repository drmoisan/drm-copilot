---
name: commit-lesson
description: A checked-in source fixture for the writing-phase failure tests.
metadata:
  type: feedback
---

The writing phase copies this file verbatim. Its bytes carry no host-identifying token,
so the pre-pass accepts it and every failure the tests below assert originates in the
write itself rather than in the scan.
