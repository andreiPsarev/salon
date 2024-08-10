#!/bin/bash

# Команда для подключения к базе данных
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

# Функция для главного меню
MAIN_MENU() {
  echo -e "\nWelcome to My Salon, how can I help you?"
  
  # Выводим список услуг
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  
  # Проверяем, есть ли услуги
  if [[ -z $SERVICES ]]
  then
    echo -e "\nNo services found."
  else
    # Выводим услуги с номерами
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi

  # Запрашиваем выбор услуги у пользователя
  read SERVICE_ID_SELECTED

  # Проверка, что введенный ID услуги существует
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    # Если введена несуществующая услуга, показать меню снова
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Если услуга найдена, продолжаем
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Ищем клиента по номеру телефона
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Если клиент не найден
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Вставляем нового клиента в базу данных
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Запрашиваем время услуги
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Получаем ID клиента
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Вставляем новое назначение
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Подтверждаем запись
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
