#!/bin/bash
set -ex

mkdir -p ./executables/
g++ ./mm_inplace.cpp -o ./executables/cache_adaptive_balloon
chmod a+x ./executables/cache_adaptive_balloon
g++ ./mm_scan.cpp -o ./executables/non_cache_adaptive_balloon
chmod a+x ./executables/non_cache_adaptive_balloon
g++ ./make-mm-data.cpp -o ./executables/make-mm-data
chmod a+x ./executables/make-mm-data

g++ ./balloon.cpp -o ./executables/balloon
chmod a+x ./executables/balloon

NUMRUNS=3
NUMINSTANCE=6


declare -a matrixwidth=( 2048 )
declare -a startingmemory=( 10 )

#creating nullbytes
mkdir -p ./data_files/
for i in `seq 1 $NUMINSTANCE`;
do
	if [ ! -f "data_files/nullbytes$i" ]
	then
	  echo "First creating file for storing data."
	  dd if=/dev/urandom of=data_files/nullbytes$i count=32768 bs=1048576
	fi
done

#deleting out-sorting.txt and creating again
if [ -f "out-mm.txt" ]
then
  echo "out-mm.txt already exists. Deleting it first."
  rm out-mm.txt && touch out-mm.txt
fi

if [ -f "log.txt" ]
then
  echo "log.txt already exists. Deleting it first."
  rm log.txt && touch log.txt
fi

for i in `seq 1 $NUMRUNS`;
do
	for (( index=0; index<=${#matrixwidth[@]}-1; index++ ));
	do
		MATRIXWIDTH=${matrixwidth[$index]}
		STARTINGMEMORY_MB=${startingmemory[$index]}
		TOTALMEMORY=$((STARTINGMEMORY_MB*1024*1024))

		#code for constant memory profile merge sort
		echo "Running 1 instance on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $TOTALMEMORY > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 1 instance" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1
		sleep 5
		wait
		

		#code for competition memory profile merge sort with m memory of same size
		echo "Running 2 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((2*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 2 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2
		sleep 5
		wait
		
		#code for competition memory profile merge sort with m memory of same size
		echo "Running 3 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((3*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 3 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3
		sleep 5
		wait
		
		#code for competition memory profile merge sort with m memory of same size
		echo "Running 4 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 4 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4
		sleep 5
		wait


		#code for competition memory profile merge sort with m memory of same size
		echo "Running 5 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes5
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 5 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5
		sleep 5
		wait


		#code for competition memory profile merge sort with m memory of same size
		echo "Running 6 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes5
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes6
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
		sleep 5
		wait


		
		#code for constant memory profile merge sort
		echo "Running 1 instance on constant memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $TOTALMEMORY > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 1 instance" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1
		sleep 5
		wait
		
		#code for constant memory profile funnel sort
		echo "Running 2 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((2*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 2 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2
		sleep 5
		wait
		
		#code for constant memory profile funnel sort
		echo "Running 3 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((3*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 3 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3
		sleep 5
		wait
		
		#code for constant memory profile funnel sort
		echo "Running 4 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 4 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/non_cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4
		sleep 5


		#code for competition memory profile merge sort with m memory of same size
		echo "Running 5 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes5
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 5 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5
		sleep 5
		wait


		#code for competition memory profile merge sort with m memory of same size
		echo "Running 6 instances on M memory"
		./cgroup_creation.sh cache-test-arghya
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes1
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes2
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes3
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes4
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes5
		./executables/make-mm-data $MATRIXWIDTH data_files/nullbytes6
		sudo sh -c "sync; echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/vfs_cache_pressure"
		echo $((4*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/cache_adaptive_balloon 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
		sleep 5
		wait
	done
done
