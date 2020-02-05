#define DEFAULT_THRESHOLD  8000

#define DEFAULT_FILENAME "BWstop-sign.ppm"
#define BLOCK_SIZE 32
#define TILE_SIZE 32
__global__ void sobel( int xd_size, int yd_size, int maxdval, int d_thresh, unsigned int *input , int * output)
{

	int sum1,sum2,magnitude;
	
int i = blockIdx.y * blockDim.y + threadIdx.y; 
	int j = blockIdx.x * blockDim.x + threadIdx.x; 
	int tid_x = threadIdx.y; 
	int tid_y = threadIdx.x;
__shared__ int inter[(TILE_SIZE) * (TILE_SIZE)];
	
	
	if ((i < yd_size) && (j < xd_size))
        {
        output[i * xd_size + j] = 0;
        }
        __syncthreads();
    inter[tid_x * TILE_SIZE + tid_y]  = 0; 
	__syncthreads();
	inter[tid_x * TILE_SIZE + tid_y] = input[i * (xd_size) + j];
	__syncthreads();
	if (i > 0 && j > 0 && i < yd_size - 1 && j < xd_size - 1){	
	
		if ((tid_x > 0) && (tid_x < TILE_SIZE - 1)  && (tid_y > 0) && (tid_y < TILE_SIZE - 1))
        	{
        	int offset = i * xd_size + j;
        	int shared_a = inter[ TILE_SIZE * (tid_x-1) + tid_y+1];
        	int shared_b = inter[ TILE_SIZE * (tid_x-1) + tid_y-1 ];
        	int shared_c = inter[ TILE_SIZE * (tid_x+1) + tid_y+1];

       		 sum1 =  shared_a - shared_b+shared_c + 2 * inter[ TILE_SIZE * (tid_x)   + tid_y+1 ] - 2 * inter[ TILE_SIZE*(tid_x)   + tid_y-1 ] - inter[ TILE_SIZE*(tid_x+1) + tid_y-1 ];

        	sum2 = shared_a+shared_b-shared_c + 2 * inter[ TILE_SIZE * (tid_x-1) + tid_y ]  - inter[TILE_SIZE * (tid_x+1) + tid_y-1 ] - 2 * inter[ TILE_SIZE * (tid_x+1) + tid_y ];
		magnitude=sum1*sum1+sum2*sum2;
	
		int e_ig =0;
		if(magnitude>d_thresh){
          	e_ig=255;
		}
       output[offset]=e_ig;}
       __syncthreads();
		if ((i == blockIdx.y * blockDim.y + blockDim.y - 1) || (j == blockIdx.x * blockDim.x + blockDim.x - 1) ||  (i == blockIdx.y * blockDim.y) || (j == blockIdx.x * blockDim.x))
		{
		int offset = i * xd_size + j;
		int golbal_a = input[ xd_size * (i-1) + j+1];
		int golbal_b = input[ xd_size * (i-1) + j-1 ];
		int golbal_c = input[ xd_size *	(i+1) + j+1];

       		 sum1 =  golbal_a - golbal_b+golbal_c+ 2 * input[ xd_size * (i)   + j+1 ] - 2 * input[ xd_size*(i)   + j-1 ] -input[ xd_size*(i+1) + j-1 ];

       		 sum2 = golbal_a+golbal_b + 2 * input[ xd_size * (i-1) + j ] - input[xd_size * (i+1) + j-1 ] - 2 * input[ xd_size * (i+1) + j ] - golbal_c;

		magnitude=sum1*sum1+sum2*sum2;
		int e_ig=0;
		if(magnitude>d_thresh){
        		e_ig=255;
        	}
        output[offset]=e_ig;
    }
      			  __syncthreads();
}               
}

