# aws-terraform-ansible-example

Пример создания и настройки инфраструктуры в [AWS облаке](http://aws.amazon.com/) с помощью [Terraform](https://www.terraform.io/) и [Ansible](https://www.ansible.com/).
С его помощью создается инстанс с [Docker](https://www.docker.com/) для запуска приложения и БД-инстанс с [PostgreSQL](https://www.postgresql.org/).

## Предисловие

Этот репозитарий был создан по принципу **минимализма**, т.е. содержит в себе минимально необходимый
функционал и не более. Все остальные усложенения привносятся в проект по мере роста и необходимости.
Использование *terraform модулей*, *ansible ролей* (хотя они приведены здесь в качестве примера),*внешних ansible ролей* и т.д. избыточно конкретно в этом репозитарии и на **данный момент развития!**

## Перед стартом

Для работы понадобится [Python](https://www.python.org/) и [Terraform](https://www.terraform.io/).
Они уже должны быть установлены и доступны через командную оболочку.

Сначала убеждаемся, что настроен доступ к AWS облаку:

```bash
$ cat ~/.aws/credentials
[default]
aws_access_key_id = <AWS_ACCESS_TOKEN>
aws_secret_access_key = <AWS_SECRET_ACCESS_KEY>
...
```

После клонируем этот репозитарий и производим установку необходимых Python зависимостей, а также настройку
переменных окружения Terraform (в большинстве случаев достаточно просто скопировать с имеющегося .example файла):

```bash
$ git clone https://github.com/abra7134/aws-terraform-ansible-example

$ cd aws-terraform-ansible-example
$ pip install -r requirements.txt
$ cp terraform.tfvars.example terraform.tfvars
$ cat terraform.tfvars
# AWS Region for instances created
aws_region = "eu-central-1"

# Path to ssh public key used to create this one on AWS
ssh_public_key_path = "~/.ssh/id_rsa.pub"

# Path to ssh private key used to connect to instance
ssh_private_key_path = "~/.ssh/id_rsa"
```

## Создание и настройка инфраструктуры

Достаточно запустить две команды:

```bash
$ terraform apply terraform/
$ cd ansible && ansible-playbook playbooks/site.yml
```

## Уничтожение инфраструктуы

```bash
$ terraform destroy terraform/
```

## Примечания

* В Ansible используется динамический inventory, который формируется из terraform посредством
специального скрипта [terraform-inventory](https://github.com/adammck/terraform-inventory);
* Terraform поддерживает настройку (provision) только что созданной инфраструктуры (т.е. он может самостоятельно
запустить Ansible после создания инфраструктуры), но в данном репозитарии не используется эта возможность, т.к. 1)
более наглядно явное указание используемых команд, 2) в terraform имеется проблема с актуальной версией .tfstate
файла в момент запуска ресурса null_resource, однако проблему можно нивелировать используя
[remote state](https://www.terraform.io/docs/state/remote.html).
