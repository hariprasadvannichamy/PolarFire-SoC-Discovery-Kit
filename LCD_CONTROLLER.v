module lcd_controller (
    input wire clk,
    input wire reset,
    input wire [15:0] heart_rate,
    input wire [15:0] spo2,
    output reg rs,
    output reg rw,
    output reg en,
    output reg [7:0] data
);

    // LCD initialization and data display logic
    // Convert heart_rate and spo2 to ASCII and send to LCD

    // Simplified example: Display "HR: 000 SpO2: 00"
    reg [3:0] state;
    reg [3:0] next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            0: begin
                rs = 1'b0; // Command mode
                rw = 1'b0; // Write
                en = 1'b1; // Enable
                data = 8'h38; // Function set: 8-bit, 2 lines
                next_state = 1;
            end
            1: begin
                en = 1'b0; // Disable
                next_state = 2;
            end
            2: begin
                rs = 1'b1; // Data mode
                en = 1'b1;
                data = 8'h48; // ASCII 'H'
                next_state = 3;
            end
            3: begin
                en = 1'b0;
                next_state = 4;
            end
            4: begin
                rs = 1'b1;
                en = 1'b1;
                data = 8'h52; // ASCII 'R'
                next_state = 5;
            end
            5: begin
                en = 1'b0;
                next_state = 6;
            end
            6: begin
                rs = 1'b1;
                en = 1'b1;
                data = 8'h20; // ASCII ' '
                next_state = 7;
            end
            7: begin
                en = 1'b0;
                next_state = 8;
            end
            // Continue for displaying heart rate and SpO2...
            default: next_state = 0;
        endcase
    end

endmodule
