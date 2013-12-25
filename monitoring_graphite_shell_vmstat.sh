#/bin/bash

# shell script taking vmstat data and export to graphite 
# add date and timestamp to vmstat, export to log file or graphite
# Usage 
# vmstat frequency(seconds) nb_iteration | ./perf_vmstat.sh --log --graphite
# vmstat 10 8640 | ./perf_vmstat.sh --log --graphite



usage ()
{
  echo '    -l|--log : log in a file :  default : false' 
  echo '    -g|--graphite : export data to graphite :  default : false'
  echo '    -a|--graphiteLocation  : graphiteLocation : default localhost'
  echo '    -f|--preformat : preformat to graphite (default dev)'
  exit
}

if [ "$#" -eq 0 ]
then
	echo "Usage"
	echo "vmstat frequency(seconds) nb_iteration | ./perf_vmstat.sh --log --graphite"
	echo "vmstat 10 8640 | "$0" --graphite --log"  
	usage
fi

#default value
graphiteLocation="localhost" #graphite server adress
preformat="10sec.dev." #preformationg data for graphite
log="False"
graphite="False"

while [ "$1" != "" ]; do
case $1 in
        -l|--log )           shift
                       log="True"
                       ;;
        -g|--graphite )           shift
                       graphite="True"
                       ;;
        -a|--graphiteLocation )           shift
                       graphiteLocation=$1
                       ;;
        -f|--preformat )           shift
                       preformat=$1
                       ;;
        * )            QUERY=$1
    esac
    shift
done


currrent_date_file=$(date +'%Y-%m-%d-%H-%M-%S');
if [[ $log == "True" ]]; then echo "*** write output in file /tmp/perf_vmstat_"$currrent_date_file".log"; fi

#echo " r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa"
# add date and timestamp to vmstat 

	while read line
	do
		vmstatdate=$(date +'%Y/%m/%d %H:%M:%S');
		currenttimestamp=$(date +%s);

		# Sortie ecran
		echo $vmstatdate $currenttimestamp $line 

		#suppression de la ligne de commentaire vmstat pour ne pas l'envoyer dans graphite ou dans les logs
		echo $line| egrep 'r' 2>&1 >/dev/null 
		if [[ $? -ne 0 ]] ;
		then

			#export to log file
			if [[ $log == "True" ]]; then echo $vmstatdate $currenttimestamp $line >>"/tmp/perf_vmstat_"$currrent_date_file"_"$HOSTNAME".log"; fi

			#export to graphite
			if [[ $graphite == "True" ]] ;   then 
				procsr=$(echo $line | awk -F' ' '{ print $1}')
				echo $preformat$HOSTNAME'.procs.r' $procsr $currenttimestamp | nc $graphiteLocation 2003;
				procsb=$(echo $line | awk -F' ' '{ print $2}')
				echo $preformat$HOSTNAME'.procs.b' $procsb $currenttimestamp | nc $graphiteLocation 2003;
				swap=$(echo $line | awk -F' ' '{ print $3}')
				echo $preformat$HOSTNAME'.memory.swap' $swap $currenttimestamp | nc $graphiteLocation 2003;
				free=$(echo $line | awk -F' ' '{ print $4}')
				echo $preformat$HOSTNAME'.memory.free' $free $currenttimestamp | nc $graphiteLocation 2003;
				buffer=$(echo $line | awk -F' ' '{ print $5}')
				echo $preformat$HOSTNAME'.memory.buffer' $buffer $currenttimestamp | nc $graphiteLocation 2003;
				cache=$(echo $line | awk -F' ' '{ print $6}')
				echo $preformat$HOSTNAME'.memory.cache' $cache $currenttimestamp | nc $graphiteLocation 2003;
				si=$(echo $line | awk -F' ' '{ print $7}')
				echo $preformat$HOSTNAME'.swap.si' $si $currenttimestamp | nc $graphiteLocation 2003;
				so=$(echo $line | awk -F' ' '{ print $8}')
				echo $preformat$HOSTNAME'.swap.so' $so $currenttimestamp | nc $graphiteLocation 2003;
				bi=$(echo $line | awk -F' ' '{ print $9}')
				echo $preformat$HOSTNAME'.io.bi' $bi $currenttimestamp | nc $graphiteLocation 2003;
				bo=$(echo $line | awk -F' ' '{ print $10}')
				echo $preformat$HOSTNAME'.io.bo' $bo $currenttimestamp | nc $graphiteLocation 2003;
				#in=$(echo $line | awk -F' ' '{ print $11}')
				#echo $preformat$HOSTNAME'.system.in' $in $currenttimestamp | nc $graphiteLocation 2003;
				#cs=$(echo $line | awk -F' ' '{ print $12}')
				#echo $preformat$HOSTNAME'.system.cs' $cs $currenttimestamp | nc $graphiteLocation 2003;
				cpuuser=$(echo $line | awk -F' ' '{ print $13}')
				echo $preformat$HOSTNAME'.cpu.user' $cpuuser $currenttimestamp | nc $graphiteLocation 2003;
				cpusystem=$(echo $line | awk -F' ' '{ print $14}')
				echo $preformat$HOSTNAME'.cpu.system' $cpusystem $currenttimestamp| nc $graphiteLocation 2003;
				cpuidle=$(echo $line | awk -F' ' '{ print $15}')
				echo $preformat$HOSTNAME'.cpu.idle' $cpuidle $currenttimestamp | nc $graphiteLocation 2003;
				cpuwait=$(echo $line | awk -F' ' '{ print $16}')
				echo $preformat$HOSTNAME'.cpu.wait' $cpuwait $currenttimestamp | nc $graphiteLocation 2003;
			fi
		fi
	done

