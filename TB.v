`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Prajwal H N
// 
// Create Date: 30.04.2023 13:58:19
// Module Name: TB
// Project Name: SPI Implementation using Verilog HDL
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module TB();

//Declaring Test Bench signals to drive ports of DUT:
reg clk, reset;
reg cpol, cpha;
reg [7:0] din;
reg miso;
wire [7:0] dout;
wire sclk;
wire mosi, ss_n, done;


//Instantiating DUT and mapping TB signals to DUT ports:
SPI_Master DUT(clk, reset, cpol, cpha, din, miso, dout, sclk, mosi, ss_n, done);


//Initialising Test Bench signals which are input ports of DUT:
initial
begin
    clk = 1;
    reset = 1;
    din = 8'h00;
    miso = 1'bz;
end


//Generation of clock signal:
always #50 clk = ~clk;

//Defining tasks to be used for driving input ports of DUT:
task mode0;
    begin
        cpol = 0;
        cpha = 0;
        reset = 1;
        #100;
        reset = 0;
        din = $urandom_range(0,255);
        
        //wait(done);
        //reset = 1;
    end
endtask

task mode1;
    begin
        cpol = 0;
        cpha = 1;
        reset = 1;
        #100;
        reset = 0;
        din = $urandom_range(0,255);
        
        //wait(done);
        //reset = 1;
    end
endtask

task mode2;
    begin
        cpol = 1;
        cpha = 0;
        reset = 1;
        #100;
        reset = 0;
        din = $urandom_range(0,255);
        //wait(done);
        //reset = 1;        
    end
endtask

task mode3;
    begin
        cpol = 1;
        cpha = 1;
        reset = 1;
        #100;
        reset = 0;
        din = $urandom_range(0,255);
        
       //wait(done);
       //reset = 1;
    end
endtask


//Driving input ports of the DUT using Test Bench Signals:
initial
begin
    reset = 1;
    #100;
    reset = 0;
    mode0;
    #5000;
    mode1;
    #5000;
    mode2;
    #5000;
    mode3;
    #5000 $finish;
end


endmodule
