#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY_GAME() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

  echo "Enter your username:"
  read -r USERNAME

  USER_ID=$($PSQL "select user_id from user_data where name ='$USERNAME'")

  if [[ $USER_ID ]]; then
    GAMES_PLAYED=$($PSQL "select count(user_id) from game_data where user_id ='$USER_ID'")
    BEST_GUESS=$($PSQL "select min(guesses) from game_data where user_id ='$USER_ID'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    INSERTED_TO_USERS=$($PSQL "insert into user_data(name) values('$USERNAME')")
    USER_ID=$($PSQL "select user_id from user_data where name = '$USERNAME'")
  fi

  GAME_LOOP
}

GAME_LOOP() {
  SECRET=$((1 + RANDOM % 1000))
  TRIES=0
  GUESSED=0

  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read -r GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    elif [[ $SECRET = $GUESS ]]; then 
      TRIES=$((TRIES+1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $GUESS. Nice job!"
      INSERTED_TO_GAMES=$($PSQL "insert into game_data(user_id, guesses) values($USER_ID, $TRIES)")
      GUESSED=1
    elif [[ $SECRET -gt $GUESS ]]; then
      TRIES=$((TRIES+1))
      echo -e "\nIt's higher than that, guess again:"
    else
      TRIES=$((TRIES+1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}

DISPLAY_GAME
