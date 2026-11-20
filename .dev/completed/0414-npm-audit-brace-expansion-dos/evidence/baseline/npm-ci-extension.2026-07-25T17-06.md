# Baseline Install — `npm ci`, `extensions/drm-copilot` (#414, [P0-T12])

Timestamp: 2026-07-25T17-06

Command: `npm ci` (working directory: `extensions/drm-copilot`, from the unmodified committed `package-lock.json`)
EXIT_CODE: 0

```text
npm warn deprecated glob@10.5.0: Old versions of glob are not supported, and contain widely publicized security vulnerabilities, which have been fixed in the current version. Please update. Support for old versions may be purchased (at exorbitant rates) by contacting i@izs.me

added 460 packages, and audited 461 packages in 5s

104 packages are looking for funding
  run `npm fund` for details

20 high severity vulnerabilities

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

Verification that `node_modules` is present after the install:

Command: `node -e "console.log(require('node:fs').existsSync('node_modules'))"` (`extensions/drm-copilot`)
EXIT_CODE: 0

```text
true
```

Output Summary: PASS. `npm ci` exits 0 and installs 460 packages from the unmodified committed extension lockfile; `node_modules` is present in `extensions/drm-copilot`. The install reiterates the 20 high-severity findings recorded in [P0-T8], confirming the pre-edit dependency state. The `glob@10.5.0` deprecation warning is pre-existing and is not a failure signal.
