aptos init --skip-faucet
account=`grep account .aptos/config.yaml | cut -d ' ' -f 6`
echo funding $account...
aptos account fund-with-faucet --account=$account --amount=100000000
echo deploy...
aptos move publish --named-addresses "msafe=0x$account" --assume-yes
mapSize=$1
echo add $mapSize elements
aptos move run --function-id 0x$account::simple_map_test::add --args u64:$mapSize #--max-gas 100000 #--assume-yes
echo borrow test...
aptos move run --function-id 0x$account::simple_map_test::borrow --args u64:0 --estimate-max-gas