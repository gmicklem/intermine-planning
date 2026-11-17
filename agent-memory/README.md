# Orchestrator memory (copy)

These are the orchestrator's memory notes, copied from the sandbox at
`/home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/memory/`
(the sandbox's home directory is NOT on the Mac; it disappears if the sandbox is recreated).
`MEMORY.md` is the index Claude Code loads each session.

To restore into a new sandbox before the first session there:

```bash
mkdir -p /home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/memory
cp /Users/gos/claude_projects/update_intermine_planning/repos/intermine-planning/agent-memory/*.md \
   /home/agent/.claude/projects/-Users-gos-claude-projects-update-intermine-planning-repos/memory/
```

(The directory name encodes the project path; if the project path changes, so does the name.)
