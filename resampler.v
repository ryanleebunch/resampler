//(C) 2018 Ryan Lee Bunch
// Resampler for real number modeling of timing error/jitter
// Create FIFO with incoming samples
// Adds broadband group delay to input and resamples on clk using
// 4 point Lagrange Interpolation

`timescale 1fs/1fs

module resampler(
  input real vin,
  input clk,
  output real vout
);


real ts_fifo[16];
real vs_fifo[16];

real input_period = 0.0;
real ts_prev = 0.0;
real ts_sample = 0.0;

real interp_grp_delay = 50000;  //50ps of group delay so we have points to interpolate around

reg [3:0] wr_ptr = 0;
reg [3:0] rd_ptr = 0;
reg [3:0] rd_ptr_t0 = 0;
reg [3:0] rd_ptr_t1 = 0;
reg [3:0] rd_ptr_t2 = 0;
reg [3:0] rd_ptr_t3 = 0;

real t0,t1,t2,t3;
real y0,y1,y2,y3;
real L0,L1,L2,L3;
real t,y;

/*

What we want to do is make a FIFO with the incoming time x voltage pairs, length
of the FIFO will be such that we can do a multipoint interpolation about the middle
onto the sampling clock

*/

integer ii;

always @(vin)
begin
  input_period = $realtime - ts_prev;  
  ts_fifo[wr_ptr] = $realtime;
  vs_fifo[wr_ptr] = vin;
 /* $display("------------------- period = %0f",input_period);
  for(ii=0;ii<16;ii=ii+1)
  begin
    $display("%0c : ii=%0d :%f : %f",ii==wr_ptr ? "w" : ii==rd_ptr ? "r" : " ",ii,ts_fifo[ii],vs_fifo[ii]);
  end*/
  wr_ptr = wr_ptr + 1;
  rd_ptr = wr_ptr - interp_grp_delay/input_period;
  ts_prev = $realtime;
end


always @(posedge clk)
begin
  ts_sample = $realtime;
  //$display("interpolate at %f-%f=%f corresponds to read pointer + %f",ts_sample,interp_grp_delay,ts_sample-interp_grp_delay,ts_sample-interp_grp_delay-ts_fifo[rd_ptr]);
  rd_ptr_t0 = rd_ptr-2;
  rd_ptr_t1 = rd_ptr-1;
  rd_ptr_t2 = rd_ptr;
  rd_ptr_t3 = rd_ptr+1;
  
  //$display("interpolating %f between the points:\n%f\n%f\n%f\n%f",ts_sample-interp_grp_delay,ts_fifo[rd_ptr_t0],ts_fifo[rd_ptr_t1],ts_fifo[rd_ptr_t2],ts_fifo[rd_ptr_t3]);
  
t=ts_sample-interp_grp_delay;
t0=ts_fifo[rd_ptr_t0];
t1=ts_fifo[rd_ptr_t1];
t2=ts_fifo[rd_ptr_t2];
t3=ts_fifo[rd_ptr_t3];
y0=vs_fifo[rd_ptr_t0];
y1=vs_fifo[rd_ptr_t1];
y2=vs_fifo[rd_ptr_t2];
y3=vs_fifo[rd_ptr_t3];
L0=((t-t1)/(t0-t1))*((t-t2)/(t0-t2))*((t-t3)/(t0-t3));
L1=((t-t0)/(t1-t0))*((t-t2)/(t1-t2))*((t-t3)/(t1-t3));
L2=((t-t0)/(t2-t0))*((t-t1)/(t2-t1))*((t-t3)/(t2-t3));
L3=((t-t0)/(t3-t0))*((t-t1)/(t3-t1))*((t-t2)/(t3-t2));
y=L0*y0+L1*y1+L2*y2+L3*y3;
//y=y2;  //experiment with this line uncommented to see just how bad the SNR of neareset neigbor is
  
end

assign vout = y;

endmodule
