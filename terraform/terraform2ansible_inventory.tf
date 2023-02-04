# https://coffay.haus/pages/terraform+ansible/
resource "local_file" "inventory" {
  filename = "../ansible/hosts.ini"
  content  = <<-EOF
    [frontend]
    ${module.frontend[0].private_ip}
    ${module.frontend[1].private_ip}
    ${module.frontend[2].private_ip}

    [backend]
    ${module.backend[0].private_ip}
    ${module.backend[0].private_ip}
    ${module.backend[0].private_ip}

    [auth_server]
    ${module.auth_server[0].private_ip}

    [artifact_repository]
    ${module.repository_server[0].private_ip}

    [cribl_server]
    ${module.cribl_server[0].private_ip}

    [docker_server]
    ${module.corp_docker_server[0].private_ip}

    [vuln_log4j_webserver]
    ${module.vuln_log4j_webserver[0].private_ip}

    EOF
}

resource "local_file" "host_script" {
  filename = "./add_hosts.sh"

  content = <<-EOF
    echo "Setting SSH Key"
    ssh-add ../terraform/ssh_keys/id_ed25519.pub
    echo "Adding IPs"

    ssh-keyscan -H ${module.cribl_server[0].private_ip} >> ~/.ssh/known_hosts
    ssh-keyscan -H ${module.corp_docker_server[0].private_ip} >> ~/.ssh/known_hosts
    ssh-keyscan -H ${module.vuln_log4j_webserver[0].private_ip} >> ~/.ssh/known_hosts

    EOF

}
