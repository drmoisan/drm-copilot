# Vale Install Step: Checksum Mismatch Proof (P4-T2, D15)

Timestamp: 2026-11-23T11-54
Command: sh SCRATCH/issue-1219-vale-mismatch.sh (PowerShell 7 launched from the script file: extracts the `run: |` body of the step carrying `VALE_SHA256:` from the committed .claude/lib/docs/templates/_docs-quality.yml, wraps it as the GitHub pwsh shell does ($ErrorActionPreference = 'stop' before the body, the LASTEXITCODE exit after it), and runs it with `pwsh -NoProfile -File` with RUNNER_TEMP=SCRATCH/vale-mismatch, VALE_VERSION=3.25.1 (as committed) and VALE_SHA256 altered in its first character)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Step env as committed: VALE_VERSION 3.25.1; committed VALE_SHA256 4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182; altered value used 0bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182 (64 hex characters).
- The step downloaded vale_3.25.1_Linux_64-bit.tar.gz, computed its lower-cased SHA-256, and threw: `VALE_SHA256_MISMATCH: expected 0bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182, got 4bf5c5176b682b1da0830f471584d3494f1c2e27ee3029e1ad6f6661d4962182` (thrown at line 6 of the extracted step, before the tar line).
- Install step exit code: 1.
- Run directory listing (SCRATCH/vale-mismatch, recursive): one entry, `vale_3.25.1_Linux_64-bit.tar.gz (13080706 bytes)`; no `vale` directory and no extracted `vale` binary (count of files named vale or vale.exe: 0).
- The actual hash of the downloaded archive equals the committed VALE_SHA256, which also confirms the committed pin against the upstream asset.
