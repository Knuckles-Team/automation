# Ansible 

## About
- Written in Python
- Open Source
- Owned by RedHat
- Provides automation framework
- Agentless (No need to install anything on any node) 
  because it uses SSH, a common connection across platforms
- Creates idempotent scripts (Repeatable without change)  
  
#### Templates:
  Can be found on [Ansible Galaxy](https://galaxy.ansible.com)
#### Modules: 
  Extends functionality of what ansible can do. https://docs.ansible.com/ansible/latest/collections/ansible/builtin/
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
- You can specify tags to run only certain tags instead of the whole playbook

Strucutre:
```yaml
---
  - hosts: all
    tasks:
      - name: Do something
        module:
          parameter: value
          parameter: '{{variable}}'
        tags:
          - tag-name
```

Example: sample.yml
```yaml
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
ansible-playbook sample.yml -v --tags install-stress-ng -i hosts
ansible-playbook sample.yml -v --skip-tags install-stress-ng -i hosts


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
By default, there is an "all" grouping that doesn't have to be
specified
```yaml
[southeast]
localhost       ansible_connection=local
example1.com    ansible_connection=ssh      ansible_user=ubuntu
  
[web]
web1 ansible_ssh_host=web1.example.com variable=value

[northeast]
example2.com
10.10.10.10

[southwest]
10.10.200.10

[east:children]
southeast
northeast
```

### Ad-Hoc Commands
```bash
ansible localhost -m find -a "paths=Downloads file_type=file"
```

### Ansible Playbooks
first.yml
```yaml
---
  - name: "My first play"
    hosts: localhost

    tasks:

    - name: "test reachability"
      ping:

    - name: "upgrade ubuntu"
      apt:
        upgrade: yes

    - name: "install stress-ng"
      apt:
        name: stress-ng
        state: present
      tags:
        - install-stress-ng

    - name: "Create file on machine"
      file:
        dest: /tmp/file
        state: '{{file_state}}'
        
  - name: "Second Play"
    hosts: all:&southwest:!southeast
    tags: 
      - add-file
    tasks:
    - name: Create file on web machines
      file: 
        dest: /tmp/web-file
        state: '{{file_state}}'
    
```
ansible-playbook first.yml -v -i hosts -e file_state=touch

## SSH Key Management
Add local ansible control node SSH Key to all node SSH authorized_keys
Can be found in: .ssh directory.

## Serial
```yaml
---
- name: "React with Change Example"
  hosts: webservers
  serial: 1
```
Serial 1 will have each node perform all tasks on each node sequentially (one node after another node)

## Strategy & Forks
```yaml
---
- name: "React with Change Example"
  hosts: webservers
  strategy: free
```
strategy free will perform all tasks on all nodes as quickly as possible.
By default ansible's configuration is only set to run with 5 forks.
Forks are how many threads, or how many concurrent nodes you would want to process at once
This runs with the -f flag for custom fork amount.
```bash
ansible-playbook change.yml -f 30 -i hosts -v
```
-f determines # of forks to use
-i uses a specified hosts inventory file
-v verbose


## Examples:
### Skipping Tasks
tasks.yml
```yaml
---
- hosts: all
  tasks:
    - name: the first task
      file:
        dest: /tmp/first-task
        state: '{{file_state}}'
    - name: the second task
      file:
        dest: /tmp/second-task
        state: '{{file_state}}'
    - name: the third task
      file:
        dest: /tmp/third-task
        state: '{{file_state}}'
```
ansible-playbook -i hosts tasks.yml -e file_state=touch
ansible-playbook -i hosts tasks.yml -e file_state=absent
ansible-playbook -i hosts tasks.yml -e file_state=touch --start-at-task='the second task'


### Variables in Host Inventory File
inventory (File)
- Can store variables for each of the groups as well

```
[all]
web1 ansible_ssh_host=web1.kumulus.co
web2 ansible_ssh_host=web2.kumulus.co
db1 ansible_ssh_host=db1.kumulus.co
db2 ansible_ssh_host=db2.kumulus.co
[web]
web1
web2
[db]
db1
db2
[backup]
db2 backup_file=/tmp/backup_file
[all:vars]
all_file=/tmp/all_file
[web:vars]
web_file=/tmp/web_file
```

variables-test.yml
- Variables can be read from hosts file
- when: db_file is defined will do this task when the variable is specified in the host file

```yaml
---
- hosts: web
  tasks:
  - name: create a web file
    file:
      dest: '{{web_file}}'
      state: '{{file_state}}'

- hosts: backup
  tasks:
  - file:
      dest: '{{backup_file}}'
      state: '{{file_state}}'

- hosts: db
  tasks:
  - file:
      dest: '{{web_file}}'
      state: '{{file_state}}'
    when: db_file is defined
    
- hosts: all
  tasks:
  - name: create a web file
    file:
      dest: '{{all_file}}'
      state: '{{file_state}}'
```
Execute:
```bash
ansible-playbook -i inventory variables-test.yml -e file_state=touch
```

### Dynamic Inventory
- Cloud Provider: Packet.net have a dynamic inventory script.

Run script that performs dynamic inventory:
```bash
packet_net.py --list
```

dynamic-test.yml
```yaml
---
- hosts: tag_all
  tasks:
  - name: create a file
    file:
      dest: /tmp/file
      state: touch

- hosts: tag_all:!tag_db2
  tags:
    - delete-file
  tasks:
  - name: delete a file 
    file:
      dest: /tmp/file
      state: absent

- hosts: tag_db2
  tasks:
  - name: delete a file  
    file:
      dest: /tmp/file
      state: absent
    tags:
      - delete-file
```
- Using things like packet_net.py to generate a dynamic list, we can integrate using:
```bash
ansible-playbook -i ../../packet_net.py dynamic-test.yml --tags create-file
```

### Group Variables
- An inventory file can grab the hosts dynamically through tags
- all:children specifies children otherwise it would recognize tag_all literally instead of dynamically

inventory file:
```
[all:children]
tag_all
[web:children]
tag_web
[db:children]
tag_db
[backup:children]
tag_backup
```
Execute
```bash
ansible-playbook -i packet_net.py -i inventory dynamic-test.yml -e file_state=touch
```

### Templates
jinja

template-test.yml
```yaml
---
- hosts: all
  tasks:
  - name: deploy a simple template file
    template:
      src: templates/template.j2
      dest: /tmp/template.txt
    tags:
      - create
  - name: remove templated file
    file:
      dest: /tmp/template.txt
      state: absent
    tags:
      - destroy
```

template.j2
```jinja
This file is a template on {{hostvars[inventory_hostname]['ansible_fqdn']}}
backup_file {% if backup_file is defined %} is defined {% else %} is not defined
```



