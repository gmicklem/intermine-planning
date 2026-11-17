# Deploying the InterMine Registry and retiring Heroku and Atlas

For Gos. This guide moves registry.intermine.org from the Heroku app `intermine-registry`
(Node, stack heroku-16, data in MongoDB Atlas) to the rewritten registry (Clojure, no database,
branch `maint-2026` of gmicklem/intermine-registry) on a server, with no gap in https
service (recommended: the DBCLS server that already runs the mines; fallback: a small VPS). Then it retires the Heroku app and the Atlas cluster. Bead im-bdy.13.

How to read it:

- Every command is in a block that says where it runs: **On the Mac** or **On the server**.
- Words in ANGLE BRACKETS, such as `<IPV4>`, are placeholders. A line under each block says what to
  put there. Type the value without the brackets.
- Steps marked **Check before you run this** change something the outside world sees, or cannot be
  undone. Read the whole step first.
- After each step: "Success looks like" and "If it fails".
- Never paste the admin token, `MONGODB_URL` or the Mongo dump into a chat, an issue or a commit.

Background: docs/INTERMINE_ORG_HOSTING.md (what runs where), docs/REGISTRY-BACKUP.md (the dump),
decisions/0008-registry-rewrite.md (why the rewrite has no database).

---

## 0. Overview and what you need

### Why there is no database any more

The new registry keeps its list of mines in a file, `resources/instances.edn`, which is in git and
is built into the image. Mines are added by pull request. There are no user accounts and no write
endpoints. What the server learns by itself (versions, branding, logos, last check) goes in a cache
directory; if that is lost, the next refresh (10 seconds after start-up) rebuilds it. So the
registry needs no MongoDB, no Atlas and no backups of its own. That is why Atlas can be shut down.

### Three ways to host it

| | (a) Small VPS (fallback) | (b) The DBCLS mines server (recommended) | (c) Managed container host |
|---|---|---|---|
| What | A 2-4 GB Debian/Ubuntu VPS (Hetzner, DigitalOcean ...) with Docker Compose and Caddy | One more container on the DBCLS server (133.39.78.111) that runs HumanMine, FlyMine and both JBrowse hosts as Docker containers behind nginx; the Compose stack holds the registry only (no Caddy) | Fly.io or Render runs the image; no server |
| Rough cost per month | Hetzner about EUR 4-6; DigitalOcean USD 6 (1 GB) to 12 (2 GB). Provider backups add about 20 %, and are not needed | Nothing extra | Fly.io about USD 3-6; Render about USD 7 (the free tier sleeps, so it is not suitable) |
| You look after | OS updates (automatic), Docker updates (monthly `apt upgrade`), the stack | Shared with the mines; who administers the server and what their change process is must be confirmed (see "What you need") | Only the app; the provider patches the host |
| TLS | Caddy, automatic | The server's existing nginx, one Let's Encrypt certificate per hostname | Provider, automatic |
| Backups | None needed: data is in git, cache is disposable | Same | Same |
| Who notices an outage | Nobody, unless monitoring is set up (step 8 does that; it emails you) | Same | Same; the provider fixes host failures |

Prices are rough and change. Check them on the day. For comparison, the Heroku app costs a dyno
(Eco about USD 5 or Basic about USD 7 per month) plus whatever the Atlas cluster costs.

**Recommendation (revised 17 Nov 2026): (b), the DBCLS server, with (a) as the fallback.** The first
version of this guide recommended (a) because it believed no InterMine server existed. One does: the old
Cambridge VM was taken down, but HumanMine and FlyMine run today as Docker containers behind nginx on a server
at DBCLS (docs/INTERMINE_ORG_HOSTING.md, "Update 17 Nov 2026 (Gos)"). Reasons:

- The server exists, already serves valid https for www.humanmine.org, flymine.org, www.flymine.org and
  jbrowse.intermine.org (and jbrowse2), and has about 256 GB RAM, so one more small container costs nothing:
  no new provider, no new bill, no new server to patch.
- The registry is tiny and needs no database: one container.
- The layout is the one docker_template started from (Docker Compose behind a reverse proxy), so the
  knowledge carries over. Routing there is by hostname with a Let's Encrypt certificate per hostname:
  registry.intermine.org (and registry-new.intermine.org for the test phase) get a server block and a
  certificate of their own, with no new ports.
- (a) stays as the fallback if DBCLS access or policy prevents (b): no SSH access, no permission to run
  another container or to add an nginx server block, or a change process too slow. The registry then runs on a
  VPS exactly as sections 2 and 3 describe, and can move to the DBCLS server later in an hour. A VPS of this
  size cannot run a mine, so it is only ever a home for the registry.
- (c) is a good choice if you never want to log in to a server. Its weak point is another account
  and another vendor-specific config file. One real advantage: Fly.io can validate the certificate
  for registry.intermine.org before DNS moves (with an `_acme-challenge` record), so the switch has
  no certificate gap at all. This guide does not give the Fly.io steps.

If you choose (b): the docker_template stacks do not terminate TLS themselves. Each mine's nginx
listens on `HTTP_PORT` (for example 14808) and "the proxy in front" handles https; on the DBCLS server that
proxy is the nginx 1.27.1 that also serves jbrowse. So skip section 2 (except the test DNS name in 2.2,
which points at 133.39.78.111; see the note at the start of section 2), skip the Caddy service in step 3,
and use the nginx variant in step 3.6: a server block for registry-new.intermine.org and
registry.intermine.org in that front proxy, forwarding to `127.0.0.1:3000`. Do not start a second
proxy on ports 80/443. Everything else in this guide is the same. Note that Docker publishes
each mine's `HTTP_PORT` on all addresses and bypasses ufw (step 2.6), so on that server those
ports should be closed by the provider's firewall or bound to `127.0.0.1`; that is for its administrators
to decide, not something to change as part of this guide.

### What you need before starting

1. **GitHub**: access to https://github.com/gmicklem/intermine-registry (public). The code to deploy
   is branch `maint-2026` (at the time of writing 683c4a6 on GitHub; e8b5332 or later is fine).
2. **SSH access.** For option (b), the recommendation: SSH access to the DBCLS server (133.39.78.111) as
   a user who may run `docker` and edit the nginx configuration, or a named DBCLS administrator who does
   those steps with you. Find out first: who administers the server; what their change process is (a
   request, an agreed time window, a review of nginx changes); and how the mines' containers are run there
   (Docker Compose, which directory). If you cannot get access or permission, stop and use option (a).
   For either option you need an **SSH key on the Mac**: check with `ls ~/.ssh/id_ed25519.pub`. If it is
   missing, run `ssh-keygen -t ed25519` and accept the defaults. For (b), the public key is what the DBCLS
   administrator authorises.
3. **DNS login for intermine.org.** Find out who runs the DNS:

   On the Mac:
   ```bash
   dig NS intermine.org +short
   whois intermine.org | grep -i -E 'registrar:|name server'
   ```
   The name servers tell you where to log in. `*.ns.cloudflare.com` is Cloudflare;
   `*.domaincontrol.com` is GoDaddy; `*.registrar-servers.com` is Namecheap; `*.awsdns-*` is AWS
   Route 53; `*.googledomains.com` is Google Domains (now Squarespace); `*.cam.ac.uk` means
   University of Cambridge IT runs it and you send them a request. If you cannot get a login, stop
   here: nothing else can happen without it.
4. **Certificate authority check.** On the Mac: `dig CAA intermine.org +short`. Empty output is
   fine (any authority may issue). If there is output, it must include `letsencrypt.org`, or neither Caddy
   nor certbot can get a certificate. Add `0 issue "letsencrypt.org"` at the DNS host if it is missing.
5. **Heroku CLI**, already installed and logged in (`heroku auth:whoami`). The app's owner account
   is intermineorg@gmail.com. Check what you see:

   On the Mac:
   ```bash
   heroku apps:info -a intermine-registry
   ```
   Success looks like: a block with `Owner:`, `Stack: heroku-16` and `Web URL:`. If it says you
   have no access, log in as the owner (`heroku login`), or ask for a transfer (step 7.7).
6. **The private Mongo dump** from docs/REGISTRY-BACKUP.md, kept outside any git repository. Check
   that the folder still has `instances.bson` and `users.bson` (or the exported JSON files). It is
   the only copy of the old admin accounts; keep it at least a year.
7. **jq on the Mac** (a JSON tool). Check with `jq --version`; if missing, `brew install jq`.
8. **About 2 hours** for steps 1-4, then a 24-hour wait, then **about 30 minutes** for the switch
   (step 5), then 7 days of light checks, then **about 30 minutes** to retire Heroku and Atlas. For option (b), add whatever time the DBCLS
   administrators need for their change process.

---

## 1. Build and publish the image

There are two routes. **1A (recommended to start): the server builds the image itself** from a git
checkout. Nothing to publish, nothing new to commit. **1B: GitHub builds it and publishes it** to
the GitHub Container Registry (GHCR); the server only downloads it. 1B needs a new workflow file in
the fork and is worth doing later.

### 1.1 (Optional) Try the image on the Mac first

Only if Docker Desktop is installed on the Mac. It shows what "working" looks like before a server
is involved.

On the Mac:
```bash
mkdir -p ~/src && cd ~/src
git clone --branch maint-2026 https://github.com/gmicklem/intermine-registry.git
cd intermine-registry
git log --oneline -1
docker build -t intermine-registry:local .
docker run -d --name registry-test -p 3000:3000 \
  -e REGISTRY_BASE_URL=http://localhost:3000 \
  -v registry-test-cache:/cache intermine-registry:local
```
The build takes a few minutes the first time (it downloads Clojure libraries). Then wait 40
seconds and check:

On the Mac:
```bash
curl -fsS http://localhost:3000/health | jq .
curl -fsS http://localhost:3000/service/instances | jq '.instances | length'
curl -fsS 'http://localhost:3000/service/instances?mines=all' | jq '.instances[].name'
open http://localhost:3000/
```
Success looks like: `/health` answers `"status": "ok"` with `"instances": 15`; the first count is
the number of production mines (15 at the time of writing, TargetMine included); the browser shows
the list of mines. Logos appear about a minute after start-up, once the first refresh has run.

If it fails: `docker logs registry-test` shows why. A problem in `instances.edn` is listed by name
at start-up. "port is already allocated" means something else uses port 3000: use `-p 3100:3000`
and `localhost:3100`.

Clean up afterwards:

On the Mac:
```bash
docker rm -f registry-test && docker volume rm registry-test-cache
```

### 1.2 The two settings that matter

- `REGISTRY_BASE_URL` is the public address, used for absolute links in the pages, the API docs and
  `images.logo_cached` in the API. Set it to `https://registry.intermine.org` from the start, even
  while testing on registry-new. During testing, those few links point at the old host, which is
  harmless; after the switch they are right, with nothing to remember to change.
- `REGISTRY_ADMIN_TOKEN` enables `PUT /service/synchronize` (refresh now). Without it, that endpoint
  answers 405 and the registry still refreshes every six hours by itself. Step 3.3 generates the
  token on the server with `openssl rand -hex 24`, so it is never typed or pasted anywhere. Keep a
  copy in your password manager. Never commit it.

### 1.3 Route 1B (later, optional): publish to GHCR from the fork

**Check before you run this**: this adds a commit to the fork (gated, via the usual orchestrator
flow) and publishes a public image.

File `.github/workflows/image.yml` in gmicklem/intermine-registry:
```yaml
# Builds the registry image and publishes it to ghcr.io/gmicklem/intermine-registry.
name: Image
on:
  push:
    branches: [maint-2026]
    tags: ["v*"]
  workflow_dispatch:
permissions:
  contents: read
  packages: write
jobs:
  image:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=ref,event=branch
            type=sha
            type=semver,pattern={{version}}
      - uses: docker/build-push-action@v6
        with:
          context: .
          platforms: linux/amd64     # add linux/arm64 for an ARM server (slower build)
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```
After the first run, open github.com, your profile, Packages, intermine-registry, Package
settings, and make it Public (names may differ), so the server can download it without a login.
On the server, in step 3's `docker-compose.yml`, replace the two lines `build:` and
`image: intermine-registry:local` with
`image: ghcr.io/gmicklem/intermine-registry:maint-2026`. Updates then become
`docker compose pull registry && docker compose up -d registry`.

---

## 2. Provision the server (option a)

**Option (b), the DBCLS server, skips this section** except for two things. In 2.2, the `registry-new` A
record points at `133.39.78.111` instead of `<IPV4>` (confirm that address with the administrators).
And instead of 2.3 to 2.8 (the server already exists and is administered by DBCLS), check on the server that
what step 3 needs is there:

On the DBCLS server:
```bash
docker --version && docker compose version
ss -ltn | grep ':3000 ' || echo "port 3000 is free"
```
Success looks like: Docker and a Compose 2.x version, and "port 3000 is free". If port 3000 is taken, choose
another free port and use it everywhere this guide says `127.0.0.1:3000`.

### 2.1 Create the VPS

In the provider's web console (Hetzner Cloud shown; others are similar; names may differ):

- Image: **Debian 12** or **Debian 13** (Ubuntu 24.04 also works; see the note in 2.5).
- Type: the smallest shared **x86** type with **at least 2 GB RAM** (on Hetzner, CX22 or its
  successor; on DigitalOcean, the 2 GB Basic droplet). x86 rather than ARM keeps route 1B simple.
- Networking: IPv4 **and** IPv6. Many clients are IPv4-only, so the IPv4 address is required.
- SSH key: paste the contents of `~/.ssh/id_ed25519.pub` from the Mac.
- Name: for example `registry-1`.

Write down the IPv4 address (and the IPv6 address). Below they are `<IPV4>` and `<IPV6>`.

Success looks like: the console shows the server as running, with both addresses.

### 2.2 DNS for the test name

**Check before you run this**: this creates a new public name under intermine.org. It does not
touch registry.intermine.org.

At the DNS host for intermine.org, add:

| Name | Type | Value | TTL |
|---|---|---|---|
| `registry-new` | A | `<IPV4>` | 300 |

Leave out an AAAA record for now; step 4.4 adds it after IPv6 is tested. If the DNS host is
Cloudflare, set the record to "DNS only" (grey cloud), not "Proxied".

On the Mac, a few minutes later:
```bash
dig +short registry-new.intermine.org
```
Success looks like: the output is `<IPV4>`. If it is empty, wait 10 minutes and try again; check
the record name (some DNS hosts want `registry-new`, others `registry-new.intermine.org.`).

### 2.3 First login, updates, a deploy user

On the Mac:
```bash
ssh root@<IPV4>
```
`<IPV4>`: the server's IPv4 address. Answer `yes` to the fingerprint question.

On the server (as root):
```bash
apt-get update && apt-get -y full-upgrade
apt-get install -y git jq curl ca-certificates dnsutils
adduser deploy
usermod -aG sudo deploy
install -d -m 700 -o deploy -g deploy /home/deploy/.ssh
install -m 600 -o deploy -g deploy /root/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
reboot
```
`adduser` asks for a password for `deploy`: choose one and keep it in the password manager (it is
needed for `sudo`). Press Enter through the other questions (full name and so on).

Add this to `~/.ssh/config` on the Mac (create the file if it does not exist), so later commands
can say `ssh registry-vps`:
```
Host registry-vps
    HostName <IPV4>
    User deploy
```

On the Mac, after a minute:
```bash
ssh registry-vps
sudo -v
```
Success looks like: you are logged in as `deploy` and `sudo -v` accepts the password.

If it fails: log in as root again (`ssh root@<IPV4>`) and check the two `install` lines.

### 2.4 Lock down SSH

**Check before you run this**: a mistake here can lock you out. Keep one SSH session open while you
test the change in a second Terminal window. The provider's web console has a rescue login if all
else fails.

On the server (as deploy):
```bash
sudo tee /etc/ssh/sshd_config.d/10-hardening.conf > /dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
sudo sshd -t && sudo systemctl reload ssh
```
In a **second** Terminal window on the Mac: `ssh registry-vps`. Success looks like: you are in.
`ssh root@<IPV4>` now says "Permission denied".

If it fails: in the first, still-open session, `sudo rm /etc/ssh/sshd_config.d/10-hardening.conf`
and `sudo systemctl reload ssh`.

### 2.5 Install Docker Engine and the Compose plugin (official repository)

On the server:
```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker deploy
exit
```
On Ubuntu, replace `linux/debian` with `linux/ubuntu` in both URLs. Membership of the `docker`
group is equivalent to root, so only `deploy` gets it.

Log in again (`ssh registry-vps`), then:
```bash
docker run --rm hello-world
docker compose version
```
Success looks like: "Hello from Docker!" and a Compose version 2.x.

If it fails: "permission denied ... docker.sock" means you did not log out and in again.

### 2.6 Firewall

**Check before you run this**: allow SSH before enabling the firewall, or you lock yourself out.

On the server:
```bash
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp
sudo ufw enable
sudo ufw status verbose
```
Success looks like: "Status: active" with 22, 80 and 443 allowed.

Important: Docker bypasses ufw for ports it publishes. That is why step 3 publishes the
registry's port 3000 on `127.0.0.1` only, never on all addresses. (The `ports: "3000:3000"` in the
repository's `docker-compose.example.yml` would be open to the internet on a VPS.)

Outgoing traffic is allowed, which the registry needs: every six hours it fetches
`/service/version*`, `/service/branding` and a logo from each mine (the hosts are listed in
docs/SANDBOX-NETWORK.md). On a server with an outgoing firewall (possible on the DBCLS server for option b: ask), those
hosts must be allowed on port 443 and 80.

### 2.7 Automatic security updates

On the server:
```bash
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```
Answer **Yes**. Optional, recommended: let it reboot at night when a kernel update needs it (the
containers come back by themselves):
```bash
printf 'Unattended-Upgrade::Automatic-Reboot "true";\nUnattended-Upgrade::Automatic-Reboot-Time "04:30";\n' \
  | sudo tee /etc/apt/apt.conf.d/52auto-reboot
```
Docker itself comes from Docker's repository, which unattended-upgrades does not cover: run
`sudo apt-get update && sudo apt-get -y upgrade` once a month (step 9).

### 2.8 (Only with 2 GB RAM or less) Add swap

The first image build compiles Clojure and can need more than 1 GB.

On the server:
```bash
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
free -h
```
Success looks like: `free -h` shows 2.0Gi of swap.

---

## 3. The Compose stack with Caddy

(Option (b), the DBCLS server, uses the same layout and `docker-compose.yml` without the `caddy` service;
its proxy part is the nginx variant in step 3.6 instead of 3.4. The Caddy steps below are option (a).)

Layout on the server, all owned by `deploy`:
```
/srv/registry/
  intermine-registry/   git checkout of gmicklem/intermine-registry, branch maint-2026
  docker-compose.yml    the stack: registry + Caddy
  caddy/Caddyfile       Caddy's configuration
  .env                  secrets and settings (mode 600, never in git)
```
The Caddyfile is in its own directory because Docker does not see edits to a file mounted on its
own (most editors replace the file); mounting the directory avoids that trap.

### 3.1 Get the code

On the server:
```bash
sudo install -d -o deploy -g deploy /srv/registry
cd /srv/registry
git clone --branch maint-2026 https://github.com/gmicklem/intermine-registry.git
git -C intermine-registry log --oneline -1
mkdir caddy
```
Success looks like: the last line shows the commit at the top of `maint-2026` (683c4a6 or later).

### 3.2 Write docker-compose.yml

Paste the whole block into the server's terminal. It writes the file.

On the server:
```bash
cat > /srv/registry/docker-compose.yml <<'EOF'
# InterMine Registry with Caddy in front (TLS, http->https, HSTS, gzip, access log).
# Guide: intermine-planning/docs/REGISTRY-DEPLOYMENT.md
name: registry

x-logging: &logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "5"

services:
  registry:
    build: ./intermine-registry
    image: intermine-registry:local
    container_name: intermine-registry
    restart: unless-stopped
    environment:
      PORT: "3000"
      REGISTRY_REFRESH_MINUTES: "360"         # every 6 hours
      REGISTRY_UNREACHABLE_AFTER_HOURS: "24"
      REGISTRY_CACHE_DIR: /cache
      REGISTRY_BASE_URL: https://registry.intermine.org
      REGISTRY_ADMIN_TOKEN: ${REGISTRY_ADMIN_TOKEN:?set REGISTRY_ADMIN_TOKEN in .env}
    volumes:
      - registry-cache:/cache
    ports:
      - "127.0.0.1:3000:3000"                 # for curl on the server only; Caddy uses the internal network
    mem_limit: 768m
    healthcheck:
      test: ["CMD", "curl", "-fsS", "http://localhost:3000/health"]
      interval: 30s
      timeout: 5s
      start_period: 40s
      retries: 3
    logging: *logging

  caddy:
    image: caddy:2
    container_name: registry-caddy
    restart: unless-stopped
    depends_on:
      - registry
    environment:
      ACME_EMAIL: ${ACME_EMAIL:?set ACME_EMAIL in .env}
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./caddy:/etc/caddy:ro
      - caddy-data:/data                      # certificates and the ACME account
      - caddy-config:/config
    logging: *logging

volumes:
  registry-cache:
  caddy-data:
  caddy-config:
EOF
```

### 3.3 Write .env (the token is generated on the server)

On the server:
```bash
cd /srv/registry
umask 077
printf 'REGISTRY_ADMIN_TOKEN=%s\n' "$(openssl rand -hex 24)" > .env
echo 'ACME_EMAIL=<YOUR-EMAIL>' >> .env
umask 022
ls -l .env
cat .env
```
`<YOUR-EMAIL>`: the address Let's Encrypt should have for the certificate account (Let's Encrypt no
longer sends expiry reminders, so step 8's monitoring is what warns you).

Success looks like: `ls` shows `-rw-------`; `cat` shows the two lines. Copy the token into your
password manager now, then clear the screen (`clear`). This file is the only place on the server
that holds it.

### 3.4 Write the Caddyfile

