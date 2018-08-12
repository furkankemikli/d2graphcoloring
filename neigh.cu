#include <stdio.h>
#include <assert.h>
#include <math.h>
#include <limits.h>

__global__ void operate(int *test, int *train, double *dist, int tr_num, int index, int dimen){
  int tid = blockDim.x * blockIdx.x + threadIdx.x;

 
  //printf("%d  %d\n", tid, tr_num);
  if(tid < tr_num)
  {
  	double sum = 0.0;
/* 	
    int loc = tid*dimen;
  	sum =  (train[loc+0] - test[0+index])  *  (train[loc+0] - test[0+index]) +
  				 (train[loc+1] - test[1+index])  *  (train[loc+1] - test[1+index]) +
  				 (train[loc+2] - test[2+index])  *  (train[loc+2] - test[2+index]) +
  				 (train[loc+3] - test[3+index])  *  (train[loc+3] - test[3+index]) +
  				 (train[loc+4] - test[4+index])  *  (train[loc+4] - test[4+index]) +
  				 (train[loc+5] - test[5+index])  *  (train[loc+5] - test[5+index]) +
  				 (train[loc+6] - test[6+index])  *  (train[loc+6] - test[6+index]) +
  				 (train[loc+7] - test[7+index])  *  (train[loc+7] - test[7+index]) +
  				 (train[loc+8] - test[8+index])  *  (train[loc+8] - test[8+index]) +
  				 (train[loc+9] - test[9+index])  *  (train[loc+9] - test[9+index]) +
  				(train[loc+10] - test[10+index]) * (train[loc+10] - test[10+index]) +
  				(train[loc+11] - test[11+index]) * (train[loc+11] - test[11+index]) +
  				(train[loc+12] - test[12+index]) * (train[loc+12] - test[12+index]) +
  				(train[loc+13] - test[13+index]) * (train[loc+13] - test[13+index]) + 
  				(train[loc+14] - test[14+index]) * (train[loc+14] - test[14+index]) +
  				(train[loc+15] - test[15+index]) * (train[loc+15] - test[15+index]);
  	
  	*/
  	for(int i = 0; i < dimen; i++){
  		sum = sum + (train[tid*dimen+i] - test[i+index]) * (train[tid*dimen+i] - test[i+index]); 
  	}
  	
  	dist[tid] = sum;
    //printf("%d : %lf\n", tid,sum);
  }
}

__global__ void write(int *bla, int size)
{
 for (int i = 0; i < size; ++i)
  {
    if(i != 0 && i%16 == 0) printf("\nline %d \n", i/16);
    printf("%d ", bla[i]);
  }
}

void call(int *test, int *train, double *dist, int *d_test, int *d_train, double *d_dist, int ts_num, int tr_num, int dimen)
{
  int ts_size = ts_num*dimen;
  int tr_size = tr_num*dimen;
  
//  printf("%d\n", ts_size);
//  printf("%d\n", tr_size);
 

  cudaMalloc( (void**)&d_test, ts_size*sizeof(int));
  cudaMalloc( (void**)&d_train, tr_size*sizeof(int));
  cudaMalloc( (void**)&d_dist, tr_num*sizeof(double));

  cudaMemcpy(d_test, test, ts_size*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_train, train, tr_size*sizeof(int), cudaMemcpyHostToDevice);
  cudaMemcpy(d_dist, dist, tr_num*sizeof(double), cudaMemcpyHostToDevice);
  //write<<<1,1>>>(d_test, ts_size);
  //write<<<1,1>>>(d_train, tr_size);

  FILE *f = fopen("out.txt", "w");
	if (f == NULL)
	{
    printf("Error opening file!\n");
    exit(1);
	}
  const int blockSize = 20;
  const int bla = 1024;

  float totaltime;
  cudaEvent_t startEvent, endEvent;
  cudaEventCreate(&startEvent);
  cudaEventCreate(&endEvent);
  cudaEventRecord(startEvent, 0);

  for(int i = 0; i < ts_size; i+=dimen)
  {
    
    operate<<<blockSize, bla>>>(d_test, d_train, d_dist, tr_num, i, dimen);
    cudaMemcpy(dist, d_dist, tr_num*sizeof(double), cudaMemcpyDeviceToHost);

    double min_dist = 100000000.0;
    int which = -1;
    for(int j = 0; j<tr_num; j++)
    {
      if(min_dist>dist[j]){
        which = j;
        min_dist = dist[j];
      }
    }
    //printf("test: %d,\ttrain: %d,\tdistance: %lf\n", i/16, which, sqrt(min_dist));
    fprintf(f, "%d\n", which);
  }	
  cudaEventRecord(endEvent, 0);
  cudaEventSynchronize(endEvent);
	cudaEventElapsedTime(&totaltime, startEvent, endEvent);
	fclose(f);
  printf("Execution time is %f secs.\n", totaltime/1000);

  cudaFree(d_test);
  cudaFree(d_train);
  cudaFree(d_dist);

}