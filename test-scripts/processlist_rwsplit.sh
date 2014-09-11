#/bin/bash

# $1 - end of IP of the node to which maxscale should be connected
# $2 - number of nodes

#set -x

IP_end=$1
N=$2

conn_node="$1"
Master_IP=`expr $IP_end + 1`
Last_node=`expr $IP_end + $N - 1`

slave_connections=`expr $N / 2`
all_connections=`expr $slave_connections + 1`

echo $slave_connections


/home/ec2-user/test-scripts/c/connect_rw 192.168.122.$IP_end &

for i in $(seq $Master_IP $Last_node)
do
   echo "$i:"
   echo "show processlist;" | mysql -h 192.168.122.$i -uskysql -pskysql | grep "$IP_end"
done

a=0
conn_num=0

for i in $(seq $Master_IP $Last_node)
do
	lines=`echo "show processlist;" | mysql -h 192.168.122.$i -uskysql -pskysql | grep "105" | grep "test" | wc -l`
	echo "Number of connections to $i is $lines"
        conn_num=`expr $IP_end + $lines`
	if [[ "$i" == "$Master_IP" && $lines != 1 ]] ; then 
                echo "Connection to Master is not 1, it is $lines"
		a=1
	fi
done

if [ "conn_num" != "$all_connections" ] ; then
	a=1
	echo "total number of connection is $con_num instead of expecte $all_connections"
fi

exit $a
