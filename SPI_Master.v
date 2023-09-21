`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Engineer: Prajwal H N
// 
// Create Date: 29.04.2023 22:20:49
// Module Name: SPI_Master
// Project Name: SPI Implementation using Verilog HDL
// Description: 
//////////////////////////////////////////////////////////////////////////////////

module SPI_Master(
    input clk, reset,
    input cpol, cpha,
    input [7:0] din,
    input miso,
    output reg [7:0] dout,
    output sclk,
    output reg mosi, ss_n, done    
    );
    
    
//---------------------------- Operating Modes -----------------------------
//Defining Operating modes of SPI:
parameter mode0 = 0,
          mode1 = 1,
          mode2 = 2,
          mode3 = 3;
          
//Variable to hold the value of mode:
reg [1:0] mode;

always @(posedge clk)
begin
    if(~cpol && ~cpha)
        mode <= mode0;
    else if(~cpol && cpha)
        mode <= mode1;
    else if(cpol && ~cpha)
        mode <= mode2;
    else
        mode <= mode3;
end


//---------------------------- SPI Clock Generation -----------------------------
parameter fclk = 10;      //On-Board FPGA Clock = 10 MHz
parameter fsclk = 5;       //SPI Clock = 5 MHz (NOTE: fclk >= 2*fsclk)
parameter n = fclk/fsclk;

integer waitCount = 0;
reg sclk_temp;

always @(negedge reset) sclk_temp = cpol ^ cpha;

always @(posedge clk) 
begin
    if(reset == 1)
        sclk_temp <= cpol;
        
    else
        if(waitCount < n/2)
            waitCount <= waitCount + 1;
        
        else
        begin
            waitCount <= 0;
            sclk_temp <= ~sclk_temp;
        end
        
end

assign sclk = sclk_temp;


//---------------------------- SPI FSM Implementation ---------------------------
//Defining states of the FSM:
parameter IDLE = 2'b00,
          START = 2'b01,
          SEND = 2'b10,
          END = 2'b11;
          
reg [1:0] stateP, stateN;   //State Variable to hold the value of Present State and Next State:
reg [7:0] data;     //Data Register to hold the value of input byte
//reg [7:0] dout;
integer bitIndex = 0;

//Reset/Present state logic:
always @(sclk, reset)
begin
    if(reset == 1)
        stateP <= IDLE;
    else
        stateP <= stateN;
end

//Next State and Output Logic:
always @(sclk)
begin
    case(stateP)
    
        IDLE:
        begin
            mosi = 0;
            ss_n = 1;
            done = 0;
            
            if(reset == 0)
                stateN = START;
            else
                stateN = IDLE;
        end
        
        START:
        begin
            ss_n = 0;
            data = din;
            
            stateN = SEND;
        end
        
        SEND:
        begin
            if(bitIndex < 8)
            begin
                if((mode == mode0) || (mode == mode3))  
                    @(negedge sclk) 
                    begin 
                        mosi = data[bitIndex];
                        bitIndex = bitIndex + 1;
                        //dout = {mosi, dout[7:1]};
                    end
                    
                else if((mode == mode1) || (mode == mode2))
                    @(posedge sclk)
                    begin
                        mosi = data[bitIndex];
                        bitIndex = bitIndex + 1;
                        //dout = {mosi, dout[7:1]};
                    end
                
                stateN = SEND;
            end
            
            else
            begin
                if((mode == mode0) || (mode == mode3))  
                    @(negedge sclk) 
                    begin
                        mosi = 0;
                        bitIndex = 0; 
                    end
                    
                else if((mode == mode1) || (mode == mode2))
                    @(posedge sclk)
                    begin
                        mosi = 0;
                        bitIndex = 0;
                    end
                
                stateN = END;
            end
        end
        
        END:
        begin
            ss_n = 1;
            done = 1;
            
            stateN = IDLE;
        end
        
        default: stateN = IDLE;
        
    endcase
end

endmodule