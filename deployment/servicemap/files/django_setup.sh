#!/bin/bash
source $HOME/smvenv/bin/activate
export DJANGO_SETTINGS_MODULE=smbackend.settings
DM="python manage.py"

cd $HOME/smbackend/

$DM collectstatic --noinput
$DM syncdb --noinput
