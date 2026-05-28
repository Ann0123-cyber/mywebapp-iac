# MyWebApp IaC — Лабораторна робота №4

## Архітектура
- **VM1 (worker)**: nginx reverse proxy + Python веб-застосунок
- **VM2 (db)**: MariaDB база даних

## Вимоги

- Linux хост з QEMU/KVM (libvirt)
- Terraform >= 1.7
- Ansible >= 2.14
- SSH ключ для ansible user

## Розгортання

### 1. Terraform — створення VM

```bash
cd terraform

# Створити SSH ключ для ansible (якщо немає)
ssh-keygen -t ed25519 -f ~/.ssh/ansible_key -N ""

# Ініціалізація
terraform init

# Створення VM
terraform apply -var="ansible_public_key=$(cat ~/.ssh/ansible_key.pub)"
```

Після `terraform apply` дізнайтесь IP адреси VM:
```bash
sudo virsh net-dhcp-leases lab-network
```

### 2. Оновити inventory

Відредагуйте `ansible/inventory.ini` з актуальними IP:
```ini
[workers]
worker ansible_host=<WORKER_IP>

[db]
db ansible_host=<DB_IP>
```

### 3. Ansible — налаштування

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

## Перевірка

```bash
# Головна сторінка
curl http://<WORKER_IP>/

# Health checks
curl http://<WORKER_IP>/health/alive
curl http://<WORKER_IP>/health/ready
```

## Користувачі

| Користувач | VM | Пароль | Права |
|---|---|---|---|
| ansible | всі | SSH ключ | sudo без пароля |
| teacher | всі | 12345678 | sudo з паролем |
| app | worker | — | системний |
| operator | worker | 12345678 | обмежений sudo |
