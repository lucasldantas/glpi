# 🐧 Instalação do GLPI 10.0.16 no Ubuntu

Este guia apresenta um passo a passo para instalar o [GLPI 10.0.16](https://github.com/glpi-project/glpi/releases) em servidores Ubuntu.

---

## 📦 1. Atualizando o sistema

```bash
sudo apt update && sudo apt upgrade -y
```

---

## 🌐 2. Instalando Apache, PHP e MySQL

```bash
sudo apt install apache2 php libapache2-mod-php mysql-server -y
```

---

## 🧩 3. Instalando as extensões PHP necessárias para o GLPI

```bash
sudo apt install php-mysql php-gd php-mbstring php-xml php-zip php-intl php-curl php-ldap php-bz2 -y
```

---

## 🔄 4. Ativando o módulo `rewrite` do Apache

```bash
sudo a2enmod rewrite
```

---

## 🔁 5. Reiniciando o Apache

```bash
sudo systemctl restart apache2
```

---

## 🗃️ 6. Criando o banco de dados e usuário do GLPI

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

## ⬇️ 7. Baixando o GLPI 10.0.16

```bash
wget https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz
```

---

## 📁 8. Criando diretório e extraindo o pacote

```bash
sudo mkdir /var/www/html
sudo tar -zxvf glpi-10.0.16.tgz -C /var/www/html
```

---

## 🔒 9. Ajustando permissões

```bash
sudo chown -R www-data:www-data /var/www/html/glpi
```

---

## ⚙️ 10. Configurando o Apache para servir o GLPI

Edite o arquivo de configuração:

```bash
sudo vi /etc/apache2/sites-available/000-default.conf
```

Adicione dentro do bloco
