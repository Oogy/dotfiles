# Global Rules
## Coding Style
### Bash
- Keep it simple and succinct.
- Handle errors where you can without overcomplicating a script.
- Idempotency where possible, i.e. check if files or directories exist before creating or downloading.
- Use functions liberally.
- High level functions should be used within a main() function. These high level functions should make clear what the script is doing even if it abstracts the how.

## Git
- Initialize git in every project if it has not already been done.
- Commit after every edit to enable viewing diffs and easy rollback - don't batch changes.
- DO NOT push to remote or create github repos until user explicitly requests it.
- Commit frequently with messages using the Conventional Commits specification(feat:, fix:, docs:, build:, chore:, ci:, docs:, style:, refactor:, perf:, test:)
- Create feature brances for new work, never commit directly to main/master.
- Use PR's for all merges to main, even for solo projects.
- Keep .gitignore updated - never commit secrets, .env files, or build artifacts.
- Before starting work on an existing repo always git pull to sync with remote.
