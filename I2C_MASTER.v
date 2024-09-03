module i2c_master (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [6:0] address,
    input wire [7:0] data_in,
    output reg done,
    output reg [7:0] data_out,
    inout wire sda,
    output wire scl
);
    // State encoding
    localparam IDLE  = 3'b000,
               START = 3'b001,
               ADDR  = 3'b010,
               WRITE = 3'b011,
               READ  = 3'b100,
               STOP  = 3'b101;

    reg [2:0] state, next_state;

    // Clock division for SCL generation
    reg [15:0] clk_div;
    reg scl_en;

    // Internal signals
    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    reg sda_out;
    reg sda_dir; // 1 = output, 0 = input

    assign scl = clk_div[15];
    assign sda = (sda_dir) ? sda_out : 1'bz;

    // Clock division logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_div <= 16'd0;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            sda_out <= 1;
            sda_dir <= 1;
            bit_cnt <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        done = 0;
        case (state)
            IDLE: begin
                done = 0;
                if (start) begin
                    next_state = START;
                end
            end
            START: begin
                sda_out = 0; // Start condition
                next_state = ADDR;
            end
            ADDR: begin
                if (bit_cnt < 7) begin
                    sda_out = address[6-bit_cnt];
                    bit_cnt = bit_cnt + 1;
                end else begin
                    bit_cnt = 0;
                    sda_dir = 0; // Switch to input for ACK
                    next_state = WRITE;
                end
            end
            WRITE: begin
                sda_dir = 1;
                if (bit_cnt < 8) begin
                    sda_out = data_in[7-bit_cnt];
                    bit_cnt = bit_cnt + 1;
                end else begin
                    bit_cnt = 0;
                    sda_dir = 0; // Switch to input for ACK
                    next_state = STOP;
                end
            end
            READ: begin
                sda_dir = 0; // Set to input mode for reading
                if (bit_cnt < 8) begin
                    data_out[7-bit_cnt] = sda; // Read data bit
                    bit_cnt = bit_cnt + 1;
                end else begin
                    bit_cnt = 0;
                    next_state = STOP;
                end
            end
            STOP: begin
                sda_out = 1;
                sda_dir = 1;
                done = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule
