# Backing up the InterMine Registry database (Heroku app)

For Gos, on the Mac. The registry app on Heroku (stack Heroku-16, end of life) stores its data in a MongoDB
whose address is in the app's `MONGODB_URL` config variable. The dump is the only copy of the instance
list and the admin accounts (bcrypt password hashes), so treat it as sensitive: never paste `MONGODB_URL`
or the dump into a chat, a commit or an issue.

## 1. Tools (once)

```bash
brew tap heroku/brew && brew install heroku          # Heroku CLI
brew tap mongodb/brew && brew install mongodb-database-tools   # mongodump, mongorestore, mongoexport
heroku login                                           # opens the browser
```

## 2. Identify the app and its database

```bash
heroku apps                                           # lists your apps; note the registry's name (APP below)
heroku apps:info -a APP                               # stack (heroku-16), region, dynos, web URL
heroku domains -a APP                                 # should show registry.intermine.org
heroku addons -a APP                                  # does a MongoDB add-on still exist? (mLab was retired in 2020)
heroku config -a APP                                  # prints MONGODB_URL among others; do not share the output
```

`MONGODB_URL` looks like `mongodb://user:password@host:port/dbname` or `mongodb+srv://...`. The host tells
you who runs the database (an Atlas cluster, ObjectRocket, or something else). If the variable is missing,
the app has no database and the registry has been running on an empty or default store; say so.

## 3. Dump the database

```bash
mkdir -p ~/Private/intermine-registry-backup && cd ~/Private/intermine-registry-backup
export MONGODB_URL="$(heroku config:get MONGODB_URL -a APP)"
mongodump --uri="$MONGODB_URL" --out="dump-$(date +%Y%m%d-%H%M)"
ls -R dump-*                                          # expect <dbname>/instances.bson, users.bson (names may differ)
```

If `mongodump` fails with an authentication or TLS error, the server is probably old or wants `--ssl`;
add `--ssl` (Atlas) or try `--uri="$MONGODB_URL&tls=true"`. If it fails on protocol version, the
database server is very old: use a MongoDB Database Tools release from the same era, or fall back to
step 4, which needs no Mongo tools at all.

Readable copies next to the BSON (useful to check the content and for the migration):

```bash
DB=$(ls dump-*/ | head -1)
mongoexport --uri="$MONGODB_URL" --collection=instances --jsonArray --pretty --out="instances-$(date +%Y%m%d).json"
mongoexport --uri="$MONGODB_URL" --collection=users --jsonArray --pretty --out="users-$(date +%Y%m%d).json"
```

## 4. Fallback copy through the public API (no credentials needed)

```bash
curl -s https://registry.intermine.org/service/instances -o "instances-api-$(date +%Y%m%d).json"
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(len(d.get("instances", d)), "instances")' instances-api-*.json
```

This has the instance list but not the admin users; it is the minimum to keep if the dump fails.

## 5. Keep it private

- Store the folder outside any git repository (for example an encrypted disk image or the University's
  private file store). The dump holds password hashes and `MONGODB_URL` holds a live password.
- Record where it is in your own notes, not in the planning repo.
- Then unset the variable in that shell: `unset MONGODB_URL`.

## 6. While you are in the account

Also note (text only, no secrets) for the migration: the app name, region, stack, dyno type, the add-ons
list, the output of `heroku releases -n 5 -a APP` (when it was last deployed and from what), and whether
`heroku logs --tail -a APP` shows the app serving requests. Those go in a comment on bead im-bdy.13.
