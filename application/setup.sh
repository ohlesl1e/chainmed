#!/usr/bin/env bash

#!/usr/bin/env bash

truffle compile

echo 'Copying the contracts to applications'
cp build/contracts/* chaindoser/src/lib/contracts
cp build/contracts/* manager/src/lib/contracts

echo 'Checking contracts'
diff -r chaindoser/src/lib/contracts manager/src/lib/contracts

network=development

while getopts hn:m:j: flag; do
    case "${flag}" in
    n)
        network=$OPTARG
        ;;
    *)
        echo "default (none of above)"
        ;;
    esac

done

echo "Using network: $network"

truffle test ./test/setup.min.js --network "$network"

npm run build --prefix manager
npm run build --prefix chaindoser
