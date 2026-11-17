Title: Request to join the org.intermine group (maintainer change)

Dear Clojars Administrators,

I am asking to be added to the Clojars group `org.intermine`, whose current members are no longer
active on the project. I am Gos Micklem (Clojars username `gmicklem`), head of the group at the
University of Cambridge that developed InterMine and BlueGenes, and the principal investigator on
the grants that funded them. Until recently I wrote none of the code; I am now the maintainer.

**The group and its artifacts.** `org.intermine` holds four libraries, all part of the InterMine
project:

| Artifact | Latest release | Source repository named in the published POM |
|---|---|---|
| org.intermine/imcljs | 1.6.0 | github.com/uosl/imcljs |
| org.intermine/im-tables | 0.15.0 | github.com/heralden/im-tables-3 |
| org.intermine/bluegenes-tool-store | 0.2.3 | github.com/uosl/bluegenes-tool-store |
| org.intermine/bluegenes | 1.4.5 | github.com/heralden/bluegenes |

Each of those POMs gives `http://www.intermine.org` as the project homepage (imcljs gives the EPL
licence URL), and each `scm` entry points at a personal GitHub fork of the canonical repository
under the InterMine organisation: `uosl` is the former GitHub name of `heralden`, and all four are
forks of `github.com/intermine/imcljs`, `intermine/im-tables-3`, `intermine/bluegenes-tool-store`
and `intermine/bluegenes` respectively. In other words the published artifacts are the
InterMine organisation's code, released by its developers of the time.

**My standing.** I am an owner of the `intermine` GitHub organisation
(https://github.com/intermine), where those four canonical repositories live, and of
`intermineorg`; the maintenance work is currently on my own account,
https://github.com/gmicklem, where forks of all four carry the next releases (imcljs 1.7.0,
im-tables 0.16.0, bluegenes-tool-store 0.3.0, bluegenes 1.5.0), ready to deploy once I can.
My association with the project is public: https://www.gen.cam.ac.uk/people/gos-micklem and
https://www.micklemlab.org/, which lists the developers below; and I am the senior author on the
InterMine papers, for example https://pubmed.ncbi.nlm.nih.gov/23023984/.

**The current members.** The group page https://clojars.org/groups/org.intermine lists `dani`,
`julie`, `sergio`, `uosl` and `yo`. These are Daniela Butano, Julie Sullivan, Sergio Contrino,
Kevin Reierskog and Yo Yehudi, all former developers in my group; none has worked on InterMine for
several years, and if they registered with their `@cam.ac.uk` or `@intermine.org` addresses they
no longer have access to those mailboxes, so I cannot ask one of them to add me through the
normal route, and an email of support from one of them would not be verifiable anyway.

**Domain control.** I control the DNS of `intermine.org` and have already published the TXT record
`clojars gmicklem` on it; the self-service verification page at https://clojars.org/verify/group
reads it correctly and refuses only because I am not yet a member ("You are not an active member of
the group"). Once I am a member I will complete the verification of `org.intermine` there.

**What I am asking.** Please add `gmicklem` to `org.intermine` as an admin so that I can deploy the
next versions of the four existing artifacts and manage the group's membership. I would be glad to
provide anything further; I can be reached at gmicklem@gmail.com (the address registered on
Clojars) or gm263@cam.ac.uk, and I can confirm this request from the `intermine` organisation on
GitHub in whatever form you prefer, for example a note in a repository under that organisation.

Many thanks,

Gos Micklem
