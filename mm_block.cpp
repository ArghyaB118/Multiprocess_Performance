#include "CacheHelper.h"
#include<sys/types.h>
#include<sys/stat.h>
#include<sys/mman.h>
#include<fcntl.h>
#include<chrono>
#include<fstream>
#include <string>
#include <cstring>
#include <stdlib.h>
#include <stdio.h>
#define TYPE int
using namespace std;

unsigned long length = 0;
const int progress_depth = 4;
char* datafile;
int pause_time;

//x is the output, u and v are the two inputs
void mm( TYPE* x, TYPE* u, TYPE* v, int n ) {
	if ( n > CacheHelper::MM_BLOCK_BASE_SIZE ) {
		printf("something wrong");
	}
	for ( int i = 0; i < n; i++ )
		{
			TYPE* vv = v;
			for ( int j = 0; j < n; j++ )
			{
				TYPE t = 0;

				for ( int k = 0; k < n; k++ )
					t += u[ k ] * vv[ k ];

				( *x++ ) += t;
				vv += n;
			}
			u += n;
		}
}


void mm_root( TYPE* x, TYPE* u, TYPE* v, int n )
{

	//int nn = ( n >> 1 );
	int nn = CacheHelper::MM_BLOCK_BASE_SIZE;
	int nn2 = nn * nn;
	if ( length < CacheHelper::MM_BLOCK_BASE_SIZE ) {
		mm( x , u , v , n );
	}
	else {
		for ( int i = 0; i < length / nn ; i++ ) {
			if (i == 1 && pause_time == 1) {
				cout.flush();
				sleep(10);
				pause_time = 0;
			}
			for ( int j = 0; j < length / nn ; j++ ) {
				for ( int k = 0; k < length / nn ; k++ ) {
					// if (pause_time == 1) {
					// 	sleep(0.01);						
					// }
					//std::cout << i << j << k << endl;
					mm( x + (length * i / nn + j) * nn2, u + (length * i / nn + k) * nn2, v + (length * j / nn + k) * nn2 , nn );
				}
			}
		}
	}
}



int main(int argc, char *argv[]){

	if (argc < 4){
	std::cout << "Insufficient arguments! Usage: cgroup_cache_adaptive <memory_profile> <matrix_width> <memory_limit> <cgroup_name>\n";
	exit(1);
	}
	std::ofstream mm_out = std::ofstream("out-mm.txt",std::ofstream::out | std::ofstream::app);
	pause_time = std::stol(argv[1]); length = std::stol(argv[2]);
	std::cout << "Running cache_adaptive matrix multiply with matrices of size: " << (int)length << "x" << (int)length << "\n";
	std::vector<long> io_stats = {0,0};
	CacheHelper::print_io_data(io_stats, "Printing I/O statistics at program start @@@@@ \n");

	int fdout;
	datafile = new char[strlen(argv[4]) + 1](); strncpy(datafile,argv[4],strlen(argv[4]));
	if ((fdout = open (datafile, O_RDWR, 0x0777 )) < 0){
		printf ("can't create nullbytes for writing\n");
		return 0;
	}

	TYPE* dst;
	if (((dst = (TYPE*) mmap(0, sizeof(TYPE)*length*length*3, PROT_READ | PROT_WRITE, MAP_SHARED , fdout, 0)) == (TYPE*)MAP_FAILED)){
	   printf ("mmap error for output with code");
	   return 0;
	}

	/*
	for (unsigned int i = 0 ; i < 3*length*length; i++){
		std::cout << dst[i] << "\t";
	}
	std::cout << "\n";
	*/
	CacheHelper::print_io_data(io_stats, "Printing I/O statistics AFTER loading output matrix to cache @@@@@ \n");
	std::cout << "===========================================\n";

	//MODIFY MEMORY WITH CGROUP
	//CacheHelper::limit_memory(std::stol(argv[3])*1024*1024,argv[4]);

	std::chrono::system_clock::time_point t_start = std::chrono::system_clock::now();
	std::clock_t start = std::clock();
	mm_root(dst,dst+length*length,dst+length*length*2,length);
	if (pause_time == 0) {
		cout.flush();
		sleep(10);
	}
	std::chrono::system_clock::time_point t_end = std::chrono::system_clock::now();
	double cpu_time = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	auto wall_time = std::chrono::duration<double, std::milli>(t_end-t_start).count();

	std::cout << "===========================================\n";
	std::cout << "Total wall time: " << wall_time << "\n";
	std::cout << "Total CPU time: " << cpu_time << "\n";

	std::cout << "===========================================\n";
	std::cout << "Data: " << (unsigned int)dst[length*length/2/2+length] << std::endl;
	std::cout << "===========================================\n";
	std::cout << "===========================================\n";
	CacheHelper::print_io_data(io_stats, "Printing I/O statistics AFTER matrix multiplication @@@@@ \n");

	mm_out << "MM_BLOCK," << argv[3] << "," << length << "," << wall_time << "," << (float)io_stats[0]/1000000.0 << "," << (float)io_stats[1]/1000000.0 << "," << (float)(io_stats[0] + io_stats[1])/1000000.0 << std::endl;
	/*std::cout << "Result array\n";
	for (unsigned int i = 0 ; i < length*length; i++){
	std::cout << dst[i] << " ";
	}
	std::cout << std::endl;
	*/
  	return 0;
}