Why `registry.intermine.org` is commented out: if Caddy is told about that name while DNS still
points at Heroku, it tries to get a certificate, fails, and backs off for longer and longer
(minutes to hours) between attempts, and repeated failures count against Let's Encrypt's limit of
5 failed validations per name per hour. So the real name is added at the moment of the switch
(step 5.5), and a reload makes Caddy try straight away.

On the server:
```bash
cat > /srv/registry/caddy/Caddyfile <<'EOF'
# Caddy for the InterMine Registry. Guide: intermine-planning/docs/REGISTRY-DEPLOYMENT.md
{
    email {$ACME_EMAIL}
}

(registry_site) {
    encode zstd gzip
    header Strict-Transport-Security "max-age=31536000"
    log {
        output stdout
        format console
    }
    reverse_proxy registry:3000
}

# Test name, live from step 3.
registry-new.intermine.org {
    import registry_site
}

# Real name: uncomment these three lines at the DNS switch (step 5.5), then reload Caddy.
#registry.intermine.org {
#    import registry_site
#}

# Plain http: permanent redirect to https. The CORS header on the redirect lets old pages that
# still call http://registry.intermine.org/service/... from a browser follow it. Caddy still
# answers Let's Encrypt's http challenges on port 80.
http://registry-new.intermine.org, http://registry.intermine.org {
    header Access-Control-Allow-Origin "*"
    redir https://{host}{uri} 301
}
EOF
```
Notes: HSTS has no `includeSubDomains` and no `preload`, on purpose: other intermine.org names are
still http-only. The redirect is a 301 rather than Caddy's default 308 because some old HTTP
libraries do not follow 308.

### 3.5 Build and start

On the server:
```bash
cd /srv/registry
docker compose config --quiet && echo "config OK"
docker compose build
docker compose up -d
docker compose ps
```
The build takes 5-10 minutes the first time. Wait a minute after `up`, then:
```bash
docker compose ps
curl -fsS http://127.0.0.1:3000/health | jq .
docker compose logs caddy | grep -i -E 'certificate obtained|error'
```
Success looks like: both containers `Up`, `intermine-registry` `(healthy)`; `/health` says
`"status": "ok"`; Caddy's log has "certificate obtained successfully" for
`registry-new.intermine.org`.

If it fails:
- `config --quiet` complains about `REGISTRY_ADMIN_TOKEN` or `ACME_EMAIL`: `.env` is missing a line.
- The build stops with "Killed" or exit code 137: not enough memory; do step 2.8.
- No certificate: check `dig +short registry-new.intermine.org` gives `<IPV4>` and
  `sudo ufw status` allows 80 and 443. Then `docker compose restart caddy`. Do not restart it more
  than a few times an hour (Let's Encrypt's failure limit).
- The registry is not healthy: `docker compose logs registry | tail -50`.

### 3.6 On the DBCLS server (nginx instead of Caddy)

Use this instead of the `caddy` service, step 3.4 and the Caddy parts of 3.5. The server already terminates
TLS in nginx 1.27.1, with one Let's Encrypt certificate per hostname and routing by hostname, so the registry
is one more container and one more server block.

**Compose.** Write the same `docker-compose.yml` as in 3.2, minus the `caddy` service (and its `depends_on`
and the `ACME_EMAIL` line) and minus the `caddy-data` and `caddy-config` volumes. Keep
`"127.0.0.1:3000:3000"` on the registry: the host's nginx reaches the container there, and the port is not
open to the internet. `.env` holds only `REGISTRY_ADMIN_TOKEN` (the first line of 3.3). Put `/srv/registry`
where the mines' stacks live if DBCLS has a convention. Build and start with `docker compose build` and
`docker compose up -d`, then `curl -fsS http://127.0.0.1:3000/health | jq .`.

**Read the existing setup first. Do not invent the certbot command.** The exact certbot invocation (nginx
plugin, webroot with a particular path, or standalone) must be read off the server's existing setup, not
guessed.

On the DBCLS server:
```bash
sudo certbot certificates
ls /etc/nginx /etc/nginx/conf.d /etc/nginx/sites-enabled 2>/dev/null
sudo grep -rn -E 'server_name|ssl_certificate|proxy_pass|acme-challenge' /etc/nginx
sudo ls /etc/letsencrypt/renewal
```
`certbot certificates` lists the certificates, their hostnames and expiry. The files in
`/etc/letsencrypt/renewal/` say which authenticator each certificate uses (`authenticator = nginx` or
`webroot`, with `webroot_path`). The server blocks under `/etc/nginx/` show where such files live on this
server and whether an `/.well-known/acme-challenge/` location exists. Copy that pattern.

