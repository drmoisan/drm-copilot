# Final QC: read-only listing of the root format (write) script file set (AC-2, write script)

Timestamp: 2026-10-09T06-30
Command: npx prettier --no-error-on-unmatched-pattern --list-different "src/**/*.{ts,tsx,js,mjs,cjs,json}" "tests/**/*.{ts,tsx,js,mjs,cjs,json}" "eslint.config.mjs" "jest.config.cjs" "tsconfig*.json" "run-*.cjs"
EXIT_CODE: 0
Output Summary: exit 0 and no output lines and no [error] line; no path matched by the write script's six globs would be rewritten, so the fixtures directory is excluded for the write script as well.
