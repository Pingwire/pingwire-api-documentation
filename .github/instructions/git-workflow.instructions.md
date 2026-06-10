# Git workflow

## Branch naming

Format: `<type>/<ticket-identifier>-<short-description>`

- `<type>`: `feature`, `fix`, or `epic`
- `<ticket-identifier>`: e.g. `DEV-360` or `Data-1234`
- `<short-description>`: kebab-case summary, begins with a verb

Example: `feature/DEV-360-add-user-authentication`

If the ticket identifier or purpose is unclear, ask before creating the branch.

## Commit messages

Format: `[<ticket-identifier>] <short description>`

Example: `[DEV-360] Sanitize the document after saving request audit trail events`

- Keep concise and focused on purpose
- Do not add co-authors or additional metadata
- When a lot of changes have been made, consider breaking into smaller focused commits

## Pull requests

Title format: `[<ticket-identifier>] <short description>`

Example: `[DEV-360] Add user authentication`

Create PR to `master`:

```
gh pr create --title "<title>" --body "<description>" --base master
```

The PR description should include a summary of the changes made, the motivation, and any relevant context.