**Check before you run this**: this changes a shared production proxy that also serves HumanMine, FlyMine
and JBrowse. Agree it with the administrators first (their change process). Keep a copy of every file you
change. Run `sudo nginx -t` before every reload, and use `sudo systemctl reload nginx` (a reload does not
drop the mines' connections; a restart might).

Step 1, port 80 only (a block that names the 443 certificate before it exists makes `nginx -t` fail).
Path below is an example: follow the existing layout.

On the DBCLS server:
```nginx
# /etc/nginx/conf.d/registry.conf
server {
    listen 80;
    # listen [::]:80;   # only if the existing blocks listen on IPv6
    server_name registry-new.intermine.org registry.intermine.org;

    # If the existing hosts renew by webroot, copy their /.well-known/acme-challenge/ location here,
    # above the redirect.

    # Plain http: permanent redirect to https. The CORS header lets old pages that still call
    # http://registry.intermine.org/service/... from a browser follow it (as in the Caddy variant).
    location / {
        add_header Access-Control-Allow-Origin "*" always;
        return 301 https://$host$request_uri;
    }
}
```
Then `sudo nginx -t && sudo systemctl reload nginx`.

Step 2, the certificate for `registry-new.intermine.org` only (the real name waits for step 5.5, for the same
reason as in 3.4: Let's Encrypt limits failed validations). Run the same kind of command that created the
other hosts' certificates, with `-d registry-new.intermine.org`. As an illustration only, if the server's
certificates use the nginx plugin it looks like `sudo certbot --nginx -d registry-new.intermine.org`; if
`certbot certificates` and the renewal files show webroot, it is a `certonly --webroot -w <WEBROOT-PATH> -d
registry-new.intermine.org`. Use what the server shows, not this sentence. `<WEBROOT-PATH>`: the
`webroot_path` in an existing renewal file.

Step 3, the https block (if certbot's nginx plugin already wrote one, check it against this instead of
adding a second):

On the DBCLS server:
```nginx
server {
    listen 443 ssl;
    http2 on;
    server_name registry-new.intermine.org;

    ssl_certificate     /etc/letsencrypt/live/registry-new.intermine.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/registry-new.intermine.org/privkey.pem;
    # include the same ssl_* / options file the other hosts' blocks include, if they have one

    # no includeSubDomains and no preload, on purpose (other intermine.org names are still http-only)
    add_header Strict-Transport-Security "max-age=31536000" always;

    gzip on;
    gzip_types application/json text/css application/javascript image/svg+xml;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
Copy the proxy headers from the mines' existing blocks if they differ. Then
`sudo nginx -t && sudo systemctl reload nginx`.

Success looks like: `curl -fsS https://registry-new.intermine.org/health | jq .` from the Mac answers
`"status": "ok"`, and `sudo certbot certificates` lists a certificate for `registry-new.intermine.org`.
Confirm that the server's automatic renewal covers it: `sudo certbot renew --dry-run`.

If it fails: `sudo nginx -t` names the file and line. A certificate error usually means DNS for
`registry-new` does not yet answer with the server's address, or port 80 is not reaching nginx; check
`dig +short registry-new.intermine.org` and the nginx error log (path in the existing config, often
`/var/log/nginx/error.log`). To back out, remove the `registry.conf` file and reload; the mines are
untouched.

---

## 4. Verify on the new name

All from the Mac. Set a shorthand first (a shell variable, valid in this Terminal window):

On the Mac:
```bash
H=https://registry-new.intermine.org
```

### 4.1 The endpoints

On the Mac:
```bash
curl -fsS $H/health | jq .
curl -fsS $H/service/instances | jq '.instances | length'
curl -fsS "$H/service/instances?mines=all" | jq -r '.instances[] | "\(.name)\t\(.status)"'
curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' $H/instances/flymine/logo
curl -sS -o /dev/null -w '%{http_code}\n' $H/map
curl -sS -o /dev/null -w '%{http_code}\n' $H/status
curl -fsS "$H/service/namespace?url=https://www.flymine.org/flymine" | jq .
```
Success looks like: health ok; 15 instances (or the current count); every mine with a status
(TargetMine "Unreachable" is expected while its server is repaired); logo `200 image/...`; map and
status `200`; namespace `"flymine"`. A logo `404` in the first minutes only means the first refresh
has not fetched it yet.

### 4.2 Headers: CORS, HSTS, the http redirect, the certificate

On the Mac:
```bash
curl -sSI $H/service/instances | grep -i -E '^(HTTP|access-control-allow-origin|strict-transport|content-encoding)'
curl -sSI -H 'Accept-Encoding: gzip' $H/service/instances | grep -i content-encoding
curl -sSI http://registry-new.intermine.org/service/instances | grep -i -E '^(HTTP|location|access-control)'
echo | openssl s_client -connect registry-new.intermine.org:443 -servername registry-new.intermine.org 2>/dev/null \
  | openssl x509 -noout -subject -issuer -enddate
```
Success looks like: `HTTP/2 200`, `access-control-allow-origin: *`, `strict-transport-security`;
`content-encoding: gzip` (or zstd) when asked; the http request answers `301` with
`location: https://registry-new.intermine.org/service/instances` and the CORS header; the
certificate subject is `registry-new.intermine.org`, issuer Let's Encrypt, about 90 days left.

### 4.3 Compare with the Heroku registry

On the Mac:
```bash
mkdir -p ~/registry-compare && cd ~/registry-compare
curl -fsS https://registry.intermine.org/service/instances > old.json
curl -fsS $H/service/instances > new.json
jq -r '.instances[] | [.namespace, .url, .status] | @tsv' old.json | sort > old.tsv
jq -r '.instances[] | [.namespace, .url, .status] | @tsv' new.json | sort > new.tsv
diff old.tsv new.tsv
jq -S '.instances | map(del(._id, .__v, .last_time_updated)) | sort_by(.namespace)' old.json > old.sorted.json
jq -S '.instances | map(del(.last_check, .last_time_updated)) | sort_by(.namespace)' new.json > new.sorted.json
diff old.sorted.json new.sorted.json | less
```
The first `diff` is the short summary; the second is the full detail (`q` leaves `less`).

Expected differences (anything else is worth a look):

- `_id` and `__v` are gone; `last_check` is new.
- New fields under `images`: `logo_cached`, `logo_tile`, and for PlanMine `logo_declared` (its
  `logo` is now the registry's planarian).
- Corrected data: AllianceMine's `url` is `https://alliancemine.alliancegenome.org/alliancemine`;
  OakMine, RepetDB and WheatMine use `urgi.versailles.inrae.fr`; AllianceMine, AquaMine and
  FAANGMine now have a location.
- TargetMine is new (it was a "Not Running" entry in Mongo), listed as Unreachable.
- Versions and branding may differ by whatever changed since Heroku's last daily refresh.
- `/service/namespace?url=https://www.flymine.org/flymine` answers `flymine` on the new registry
  and `flymine.beta` on the old one: a deliberate fix.

### 4.4 IPv6 (optional, recommended)

On the server:
```bash
curl -6 -sS -o /dev/null -w '%{http_code}\n' --resolve registry-new.intermine.org:443:[<IPV6>] https://registry-new.intermine.org/health
```
`<IPV6>`: the server's IPv6 address. If this prints `200`, add an AAAA record `registry-new` ->
`<IPV6>` at the DNS host (**Check before you run this**: outward-facing, but only for the test
name). If it fails, leave IPv6 out; IPv4 alone is fine. On the DBCLS server, skip this unless the existing
hosts have AAAA records and the nginx blocks listen on IPv6.

### 4.5 Check from a real BlueGenes page

BlueGenes reads the registry through imcljs, which hard-codes
`https://registry.intermine.org/service` (`imcljs/src/cljc/imcljs/fetch.cljc`, function
`registry`). BlueGenes has no setting for another registry address (only `HIDE_REGISTRY_MINES`,
which turns it off). Pointing a BlueGenes at registry-new would mean editing imcljs and building
BlueGenes locally, which is not worth it. Instead, check the one thing that could differ, that a
mine's page is allowed to read the new registry (CORS):

1. Open https://www.humanmine.org/ in Chrome or Firefox.
2. Open the developer console (Chrome: Cmd-Option-J; Firefox: Cmd-Option-K).
3. Paste and press Enter:
   ```js
   fetch('https://registry-new.intermine.org/service/instances').then(r => r.json()).then(d => console.log(d.instances.length, 'mines'))
   ```

Success looks like: `15 mines` (or the current count) and no red CORS error. The full BlueGenes
check (the mine switcher) is done right after the switch, in step 5.6.

---

## 5. Lower the TTL, then move DNS

### 5.1 Record what is there now

On the Mac:
```bash
dig NS intermine.org +short
dig registry.intermine.org CNAME +noall +answer
dig @<NAMESERVER> registry.intermine.org CNAME +noall +answer
heroku domains -a intermine-registry
heroku certs:auto -a intermine-registry
```
`<NAMESERVER>`: one of the names printed by the first command (asking it directly shows the real
TTL, not a cached countdown).

Write down, in your own notes (not in git): the CNAME target, which looks like
`<something>.herokudns.com` and should match the "DNS Target" column of `heroku domains`
(below: `<HEROKU-DNS-TARGET>`); the TTL (the number after the name, in seconds); and the expiry
date of Heroku's certificate. The target is the rollback value. Heroku cannot renew its certificate
once DNS has moved, so rollback works only until that expiry date; if it is less than two weeks
away, do the switch soon after a renewal.

### 5.2 Lower the TTL, at least 24 hours (and at least one old TTL) before the switch

**Check before you run this**: outward-facing, harmless. It only makes caches forget sooner.

At the DNS host, edit the record `registry` (type CNAME, value unchanged) and set its TTL to **300**
seconds (or 60 if the DNS host allows it). Do the same for `registry-new` if it is not already 300.

On the Mac, to confirm:
```bash
dig @<NAMESERVER> registry.intermine.org CNAME +noall +answer
```
Success looks like: the TTL column shows 300 (or 60). Then wait at least 24 hours, and at least as
long as the old TTL, so that no cache anywhere still holds the old long TTL.

### 5.3 Pre-flight, on the day

Pick a quiet time, for example early on a weekend morning UK time. Then check:

On the Mac:
```bash
curl -fsS https://registry-new.intermine.org/health | jq .status
dig @<NAMESERVER> registry.intermine.org CNAME +noall +answer
dig CAA intermine.org +short
```
And in a terminal logged in to the server, start watching Caddy (leave it running):

On the server:
```bash
cd /srv/registry && docker compose logs -f --since 1m caddy | grep -i -E 'registry.intermine.org|obtain|error'
```
Success looks like: health "ok", TTL 300 or less, CAA empty or allowing letsencrypt.org.

On the DBCLS server (nginx) there is no Caddy to watch. Instead, in a terminal on the server, watch nginx's
error log (path from the existing config, often `/var/log/nginx/error.log`) with
`sudo tail -f /var/log/nginx/error.log`, and have the administrators on hand if the change process requires
it.

What users may notice during the switch: between the DNS change and Caddy's new certificate (a few
minutes with TTL 300, one or two with TTL 60), some clients reach the new server before it has a
certificate for registry.intermine.org and get a TLS error. In BlueGenes that shows as the toast
"Unable to contact InterMine registry ... You will not be able to switch to other mines" until the
page is reloaded; the mine itself is unaffected. InterMine webapps with `markup.webpages.enable`
skip the registry lookup after a timeout. Nobody else is affected. (A gap-free switch is possible by
obtaining the certificate in advance with a DNS-01 challenge, a hand-made `_acme-challenge` TXT
record and a certificate Caddy does not renew by itself; the extra moving parts are not worth a
few minutes.)

### 5.4 Switch the record

**Check before you run this**: this is the switch. Rollback is in 5.7.

At the DNS host, edit the existing `registry` record. Keep the type CNAME and change only its value
from `<HEROKU-DNS-TARGET>` to:
```
registry-new.intermine.org.
```
(With or without the final dot, as the DNS host's form expects.) Do not add an A record next to the
CNAME: a name cannot have both. If the DNS host does not allow a CNAME to another name in the same
zone (rare), delete the CNAME and add an A record `registry` -> `<IPV4>` (and AAAA -> `<IPV6>` if
added in 4.4).

Watch it spread:

On the Mac:
```bash
for i in $(seq 1 20); do
  date +%T
  for r in <NAMESERVER> 8.8.8.8 1.1.1.1; do echo "  $r: $(dig @$r +short registry.intermine.org | tr '\n' ' ')"; done
  sleep 30
done
```
`<NAMESERVER>`: as in 5.1. Press Ctrl-C to stop early.

Success looks like: the name server answers `registry-new.intermine.org.` and `<IPV4>` at once;
Google (8.8.8.8) and Cloudflare (1.1.1.1) follow within the TTL.

### 5.5 Tell Caddy about the real name

Do this as soon as the authoritative name server shows the new value (do not wait for 8.8.8.8):

On the server:
```bash
cd /srv/registry
sed -i 's/^#registry.intermine.org {/registry.intermine.org {/; s/^#    import registry_site/    import registry_site/; s/^#}/}/' caddy/Caddyfile
grep -n -A2 '^registry.intermine.org' caddy/Caddyfile
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```
The `sed` removes the `#` from the three commented lines (it touches nothing else, because only
those lines start with `#` in that way). `grep` should show the uncommented block:
```
registry.intermine.org {
    import registry_site
}
```
In the window that watches Caddy's log, look for "certificate obtained successfully" with
`registry.intermine.org`. This normally takes 10-60 seconds after Let's Encrypt sees the new DNS.

If no certificate after 5 minutes: look for the error in the log. "NXDOMAIN", "connection refused"
or a Heroku address in the error means Let's Encrypt still sees the old record; Caddy retries by
itself, so wait another TTL. If after 15 minutes there is still no certificate, roll back (5.7) and
investigate without time pressure.

**On the DBCLS server (nginx), the same moment, the same rule** (do not wait for 8.8.8.8, and do not run this
before the authoritative name server shows the new value). **Check before you run this**: a production proxy
(see 3.6). `server_name registry.intermine.org` is already in the port-80 block from 3.6. Now:

1. Get a certificate for `registry.intermine.org` with the same kind of certbot command that you read off the
   server for `registry-new` in 3.6, with `-d registry.intermine.org` (its own certificate, as for the other
   hosts).
2. Add an https server block as in 3.6 step 3, with `server_name registry.intermine.org;` and the
   `/etc/letsencrypt/live/registry.intermine.org/` certificate paths.
3. `sudo nginx -t && sudo systemctl reload nginx`.

Success looks like: `sudo certbot certificates` lists `registry.intermine.org`, and section 5.6's checks pass.
If certbot fails because DNS still shows Heroku, wait a TTL and retry; after 15 minutes without a certificate
roll back (5.7). Do not retry more than a few times an hour (failed-validation limit).

### 5.6 Verify on the real name

On the Mac:
```bash
H=https://registry.intermine.org
curl -sS -o /dev/null -w '%{http_code}\n' $H/health
curl -fsS $H/service/instances | jq '.instances | length'
echo | openssl s_client -connect registry.intermine.org:443 -servername registry.intermine.org 2>/dev/null \
  | openssl x509 -noout -subject -issuer -enddate
curl -sSI http://registry.intermine.org/service/instances | grep -i -E '^(HTTP|location)'
```
`/health` is the quickest tell: the new registry answers `200`, the old Node app `404`. Then repeat
the rest of step 4.1 and 4.2 with this `H`.

Success looks like: `200`; the instance count; subject `registry.intermine.org`, issuer Let's
Encrypt; http answers `301` to https.

Then the real BlueGenes test: open https://www.humanmine.org/ in a private window, open the mine
switcher (the mine name at the top left; names may differ), and check that the other mines are
listed and that switching to FlyMine works. Do the same on https://www.flymine.org/.

### 5.7 Rollback (any time during the soak)

**Check before you run this**: outward-facing.

At the DNS host, set the `registry` CNAME value back to `<HEROKU-DNS-TARGET>`. Heroku keeps serving
with its own certificate for as long as the app exists, the custom domain is still attached, and
its certificate has not expired (5.1). The new server can keep running; it does no harm.

---

## 6. Soak: keep Heroku running for 7 days

Leave the Heroku app untouched for a week. Do not add or edit mines in the old web interface;
nothing done there carries over.

Once a day:

On the Mac:
```bash
curl -fsS https://registry.intermine.org/health | jq .
```
Success looks like: `"status": "ok"`, `lastRefresh` within the last six hours, `unreachable` small
(TargetMine is expected).

On the server:
```bash
cd /srv/registry
docker compose ps
docker compose logs --since 24h caddy | grep -i -E 'error|warn' | tail -20
docker compose logs --since 24h registry | grep -c Refreshed
docker compose logs --since 24h registry | grep -i -E 'error|warn' | tail -20
df -h /
```
(On the DBCLS server there is one container, `intermine-registry`, and no Caddy lines; check nginx's error
log for the two hostnames instead.)

Success looks like: both containers `Up`, the registry `(healthy)`; few or no Caddy errors (the odd
TLS handshake error from scanners is normal); about 60 `Refreshed` lines per day (one per mine per
refresh, four refreshes a day, counted from the last start, not from midnight); disk use well under
80 %.

To see the six-hourly checks themselves, each line naming a mine and its status:
```bash
docker compose logs --since 24h registry | grep Refreshed | tail -20
```
or open https://registry.intermine.org/status in a browser.

To refresh now (for example after a maintainer fixes their mine), on the server:
```bash
cd /srv/registry
TOKEN=$(grep '^REGISTRY_ADMIN_TOKEN=' .env | cut -d= -f2)
curl -fsS -X PUT -H "Authorization: Bearer $TOKEN" http://127.0.0.1:3000/service/synchronize | jq -r .message
curl -fsS -X PUT -H "Authorization: Bearer $TOKEN" http://127.0.0.1:3000/service/synchronize/<NAMESPACE> | jq .
unset TOKEN
```
`<NAMESPACE>`: one mine's namespace, id or name, for example `flymine`. The first command refreshes
every mine (up to a minute); the second only one. Success looks like: "15 instances synchronised"
or a 201 answer listing what changed.

At the end of the week, check that Heroku no longer gets traffic for the name:

On the Mac:
```bash
heroku logs -n 1500 -a intermine-registry | grep -c 'host=registry.intermine.org'
heroku logs -n 1500 -a intermine-registry | grep -c 'host=intermine-registry.herokuapp.com'
```
Success looks like: `0` or nearly 0 for both. Requests to `intermine-registry.herokuapp.com` mean
something uses the Heroku address directly; look at the `path=` in those lines to guess what, before
going on.

---

## 7. Retire Heroku and Atlas

Do these in order. Each step is a point where you can still stop, until 7.4.

### 7.1 Note the Atlas cluster and database user (without printing the password)

On the Mac:
```bash
heroku config:get MONGODB_URL -a intermine-registry | sed -E 's#^.*@([^/?]+).*$#host: \1#'
heroku config:get MONGODB_URL -a intermine-registry | sed -E 's#^mongodb(\+srv)?://([^:]+):.*$#user: \2#'
```
These print only the host and the user name. The host looks like
`<cluster>.<code>.mongodb.net`; the first part is the cluster's name in Atlas (`<CLUSTER-NAME>`
below). The user is `<DB-USER>`. Write both down in your notes. If the host is not on
`mongodb.net`, the database is not in Atlas; say so in bead im-bdy.13 and skip 7.6.

Optional: if you want a fresh dump (nothing should have changed since the first one), repeat
section 3 of docs/REGISTRY-BACKUP.md now.

### 7.2 Maintenance mode for a day or two

**Check before you run this**: outward-facing; reversible with `maintenance:off`.

On the Mac:
```bash
heroku maintenance:on -a intermine-registry
```
Anything still using the Heroku app now gets a maintenance page. Wait a day or two for anyone to
complain. Undo with `heroku maintenance:off -a intermine-registry`.

### 7.3 Remove the custom domain from Heroku

**Check before you run this**: after this, rollback to Heroku needs `heroku domains:add` and a new
Heroku certificate. Only do it when `dig +short registry.intermine.org` shows the new server.

On the Mac:
```bash
dig +short registry.intermine.org
heroku domains:remove registry.intermine.org -a intermine-registry
heroku domains -a intermine-registry
```
Success looks like: only `intermine-registry.herokuapp.com` remains. Heroku stops trying to renew
the certificate (it may have sent "certificate failing" e-mails during the soak; ignore those).

### 7.4 Destroy the Heroku app

**Check before you run this**: IRREVERSIBLE. The app, its config (including `MONGODB_URL`), its
logs and its add-ons are deleted. Before running it, confirm: the private dump exists (step 0,
item 6); you have noted the Atlas host and user (7.1); the new registry has run for 7 days.

On the Mac:
```bash
heroku apps:destroy --app intermine-registry --confirm intermine-registry
heroku apps
```
Success looks like: "Destroying intermine-registry ... done" and the app missing from the list.

### 7.5 Stop paying Heroku

In the Heroku web dashboard, logged in as the owner (intermineorg@gmail.com unless transferred):
Account settings, then Billing (names may differ). If the app was on Eco dynos and no other app
uses them, unsubscribe from the Eco plan there. A last invoice for the part-month will still come.
Do not delete the account itself: the address may be used elsewhere.

### 7.6 Retire the Atlas cluster

In the Atlas web UI (https://cloud.mongodb.com), logged in with the account that owns the cluster
(try intermineorg@gmail.com first, then your own). Menu names may differ; Atlas changes them often.

1. Find the organisation and project whose cluster is `<CLUSTER-NAME>` (from 7.1). Note the tier
   shown on the cluster card (M0 = free, M2/M5/Flex = shared, M10 and up = dedicated).
2. Open the cluster's metrics (Metrics or Monitoring, Connections). Success looks like: no
   connections since the Heroku app was destroyed. If something still connects, stop and find out
   what before going on.
3. **Check before you run this**: in Security, Database Access (or "Database Users"), delete
   `<DB-USER>`. This retires the old password that was in `MONGODB_URL`. It is the reversible way
   to find a hidden user of the database: anything left breaks now, and a new user could be created
   if needed.
4. Pause, only if the tier is M10 or larger (Atlas cannot pause free or shared clusters): in the
   cluster's "..." menu, Pause Cluster. Wait two or three days. For M0/M2/M5/Flex, simply wait the
   same two or three days after step 3.
5. **Check before you run this**: IRREVERSIBLE. In the cluster's "..." menu, Terminate; type the
   cluster name to confirm. If asked whether to keep backup snapshots, do not keep them (they are
   charged, and the dump is the backup).
6. In Security, Network Access, remove any entries (often `0.0.0.0/0` for Heroku).
7. **Check before you run this**: in Project Settings, Delete Project (possible once the project has
   no clusters).
8. In Organization, Billing: if no other projects remain, remove the payment method (if any).

Success looks like: the project is gone and the billing page shows no running charges.

### 7.7 If you take over ownership first (instead of logging in as intermineorg@gmail.com)

Only needed if you prefer to act from your own Heroku account. The current owner runs:

On the Mac, logged in to Heroku as the owner:
```bash
heroku apps:transfer <YOUR-HEROKU-EMAIL> -a intermine-registry
```
`<YOUR-HEROKU-EMAIL>`: the e-mail of your own Heroku account. You then accept the transfer in the
Heroku dashboard or the e-mail Heroku sends (names may differ); paid resources need a verified
payment method on the receiving account. For destroying the app, logging in as the owner is
simpler than transferring it.

---

## 8. Afterwards

### 8.1 Update the documents

- `intermine-planning/docs/INTERMINE_ORG_HOSTING.md`: add a dated section "Registry moved": the
  provider and server name (for option b: the DBCLS server and who administers it), who pays, the DNS record (`registry` CNAME `registry-new`), and that
  Heroku and Atlas were retired on that date. Mark the older Mongo/Atlas recommendations there as
  superseded by decision 0008.
- Registry README: add a "Production deployment" paragraph that points to this guide and says
  where the registry runs (no addresses of the server needed).
- `docs/REGISTRY-BACKUP.md`: add one line saying the Heroku app and Atlas are gone and the dump is
  the archive.

### 8.2 Hard-coded registry URLs (bead im-bdy.10)

Found with
`grep -rn "registry.intermine.org"` across bluegenes, imcljs, im-tables-3, bluegenes-tool-store and
intermine (branches `maint-2026`; excluding node_modules, target, .git):

| File | Now | Change |
|---|---|---|
| `bluegenes/docs/useful-faqs.md:8` | `http://registry.intermine.org/` | to https |
| `bluegenes/docs/building.md:346` | `http://registry.intermine.org/service/instances` | to https |
| `intermine/README.md:28` (`:27` on `dev`) | `http://registry.intermine.org` | to https |
| `intermine/intermine/webapp/src/main/webapp/vendor/js/intermine/imjs/3.18.1/im.js:3022` | `ROOT = "http://registry.intermine.org/service/"` | to https (vendored library; edit in place with a comment, or replace the vendored copy). On an https mine page the browser blocks this http call as mixed content, so it is broken today regardless of the move |
| `intermine/intermine/webapp/src/main/webapp/vendor/js/intermine/im-tables/2.2.0-beta/imtables.js:45251` | same `ROOT` | to https, as above |
| `imcljs/src/cljc/imcljs/fetch.cljc:280` | `https://registry.intermine.org/service` | none (already https) |
| `intermine/intermine/webapp/src/main/java/org/intermine/web/fair/SemanticMarkupFormatter.java:71` (`:67` on `dev`) | `https://registry.intermine.org/` | none |
| `intermine/docs/UPGRADING-build.md:460` | host name only | none |

im-tables-3 and bluegenes-tool-store have no references. The http redirect in step 3.4 (3.6 on the DBCLS server) keeps the
old http references working for GET requests, so these changes are tidying, not urgent.

### 8.3 Monitoring

Nobody is told when the registry stops unless something watches it. Use one or both:

- **UptimeRobot** (free; https://uptimerobot.com): an HTTP(s) monitor on
  `https://registry.intermine.org/health`, every 5 minutes, keyword `"status":"ok"`, alerts by
  e-mail. It also warns before the certificate expires if that option is ticked (names may differ).
- **A GitHub Actions cron**, for example as `.github/workflows/uptime.yml` in the registry fork
  (**Check before you run this**: a commit, through the usual gated flow). A failed scheduled run
  e-mails whoever last changed the workflow file. GitHub switches off scheduled workflows in a
  public repository after 60 days without commits, and e-mails a warning first; re-enable them in
  the Actions tab. That is why UptimeRobot is the better primary.

```yaml
# Checks registry.intermine.org every 30 minutes: /health answers ok and the
# certificate has at least 14 days left.
name: Registry uptime
on:
  schedule:
    - cron: "17,47 * * * *"
  workflow_dispatch:
permissions: {}
jobs:
  ping:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - name: /health answers ok
        run: |
          for i in 1 2 3; do
            if curl -fsS --max-time 20 https://registry.intermine.org/health | jq -e '.status == "ok"'; then
              exit 0
            fi
            sleep 30
          done
          echo "::error::https://registry.intermine.org/health failed three times"
          exit 1
      - name: Certificate valid for 14 more days
        run: |
          echo | openssl s_client -connect registry.intermine.org:443 -servername registry.intermine.org 2>/dev/null \
            | openssl x509 -noout -enddate -checkend 1209600
```

### 8.4 Backups

Nothing on the server needs a regular backup:

- The data is `resources/instances.edn`, in git.
- The `registry-cache` volume is disposable: one refresh rebuilds it (logos show the mine's initial
  for the first minute).
- The `caddy-data` volume holds the certificates and the Let's Encrypt account. Also disposable:
  Caddy gets new certificates at start-up. Do not throw it away often, though: Let's Encrypt allows
  only 5 identical certificates per week. On the DBCLS server (nginx) there is no `caddy-data`: the
  certificates are in `/etc/letsencrypt`, backed up and renewed with the server's other certificates;
  check `sudo certbot renew --dry-run` after adding them.
- Keep, outside the server: the admin token (password manager), and copies of
  `docker-compose.yml` and `caddy/Caddyfile` (they are in this guide; any change you make to them
  should be copied back here). Rebuilding the whole server from this guide takes about an hour.

---

## 9. Operations cheat-sheet

All on the server, in `/srv/registry` (`ssh registry-vps`, then `cd /srv/registry`).

On the DBCLS server (option b): log in as arranged with its administrators and use the directory chosen in
3.6. There is no Caddy, so leave out the Caddy lines below (the `caddy` log line and the monthly
`docker compose pull caddy`); the proxy is reloaded with `sudo nginx -t && sudo systemctl reload nginx`;
OS and Docker updates are the administrators', unless agreed otherwise.

**State at a glance**
```bash
docker compose ps
curl -fsS http://127.0.0.1:3000/health | jq .
```

**Logs**
```bash
docker compose logs --tail 100 registry          # the registry
docker compose logs -f caddy                      # Caddy, live (Ctrl-C to stop)
docker compose logs --since 24h registry | grep Refreshed
```

**Restart**
```bash
docker compose restart registry                   # about 30 s of 502 while the JVM starts
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile   # after editing the Caddyfile
```

**Update to a new registry release** (also how a merged mine change goes live)
```bash
cd /srv/registry/intermine-registry && git pull --ff-only && git log --oneline -3
cd /srv/registry
docker tag intermine-registry:local intermine-registry:previous
docker compose build registry && docker compose up -d registry
docker compose ps && curl -fsS http://127.0.0.1:3000/health | jq .status
```
Success looks like: `(healthy)` within a minute and `"ok"`. To go back:
`docker tag intermine-registry:previous intermine-registry:local && docker compose up -d --force-recreate registry`.
The registry is down for about 30 seconds during `up -d`; choose a quiet time.

**Add or change a mine**: a pull request to `resources/instances.edn` (copy an existing entry; the
comment at the top of the file explains each field). CI checks the file. After the merge, run
"Update" above: the file is built into the image. Never change an existing mine's `namespace`.

**Monthly**
```bash
sudo apt-get update && sudo apt-get -y upgrade    # includes Docker itself
docker compose pull caddy && docker compose up -d caddy
df -h / && docker system df
```

**Disk cleanup**
```bash
docker image prune -f        # unused image layers from earlier builds
docker builder prune -f      # the build cache (the next build is slower)
docker system prune -f       # both, plus stopped containers and unused networks
```
Never add `--volumes` while the stack is down (it would delete the certificates and the cache);
`-a` also deletes the `previous` image kept for rollback.

**Server reboot**: `sudo reboot`. Docker starts at boot and both containers come back by themselves
(`restart: unless-stopped`). Check with `docker compose ps` afterwards.

**A mine's maintainer says their mine is wrongly shown as Unreachable**

1. Look at https://registry.intermine.org/status and the mine's page
   (`/instances/<NAMESPACE>`): the reason and since when (`timeout`, `http 403`,
   `bot-protection page`, `html instead of json` ...). A mine becomes Unreachable only after more
   than 24 hours of failed checks; TargetMine is listed Unreachable on purpose until its server is
   repaired.
2. Repeat the registry's own request, from the registry's own container (so from the server's IP
   address, which matters for bot protection):
   ```bash
   docker compose exec registry curl -sS -m 10 \
     -A 'InterMine-Registry/2.0 (+https://registry.intermine.org)' \
     -H 'Accept: text/plain, application/json;q=0.9, */*;q=0.1' \
     -w '\nHTTP %{http_code}\n' <MINE-URL>/service/version/intermine
   ```
   `<MINE-URL>`: the mine's `url` from `/service/instances/<NAMESPACE>`, for example
   `https://www.flymine.org/flymine`. A good answer is a bare number such as `5.1.0` and HTTP 200.
3. If it now answers well, refresh that mine (step 6, `synchronize/<NAMESPACE>`); it turns Running
   at once.
4. If it gets an HTML or challenge page, send the maintainer the README section "For mine
   maintainers: letting the registry check your mine" (exempt the four `/service/version*` and
   `/service/branding` paths, or allow the User-Agent `InterMine-Registry/2.0`, or the server's
   IPv4 address from the provider console).
5. If the mine has moved, fix its `url` by a pull request to `instances.edn`, then "Update".