exit

#export to graphite from file
#cat perf_vmstat_*.log | awk -F' ' '{ myvalue=$5;cmd=" date -d\""$1" "$2"\" +%s";cmd|getline;mydate=$0;close(cmd);print "echo #hostname.memory.swap#", myvalue, mydate " | nc $graphiteServer 2003;"; }' | sed s/\#/\'/g > "perf_vmstat_GRAPHITE.dat"
#cat perf_vmstat_*.log | awk -F' ' '{ myvalue=$15;cmd=" date -d\""$1" "$2"\" +%s";cmd|getline;mydate=$0;close(cmd);print "echo #hostname.cpu.user#", myvalue, mydate " | nc $graphiteServer 2003;"; }' | sed s/\#/\'/g >> "perf_vmstat_GRAPHITE.dat"
#cat perf_vmstat_*.log | awk -F' ' '{ myvalue=$16;cmd=" date -d\""$1" "$2"\" +%s";cmd|getline;mydate=$0;close(cmd);print "echo #hostname.cpu.system#", myvalue, mydate " | nc $graphiteServer 2003;"; }' | sed s/\#/\'/g >> "perf_vmstat_GRAPHITE.dat"
#cat perf_vmstat_*.log | awk -F' ' '{ myvalue=$17;cmd=" date -d\""$1" "$2"\" +%s";cmd|getline;mydate=$0;close(cmd);print "echo #hostname.cpu.idle#", myvalue, mydate " | nc $graphiteServer 2003;"; }' | sed s/\#/\'/g >> "perf_vmstat_GRAPHITE.dat"
#cat perf_vmstat_*.log | awk -F' ' '{ myvalue=$18;cmd=" date -d\""$1" "$2"\" +%s";cmd|getline;mydate=$0;close(cmd);print "echo #hostname.cpu.wait#", myvalue, mydate " | nc $graphiteServer 2003;"; }' | sed s/\#/\'/g >> "perf_vmstat_GRAPHITE.dat"
#bash <perf_vmstat_GRAPHITE.dat
#rm perf_vmstat_GRAPHITE.dat


