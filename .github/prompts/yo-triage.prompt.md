---
name: yo-triage
description: "Brainstorm what to work on next from the backlog, then promote chosen items to Todo"
argument-hint: "Optional focus, e.g. 'only infra' or 'max 3 items'"
agent: Work Buddy
---
Help the human decide what to work on next in the GitHub Project.

1. Run `./scripts/yo-gh today` and `./scripts/yo-gh goals`, then `./scripts/yo-gh show <ref>` for each `Backlog` and `Todo` item worth a closer look (comments, sub-issues).
2. Propose a short ranked list (default max 5) of items to work on now, each with one line on why (urgency, moves a goal with a near due date, unblocks others, quick win). Flag items that are vague, too large (suggest a split into sub-issues), have no goal, or sit in a repo with no local clone.
3. Ask which to promote and with what priority.
4. For confirmed items only: `./scripts/yo-gh priority <ref> <Priority>` and `./scripts/yo-gh status <ref> Todo`.
5. Reply with the final `Todo` list and suggest `/yo-plan` for the top one.

Apply the human's focus if given: ${input:focus}
