---
name: revision-syntax-lesson
description: Ordinary revision syntax that the short-name pattern must not match.
metadata:
  type: feedback
---

Rebase onto HEAD~3, then compare HEAD~1..HEAD and show main~2. The upstream form
origin/main~1 and the ref form refs/heads/main~1 both appear here, and so does the
near-miss docs/notes~1.md, whose tilde segment is followed by a dot rather than by a
path delimiter. The short-name pattern requires BOTH delimiters, so none of these is
a match. A genuine short-name path segment carries a delimiter on each side.
