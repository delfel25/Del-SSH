#!/bin/bash

CONFIG="$HOME/.ssh_servers"

add_server() {
    echo "Добавить подлключение:"
    read -p "Имя (для удобства): " name
    read -p "Логин[$(whoami)]: " user
    user=${user:-$(whoami)}
    read -p "Хост/IP: " host
    read -p "Порт [22]: " port
    port=${port:-22}
    echo "$name|$user@$host|$port" >> "$CONFIG"
    echo "Сервер добавлен."
    sleep 1
}

list_servers() {
    clear
    echo "Список подключений:"
    if [ ! -s "$CONFIG" ]; then
        echo "Нет подключения"
    else
        n=1
        while IFS='|' read name conn port; do
        echo "$n. $name - $conn:$port"
        ((n++))
        done < "$CONFIG"
    fi
    echo "Выполнено."
}

connect_to() {
    list_servers
    if [ ! -s "$CONFIG" ]; then
        read -p "Нажмите Enter..."
        return
    fi

    read -p "Номер подключения: " num
    if [[ ! "$num" =~ ^[0-9]+$ ]]; then
        echo "Неверный номер"
        sleep 1
        return
    fi

    server=$(sed -n "${num}p" "$CONFIG" 2>/dev/null)
    if [ -z  "$server" ]; then
        echo "Подключение не найдено"
        sleep 1
        return
    fi
    
    IFS='|' read name conn port <<< "$server"
    echo "Подключение к $name..."
    ssh -p "$port" "$conn"
}

delete_server() {
    list_servers
    if [ ! -s "$CONFIG" ]; then
        read -p "Нажмите Enter"
        return
    fi

    read -p "Номер для удаления: " num
    if [[ ! "$num" =~ ^[0-9]+$ ]]; then
        echo "Неверный номер."
        sleep 1
        return
    fi

    sed -i "${num}d" "$CONFIG" 2>/dev/null
    echo "Удалено"
    sleep 1
}

main_menu() {
    while true; do
        clear
        echo "1. Список подключений        ____       _           ____ ____  _   _ "
        echo "2. Добавить подключение     |  _ \  ___| |         / ___/ ___|| | | |"
        echo "3. Подключиться             | | | |/ _ \ |  _____  \___ \___ \| |_| |"
        echo "4. Удалить подключение      | |_| |  __/ | |_____|  ___) |__) |  _  |"
        echo "5. Быстрое подключение      |____/ \___|_|         |____/____/|_| |_|"
        echo "6. Выход                                                             "

        read -p "Выбор за вами:" choise

        case $choise in 
            1) list_servers ;;
            2) add_server ;;
            3) connect_to ;;
            4) delete_server ;;
            5) quick_connect ;;
            6) echo "Еще увидимся"; exit 0 ;;
            *) echo "Неверный выбор"; sleep 1 ;;
        esac
    done
}

touch "$CONFIG"

main_menu

echo " ____       _           ____ ____  _   _ 
|  _ \  ___| |         / ___/ ___|| | | |
| | | |/ _ \ |  _____  \___ \___ \| |_| |
| |_| |  __/ | |_____|  ___) |__) |  _  |
|____/ \___|_|         |____/____/|_| |_|"

