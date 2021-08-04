# Autodeploy Windows Servers

Step 1: Run install_ansible.ps1 on your local windows machine to install 
python3 and ansible dependencies

Step 2: Configure inventory file for Windows Servers

Step 3: Run 
```yaml
ansible-playbook -i windows_jumphosts.txt ./autodeploy_hosts.yaml
```