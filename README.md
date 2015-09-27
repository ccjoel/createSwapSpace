# CREATE SWAP UBUNTU AWS/DIGITALOCEAN instances

### Running:

Please, run with sudo: (needs sudo/root for a lot of operations, writing in some system files)

```
sudo ruby main.rb
```

Ps. Don't worry about not finding gems since we are running as root, I didn't use any... :-)

# Important:

Modified /etc/fstab file if no swap entry is found, so that swap is mounted on boot
Also, modifies sysctl properties both runtime and permanent

### TODO:

 - Receive desired swap size from user, after being informed of current space disk space / memory
 - Give the user a recommendation of what the swap size should be
