#!/bin/bash

cd tool
trash ./artifacts/*
cp -rf ../artifacts ./
trash fabric*
node app.js