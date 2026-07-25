# Baseline Install — `npm ci`, Repository Root (#414, [P0-T10])

Timestamp: 2026-07-25T17-03

Command: `npm ci` (working directory: repository root, from the unmodified committed `package-lock.json`)
EXIT_CODE: 0

```text
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 533 packages, and audited 534 packages in 6s

130 packages are looking for funding
  run `npm fund` for details

22 high severity vulnerabilities

To address issues that do not require attention, run:
  npm audit fix

To address all issues possible (including breaking changes), run:
  npm audit fix --force

Some issues need review, and may require choosing
a different dependency.

Run `npm audit` for details.
```

Verification that `node_modules` is present after the install:

Command: `node -e "console.log(require('node:fs').existsSync('node_modules'))"` (repository root)
EXIT_CODE: 0

```text
true
```

Output Summary: PASS. `npm ci` exits 0 and installs 533 packages from the unmodified committed lockfile; `node_modules` is present at the repository root. The install reiterates the 22 high-severity findings recorded in [P0-T7], confirming the pre-edit dependency state. npm's deprecation warning for `glob@10.5.0` is pre-existing and is not a failure signal.
