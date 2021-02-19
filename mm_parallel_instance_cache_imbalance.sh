#!/bin/bash
set -ex

mkdir -p ./executables/

g++ ./mm_inplace.cpp -o ./executables/mm_inplace
chmod a+x ./executables/mm_inplace

g++ ./mm_scan.cpp -o ./executables/mm_scan
chmod a+x ./executables/mm_scan

g++ ./mm_block.cpp -o ./executables/mm_block
chmod a+x ./executables/mm_block

g++ ./make-mm-data.cpp -o ./executables/make-mm-data
chmod a+x ./executables/make-mm-data


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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-BLOCK 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-BLOCK 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_block 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-INPLACE 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_inplace 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
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
		echo $((6*TOTALMEMORY)) > /sys/fs/cgroup/memory/cache-test-arghya/memory.limit_in_bytes
		echo "Running MM-SCAN 6 instances" >> out-mm.txt
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes1 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes2 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 0 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes3 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes4 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes5 &
		cgexec -g memory:cache-test-arghya ./executables/mm_scan 1 $MATRIXWIDTH $STARTINGMEMORY_MB data_files/nullbytes6
		sleep 5
		wait
	done
done
