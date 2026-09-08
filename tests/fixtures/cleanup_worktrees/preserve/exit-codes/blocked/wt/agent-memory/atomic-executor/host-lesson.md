---
name: exit-codes-blocked-lesson
description: A checked-in source file for the exit-codes/blocked preserve scenario.
metadata:
  type: feedback
---

The preserve pass copies this file verbatim and stages it. The line below carries a
fabricated Windows user-profile path so the local content scan refuses the whole pass:

    C:\Users\exampleaccount\repos\demo\notes.md

