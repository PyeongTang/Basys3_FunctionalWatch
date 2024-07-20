`timescale 1ns / 1ps

module clock_div_10(
   input        wire                i_clk,
   input        wire                i_reset,
   input        wire                i_cp,
   output       wire                o_cp,
   output       wire                o_tick_posedge,
   output       wire                o_tick_negedge
);

    reg     [3 : 0]                 r_count;

    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );

    edge_detector_n                 ED_OUTPUT_TICK(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (o_cp), 
        .o_posedge                  (o_tick_posedge),
        .o_negedge                  (o_tick_negedge)
    );

    // r_count
   always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count = 0;
        end
        else if (w_negedge_tick) begin 
            if(r_count >= 10 - 1) begin
                r_count = 0;
            end
            else begin
                r_count = r_count + 1;
            end
        end
   end

   assign o_cp = (r_count < (10 / 2))  ? 0 : 1;

endmodule
///////////////////////////////////////////////////////////////////////////
module clock_div_100(
   input        wire                i_clk,
   input        wire                i_reset,
   output       wire                o_cp,
   output       wire                o_tick_posedge,
   output       wire                o_tick_negedge
);

    reg     [6 : 0]                 r_count;

    edge_detector_n                 ED_OUTPUT_TICK(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (o_cp), 
        .o_posedge                  (o_tick_posedge),
        .o_negedge                  (o_tick_negedge)
    );

    always @(posedge i_clk or posedge i_reset) begin
        if(i_reset) begin
            r_count = 0;
        end
        else begin 
            if(r_count >= 100 - 1) begin
                r_count = 0;
            end
            else begin
                r_count = r_count + 1;
            end
        end
    end

    assign o_cp    = (r_count < (100 / 2))  ? 0 : 1;

endmodule
///////////////////////////////////////////////////////////////////////////
module clock_div_1000(
   input        wire                i_clk,
   input        wire                i_reset,
   input        wire                i_cp,
   output       wire                o_cp,
   output       wire                o_tick_posedge,
   output       wire                o_tick_negedge
);

    reg     [9 : 0]                 r_count;
    wire                            w_negedge_tick;
    wire                            w_posedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );

    edge_detector_n                 ED_OUTPUT_TICK(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (o_cp), 
        .o_posedge                  (o_tick_posedge),
        .o_negedge                  (o_tick_negedge)
    );

   always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count = 0;
        end
        else if (w_negedge_tick) begin 
            if(r_count >= 1000 - 1) begin
                r_count = 0;
            end
            else begin
                r_count = r_count + 1;
            end
        end
   end

   assign o_cp = (r_count < (1000 / 2))  ? 0 : 1;
endmodule
///////////////////////////////////////////////////////////////////////////
module clock_div_58(
   input        wire                i_clk,
   input        wire                i_reset,
   input        wire                i_cp,
   output       wire                o_cp,
   output       wire                o_tick_posedge,
   output       wire                o_tick_negedge
);

    integer                         r_count;

    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );
    
    edge_detector_n                 ED_OUTPUT_TICK(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (o_cp), 
        .o_posedge                  (o_tick_posedge),
        .o_negedge                  (o_tick_negedge)
    );

   always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count = 0;
        end
        else if (w_negedge_tick) begin 
            if(r_count >= 58 - 1) begin
                r_count = 0;
            end
            else begin
                r_count = r_count + 1;
            end
        end
   end

   assign o_cp = (r_count < (58 / 2))  ? 0 : 1;

endmodule
///////////////////////////////////////////////////////////////////////////
module clock_div_60(
   input        wire                i_clk,
   input        wire                i_reset,
   input        wire                i_cp,
   output       wire                o_cp,
   output       wire                o_tick_posedge,
   output       wire                o_tick_negedge
);

    integer                         r_count;

    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );
    
    edge_detector_n                 ED_OUTPUT_TICK(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (o_cp), 
        .o_posedge                  (o_tick_posedge),
        .o_negedge                  (o_tick_negedge)
    );

   always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count = 0;
        end
        else if (w_negedge_tick) begin 
            if(r_count >= 60 - 1) begin
                r_count = 0;
            end
            else begin
                r_count = r_count + 1;
            end
        end
   end

   assign o_cp = (r_count < (60 / 2))  ? 0 : 1;

endmodule
///////////////////////////////////////////////////////////////////////////
module counter_bcd_60(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_cp,
    input       wire                i_jump,
    output      wire    [3 : 0]     o_bcd_ones,
    output      wire    [3 : 0]     o_bcd_tens
);

    reg     [3 : 0]                 r_bcd_tens;
    reg     [3 : 0]                 r_bcd_ones;

    wire                            w_tick_negedge_cp;
    wire                            w_tick_posedge_jump;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (),
        .o_negedge                  (w_tick_negedge_cp)
    );
    
    edge_detector_n                 ED_INPUT_JUMP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_jump), 
        .o_posedge                  (w_tick_posedge_jump),
        .o_negedge                  ()
    );

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_bcd_tens      <=   0;
            r_bcd_ones      <=   0;
        end
        else if(w_tick_negedge_cp) begin
            if (r_bcd_ones >= 10 - 1) begin
                if (r_bcd_tens >= 6 - 1) begin
                    r_bcd_tens <= 0;
                    r_bcd_ones <= 0;
                end
                else begin
                    r_bcd_tens <= r_bcd_tens + 1;
                    r_bcd_ones <= 0;
                end
            end
            else begin
                r_bcd_tens <= r_bcd_tens;
                r_bcd_ones <= r_bcd_ones + 1;
            end
        end
        else if (w_tick_posedge_jump) begin
            if (r_bcd_tens >= 6 - 1) begin
                r_bcd_tens <= 0;
            end
            else begin
                r_bcd_tens <= r_bcd_tens + 1;
            end
        end
     end

    assign o_bcd_ones   =   r_bcd_ones;
    assign o_bcd_tens   =   r_bcd_tens;

endmodule
///////////////////////////////////////////////////////////////////////////
module counter_bcd_99(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_cp,

    output      wire    [3 : 0]     o_bcd_ones,
    output      wire    [3 : 0]     o_bcd_tens
);

    reg     [3 : 0]                 r_bcd_tens;
    reg     [3 : 0]                 r_bcd_ones;
    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_bcd_tens      <=   0;
            r_bcd_ones      <=   0;
        end
        else if(w_negedge_tick) begin
            if (r_bcd_ones >= 10 - 1) begin
                if (r_bcd_tens >= 10 - 1) begin
                    r_bcd_tens <= 0;
                    r_bcd_ones <= 0;
                end
                else begin
                    r_bcd_tens <= r_bcd_tens + 1;
                    r_bcd_ones <= 0;
                end
            end
            else begin
                r_bcd_tens <= r_bcd_tens;
                r_bcd_ones <= r_bcd_ones + 1;
            end
        end
        else begin
        end
     end

    assign o_bcd_ones   =   r_bcd_ones;
    assign o_bcd_tens   =   r_bcd_tens;

endmodule
///////////////////////////////////////////////////////////////////////////
module loadable_counter_bcd_60(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_load,    
    input       wire    [3 : 0]     i_bcd_tens,
    input       wire    [3 : 0]     i_bcd_ones,

    input       wire                i_cp,
    output      wire    [3 : 0]     o_bcd_ones,
    output      wire    [3 : 0]     o_bcd_tens
);

    reg     [3 : 0]                 r_bcd_tens;
    reg     [3 : 0]                 r_bcd_ones;

    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_bcd_tens      <=      0;
            r_bcd_ones      <=      0;
        end
        else if (i_load) begin
            r_bcd_tens      <=      i_bcd_tens;
            r_bcd_ones      <=      i_bcd_ones;
        end
        else begin
            if(w_negedge_tick) begin
                if (r_bcd_ones >= 10 - 1) begin
                    if (r_bcd_tens >= 6 - 1) begin
                        r_bcd_tens <= 0;
                        r_bcd_ones <= 0;
                    end
                    else begin
                        r_bcd_tens <= r_bcd_tens + 1;
                        r_bcd_ones <= 0;
                    end
                end
                else begin
                    r_bcd_tens <= r_bcd_tens;
                    r_bcd_ones <= r_bcd_ones + 1;
                end
            end
        end
     end

    assign o_bcd_ones   =   r_bcd_ones;
    assign o_bcd_tens   =   r_bcd_tens;

endmodule
///////////////////////////////////////////////////////////////////////////
module loadable_down_counter_bcd_60(
    input       wire                i_clk,
    input       wire                i_reset,
    input       wire                i_load,    
    input       wire    [3 : 0]     i_bcd_tens,
    input       wire    [3 : 0]     i_bcd_ones,
    input       wire                i_cp,
    output      wire    [3 : 0]     o_bcd_ones,
    output      wire    [3 : 0]     o_bcd_tens,
    output      wire                o_bcd_zero
);

    reg     [3 : 0]                 r_bcd_tens;
    reg     [3 : 0]                 r_bcd_ones;

    wire                            w_posedge_tick;
    wire                            w_negedge_tick;

    edge_detector_n                 ED_INPUT_CP(
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_cp                       (i_cp), 
        .o_posedge                  (w_posedge_tick),
        .o_negedge                  (w_negedge_tick)
    );

    always @(posedge i_clk or posedge i_reset)begin
        if(i_reset)begin
            r_bcd_tens      <=      0;
            r_bcd_ones      <=      0;
        end
        else if (i_load) begin
            r_bcd_tens      <=      i_bcd_tens;
            r_bcd_ones      <=      i_bcd_ones;
        end
        else begin
            if(w_negedge_tick) begin
                if (r_bcd_ones == 0) begin
                    if (r_bcd_tens == 0) begin
                        r_bcd_tens      <=  5;
                        r_bcd_ones      <=  9;
                    end
                    else begin
                        r_bcd_tens      <=  r_bcd_tens - 1;
                        r_bcd_ones      <=  9;
                    end
                end
                else begin
                    r_bcd_tens      <=  r_bcd_tens;
                    r_bcd_ones      <=  r_bcd_ones - 1;
                end
            end
        end
     end

    assign o_bcd_ones   =   r_bcd_ones;
    assign o_bcd_tens   =   r_bcd_tens;
    assign o_bcd_zero   =   (r_bcd_ones == 0) && (r_bcd_tens == 0);

endmodule
///////////////////////////////////////////////////////////////////////////
module timer (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_enable,
    input       wire                        i_load,
    input       wire    [15 : 0]            i_time_bcd,
    output      wire    [15 : 0]            o_time_bcd,
    output      wire                        o_time_out
);

    wire                                    w_selected_clk;
    wire                                    w_cp_usec;
    wire                                    w_cp_msec;
    wire                                    w_cp_sec;
    wire                                    w_cp_min;
    
    wire    [3 : 0]                         w_ones_sec_load;
    wire    [3 : 0]                         w_tens_sec_load;
    wire    [3 : 0]                         w_ones_min_load;
    wire    [3 : 0]                         w_tens_min_load;
    wire    [3 : 0]                         w_ones_hour_load;
    wire    [3 : 0]                         w_tens_hour_load;

    wire    [3 : 0]                         w_ones_sec;
    wire    [3 : 0]                         w_tens_sec;
    wire    [3 : 0]                         w_ones_min;
    wire    [3 : 0]                         w_tens_min;
    wire    [3 : 0]                         w_ones_hour;
    wire    [3 : 0]                         w_tens_hour;

    wire                                    w_sec_zero;
    wire                                    w_min_zero;
    wire                                    w_hour_zero;

    wire                                    w_timer_enable_q;
    wire                                    w_time_out_posedge;
    reg                                     r_time_out;
    reg                                     r_enable_z;

    // Clock Divider
    ///////////////////////////////////////////////////////////
    clock_div_100                           CLK_DIV_USEC(
        .i_clk                              (w_selected_clk),
        .i_reset                            (i_reset),
        .o_cp                               (w_cp_usec),
        .o_tick_posedge                     (),
        .o_tick_negedge                     ()
    );

    clock_div_1000                          CLK_DIV_MSEC(
        .i_clk                              (w_selected_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_cp_usec),
        .o_cp                               (w_cp_msec),
        .o_tick_posedge                     (),
        .o_tick_negedge                     ()
    );

    clock_div_1000                          CLK_DIV_SEC(
        .i_clk                              (w_selected_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_cp_msec),
        .o_cp                               (w_cp_sec),
        .o_tick_posedge                     (),
        .o_tick_negedge                     ()
    );

    // clock_div_60                            CLK_DIV_MIN(
    //     .i_clk                              (i_clk),
    //     .i_reset                            (i_reset),
    //     .i_cp                               (w_cp_sec),
    //     .o_cp                               (w_cp_min),
    //     .o_tick_posedge                     (),
    //     .o_tick_negedge                     ()
    // );
    ///////////////////////////////////////////////////////////

    // Counter
    ///////////////////////////////////////////////////////////

    loadable_down_counter_bcd_60            LDC_60_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_load                             (i_load),
        .i_bcd_tens                         (w_tens_sec_load),
        .i_bcd_ones                         (w_ones_sec_load),
        .i_cp                               (w_cp_sec),
        .o_bcd_ones                         (w_ones_min),
        .o_bcd_tens                         (w_tens_min),
        .o_bcd_zero                         (w_sec_zero)
    );

    loadable_down_counter_bcd_60            LDC_60_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_load                             (i_load),
        .i_bcd_tens                         (w_tens_min_load),
        .i_bcd_ones                         (w_ones_min_load),
        .i_cp                               (w_sec_zero),
        .o_bcd_ones                         (w_ones_min),
        .o_bcd_tens                         (w_tens_min),
        .o_bcd_zero                         (w_min_zero)
    );

    loadable_down_counter_bcd_60            LDC_60_HOUR(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_load                             (i_load),
        .i_bcd_tens                         (w_tens_hour_load),
        .i_bcd_ones                         (w_ones_hour_load),
        .i_cp                               (w_min_zero),
        .o_bcd_ones                         (w_ones_hour),
        .o_bcd_tens                         (w_tens_hour),
        .o_bcd_zero                         (w_hour_zero)
    );
    ///////////////////////////////////////////////////////////

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_enable_z <= 0;
        end
        else begin
            r_enable_z <= i_enable;
        end
    end

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_time_out <= 0;
        end
        else if (r_enable_z) begin
            if (w_hour_zero && w_min_zero && w_sec_zero) begin
                r_time_out <= 1;
            end
        end
        else begin
            r_time_out <= 0;
        end
    end
    
    assign w_selected_clk                           =   i_clk & r_enable_z & ~r_time_out;
    assign o_time_bcd                               =   {w_tens_hour, w_ones_hour, w_tens_min, w_ones_min};
    assign o_time_out                               =   r_time_out;
    assign {w_tens_hour_load, w_ones_hour_load}     =   i_time_bcd[15 -: 8];
    assign {w_tens_min_load, w_ones_min_load}       =   i_time_bcd[7  -: 8];
    assign {w_tens_sec_load, w_ones_sec_load}       =   8'h00;

endmodule
///////////////////////////////////////////////////////////////////////////
module pwm #(
    parameter   SYS_CLK_FREQ        =   100_000_000,
    parameter   PWM_FREQ            =   50,
    parameter   PWM_RESOLUTION      =   4096,
    parameter   BIT_RESOLUTION      =   12,
    parameter   CLK_DIV_FREQ        =   PWM_FREQ * PWM_RESOLUTION,
    parameter   CLK_DIV_TH          =   SYS_CLK_FREQ / CLK_DIV_FREQ
)(
    input       wire                                    i_clk,
    input       wire                                    i_reset,
    input       wire        [BIT_RESOLUTION - 1 : 0]    i_duty,
    output      wire                                    o_pwm
);
    // Frequnecy (LED Initial Setting)
    // SYS_CLK_FREQ     =   100     Mhz
    // CLK_DIV_FREQ     =   1.28    Mhz
    // PWM_FREQ         =   10      Khz
    // PWM_RESOLUTION   =   128     steps

    // SYS_CLK_FREQ     :   Clock Frequency of System
    // PWM_FREQ         :   Desired Frequency of Output PWM Pulse
    // PWM_RESOLUTION   :   Number of Steps in Voltage Level with respect to Pulse Width of Output Wave

    // 1. We need 128 time slices in each PWM period
    // 2. As target PWM_FREQ is 10Khz, Frequency of time slice is equal to 10Khz * 128 = 1.28Mhz (PWM_FREQ * PWM_RESOLUTION)
    // 3. We have SYS_CLK_FREQ, 100Mhz, we need clock divider dividing ratio of SYS_CLK_FREQ / Frequency of time slice = 78.125

    // Equation
    // TIME_SLICE_FREQ  =   PWM_FREQ * PWM_RESOLUTION
    // CLK_DIV_TH       =   SYS_CLK_FREQ / TIME_SLICE_FREQ

    // Recommended PWM Frequency
    // LED              :   10      Khz
    // DC Motor         :   100     hz
    // BLDC Motor       :   10      Khz
    // Servo Motor      :   50      hz
    // Step Motor       :   20      Khz

    reg [BIT_RESOLUTION - 1 : 0]        r_count_duty;
    integer                             r_count_freq;
    wire                                w_count_freq_negedge;
    reg                                 r_clk;
    reg                                 r_pwm;

    edge_detector_n                     ED_COUNT_freq(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (r_clk), 
        .o_posedge                      (),
        .o_negedge                      (w_count_freq_negedge)
    );

    // r_count_freq - counts upto CLK_DIV_TH
    // r_clk - toggle of r_count_freq, w_count_freq_negedge makes it's tick signal
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count_freq    <=      0;
            r_clk           <=      0;
        end
        else begin
            if (r_count_freq >= CLK_DIV_TH - 1) begin
                r_count_freq    <=      0;
            end
            else begin
                r_count_freq    <=      r_count_freq + 1;
            end
            if (r_count_freq < (CLK_DIV_TH / 2)) begin
                r_clk           <=      0;
            end
            else begin
                r_clk           <=      1;
            end
        end
    end

    // r_count_duty - counts upto RESOLUTION - 1
    // r_pwm
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count_duty    <=  0;
            r_pwm           <=  0;
        end
        else if (w_count_freq_negedge) begin
            // if (r_count_duty >= PWM_RESOLUTION - 1) begin
            //     r_count_duty <= 0;
            // end
            // else begin
                if (r_count_duty < i_duty) begin
                    r_pwm       <=  1;
                end
                else begin
                    r_pwm       <=  0;
                end
                r_count_duty    <=  r_count_duty + 1;
            // end
        end
    end

    assign o_pwm    = r_pwm;

endmodule
///////////////////////////////////////////////////////////////////////////