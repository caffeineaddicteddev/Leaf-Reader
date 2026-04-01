# Leaf Operational Rulebook

**1. Source of Truth Rules**
- `.workflow/` is the canonical source of truth. All architectural decisions must be recorded in `.workflow/DECISIONS.md` before implementation begins.
- `.workflow/API_SCHEMA.md` must be updated any time a method channel signature changes.
- `.workflow/ARCHITECTURE.md` must be updated any time a new component, engine, or data flow is added.

**2. Log Rules**
- Every agent session that touches code must produce at least one log entry in the current `.workflow/logs/log_XXX.md`.
- Log files cap at 10 entries. Create the next numbered file when full.
- Logs must be written *after* the work is done, not speculatively.

**3. Bug Rules**
- Every bug discovered must get a `.workflow/bugs/bug_XXX.md` entry before or immediately after a fix attempt.
- Bugs must not be silently fixed without documentation.
- Increment the bug number sequentially. Never reuse a number.

**4. Decision Rules**
- No architectural change (engine swap, schema change, new dependency, licensing change) may proceed without a `.workflow/DECISIONS.md` entry.
- Superseded decisions must update their `Status` field and link the superseding decision.

**5. Modification Rules**
- When updating any `.workflow/` file: read the current version first, make targeted edits, and record the change in the active log file.
- Do not rewrite entire files from scratch unless explicitly instructed — preserve historical content.
- Never delete log or bug entries. Mark them `Superseded` or `Resolved` instead.