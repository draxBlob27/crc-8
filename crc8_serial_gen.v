module crc8_serial_gen (
    input clk, rst, data_in, data_valid, last_bit,
    output reg [7:0] crc_out,
    output reg crc_done
);
    localparam IDLE = 2'b00;
    localparam PROCESS = 2'b01;
    localparam DONE = 2'b10;

    localparam Poly = 8'h49;
    localparam Init = 8'h00;
    localparam XorOut = 8'hff;

    reg [7:0] crc_reg = Init;
    reg [1:0] state, next_state;
    wire [7:0] crc_next;

    assign feedback = crc_reg[7] ^ data_in;
    assign crc_next = {crc_reg[6:0], 1'b0} ^ (feedback ? Poly : 8'h00);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (data_valid)
                    next_state = PROCESS;
            end

            PROCESS: begin
                if (data_valid && last_bit)
                    next_state = DONE;
            end

            DONE: begin
                if (!data_valid)             
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            crc_reg <= Init;
            crc_out <= 8'd0;
            crc_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    crc_reg <= Init;
                end
                PROCESS: begin
                    if (data_valid)
                        crc_reg <= crc_next;
                end
                DONE: begin
                    // crc_reg   <= crc_next;               
                    crc_out   <= crc_next ^ XorOut;    
                    crc_done <= 1'b1;
                end
                default: begin 
                    crc_reg <= Init;
                end
            endcase
        end
    end
    
endmodule

