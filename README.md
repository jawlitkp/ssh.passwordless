## 自动设置ssh无密码登陆 (Auto Setup SSH login without password)

- 测试通过的平台有（不仅限）：CentOS/RHEL/Ubuntu/Xubuntu
- Test passed on(not limited to) CentOS/RHEL/Ubuntu/Xubuntu

### How to use:
- ssh.passwordless.sh ip_address port_number username

- Example 1: (default port number is "22", default username is "root")
- ssh.passwordless.sh 192.168.1.1

- Example 2:
- ssh.passwordless.sh 192.168.1.1 2222 kashu
