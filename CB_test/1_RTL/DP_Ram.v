/* 
实现一个深度为8bit，位宽为4bit的双端口RAM，
数据全部初始化为0000。
具有两组端口，分别用于读数据和写数据，
重要:读写操作可以同时进行。
当读数据read_en有效时，read_addr、read_data，并输出；
当写数据write_en有效时，write_addr、write-data，向对应位置写入相应的数据。 
*/

`timescale 1ns/1ns
module ram_mod(
	input clk,
	input rst_n, // asy、low-active
	
	input write_en,
	input [7:0]write_addr,
	input [3:0]write_data,
	
	input read_en,
	input [7:0]read_addr,
	output reg [3:0]read_data
);

integer i;

reg [3:0] dp_ram [255:0];


// write
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for ( i=0 ; i<256; i=i+1 ) begin
            dp_ram[i] <= 0;
        end
    end
    else if(write_en) dp_ram[write_addr] <= write_data;
end

// read
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) read_data <= 4'd0;
    else if(read_en) read_data <= dp_ram[read_addr];
end

endmodule