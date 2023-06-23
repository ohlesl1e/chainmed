#!/usr/bin/env bash

truffle compile

echo 'Copying the contracts to applications'
cp build/contracts/* chaindoser/src/lib/contracts
cp build/contracts/* manager/src/lib/contracts

echo 'Checking contracts'
diff -r chaindoser/src/lib/contracts manager/src/lib/contracts

network=development
mode=prod

while getopts hn:m:j: flag; do
    case "${flag}" in
    n)
        network=$OPTARG
        ;;
    m)
        mode=$OPTARG
        ;;
    *)
        echo "default (none of above)"
        ;;
    esac

done

echo "Using network: $network"

truffle test ./test/setup.js --network "$network"

if [ "${mode}" == 'dev' ]; then
    pm2 start 'npm run dev --prefix manager'
    pm2 start 'npm run dev --prefix chaindoser'
elif [ "${mode}" == 'prod' ]; then
    npm run build --prefix manager
    npm run build --prefix chaindoser
    pm2 start 'npm run preview --prefix manager'
    pm2 start 'npm run preview --prefix chaindoser'
else
    echo "Need to specify mode"
fi

# pm2 start 'npm run dev --prefix manage'
# pm2 start 'npm run test --prefix chaindoser'
