# Vale Hyperbole Proof (P4-T3, D15 Windows route)

Timestamp: 2026-11-23T11-55
Command: sh SCRATCH/issue-1219-vale-hyperbole.sh (PowerShell 7 launched from the script file: downloads vale_3.25.1_Windows_64-bit.zip from https://github.com/vale-cli/vale/releases/download/v3.25.1/, verifies its SHA-256 with an ordinal -cne comparison before extraction, stages the source of every page-check row of Get-DocsInitTemplate at its init destination under SCRATCH/estate/, writes SCRATCH/estate/docs/guide/overview.md containing the word `perfect`, then runs `vale --config docs/documentation-estate/.vale.ini --output line docs/guide/overview.md` from SCRATCH/estate, and once more with `--output JSON` to read the alert severity)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Verified hash: expected 5f4b5cefee5d0f7ee0621d7cc035886515888fd732c4e8add36d3c922f2adc68 (upstream checksums file, recorded in evidence/other/vale-checksum-confirmation.2026-11-23T05-58.md), actual 5f4b5cefee5d0f7ee0621d7cc035886515888fd732c4e8add36d3c922f2adc68; verified before extraction. `vale --version`: vale version 3.25.1.
- Staged 10 init rows unchanged from their template sources: .markdownlint.json, .vale.ini, DocsBase HeadingPunctuation.yml and Placeholders.yml, the Project vocabulary accept.txt, and the five DocsTonality styles.
- Page line 3: `This release is a perfect fit for the reporting team.`
- Vale line output: `docs\guide\overview.md:3:19:DocsTonality.Hyperbole:Avoid hyperbole: 'perfect' (tonality policy: measured, evidence-based wording).`
- Vale JSON output: check=DocsTonality.Hyperbole severity=error line=3 match=perfect.
- Vale exit code: 1 (line run and JSON run), from the error-level DocsTonality.Hyperbole alert.
