# Ansible - Jupyterhub over k3s server
## Description

Linux server with k3s and jupyterhub.
Replaced with basic quickstart install as issue.

Github SSO will require matching oauth token
Callback url: https://jupyterhub.teleport.blueteamvillage.com/hub/oauth_callback

## Init Ansible playbook
If not generated automatically by terraform
1. `cd ansible/`
1. `vim ansible/hosts.ini` and set `[jupyterhub_server]`, `[ks3_group]`, `[ks3_cluster]`, `[ks3_masters]` to the IP address of the server

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_jupyterhub.yml`

## Troubleshooting, known issues

* Post-install error: TypeError: 'NoneType' object is not iterable
https://discourse.jupyter.org/t/post-install-error-typeerror-nonetype-object-is-not-iterable/19302

## References
* https://github.com/blueteamvillage/DC31-obsidian-sec-eng/issues/46
* https://github.com/juju4/ansible-jupyterhub/ fork of https://github.com/CyVerse-Ansible/ansible-jupyterhub
* https://github.com/juju4/ansible-k3s/ fork of https://github.com/CyVerse-Ansible/ansible-k3s
* https://oauthenticator.readthedocs.io/en/latest/tutorials/general-setup.html
* https://oauthenticator.readthedocs.io/en/latest/topic/github.html
* https://jupyterhub.readthedocs.io/en/stable/tutorial/quickstart.html
* https://github.com/KamalGalrani/jupyterhub-nativespawner to avoid creating system users as described in https://github.com/jupyterhub/jupyterhub/issues/2948 or https://github.com/jupyterhub/ldapauthenticator/issues/107. This is only valid for basic quickstart install and not if inside container and k3s.
* https://expel.com/blog/our-journey-jupyterhub-beyond/
