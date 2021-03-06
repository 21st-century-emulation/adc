docker build -q -t adc .
docker run --rm --name adc -d -p 8080:8080 adc

sleep 5

RESULT=`curl -s --header "Content-Type: application/json" \
  --request POST \
  --data '{"id":"abcd", "opcode":137,"state":{"a":61,"b":1,"c":66,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":false,"zero":false,"auxCarry":false,"parity":false,"carry":true},"programCounter":1,"stackPointer":2,"cycles":0,"interruptsEnabled":true}}' \
  http://localhost:8080/api/v1/execute`
EXPECTED='{"id":"abcd", "opcode":137,"state":{"a":128,"b":1,"c":66,"d":5,"e":15,"h":10,"l":20,"flags":{"sign":true,"zero":false,"auxCarry":true,"parity":false,"carry":false},"programCounter":1,"stackPointer":2,"cycles":4,"interruptsEnabled":true}}'

docker kill adc

DIFF=`diff <(jq -S . <<< "$RESULT") <(jq -S . <<< "$EXPECTED")`

if [ $? -eq 0 ]; then
    echo -e "\e[32mADC Test Pass \e[0m"
    exit 0
else
    echo -e "\e[31mADC Test Fail  \e[0m"
    echo "$RESULT"
    echo "$DIFF"
    exit -1
fi