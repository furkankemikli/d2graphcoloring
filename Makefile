d2gc: 
#	gcc graph.c -c -O3	
	nvcc -O3 -c d2gc.cu
	g++ -o d2gc graphio.c mmio.c d2gc.c d2gc.o -lcuda -lcudart -L/usr/local/cuda/lib64/ -fpermissive
clean:
	rm d2gc *.o *~
