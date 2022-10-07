#!/usr/bin/env bash
truffle compile
cp ../client/src/lib/contracts/* ../server/contracts
truffle migrate