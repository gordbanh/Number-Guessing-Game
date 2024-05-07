#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess_game -t --no-align -c"

#get random number
RANDOM_NUMBER=$(( 1 + $RANDOM % 1000 ))

#prompt user
echo "Enter your username:"

#get username
read USERNAME_INPUT

#get user info
USERNAME_RESULT=$($PSQL "SELECT username,games_played,best_guess FROM users LEFT JOIN user_info USING(user_id) WHERE username='$USERNAME_INPUT'")

#if username not found
if [[ -z $USERNAME_RESULT ]]
then
  #insert username
  INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
  echo -e "Welcome, $USERNAME_INPUT! It looks like this is your first time here."

  #add new user
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO user_info(user_id) VALUES($USER_ID)")

  #get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
  
  #get username
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id='$USER_ID'")

  #get game_played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE user_id='$USER_ID'")

  #get best_guess
  BEST_GUESS=$($PSQL "SELECT best_guess FROM user_info WHERE user_id='$USER_ID'")
else
  #get user id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'")
  
  #get username
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id='$USER_ID'")

  #get game_played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE user_id='$USER_ID'")

  #get best_guess
  BEST_GUESS=$($PSQL "SELECT best_guess FROM user_info WHERE user_id='$USER_ID'")

  #print user info
  echo -e "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

fi

#guessing game
echo "Guess the secret number between 1 and 1000:"

#get user number guess
read USER_GUESS

#verify user input
#if not a number
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read USER_GUESS
done

#start count
COUNT=1

#while loop
while [[ $USER_GUESS != $RANDOM_NUMBER ]]
do
  #if user guess greater than random number
  if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    
    #add count
    COUNT=$(( $COUNT + 1 ))
    
    #get user guess again
    read USER_GUESS

    #verify user input
    #if not a number
    while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read USER_GUESS
    done

  #if user guess less than random number
  elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"

    #add count
    COUNT=$(( $COUNT + 1 ))

    #get user guess again
    read USER_GUESS
    
    #verify user input
    #if not a number
    while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    do
      echo "That is not an integer, guess again:"
      read USER_GUESS
    done
  fi
done

#add to games played
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

#input new game data

#if there was no previous best guess
if [[ -z $BEST_GUESS ]]
then
  BEST_GUESS=$COUNT
  #update new data
  UPDATE_BEST_GUESS=$($PSQL "UPDATE user_info SET games_played=$GAMES_PLAYED,best_guess=$COUNT WHERE user_id=$USER_ID")
else
  #update with new data
  
  #if number of guesses less than previous best guess
  if [[ $COUNT -lt $BEST_GUESS ]]
  then
    #update games_played and best_guess
    UPDATE_BEST_GUESS=$($PSQL "UPDATE user_info SET games_played=$GAMES_PLAYED,best_guess=$COUNT WHERE user_id=$USER_ID")
  else
    #update games_played
    UPDATE_GAMES_PLAYED=$($PSQL "UPDATE user_info SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")
  fi
fi


#echo game result
echo -e "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
