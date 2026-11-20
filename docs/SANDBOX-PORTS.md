# Sandbox ports: commands to open the demo services to the laptop

Services started inside the sandbox are not reachable from the Mac until their ports are published.
Published ports are lost when the sandbox is recreated (for example to change its memory), so the
commands are kept here. Run them **on the Mac**, not inside the sandbox. The sandbox is named
`claude-repos` (agent + working directory); check with `sbx ls`.

Companion file: `docs/SANDBOX-NETWORK.md` (outbound hosts to allow).

## The ports (state of 20 Nov 2026)

| Port | What | URL on the Mac |
|---|---|---|
| 8090 | 5.1.1-line baseline demo mine (InterMine web services and classic webapp) | http://localhost:8090/humanmine |
| 5000 | BlueGenes on the baseline demo mine | http://localhost:5000 |
| 5001 | new BlueGenes build on the baseline demo mine | http://localhost:5001 |
| 18090 | "ut" hybrid HumanMine demo mine (6.0.0 line) | http://localhost:18090/humanmine |
| 15001 | front end of the ut demo: BlueGenes with tools, JBrowse 2, aligner (nginx) | http://localhost:15001 |
| 15000 | older BlueGenes on the ut demo mine | http://localhost:15000 |
| 3300 | new InterMine Registry demo | http://localhost:3300 |

Not published (used only inside the sandbox): 15011 (BlueGenes jar behind 15001), 13000 (sequence
aligner), 14881 (JBrowse 2), 18983 (Solr of the ut demo), 8983 and 5432-family ports of the stacks.

## Open them on a running sandbox

One command per port:

```bash
sbx ports claude-repos --publish 8090:8090/tcp
sbx ports claude-repos --publish 5000:5000/tcp
sbx ports claude-repos --publish 5001:5001/tcp
sbx ports claude-repos --publish 18090:18090/tcp
sbx ports claude-repos --publish 15001:15001/tcp
sbx ports claude-repos --publish 15000:15000/tcp
sbx ports claude-repos --publish 3300:3300/tcp
```

All at once:

```bash
for p in 8090 5000 5001 18090 15001 15000 3300; do sbx ports claude-repos --publish $p:$p/tcp; done
```

List what is published, or close one:

```bash
sbx ports claude-repos
sbx ports claude-repos --unpublish 3300:3300/tcp
```

## Or publish them when the sandbox is created

`sbx run` accepts `-p` only at creation (it is ignored when re-attaching). From the `repos`
directory, with the memory setting used since 20 Nov 2026 (maximum is 75% of the Mac's memory):

```bash
cd /Users/gos/claude_projects/update_intermine_planning/repos
sbx run claude . --memory 24g \
  -p 127.0.0.1:8090:8090 -p 127.0.0.1:5000:5000 -p 127.0.0.1:5001:5001 \
  -p 127.0.0.1:18090:18090 -p 127.0.0.1:15001:15001 -p 127.0.0.1:15000:15000 \
  -p 127.0.0.1:3300:3300
```

## Notes

- A published port shows nothing until the service behind it is running. After the sandbox is
  recreated the demo stacks must be rebuilt first (see the hand-over notes in `agent-memory/`).
- Services must listen on `0.0.0.0` inside the sandbox, not only on `127.0.0.1`, to be reachable.
- When a new service is added, add its port to the table and to the commands here.
