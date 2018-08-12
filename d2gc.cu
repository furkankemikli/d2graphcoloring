#include <stdio.h>
#include <assert.h>

__global__ colorWork(int* row_ptr, int* col_ind, int* neighbor_colors, int* color_array, int index, int i)
{
	int tid = 
	for(int j=row_ptr[i]; j < row_ptr[i+1]; j++){
		// neighborhood function to check neighbors of visited verte
		if(color_array[col_ind[j]] != -1){
			bool found = false;
			for(int c=0; c < index; c++){
				if(neighbor_colors[nov*tid+c] == color_array[col_ind[j]]){
					found = true;
					c = index;
				}
			}
			if(found == false){
				neighbor_colors[nov*tid+index] = color_array[col_ind[j]];
				index = index+1;
			}
			//printf("forbidden added first degree %d %d \n",col_ind[j],color_array[col_ind[j]]);
		}
		for(int k=row_ptr[col_ind[j]]; k < row_ptr[col_ind[j]+1];k++){
			if(color_array[col_ind[k]] != -1 && col_ind[k] != i){
				//colorı neighbor color içinde ara yoksa ekle
				bool alreadyIn = false;
				for(int c=0; c < index; c++){
					if(neighbor_colors[nov*tid+c] == color_array[col_ind[k]]){
						alreadyIn = true;
						c = index;
					}
				}
				if(alreadyIn == false){
					neighbor_colors[nov*tid+index] = color_array[col_ind[k]];
					index = index+1;
					//printf("forbidden added second degree %d %d \n",col_ind[k],color_array[col_ind[k]]);
				}
			}
		}
	}
}

void callD2GC(int* row_ptr, int* col_ind, int nov)
{
	float totaltime;
  cudaEvent_t startEvent, endEvent;
  cudaEventCreate(&startEvent);
  cudaEventCreate(&endEvent);
  // 
	int *color_array, *d_color_array, d_neighbor_colors;//array to keep colors of the vertices the color numbers start from 1
 	__shared__ int *d_neighbor_colors;
  cudaMalloc( (void**)&color_array, nov*sizeof(int));
  cudaMalloc( (void**)&neighbor_colors, nov*sizeof(int));
  cudaMalloc( (void**)&d_color_array, nov*sizeof(int));
  cudaMalloc( (void**)&d_neighbor_colors, nov*sizeof(int));
  cudaMemset( color_array, -1, nov*sizeof(int));
//	neighbor_colors =(int*)malloc(thread_num*nov*sizeof(int));
	cudaMemcpy(d_color_array, color_array, nov*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_neighbor_colors, neighbor_colors, nov*sizeof(int), cudaMemcpyHostToDevice);

	int maxColor;//to print out color number
	typedef int bool;//to boolean check
	enum {false, true};
	printf("Nov is %d\n", nov);
	printf("Started...");
	
	bool isFinished = false;//to check all the vertices colored without conflict and coloring finished	
	cudaEventRecord(startEvent, 0);
	while(!isFinished){		
		printf("Turn ");
		isFinished = true;//if it is not finished it is changed in conflict check part
		//COLORWORKQUEUE			
		#pragma omp parallel for num_threads(thread_num) shared(color_array)
		for(int i=0; i < nov; i++){//in parallel visit all the vertices in graph
			int tid = omp_get_thread_num();
			if(color_array[i] == -1){//checks if vertex is colored in previous turns
				int index = 0;//keeps number of colored neighbors
				//forbidden color bulma
				colorWork<<1,1>>(row_ptr, col_ind, );
				
				/*printf("vertex is %d\nForbidden of %d\n",i,i);
				for(int k=0;k<index;k++){
					printf("%d ",neighbor_colors[nov*tid+k]);
				}
				printf("\n");*/
				int col = 0;
				bool sameWithNbor = true;
				while(sameWithNbor){
					sameWithNbor = false;
					for(int k=0; k < index; k++){
						if(col == neighbor_colors[nov*tid+k]){
							col = col+1;
							sameWithNbor = true;
						}
					}
				}
				color_array[i] = col;
			}
		}
		// REMOVECONFLICTS
		//TODO: Check d2 vertices
		
		#pragma omp parallel for num_threads(thread_num) shared(isFinished, color_array)
		for(int i=0; i < nov; i++){
			for(int j=row_ptr[i]; j < row_ptr[i+1]; j++){
				if(color_array[col_ind[j]] == color_array[i] && i > col_ind[j]){//if neighbor and vertex have same color and index of vertex is greater than neighbor
					color_array[i] = -1;
					j = row_ptr[i+1];
					isFinished = false;
				}
				if(isFinished == true){
					for(int k= row_ptr[col_ind[j]]; k < row_ptr[col_ind[j]+1]; k++){
						if(color_array[col_ind[k]] == color_array[i] && i > col_ind[k]){
							color_array[i] = -1;
							k = row_ptr[col_ind[j]+1];
							j = row_ptr[i+1];
							isFinished = false;
						}
					}
				}
			}
		}/*
		printf("Colors are:\n");
		for(int i=0; i<nov;i++){
	    printf("%d  ",color_array[i]);			
		}*/
		//printf("\n");
	}
	
	printf("\n");
	cudaEventRecord(endEvent, 0);
  cudaEventSynchronize(endEvent);
	cudaEventElapsedTime(&totaltime, startEvent, endEvent);
  printf("Execution time is %f secs.\n", totaltime/1000);

	maxColor = color_array[0];
	//printf("%d  ",color_array[0]);		
	for(int i=1; i<nov;i++){
	    //printf("%d  ",color_array[i]);
		if(maxColor < color_array[i]){
			maxColor = color_array[i];
		}
	}
	printf("\nNumber of colors is %d\n", maxColor+1);

	char result_name[1024];
	strcpy(result_name,"resultOf-");
	char mtx_name[255];
	int index = strstr(fname,".")- fname;
	strncpy(mtx_name, fname, index);
	mtx_name[index] = '\0';
	sprintf(result_name,"%s%s%s",result_name, mtx_name, ".txt");

	FILE *f = fopen(result_name, "w");
	if(f == NULL){
		printf("Cannot open result_file to write\n");
		exit(1);
	}
	fprintf(f,"%d", maxColor+1);
	fprintf(f,"\n");
	for(int i = 0; i<nov;i++){
		fprintf(f,"%d ",color_array[i]);
	}
	fclose(f);

	cudaFree(color_array);
	cudaFree(neighbor_colors);
}
