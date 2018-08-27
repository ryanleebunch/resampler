//(C) 2018 Ryan Lee Bunch
// Resampler for real number modeling of timing error/jitter

`timescale 1fs/1fs

module tf_resampler;

real vin;
wire real vout;
reg clkin;
reg clkout;

always
begin  //period of input clock
 clkin = 0;
 #5000;
 clkin = 1;
 #5000;
end

always
begin  //period of output clock, this is the one we will jitter/timing error
 clkout = 0;
 #20000;
 clkout = 1;
 #20100;
end

resampler resampler_i(
  .vin(vin),
  .clk(clkout),
  .vout(vout)
);

//let make a 1GHz sine wave
real freq = 1e9;
real phase = 0.0;
real amplitude = 1.0;
real dt;
real vin_prev;

always @(posedge clkin)
begin
  vin_prev = vin;
  phase = freq*2*3.14159265358979*$realtime*1e-15;
  vin = amplitude*$sin(phase);
  if(vin==vin_prev)
    vin = vin + 1e-12;  //force vin to always be different to carry the clock intrisincally
end

real vout_compare;
real error;
real sum_sq_error;
real sum_sq_sig;
integer n;

always @(posedge clkout)
begin
  vout_compare = amplitude*$sin(freq*2*3.14159265358979*($realtime-50000.0)*1e-15);
end



initial
begin   
  $dumpvars;
  repeat(1000)
  begin
    @(posedge clkin);
  end    
  sum_sq_error = 0.0;
  sum_sq_sig = 0.0;
  n = 0;
  repeat(100000)
  begin
    @(posedge clkout);
    #1;
    error = vout_compare-vout;
    sum_sq_error = sum_sq_error + error*error;
    sum_sq_sig = sum_sq_sig + vout*vout;
    n = n+1;
  end  
  $display("Mean Squared error = %e",sum_sq_error/(1.0*n));
  $display("Mean Squared sig = %e",sum_sq_sig/(1.0*n));
  $display("SNR after resample is %f dB",10.0*$log10(sum_sq_sig/sum_sq_error));
  $finish;
end

endmodule
