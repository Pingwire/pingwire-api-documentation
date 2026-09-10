---
name: npm audit maintenance
about: Recurring ticket to clear npm audit vulnerability debt in this repo
title: 'Clear npm audit vulnerabilities'
labels: ''
assignees: ''
---

## What

Clear the current npm audit vulnerability debt in this repo. This is recurring maintenance driven
by the [weekly npm audit workflow](https://github.com/Pingwire/pingwire-api-documentation/blob/master/.github/workflows/weekly-npm-audit.yml):
dependencies with published advisories accumulate, and vulnerabilities that were acknowledged in
the past often get patched upstream without the acknowledgement being cleaned up.

<!-- If this ticket was opened in response to a Slack alert, link the alert and paste the
     advisories it flagged. -->

## How

- Run the `fix-npm-vulnerabilities` skill. This repo is a single package, so there is one pass, not
  a per-service loop.
- Apply safe patches only (`npm audit fix`, never `--force`), drop `overrides` entries that are no
  longer needed, remove stale entries from `acknowledged-npm-vulnerabilities.json`, and acknowledge
  whatever still cannot be patched.
- No new tests — `npm run test` (`redocly bundle` followed by `redocly lint`) is the guardrail after
  the dependency bump.

## Validation steps

- CI is green on the PR — that is the main signal, since only dependencies change.
- `npm run test` passes locally: the OpenAPI spec still bundles and lints cleanly.
- `npm run build` succeeds, then `npm run preview` and confirm the docs site renders: the reference
  loads, navigation works, and there are no console errors. A Redocly or Vite bump can break
  rendering without failing the lint.

## Blocked by

None - can start immediately
