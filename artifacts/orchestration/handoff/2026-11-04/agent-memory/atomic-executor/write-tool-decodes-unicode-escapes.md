---
name: write-tool-decodes-unicode-escapes
description: Text written with Write/Edit that contains the six-character sequences backslash-u-2028 or backslash-u-2029 lands on disk as the raw U+2028/U+2029 character, so a PowerShell ' ' literal silently becomes a no-op Replace and the source stops being ASCII
metadata:
  type: feedback
---

Observed 2026-11-04 (issue 1024, DocsReferenceFrontMatter.psm1): a module line written as
`.Replace([string][char]0x2028, '<backslash>u2028')` and a test literal `'"a<backslash>u2028c"'` were stored with the raw
U+2028 and U+2029 characters in place of the escape text (the backslash-u-0085 sequence survived). The Replace
then replaced the character with itself, which looked like a .NET String.Replace defect until the
code points were dumped.

**Why:** PowerShell single-quoted strings do not interpret `\u`, so the intended source was the
literal six characters; the tool layer decoded them before the file was written.

**How to apply:** never type a backslash-u escape for a line or paragraph separator in Write/Edit
content. Use ASCII-safe forms instead: `[char]0x2028` for the character, regex classes `\p{Zl}`
(U+2028) and `\p{Zp}` (U+2029) and `\x85`, or build an expected escape string from split literals
(`'\u' + '2028'`). After writing any file that handles these characters, run
`grep -nP '[^\x00-\x7F]' <files>` and fix lines with a SCRATCH PowerShell script that composes the
backslash from `[char]92`. Related: [[powershell-comma-return-and-paired-sort-pitfalls]].
