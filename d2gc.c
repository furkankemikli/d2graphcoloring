#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

#include "graphio.h"
#include "graph.h"

void callD2GC(int* row, int* col_ind, int nov);

char gfile[2048];

void usage(){
  printf("./bfs <filename> <sourceIndex>\n");
  exit(0);
}


/*
  You can ignore the ewgths and vwghts. They are there as the read function expects those values
  row_ptr and col_ind are the CRS entities. nov is the Number of Vertices
*/
int main(int argc, char *argv[]) {
	etype *row_ptr;
	vtype *col_ind;
	ewtype *ewghts;
	vwtype *vwghts;
	vtype nov, source;

	if(argc != 3)
		usage();

	const char* fname = argv[1];
	strcpy(gfile, fname);
	source = atoi(argv[2]);
	  
	if(read_graph(gfile, &row_ptr, &col_ind, &ewghts, &vwghts, &nov, 0) == -1) {
		printf("error in graph read\n");
		exit(1);
	}
  
  /****** YOUR CODE GOES HERE *******/    
	callD2GC(row_ptr, col_ind, nov);
	
	free(row_ptr);
	free(col_ind);
	
    
	return 1;
}
