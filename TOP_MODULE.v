module top (
    input wire clk,          // System clock
    input wire reset,        // System reset
    inout wire i2c_sda,      // I2C data line
    output wire i2c_scl,     // I2C clock line
    output wire lcd_rs,      // LCD register select
    output wire lcd_rw,      // LCD read/write
    output wire lcd_en,      // LCD enable
    output wire [7:0] lcd_data // LCD data lines
);

    // Internal signals
    wire [15:0] heart_rate;
    wire [15:0] spo2;

    // MAX30100 interface instantiation
    max30100_interface max30100_inst (
        .clk(clk),
        .reset(reset),
        .heart_rate(heart_rate),
        .spo2(spo2),
        .sda(i2c_sda),
        .scl(i2c_scl)
    );

    // LCD controller instantiation
    lcd_controller lcd_inst (
        .clk(clk),
        .reset(reset),
        .heart_rate(heart_rate),
        .spo2(spo2),
        .rs(lcd_rs),
        .rw(lcd_rw),
        .en(lcd_en),
        .data(lcd_data)
    );

endmodule
