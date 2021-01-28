#!/bin/bash

## Print only the command name, not the full path.
## Send the output to stderr, not stdout
usage(){
  echo "Usage: ${0##*/} [-f filename ] ... | [ -d dirname ] ..." >&2
  exit 1
}

## Quote $1 or it will fail if an argument contains whitespace
createDir(){
  if [ ! -d "$1" ]
  then
    mkdir -p "$1" >/dev/null 2>&1 && echo "Directory $1 created." ||  echo "Error: Failed to create $1 directory."
  else
    echo "Error: $1 directory exits!"
  fi
}

## Quote $1 or it will fail if an argument contains whitespace
createFile(){
  ## There's no need for an external command (touch)
  [ -f "$1" ] && echo "Error: $1 file exists!" || > "$1"
}

while getopts f:d:v option
do
  case $option in
    f) createFile "$OPTARG";;
    d) createDir "$OPTARG";;
    *) usage ;;
  esac
done
shift "$(( $OPTIND - 1 ))"

[ $# -gt 0 ] && usage
