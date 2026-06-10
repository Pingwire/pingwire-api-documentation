---
name: fix-npm-vulnerabilities
description: Fix npm audit vulnerabilities. Applies safe patches, removes stale acknowledgements, and acknowledges vulnerabilities that cannot be patched yet. Use when responding to a Slack alert from the weekly npm audit workflow, or proactively to clear vulnerability debt.
---

## Setup

Create a branch before starting. There is no ticket identifier for this maintenance task — use:

```
fix/npm-audit-YYYY-MM-DD
```

Replace `YYYY-MM-DD` with today's date.

---

## Per-service workflow

Run the following steps for each service in scope. Work through services one at a time. Create a separate commit per service that has changes.

### 1. Run the audit

```bash
cd <service>
npm audit --json > npm-audit-report.json
```

### 2. Apply safe patches

```bash
npm audit fix
```

Do **not** use `--force`. Safe patches only.

### 3. Clean up stale overrides

Some services use the `overrides` field in `package.json` to pin transitive dependencies to a safe version when the parent hasn't released a patch yet. Once the parent updates its own dependency, the override may no longer be needed.

For each entry in the `overrides` object:

1. Temporarily remove the entry from `package.json`
2. Run `npm install` to regenerate `package-lock.json` without the override
3. Run `npm audit --json > npm-audit-report.json` and check whether the advisory the override was guarding against reappears
4. If the vulnerability **does not reappear** → leave the override removed; it is no longer needed
5. If the vulnerability **reappears** → restore the override entry in `package.json` and re-run `npm install`

Test each override in isolation. If the `overrides` object is empty or absent, skip this step.

### 4. Remove stale acknowledgements

Run the audit to get the current post-fix state:

```bash
npm audit --json > npm-audit-report.json
```

Open `acknowledged-npm-vulnerabilities.json`. For each entry, check whether its advisory ID still appears in `npm-audit-report.json`. If an advisory ID is **no longer present**, remove the entry — the vulnerability has been patched (either by `npm audit fix`, by an override removal, or upstream).

### 5. Run the smoke check

```bash
npm run test
```

This runs lint, type checks, and unit tests. See the `run-tests` skill for service-specific details.

**If the smoke check fails:**
- Revert the package changes: `git checkout -- package.json package-lock.json`
- Acknowledge the affected vulnerabilities (see step 6) with:
  - `reason`: `"npm audit fix causes lint/type/test failures — needs manual investigation"`
  - `wayForward`: describe what broke and what would be needed to fix it

### 6. Acknowledge remaining vulnerabilities

For any vulnerability that still appears in the audit report after step 4 (no safe fix available, or reverted due to test failure), add an entry to `acknowledged-npm-vulnerabilities.json`.

**Schema:**

```json
{
  "acknowledgedVulnerabilities": [
    {
      "<advisory-id>": {
        "name": "<package name>",
        "dependency": "<direct parent package that pulls it in, or 'direct dependency'>",
        "title": "<advisory title from npm audit>",
        "url": "<advisory URL from npm audit>",
        "severity": "<low | moderate | high | critical>",
        "reason": "<why it cannot be fixed now>",
        "impact": "<assessment of actual exposure in this codebase>",
        "wayForward": "<concrete next step: e.g. 'Wait for X to release a patch', 'Manually upgrade Y to vN once breaking changes are assessed'>",
      }
    }
  ]
}
```

**Common reasons:**
- No patched version available yet → `reason: "No patched version of <package> available as of YYYY-MM-DD"`
- Fix requires a breaking major-version bump → `reason: "Fix requires breaking major-version bump of <package> — needs manual upgrade"` and `wayForward: "Manually upgrade <package> to vN and verify compatibility"`
- False positive (fix already applied but npm audit doesn't recognise it) → explain in `reason`

Fill `wayForward` based on what you know about the package, its release history, and the nature of the vulnerability. Check the advisory URL for upstream fix status.

### 7. Commit

```bash
rm npm-audit-report.json
```

Use the `commit-progress` skill. Only stage files that actually changed. Skip the commit if nothing changed for this service.

---

## Wrapping up

Use the `open-pr` skill. The PR description should list:
- Which vulnerabilities were patched
- Which `overrides` entries were removed because they are no longer needed
- Which vulnerabilities were newly acknowledged, with severity
- Which vulnerabilities had stale acknowledgements removed

If any vulnerability requires a breaking major-version bump, call it out explicitly so a human can decide whether to prioritise it.
