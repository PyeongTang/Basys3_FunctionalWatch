`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////
module T_flip_flop_n(
    input       wire    i_clk,
    input       wire    i_reset,
    input       wire    i_t,
    output      wire    o_q,
    output      wire    o_q_bar
);
    
    reg r_q;
    always @(negedge i_clk, posedge i_reset)begin
        if (i_reset) begin
           r_q <= 0; 
        end
        else begin
            if (i_t) begin
                r_q <= ~r_q; 
            end
            else begin
                r_q <= r_q;
            end
        end
    end
    assign o_q = r_q;
    assign o_q_bar = ~r_q;
endmodule
//////////////////////////////////////////////////////////////////////
module T_flip_flop_p(
    input       wire    i_clk,
    input       wire    i_reset,
    input       wire    i_t,
    output      wire    o_q,
    output      wire    o_q_bar
);
    
    reg r_q;
    always @(posedge i_clk, posedge i_reset)begin
        if (i_reset) begin
           r_q <= 0; 
        end
        else begin
            if (i_t) begin
                r_q <= ~r_q; 
            end
            else begin
                r_q <= r_q;
            end
        end
    end
    assign o_q = r_q;
    assign o_q_bar = ~r_q;
endmodule
//////////////////////////////////////////////////////////////////////
module up_counter_asyc(
    input i_clk, i_reset,
    output [3:0] count
);

    T_flip_flop_n T0(.i_clk(i_clk), .i_reset(i_reset), .t(1), .q(count[0]));
    T_flip_flop_n T1(.i_clk(count[0]), .i_reset(i_reset), .t(1), .q(count[1]));
    T_flip_flop_n T2(.i_clk(count[1]), .i_reset(i_reset), .t(1), .q(count[2]));
    T_flip_flop_n T3(.i_clk(count[2]), .i_reset(i_reset), .t(1), .q(count[3]));

endmodule
//////////////////////////////////////////////////////////////////////
module down_counter_asyc(
    input i_clk, i_reset,
    output [3:0] count
);

    T_flip_flop_p T0(.i_clk(i_clk), .i_reset(i_reset), .t(1), .q(count[0]));
    T_flip_flop_p T1(.i_clk(count[0]), .i_reset(i_reset), .t(1), .q(count[1]));
    T_flip_flop_p T2(.i_clk(count[1]), .i_reset(i_reset), .t(1), .q(count[2]));
    T_flip_flop_p T3(.i_clk(count[2]), .i_reset(i_reset), .t(1), .q(count[3]));

endmodule
//////////////////////////////////////////////////////////////////////
module upDownCounter(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_enable,
    input       wire                i_up_down,
    output      wire     [3 : 0]    o_count
);

    reg [3 : 0]  r_count;
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_count <= 0;
        end
        else if (i_enable) begin
            if (i_up_down) begin
                r_count <= r_count + 1;
            end
            else begin
                r_count <= r_count - 1;
            end
        end
    end
    assign o_count = r_count;

endmodule
//////////////////////////////////////////////////////////////////////
module upDownBCDCounter(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_enable,
    input       wire                i_up_down,
    output      wire    [3 : 0]     o_count
);

    reg [3 : 0] r_count;
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_count <= 0;
        end
        else if (i_enable) begin
            if(i_up_down)begin
                if (r_count >= 9) begin
                    r_count <= 0;
                end
                else begin
                    r_count <= r_count + 1;
                end
            end
            else begin
                if(r_count == 0) begin
                    r_count <= 9;
                end
                else begin
                    r_count <= r_count - 1;
                end
            end
        end
    end

    assign o_count = r_count;
endmodule
//////////////////////////////////////////////////////////////////////
module ringCounter(
    input       wire                i_clk,
    input       wire                i_reset,
    output      wire    [3 : 0]     o_led
);
    
    reg [3 : 0] r_led;
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_led <= 4'b0001;
        end
        else begin
            if (r_led == 4'b1000) begin
                r_led <= 4'b0001;
            end
            else begin
                r_led <= {r_led[2 : 0], 1'b0};
            end
        end
    end
    assign o_led = r_led;
endmodule
//////////////////////////////////////////////////////////////////////
module edge_detector_n(
    input       wire        i_clk,
    input       wire        i_reset,
    input       wire        i_cp,
    output      wire        o_posedge,
    output      wire        o_negedge
);

    reg r_cp;
    reg r_cp_z;

    always @(negedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_cp    <= 0;
            r_cp_z  <= 0;
        end
        else begin
            r_cp    <= i_cp;
            r_cp_z  <= r_cp;
        end
    end
    
    assign o_posedge    =   r_cp     &   ~r_cp_z;
    assign o_negedge    =   ~r_cp    &   r_cp_z;
endmodule
//////////////////////////////////////////////////////////////////////
module edge_detector_p(
    input       wire        i_clk,
    input       wire        i_reset,
    input       wire        i_cp,
    output      wire        o_posedge,
    output      wire        o_negedge
);

    reg r_cp;
    reg r_cp_z;

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_cp    <= 0;
            r_cp_z  <= 0;
        end
        else begin
            r_cp    <= i_cp;
            r_cp_z  <= r_cp;
        end
    end
    
    assign o_posedge    =   r_cp     &   ~r_cp_z;
    assign o_negedge    =   ~r_cp    &   r_cp_z;
endmodule
//////////////////////////////////////////////////////////////////////
module ringCounterFnd(
    input       wire                i_clk,
    input       wire                i_reset,
    output      wire    [3 : 0]     o_fnd_sel
);
    
    reg     [16 : 0]                r_delay_counter;
    reg     [3 : 0]                 r_fnd_sel;
    wire                            w_delay_counter_posedge;
    
    edge_detector_n                 ED_DELAY_COUNTER(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (r_delay_counter[16]),
        .o_posedge                  (w_delay_counter_posedge),
        .o_negedge                  ()
    );

    always @(posedge i_clk) begin
        r_delay_counter <= r_delay_counter + 1;
    end
    
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_fnd_sel <= 4'b1110;
        end
        else if (w_delay_counter_posedge) begin
            if (r_fnd_sel == 4'b0111) begin
                r_fnd_sel <= 4'b1110;
            end
            else begin
                r_fnd_sel <= {r_fnd_sel[2 : 0], 1'b1};
            end
        end
    end

    assign o_fnd_sel = r_fnd_sel;
endmodule
//////////////////////////////////////////////////////////////////////
module ringCounterLed(
    input       wire                i_clk,
    input       wire                i_reset,
    output      wire    [15 : 0]    o_led
);
    
    reg     [15 : 0]                r_led;
    reg     [20 : 0]                r_delay_counter;
    wire                            w_delay_counter_posedge;

    always @(posedge i_clk) begin
        r_delay_counter <= r_delay_counter + 1;
    end
    
    edge_detector_n     ED_DELAY_COUNTER(
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_cp           (r_delay_counter[20]),
        .o_posedge      (w_delay_counter_posedge)
    );
    
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_led <= 16'b0000_0000_0000_0001;
        end
        else if (w_delay_counter_posedge) begin
            r_led <= {r_led[14 : 0], r_led[15]};
        end
    end
    assign o_led = r_led;

endmodule
//////////////////////////////////////////////////////////////////////
module shift_register_SISO_n(
    input i_clk, i_reset,
    input d, 
    output q
);

    reg [3:0] siso_reg;
    
    always @(negedge i_clk or posedge i_reset)begin
        if(i_reset) siso_reg <= 0;
        else begin
            siso_reg[3] <= d;
            siso_reg[2] <= siso_reg[3];
            siso_reg[1] <= siso_reg[2];
            siso_reg[0] <= siso_reg[1];
        end
    end
    
    assign q = siso_reg[0];

endmodule
//////////////////////////////////////////////////////////////////////
module shift_register_SIPO_n(
    input i_clk, i_reset,
    input d, rd_en,
    output [3:0] q
);

    reg [3:0] sipo_reg;
    
    always @(negedge i_clk or posedge i_reset)begin
        if(i_reset)sipo_reg = 0;
        else sipo_reg = {d, sipo_reg[3:1]};
    end
    
    assign q = rd_en ? 4'bz : sipo_reg;
endmodule
//////////////////////////////////////////////////////////////////////
module shift_registerr_PISO(
    input i_clk, i_reset,
    input [3:0] d,
    input shift_load,
    output q
);
    
    reg [3:0] piso_reg;
    
    always @(posedge i_clk, posedge i_reset)begin
        if(i_reset)piso_reg = 0;
        else begin
            if(shift_load) piso_reg = {1'b0, piso_reg[3:1]};
            else piso_reg = d;
        end
    end
    
    assign q = piso_reg[0]; 
endmodule
//////////////////////////////////////////////////////////////////////
module register_Nbit_n #(parameter N = 8) (
    input [N-1:0] d,
    input i_clk,
    input i_reset,
    input wr_en, rd_en,
    output [N-1:0] q
);

    reg [N-1:0] register;
    always @(negedge i_clk or posedge i_reset)begin
        if(i_reset)register = 0;
        else if(wr_en) register = d;
    end
    assign q = rd_en ? register : 'bz;
endmodule
//////////////////////////////////////////////////////////////////////
module sram_8bit_1024(
    input i_clk, 
    input wr_en, rd_en,
    input [9:0] addr,
    inout [7:0] data
);
    
    reg [7:0] mem [0:1023];
    
    always @(posedge i_clk)begin
        if(wr_en) mem[addr] = data;
    end

    assign data = rd_en ? mem[addr] : 'bz;
endmodule
//////////////////////////////////////////////////////////////////////
module button2Buzz #(
    parameter                           ACTIVE  =   1,
    parameter                           NOTE    =   20'h5D2EF
) (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_btn,
    output      wire                    o_buzz_clk
);

    wire                                w_btn_posedge;
    wire                                w_btn_negedge;

    wire                                w_q;

    buttonControl                       BTN_UP_POSEDGE(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_btn                          (i_btn),
        .o_btn_posedge                  (w_btn_posedge),
        .o_btn_negedge                  (w_btn_negedge)
    );

    T_flip_flop_n                       T_FF(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_t                            (w_t),
        .o_q                            (w_q),
        .o_q_bar                        ()
    );

    buzzerControl                       #(
        .ACTIVE                         (ACTIVE),
        .NOTE                           (NOTE)
    )BUZZ(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_enable                       (w_q),
        .o_buzz_clk                     (o_buzz_clk)
    );
    
    assign w_t = w_btn_posedge | w_btn_negedge;
endmodule
/////////////////////////////////////////////////////////////////////////////////
module long_key_detector (
    input       wire        i_clk,
    input       wire        i_reset,
    input       wire        i_cp,       // Level (Q of T FF, after buttonControl)
    output      wire        o_long_key, // Edge
    output      wire        o_short_key // Edge
);

    localparam  [25 : 0]    LONG_KEY_TH = 26'h2FAF080; // .5 sec

    reg [25 : 0]            r_count;
    reg                     r_long_key;
    reg                     r_long_key_z;
    reg                     r_long_key_zz;
    wire                    w_short_key;

    edge_detector_n         ED_OUTPUT_LONG_KEY(
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_cp               (r_long_key),
        .o_posedge          (o_long_key),
        .o_negedge          ()
    );

    edge_detector_n         ED_OUTPUT_SHORT_KEY(
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_cp               (i_cp),
        .o_posedge          (),
        .o_negedge          (w_short_key)
    );

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count     <= 0;
            r_long_key  <= 0;
        end
        else begin
            if (i_cp) begin
                if (r_count >= LONG_KEY_TH) begin
                    r_count      <= 0;
                    r_long_key   <= 1;
                end
                else begin
                    r_count <= r_count + 1;
                end
            end
            else begin
                r_count      <= 0;
                r_long_key   <= 0;
            end
        end
    end

    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_long_key_z <= 0;
            r_long_key_zz <= 0;
        end
        else begin
            r_long_key_z <= r_long_key;
            r_long_key_zz <= r_long_key_z;
        end
    end

    assign o_short_key = ~r_long_key_zz & w_short_key;
endmodule
////////////////////////////////////////////////////////////////////////////////////
module functionalFan7SegSpinner(
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire        [3 : 0]     i_fan_power,
    output      wire        [7 : 0]     o_fnd_value
);

    parameter                           POWOFF      =       4'b0001;
    parameter                           POWLOW      =       4'b0010;
    parameter                           POWMID      =       4'b0100;
    parameter                           POWMAX      =       4'b1000;
    
    reg     [7  : 0]                    r_fnd_value;
    reg     [23 : 0]                    r_clk_div;
    wire                                w_select_speed;

    wire                                w_spin_fan_low;
    wire                                w_spin_fan_mid;
    wire                                w_spin_fan_max;

    wire                                w_spin_fan_low_posedge;
    
    edge_detector_n                     ED_CLK_DIV_SPIN_LOW(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_spin_fan_low),
        .o_posedge                      (w_spin_fan_low_posedge),
        .o_negedge                      ()
    );
    
    edge_detector_n                     ED_CLK_DIV_SPIN_MID(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_spin_fan_mid),
        .o_posedge                      (w_spin_fan_mid_posedge),
        .o_negedge                      ()
    );
    
    edge_detector_n                     ED_CLK_DIV_SPIN_MAX(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_spin_fan_max),
        .o_posedge                      (w_spin_fan_max_posedge),
        .o_negedge                      ()
    );

    //abcd_efgp
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_clk_div <= 0;
        end
        else if (i_fan_power != POWOFF) begin
            r_clk_div <= r_clk_div + 1;
        end
    end
    
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_fnd_value <= 8'b0111_1111;
        end
        else begin
            if (w_select_speed) begin
                if (r_fnd_value == 8'b1111_1011) begin
                    r_fnd_value <= 8'b0111_1111;
                end
                else begin
                    r_fnd_value <= {r_fnd_value[0], r_fnd_value[7 : 1]};
                end
            end
        end
    end

    assign o_fnd_value    = (i_fan_power != POWOFF) ? r_fnd_value : 8'b0111_1111;

    assign w_select_speed = (i_fan_power == POWMAX) ? (w_spin_fan_max_posedge) :
                            (i_fan_power == POWMID) ? (w_spin_fan_mid_posedge) :
                            (i_fan_power == POWLOW) ? (w_spin_fan_low_posedge) : 0;

    assign w_spin_fan_max = r_clk_div[21];
    assign w_spin_fan_mid = r_clk_div[22];
    assign w_spin_fan_low = r_clk_div[23];

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////
module ultra2Servo (
    input clk, reset_p,
    input mode, // 1 : ONEHOT 0 : 3-3
    input [8:0] distance_l,
    input [8:0] distance_m,
    input [8:0] distance_r,
    output [11:0] duty
    );

    localparam                          DETERMINE_STATE_DELAY_BIT = 18;

    parameter                           SERVO_MAX               =   12'd516;
    parameter                           SERVO_RIGHT             =   12'd411;
    parameter                           SERVO_NEUTRAL           =   12'd307;
    parameter                           SERVO_LEFT              =   12'd205;
    parameter                           SERVO_MIN               =   12'd102;

    wire                                w_left_detect;
    wire                                w_middle_detect;
    wire                                w_right_detect;

    reg [11 : 0]                        r_duty;

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            r_duty <= SERVO_NEUTRAL;
        end
        else begin
            case ({w_left_detect, w_middle_detect, w_right_detect})
            
                3'b000      : begin
                    r_duty  <= r_duty;
                end

                3'b001      :   begin
                    if (mode) begin
                        r_duty  <= SERVO_RIGHT;
                    end
                    else begin
                        r_duty  <= SERVO_MAX;
                    end
                end

                3'b010      :   begin
                    r_duty  <= SERVO_NEUTRAL;
                end

                3'b011      :   begin
                    if (mode)
                        r_duty  <= r_duty;
                    else
                        r_duty <= SERVO_RIGHT;
                end

                3'b100      :   begin
                    if (mode)
                        r_duty <= SERVO_LEFT;
                    else
                        r_duty  <= SERVO_MIN;
                end

                3'b101      :   begin
                    r_duty  <=  r_duty;
                end

                3'b110      :   begin
                    if (mode)
                        r_duty <= r_duty;
                    else
                        r_duty  <=  SERVO_LEFT;
                end

                3'b111      :   begin
                    r_duty  <=  r_duty;
                end

                default     :   begin
                    r_duty  <=  r_duty;
                end

            endcase
        end
    end
    
    /*
    assign state = {state_L,state_M,state_R};
    assign w_determine_state = r_clk_div[DETERMINE_STATE_DELAY_BIT];


    assign duty =   (position == 3'd1) ? (SERVO_MIN)        :
                    (position == 3'd2) ? (SERVO_LEFT)       :
                    (position == 3'd3) ? (SERVO_NEUTRAL)    :
                    (position == 3'd4) ? (SERVO_RIGHT)      :
                    (position == 3'd5) ? (SERVO_MAX)        : (SERVO_NEUTRAL);
    */

    assign w_left_detect    = (distance_l < 30) ? (1'b1) : (1'b0);
    assign w_middle_detect  = (distance_m < 30) ? (1'b1) : (1'b0);
    assign w_right_detect   = (distance_r < 30) ? (1'b1) : (1'b0);
    assign duty = r_duty;
endmodule