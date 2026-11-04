---
name: yo-today
description: "Daily summary of selected projects by goal: needs me, in flight, ready to plan, blocked"
agent: Work Buddy
---
Summarize the selected GitHub Projects for today. Read only; change nothing.

Run `./scripts/yo-gh today` and `./scripts/yo-gh goals`. Keep one entry per project membership; do not deduplicate issues present in multiple projects. Include `[project #N: title]` for each entry, and match the relevant membership when using `./scripts/yo-gh show <ref>`.

Reply grouped by goal (items without a goal under "No goal"), and within each goal by these sections (omit empty ones), each item as `ref Title [project #N: title]` with priority:

1. **Needs me**: `Plan review`, `Human review`, `Waiting feedback`. For each, run `./scripts/yo-gh show <ref>` and add the latest comment heading.
2. **In flight**: `Approved`, `In Progress`.
3. **Ready to plan**: `Todo`, sorted by priority.
4. **Blocked**: `Blocked`, with the reason from the latest `## Blocked` comment.
5. **Backlog**: count only.

Start each goal with its due date and open/closed counts. End with a one-line suggestion of the single most valuable next action.
