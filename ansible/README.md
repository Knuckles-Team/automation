# Ansible 

## About
- Written in Python
- Open Source
- Owned by RedHat
- Provides automation framework
- Agentless (No need to install anything on any node) 
  because it uses SSH, a common connection across platforms
  
#### Templates:
  Can be found on [Ansible Galaxy](https://galaxy.ansible.com)
#### Modules: 
  Extends functionality of what ansible can do.
#### Roles: 
  Downloadable component you install in your ansible system. 
  Contains all ingredients needed for simple to complex automation. 
  Executing within ansible environment on your nodes.
  

## Configuration
ansible.cfg will contain configurations for ansible if 
customization is needed

## Playbooks
- Written as YAML files .yml
- All files start with "---"
- "- name" indicates play
- "yum" and "service" are modules

Example: sample.yml
```ansible
---
  - namee: sampleplaybook
  hosts: all
  become: yes
  become_user: root
  tasks:
    - name: ensure apache is at latest version
      yum:
        name: httpd
        state: latest
    - name: enssure apache is running
      service:
        name: httpd
        state: started
```

## Execution
ansible-playbook sample.yml

#### Ad-Hoc Commands (Any command to any system)
ansible myservers -m ping 

## Installing
#### Ubuntu
```bash
apt install python3 python3-pip python3-dev gcc
python3 -m pip install ansible
```

#### Windows

## Hosts File
```ansible
[southeast]
localhost       ansible_connection=local
example1.com    ansible_connection=ssh      ansible_user=ubuntu

[northeast]
example2.com
10.10.10.10

[southwest]
10.10.200.10

[east:children]
southeast
northeast
```
