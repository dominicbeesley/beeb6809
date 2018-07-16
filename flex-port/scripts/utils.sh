#
# Bash script utility functions (c) Authority File Ltd 2013
# No reuse without consent of AF Ltd
# If this file is included with software provided by AF Ltd then
# it is only warranted for use as part of the provided software
#

#environment variables
#log_info  - receives all messages sent to formatting functions

bold()
{
  if [[ -t 1 ]]; then
    echo -e "\033[1;33;44m===============================================================================\033[m"
    echo -e "\033[1;33;44m${1//\\/\\\\}\033[m"
    echo -e "\033[1;33;44m===============================================================================\033[m"
    echo
  else
    echo "$1"
  fi

  logit "=================================================="
  logit "$1"
  logit "=================================================="
}

logit()
{
  if [[ -n $log_info ]]; then
    echo "$1" >> "$log_info"
  fi
}

error()
{
  if [[ -t 2 ]]; then
    echo -e "\033[1;31;47mERROR:$1\033[m" 1>&2
  else
    echo "$1" 1>&2
  fi
  
  logit "ERROR:$1"
}

warn()
{
  if [[ -t 2 ]]; then
    echo -e "\033[1;32;40mWARNING:$1\033[m" 1>&2
  else
    echo "$1" 1>&2
  fi
  
  logit "WARNING $1"
}

info()
{
  echo "$1"
  logit "INFO $1" 
}

checkstat()
{
  #get exit code of previous command
  local EX=$?
  
  local warn=0
  while [[ $# -gt 0 && "$1" =~ ^- ]]; do
    case "$1" in
      "-warn")
        warn=1
        ;;        
    esac
    shift
  done
   
  if [[ -n "$2" && -e "$2" ]]; then
    cat "$2" >&2
    if [[ -n $log_info ]]; then
      cat "$2" >> "$log_info"
    fi
  fi
  
  #get fail message if there is one
  local MESS=$1
  if [[ $EX -ne 0 ]]; then
    #print debug messages
    local frame=0
    while caller $frame; do
      ((frame++));
    done
    if [[ $warn -eq 0 ]]; then
    if [[ -x "$MESS" ]]; then
        error "FAIL:$EX"
    else
        error "FAIL:$MESS ($EX)"
    fi
    exit "$EX"
    else
      if [[ -x "$MESS" ]]; then
        warn "FAIL:$EX"
      else
        warn "FAIL:$MESS ($EX)"
      fi    
    fi
  fi
  had_error=1
}

delcheck()
{
  if [[ ! -z "$2" ]]; then
    local files=$(find "$1" -type f -iname "$2" 2>/dev/null | wc -l)
  
  if [[ $files -gt 0 ]]; then
      info " -- removing $1$2 ($files found)"
      find "$1" -type f -iname "$2" -print0 |xargs -0 rm
      checkstat "error deleteing $1 $2"
  else
      info " -- not removing $1$2 ($files found)"
    fi  
  else
    if [[ -e "$1" ]]; then
      info " -- removing $1"
      rm "$1"
      checkstat "error deleting $1"
    else
      info " -- not removing $1 - no file found"
    fi
  fi  
}

ensuredir()
{
  mkdir -p "$1"
  checkstat "creating directory $1"
}
