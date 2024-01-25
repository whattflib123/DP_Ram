`timescale 1ns/1ns
// `define SDFFILE ""
`define CYCLE 30.0

module ram_tb;


// `ifdef SDF
//     initial $sdf_annotate(`SDFFILE, U_DPRam);
// `endif

reg clk, rst_n, write_en, read_en;
reg [7:0] write_addr, read_addr;
reg [3:0] write_data;
wire [3:0] read_data;

// Instantiate the RAM module
ram_mod uut(
    .clk(clk),
    .rst_n(rst_n),
    .write_en(write_en),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_en(read_en),
    .read_addr(read_addr),
    .read_data(read_data)
);

// Clock generation
initial begin
    clk = 0;
end

always  begin
    #(`CYCLE/2) clk = ~clk;
end

// initial begin
//     $dumpfile("DP_Ram.vcd"); // 將波型檔輸出
//     $dumpvars;
// end



// Initial values
initial begin
    rst_n = 0;
    write_en = 0;
    read_en = 0;
    write_addr = 0;
    read_addr = 0;
    write_data = 4'b0000;

    #10 rst_n = 1; // Release reset

    // Write some data to RAM
    #20 write_en = 1;
    write_addr = 8'h00;
    write_data = 4'b1010;
    #10 write_addr = 8'h01;
    write_data = 4'b1100;
    #10 write_addr = 8'h0A;
    write_data = 4'b0011;

    // Read data from RAM
    #20 read_en = 1;
    read_addr = 8'h00; // Read the data written at address 0
    #20 read_addr = 8'h0A; // Read the data written at address 10
    #20 read_addr = 8'hFF; // Read from an invalid address (for testing)
    
    #10 $finish; // Finish simulation
end

endmodule
