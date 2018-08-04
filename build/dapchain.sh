#!/bin/bash -ex

cd dappchain
export GOPATH=$GOPATH:`pwd`
make deps
make
cd build
loom init
cp ../genesis.example.json genesis.json
loom run