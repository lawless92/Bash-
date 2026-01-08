#!/bin/bash

# Script para monitoreo de sistema

info_sistema(){
    
    ps aux | head -n 10
    
    sudo apt-get upgrade windsurf

}
