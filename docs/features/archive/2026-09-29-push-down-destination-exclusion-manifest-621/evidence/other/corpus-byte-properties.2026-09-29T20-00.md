# Corpus Byte Properties — Issue #621

Task: [P2-T4]
Branch: feature/push-down-destination-exclusion-manifest-exec-621

## Command 1

Timestamp: 2026-09-29T20-00
Command: grep -c -F -e '"manifest_relative_path": ".push-down-exclusions"' tests/fixtures/push_down_exclusions/matcher-corpus.json tests/fixtures/push_down_exclusions/manifest-corpus.json tests/fixtures/push_down_exclusions/plan-corpus.json
EXIT_CODE: 0
Output Summary:

```
tests/fixtures/push_down_exclusions/matcher-corpus.json:1
tests/fixtures/push_down_exclusions/manifest-corpus.json:1
tests/fixtures/push_down_exclusions/plan-corpus.json:1
```

The count is `1` for each of the three files.

## Command 2

Timestamp: 2026-09-29T20-00
Command: poetry run python -c "import glob; [print(f.replace(chr(92), '/'), b'\r' in open(f, 'rb').read()) for f in sorted(glob.glob('tests/fixtures/push_down_exclusions/*.json'))]"
EXIT_CODE: 0
Command substitution: the plan names the PowerShell loop `foreach ($f in Get-ChildItem tests/fixtures/push_down_exclusions/*.json) { (Get-Content -Raw -LiteralPath $f.FullName) -match "\r" }`. The worktree isolation guard refuses `pwsh` for this agent. The substitute tests the raw bytes of each file for a carriage return and prints `True`/`False` per file, which is the same property the PowerShell `-match "\r"` loop tests.
Output Summary:

```
tests/fixtures/push_down_exclusions/manifest-corpus.json False
tests/fixtures/push_down_exclusions/matcher-corpus.json False
tests/fixtures/push_down_exclusions/plan-corpus.json False
```

`False` three times: all three files are LF-only. The CRLF manifest case is carried as the JSON escape `\r\n`, not as raw bytes. `git check-attr text eol` reports `text: auto` and `eol: lf` for the fixture path, so the committed blobs and checkouts remain LF.
