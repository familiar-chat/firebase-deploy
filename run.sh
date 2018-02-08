#!/bin/bash

shell="/bin/bash"
base=$(pwd)
mode="production"

operator_web="operator-web"
visitor_widget="visitor-widget"

function op_build () {
  build ${operator_web}
}

function vi_build () {
  build ${visitor_widget}
}

function func_build () {
  echo "Preparing compile Function..."
  cd functions
  git pull
  npm install
  cd ..
  echo "Function preparing success."
}

function build () {
  echo "Preparing compile in ${1}..."
  cd $1
  git submodule foreach 'git checkout master; git pull'
  git pull
  rm -fR build
  echo "Compile Start..."
  npm install
  npm run postinstall:${mode}
  cd ..
  echo "Compiling finished."
}

function web_deploy () {
  rm -fR builded
  mkdir -p builded
  cp -fR ${operator_web}/assets/* builded/
  cp -fR ${operator_web}/build/* builded/
  cp -fR ${visitor_widget}/assets/* builded/
  cp -fR ${visitor_widget}/build/* builded/
  firebase deploy --only hosting
}

function func_deploy () {
  firebase deploy --only functions
}

echo "=== MENU ==="
echo "1. Compile"
echo "2. Deploy"
echo "3. ALL Execute"
echo "4. Web Both"
echo " ?= "
read i

case "$i" in
  "1" )
  echo "=== Compile MENU ==="
  echo "1. Operator-WEB Only"
  echo "2. Visitor-WEB Only"
  echo "3. WEB's Both"
  echo "4. Function Only"
  echo "5. ALL"
  echo " ?= "
  read j

  case "$j" in
    "1" ) op_build ;;
    "2" ) vi_build ;;
    "3" ) op_build; vi_build ;;
    "4" ) func_build ;;
    "5" ) op_build; vi_build; func_build ;;
  esac
  exit 0 ;;
  "2" ) 
  echo "=== Deploy MENU ==="
  echo "1. Web's Only"
  echo "2. Function's Only"
  echo "3. Both"

  read j
  case "$j" in
    "1" ) web_deploy; exit 0 ;;
    "2" ) func_deploy; exit 0 ;;
    "3" ) web_deploy; func_deploy; exit 0 ;;
  esac
  exit 0 ;;

  "3" ) op_build; vi_build; func_build; web_deploy; func_deploy; exit 0;;
  "4" ) op_build; vi_build; web_deploy; exit 0;
esac
