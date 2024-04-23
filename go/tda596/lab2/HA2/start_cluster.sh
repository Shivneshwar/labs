make build_join

i=$2
while [ $i -lt $3 ]
do
    ssh_port=`expr 1000 + $i`
    echo $ssh_port
    make run_instance a=$1 p=$i sp=$ssh_port ja=$4 jp=$5
    i=`expr $i + 1`
done