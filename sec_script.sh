#!/usr/bin/env bash
yum install -y --nogpgcheck epel-release > /dev/null && yum install -y --nogpgcheck pam_script docker-latest > /dev/null
#Создаём группу admin
if [[ ! $(cat /etc/group | grep admin) ]]
  then
      groupadd  admin
fi
#Создаём пользователя tester, с основной группой "tester", и дополнительной группой "admin". Пароль пользователя обычный знаменитый "qwerty" ;)
if [[ ! $(cat /etc/passwd | grep tester) ]]
  then
      adduser -G admin -p 'qwerty' tester
fi
echo ""
echo ""
echo -e "\e[31m      Создан  тестовый пользователь "tester" с паролем "qwerty", \
вход на тестовый стенд - 'ssh -p 2222 tester@127.0.0.1' \e[0m"
echo ""
#Проверяем наличие файла tester, с помощью которого задаём разрешения пользователю состоящему в группе tester, на выполнение команды "/bin/systemctl restart docker" от имени root, и выполнение команды "/bin/docker" от имени root, без ввода пароля
if [[ ! -e /etc/sudoers.d/tester ]]
  then
      cat <<-EOF  > /etc/sudoers.d/tester
Cmnd_Alias DOCKER = /bin/systemctl restart docker, /bin/docker
%tester secsrv=(root) NOPASSWD: DOCKER
EOF
  fi
echo ""
echo ""
echo -e "\e[31m      Разрешено пользователю tester рестартовать сервис docker через systemctl \e[0m"
echo ""

if [[ ! -e /etc/pam-script.d/pam_script_auth ]]
  then
      cp ./pam_script_auth /etc/pam-script.d/
  fi
chmod 755 /etc/pam-script.d/pam_script_auth

#Вставляем текст перед второй строкой в файле sshd, которая подключает ограничение возможности логина пользователя из группы "admin" в выходные, посредством запуска скрипта в момент логина пользователя через ssh
if [[ ! $(grep 'pam_script' /etc/pam.d/sshd) ]]
  then
      sed -i '2i auth       required     pam_script.so' /etc/pam.d/sshd
fi
echo ""
echo ""
echo -e "\e[31m      Запрещён вход пользователя tester по ssh в выходные дни    \e[0m"
echo ""
