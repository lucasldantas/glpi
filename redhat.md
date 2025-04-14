# 🚀 Instalação do GLPI 10.0.16 no Red Hat / AlmaLinux / Rocky Linux

Este guia detalha a instalação do [GLPI 10.0.16](https://github.com/glpi-project/glpi/releases) em sistemas Red Hat e derivados.

---

## 📦 1. Atualizando o sistema

```bash
sudo dnf update -y
```

---

## 🌐 2. Instalando Apache, PHP e MariaDB

```bash
sudo dnf install httpd mariadb-server php php-mysqlnd -y
```

---

## 🧩 3. Instalando as extensões PHP necessárias

```bash
sudo dnf install php-gd php-mbstring php-xml php-zip php-intl php-curl php-ldap php-bz2 -y
```

---

## 🔄 4. Iniciando e habilitando os serviços

```bash
sudo systemctl enable --now httpd mariadb
```

---

## 🔥 5. Liberando o serviço HTTP no firewall

```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

---

## 🔐 6. Protegendo o MariaDB

```bash
sudo mysql_secure_installation
```

---

## 🗃️ 7. Criando o banco de dados e usuário do GLPI

```bash
sudo mysql -u root -p
```

Dentro do MySQL:

```sql
CREATE DATABASE glpidb;
CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'sua_senha_forte';
GRANT ALL PRIVILEGES ON glpidb.* TO 'glpiuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## ⬇️ 8. Baixando o GLPI

```bash
wget https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz
```

---

## 📁 9. Extraindo e movendo para o diretório do Apache

```bash
sudo tar -zxvf glpi-10.0.16.tgz
sudo mv glpi /var/www/html/
```

---

## 🔒 10. Ajustando permissões

```bash
sudo chown -R apache:apache /var/www/html/glpi
sudo chmod -R 755 /var/www/html/glpi
```

---

## ⚙️ 11. Configurando o Apache

Crie um novo arquivo de configuração:

```bash
sudo vi /etc/httpd/conf.d/glpi.conf
```

Conteúdo:

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html/glpi
    <Directory /var/www/html/glpi>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

---

## 🔁 12. Reiniciando o Apache

```bash
sudo systemctl restart httpd
```

---

## 🌐 13. Acessando o GLPI

Abra no navegador:

```
http://SEU_IP/
```

Siga os passos da interface para completar a instalação.

---

## ✅ Finalizado!

Você agora tem o **GLPI 10.0.16** funcionando em seu servidor Red Hat / Rocky / AlmaLinux.  
Lembre-se de **excluir o diretório `/install`** após finalizar a configuração pela interface web.

---
