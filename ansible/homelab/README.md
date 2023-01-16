Add ansible user to Ubuntu and add to sudoers

```bash
sudo adduser ansible
sudo usermod -aG sudo ansible
sudo visudo /etc/sudoers
ansible ALL=(ALL) NOPASSWD:ALL
```


```bash
export ANSIBLE_HOST_KEY_CHECKING=True
ansible-playbook -i ./inventory.txt manage_homelab.yml
```
