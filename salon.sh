#! /bin/bash
PSQL="psql -X --username=freecodecamp dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
    if [[ $1 ]]
    then echo -e "\n$1"
    fi

    SERVICE=$($PSQL "select * from services order by service_id")
    echo -e "$SERVICE" | while read SERVICE_ID BAR NAME
    do
    SERVICE_ID_UPDATED=$(echo $SERVICE_ID | sed 's/ //g')
    NAME_UPDATED=$(echo $NAME | sed 's/ //g')
    echo "$SERVICE_ID_UPDATED) $NAME_UPDATED"
    done

    read SERVICE_ID_SELECTED
    VALID_SERVICE=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $VALID_SERVICE ]]
    then 
    MAIN_MENU "I could not find that service. What would you like today?"
    
    else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME_UPDATED=$(echo $CUSTOMER_NAME | sed 's/ //g')

    if [[ -z $CUSTOMER_NAME ]]
    then echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')") 
    fi
    
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME_UPDATED=$(echo $SERVICE_NAME | sed 's/ //g')
    echo -e "\nWhat time would you like your $SERVICE_NAME_UPDATED, $CUSTOMER_NAME_UPDATED?"
    read SERVICE_TIME
    SERVICE_TIME_UPDATED=$(echo $SERVICE_TIME | sed 's/ //g')
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME_UPDATED')")
    echo -e "\nI have put you down for a cut at $SERVICE_TIME_UPDATED, $CUSTOMER_NAME."
    fi
}

MAIN_MENU
