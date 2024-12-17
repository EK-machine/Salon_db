#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MENU(){
  # Display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Read selected service
  read SERVICE_ID_SELECTED
  SERVICE_AVAILABILITY=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;" | xargs)

  if [[ -z $SERVICE_AVAILABILITY ]]
  then 
    echo -e "\nI could not find that service. What would you like today?"
    MENU
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';" | xargs)

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $SERVICE_AVAILABILITY, $CUSTOMER_NAME?"
      read SERVICE_TIME
      $PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
      NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' and name='$CUSTOMER_NAME'")
      $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($NEW_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
      echo -e "\nI have put you down for a $SERVICE_AVAILABILITY at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      echo -e "\nWhat time would you like your $SERVICE_AVAILABILITY, $CUSTOMER_NAME?"
      read SERVICE_TIME
      EXS_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE' and name='$CUSTOMER_NAME'")
      $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($EXISTING_CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"
      echo -e "\nI have put you down for a $SERVICE_AVAILABILITY at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MENU
