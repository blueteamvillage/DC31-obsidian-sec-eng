# Teleport setup and login runbook
The goal of this runbook is to help new users install Teleport on their local machine, setup Teleport with the BTV cluster, log into the Teleport, and a simple tutorial.

## Prereqs
* You NEED to have a Github account
* Your Github account needs to be apart of the [BTV Github org](https://github.com/blueteamvillage)
* Your Github account needs to be apart of the approraite [Github team](https://github.com/orgs/blueteamvillage/teams/dc31-obsidian-sec-eng/teams). If you don't have access please reach out to your lead.


# Guides to install Teleport
* [Teleport for Windows](https://goteleport.com/docs/installation/#windows-tsh-client-only)
    * [![Setting up Teleport (tsh) on Windows](https://img.youtube.com/vi/XH047Qc45xs/0.jpg)](https://www.youtube.com/watch?v=XH047Qc45xs)
* [Teleport for Linux](https://goteleport.com/docs/installation/#linux)
    * [![Getting started with ( tsh ) on Linux Desktop](https://img.youtube.com/vi/x2KxhM_v4MM/0.jpg)](https://www.youtube.com/watch?v=x2KxhM_v4MM)
* [Teleport for macOS](https://goteleport.com/docs/installation/#macos)
    * [![Setting up Teleport (tsh) on Mac](https://img.youtube.com/vi/IdnQP-qCG7k/0.jpg)](https://www.youtube.com/watch?v=IdnQP-qCG7k)



## Log into Teleport via browser
1. Browese to Teleport FQDN
    1. Ex: `https://teleport.blueteamvillage.com/web/login`
1. Select "Github"
1. Select "Authorize <Github org name>
    1. ![teleport_github_authorize](../.img/teleport_github_authorize.png)

## Log into Teleport using tsh CLI
1. `tsh login --proxy=<teleport FQDN>`
    ![teleport_tsh_login](../.img/teleport_tsh_login.png)

## List the servers you can SSH into
```shell
➜  DC31-obsidian-sec-eng git:(teleport-docs) ✗ tsh ls
Node Name       Address        Labels
--------------- -------------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------
ip-172-16-10-93 127.0.0.1:3022 hostname=ip-172-16-10-93,aws/Name=DEFCON_2023_OBSIDIAN-teleport-cluster,aws/Project=DEFCON_2023_OBSIDIAN
ip-172-16-21-10 ⟵ Tunnel       hostname=ip-172-16-21-10,aws/Name=DEFCON_2023_OBSIDIAN_metrics_server,aws/Project=DEFCON_2023_OBSIDIAN,aws/Team=sec_infra,teleport.internal/resource-id=3631...
```

## SSH into your first host
1. `tsh ssh <username>@<Teleport node name>`
1. Example:
```shell
➜  DC31-obsidian-sec-eng git:(teleport-docs) ✗ tsh ssh ubuntu@ip-172-16-21-10
ubuntu@ip-172-16-21-10:~$
```

## Troubleshooting
If you have any issues please reachout to the SecEng team in Discord via `#station-engineering`.

## References
* []()
