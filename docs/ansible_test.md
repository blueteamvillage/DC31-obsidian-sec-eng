# Ansible - Test
## Description
Example ansible playbook for how to setup SSH with Teleport

## Init Ansible playbook
1. `tsh ls`
    ```shell
    ➜  DC31-obsidian-sec-eng git:(teleport_jumpbox) ✗ tsh ls
    Node Name        Address        Labels
    ---------------- -------------- --------------------------------------------------------------------------------------------------------
    ip-172-16-10-93  127.0.0.1:3022 hostname=ip-172-16-10-93,aws/Name=DEFCON_2023_OBSIDIAN-teleport-cluster,aws/Project=DEFCON_2023_OBSIDIAN
    ip-172-16-50-230 ⟵ Tunnel       hostname=ip-172-16-50-230,teleport.internal/resource-id=f1c01733-6a9a-4a52-b44d-b6fa597b5d98
    ```
1. Open `hosts.ini` and set:
```
[test]
ip-172-16-50-230.teleport.blueteamvillage.com ansible_user=ubuntu
```

## Run Ansible playbook
1. `ansible-playbook -i hosts.ini deploy_<playbook>.yml`
    1. ![ansible_teleport_ssh](../.img/ansible_teleport_ssh.png)

## References
* []()
