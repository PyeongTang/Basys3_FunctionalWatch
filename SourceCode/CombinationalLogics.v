`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////
module decoder7Seg(
    input       wire        [3 : 0]     i_hex_value,
    output      wire        [7 : 0]     o_fnd_value
);
    
    reg [7 : 0] r_fnd_value;

    //abcd_efgp  
    always @(i_hex_value)begin
        case(i_hex_value)
            4'h0    : r_fnd_value = 8'b0000_0011;  // 0
            4'h1    : r_fnd_value = 8'b1001_1111;  // 1
            4'h2    : r_fnd_value = 8'b0010_0101;  // 2
            4'h3    : r_fnd_value = 8'b0000_1101;  // 3
            4'h4    : r_fnd_value = 8'b1001_1001;  // 4
            4'h5    : r_fnd_value = 8'b0100_1001;  // 5
            4'h6    : r_fnd_value = 8'b0100_0001;  // 6
            4'h7    : r_fnd_value = 8'b0001_1111;  // 7
            4'h8    : r_fnd_value = 8'b0000_0001;  // 8
            4'h9    : r_fnd_value = 8'b0001_1001;  // 9
            4'hA    : r_fnd_value = 8'b0001_0001;  // A
            4'hB    : r_fnd_value = 8'b1100_0001;  // b
            4'hC    : r_fnd_value = 8'b0110_0011;  // C
            4'hD    : r_fnd_value = 8'b1000_0101;  // d
            4'hE    : r_fnd_value = 8'b0110_0001;  // E
            4'hF    : r_fnd_value = 8'b0111_0001;  // F
            default : r_fnd_value = 8'b1111_1101;  // Middle Bar (Error)
        endcase
    end

    assign o_fnd_value = r_fnd_value;

endmodule
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
module decoder_7seg(
    input       wire        [3 : 0]     i_hex_value,
    output      wire        [7 : 0]     o_fnd_value
);
    
    reg [7 : 0] r_fnd_value;

    //abcd_efgp  
    always @(i_hex_value)begin
        case(i_hex_value)
            4'h0    : r_fnd_value = 8'b0000_0011;  // 0
            4'h1    : r_fnd_value = 8'b1001_1111;  // 1
            4'h2    : r_fnd_value = 8'b0010_0101;  // 2
            4'h3    : r_fnd_value = 8'b0000_1101;  // 3
            4'h4    : r_fnd_value = 8'b1001_1001;  // 4
            4'h5    : r_fnd_value = 8'b0100_1001;  // 5
            4'h6    : r_fnd_value = 8'b0100_0001;  // 6
            4'h7    : r_fnd_value = 8'b0001_1111;  // 7
            4'h8    : r_fnd_value = 8'b0000_0001;  // 8
            4'h9    : r_fnd_value = 8'b0001_1001;  // 9
            4'hA    : r_fnd_value = 8'b0001_0001;  // A
            4'hB    : r_fnd_value = 8'b1100_0001;  // b
            4'hC    : r_fnd_value = 8'b0110_0011;  // C
            4'hD    : r_fnd_value = 8'b1000_0101;  // d
            4'hE    : r_fnd_value = 8'b0110_0001;  // E
            4'hF    : r_fnd_value = 8'b0111_0001;  // F
            default : r_fnd_value = 8'b1111_1101;  // Middle Bar (Error)
        endcase
    end

    assign o_fnd_value = r_fnd_value;

endmodule
///////////////////////////////////////////////////////////////////////////////
module bin2Dec(
        input       wire        [11 : 0]        i_bin,
        output      wire        [15 : 0]        o_bcd
    );

    reg [3 : 0] i;
    reg [15 : 0] r_bcd;

    always @(*) begin
        r_bcd = 0;
        for (i = 0; i < 12; i = i + 1)begin
            r_bcd = {r_bcd[14:0], i_bin[11-i]};
            if(i < 11 && r_bcd[3:0] > 4)    r_bcd[3:0]      =   r_bcd[3:0]   + 3;
            if(i < 11 && r_bcd[7:4] > 4)    r_bcd[7:4]      =   r_bcd[7:4]   + 3;
            if(i < 11 && r_bcd[11:8] > 4)   r_bcd[11:8]     =   r_bcd[11:8]  + 3;
            if(i < 11 && r_bcd[15:12] > 4)  r_bcd[15:12]    =   r_bcd[15:12] + 3;
        end
    end
    assign o_bcd = r_bcd;
    
endmodule
//////////////////////////////////////////////////////////////////////////////
module fanFndSelector (
    input           wire                        i_reset,
    input           wire                        i_functionalFan_enable,
    input           wire        [3 : 0]         i_fnd_sel,
    input           wire        [3 : 0]         i_state_timer,
    input           wire        [7 : 0]         i_fnd_spin_decoder,
    input           wire        [7 : 0]         i_fnd_timer,
    output          wire        [7 : 0]         o_fnd
);
    localparam [3 : 0]                          STATE_NO_SET      = 4'b0001;
    localparam [3 : 0]                          STATE_TIME_SET_1H = 4'b0010;
    localparam [3 : 0]                          STATE_TIME_SET_3H = 4'b0100;
    localparam [3 : 0]                          STATE_TIME_SET_5H = 4'b1000;

    localparam [7 : 0]                          SEG_OFF = 8'b1111_1111;
    localparam [7 : 0]                          SEG_MID = 8'b1111_1101;

    reg [7 : 0]                                 r_fnd;

    always @(*) begin
        if (i_reset) begin
            r_fnd = SEG_OFF;
        end
        else begin
            if (!i_functionalFan_enable) begin
                r_fnd = SEG_MID;
            end
            else begin
                if (i_state_timer == STATE_NO_SET) begin
                    if (i_fnd_sel == 4'b0111) begin
                        r_fnd = i_fnd_spin_decoder;
                    end
                    else begin
                        r_fnd = SEG_OFF;
                    end
                end
                else begin
                    if (i_fnd_sel == 4'b0111) begin
                        r_fnd = i_fnd_spin_decoder;
                    end
                    else begin
                        r_fnd = i_fnd_timer;
                    end
                end
            end
        end
    end

    assign o_fnd = r_fnd;
    
endmodule