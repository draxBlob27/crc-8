`include "crc8_serial_gen.v"
`default_nettype none

module tb_crc8_serial_gen;

    reg clk = 0;
    reg rst;
    reg data_in, data_valid, last_bit;
    wire [7:0] crc_out;
    // assign = 8'd9;
    wire crc_done;
    
    initial begin
        $dumpfile("crc8_HI_decode.vcd");
        $dumpvars(0, tb_crc8_serial_gen);
    end

    initial begin
        force crc_out = 8'hFF;
        #20 release crc_out;
    end

    crc8_serial_gen uut (
        .clk        (clk),
        .rst        (rst),
        .data_in    (data_in),
        .data_valid (data_valid),
        .last_bit   (last_bit),
        .crc_out    (crc_out),
        .crc_done   (crc_done)
    );


    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;

    reg [15:0] message = 16'h48_69;
    // reg [23:0] message = 24'h48_69_EB;
    integer i;


    initial begin
        $dumpfile("tb_crc8_serial_gen.vcd");
        $dumpvars(0, tb_crc8_serial_gen);

        $monitor("%h | %h", crc_out, uut.crc_reg);

        rst = 1;
        data_valid = 0;
        #20 rst = 0;

        @(posedge clk);
        data_valid = 1;

        for (i = 0; i < 16; i = i + 1) begin
            data_in = message[15 - i];
            last_bit = (i == 15);
            @(posedge clk);
        end

        // for (i = 0; i < 24; i = i + 1) begin
        //     data_in = message[23 - i];
        //     last_bit = (i == 23);
        //     @(posedge clk);
        // end

        data_valid = 0;
        #50;
        $finish;
    end

endmodule
`default_nettype wire