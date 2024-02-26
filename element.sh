#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# main function that checks for the input argument 
MAIN() {
  # if the argument is empty
  if [[ -z $1 ]]
  then
    # output a message telling the user to provide accepted input
    echo "Please provide an element as an argument."
  else
    INFORMATION $1
  fi
}

# function that gives info about given argument
INFORMATION() {

  # the input is argument after the file name (./element.sh *)
  INPUT=$1

  # if the input is not a number
  if [[ ! $INPUT =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE symbol='$INPUT' OR name='$INPUT';") | sed 's/ //g')
  else
    ATOMIC_NUMBER=$(echo $($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$INPUT;") | sed 's/ //g')
  fi

  # if loop that gets all the information from the user input
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo "I could not find that element in the database."
  else
    TYPE_ID=$(echo $($PSQL "SELECT type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    NAME=$(echo $($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    SYMBOL=$(echo $($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    ATOMIC_MASS=$(echo $($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    MELTING_POINT_CELSIUS=$(echo $($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    BOILING_POINT_CELSIUS=$(echo $($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')
    TYPE=$(echo $($PSQL "SELECT type FROM elements LEFT JOIN properties USING(atomic_number) LEFT JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;") | sed 's/ //g')

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi

}

MAIN $1
