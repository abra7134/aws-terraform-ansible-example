#!/bin/sh

# This is a wrapper script with a specifing right path to TF_STATE :)

# terraform-inventory getting from
# https://github.com/adammck/terraform-inventory

export TF_STATE=../
exec ./terraform-inventory "${@}"
