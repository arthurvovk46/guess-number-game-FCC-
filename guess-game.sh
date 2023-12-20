#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:\n"

read USERNAME

USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")

GAMES=$($PSQL "SELECT games FROM users WHERE username = '$USERNAME';")

BEST=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME';")

NUMBER=$((1 + $RANDOM% 1000))

NUMBEROID() {
    
    TRY=$($PSQL "SELECT tries FROM users WHERE username = '$USERNAME';")
    
    echo -e "Guess the secret number between 1 and 1000:\n"

    read GUESS

    if [[ $GUESS =~ ^[0-9]+$ && $GUESS -le 1000 && $GUESS -gt 0 ]]
    then
    
        ADDT=$($PSQL "UPDATE users SET tries = $(( $TRY + 1)) WHERE username = '$USERNAME';")

        if [[ $GUESS -gt $NUMBER ]]
        then
            
            echo -e "\nIt's lower than that, guess again:\n"

            NUMBEROID

        elif [[ $GUESS -lt $NUMBER ]]
        then
            
            echo -e "\nIt's higher than that, guess again:\n"

            NUMBEROID

        else

            echo -e "\nYou guessed it in $TRY tries. The secret number was $NUMBER. Nice job!\n"

            if [[ $BEST == 0 || $TRY -lt $BEST ]]
            then
                
                ADDB=$($PSQL "UPDATE users SET best_game = $TRY WHERE username = '$USERNAME';")

                REST=$($PSQL "UPDATE users SET tries = 0 WHERE username = '$USERNAME';")
            fi
        fi

    else
        
        echo -e "\nThat is not an integer, guess again:\n"

        NUMBEROID
    fi
}

if [[ $USER == $USERNAME ]]
then

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses"

    ADDG=$($PSQL "UPDATE users SET games = $(( $GAMES + 1)) WHERE username = '$USERNAME';")
    
    NUMBEROID

else

    NEW_USER=$($PSQL "INSERT INTO users(username, games, best_game, tries) VALUES('$USERNAME', 0, 0, 0);")

    if [[ $NEW_USER == "INSERT 0 1" ]]
    then

        echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

        ADDG=$($PSQL "UPDATE users SET games = $(( $GAMES + 1)) WHERE username = '$USERNAME';")
        
        NUMBEROID

    else

        echo -e "\nThis username is not valid. Try again.\n"
    fi
fi
