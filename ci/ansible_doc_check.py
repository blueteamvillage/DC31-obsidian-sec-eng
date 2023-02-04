"""
This script will check that each
Ansible playbook has documentation in docs/
"""
from typing import List
import sys
import os
import re


# https://regex101.com/r/Pnjlx8/1
__DEPLOY_REGEX = r"deploy_\w+.yml"
__DOC_REGEX = r"ansible_\w+.md"


def get_ansible_playbooks() -> List[str]:
    """Get playbook file names that match ansible/deploy_*.yml"""
    playbooks: List[str] = []
    for ansible_file in os.listdir("ansible"):
        if re.search(__DEPLOY_REGEX, ansible_file):
            playbooks.append(ansible_file)
    return playbooks


def get_playbook_docs() -> List[str]:
    """Get playbook doc file names that match docs/ansible_*.md"""
    playbook_docs: List[str] = []
    for doc_file in os.listdir("docs"):
        if doc_file == "ansible_template.md":
            continue
        if re.search(__DOC_REGEX, doc_file):
            playbook_docs.append(doc_file)
    return playbook_docs


def check_ansible_doc() -> None:
    """
    Check that each Ansible playbook has a README doc
    basename: vuln_log4j_webserver
    playbook: deploy_vuln_log4j_webserver.yml
    doc: ansible_vuln_log4j_webserver.md
    """
    playbooks = get_ansible_playbooks()
    playbook_docs = get_playbook_docs()
    for playbook in playbooks:
        playbook_base_name = playbook.replace("deploy_", "").replace(".yml", "")
        if f"ansible_{playbook_base_name}.md" not in playbook_docs:
            print(
                (
                    f"The following playbook {playbook} doesn't have document"
                    f" ansible_{playbook_base_name}.md"
                )
            )
            sys.exit(1)


if __name__ == "__main__":
    check_ansible_doc()
