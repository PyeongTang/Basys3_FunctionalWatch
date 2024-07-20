`timescale 1ns / 1ps
 
module top_decoder7Seg(
    input       wire        [3 : 0]         i_sw,
    output      wire        [7 : 0]         o_seg_7,
    output      wire        [3 : 0]         o_sel
);

    decoder_7seg                            FND(
        .i_hex_value                        (i_sw),
        .o_fnd_value                        (o_seg_7)
    );

    assign o_sel = {1'b0, 1'b0, 1'b0, 1'b0};

endmodule
///////////////////////////////////////////////////////////////////
module top_fndControl (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire        [15 : 0]        i_value,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_sel
);

    fndControl                              FND_CTRL (
        .i_clk                      (i_clk),
        .i_reset                    (i_reset),
        .i_value                    (i_value),
        .o_fnd                      (o_fnd),
        .o_sel                      (o_sel)
    );

endmodule
///////////////////////////////////////////////////////////////////
module top_ringCounterLed #(
    parameter N = 16
    )(
    input       wire                        i_clk,
    input       wire                        i_reset,
    output      wire        [N - 1 : 0]     o_led
);

    ringCounterLed                          LED(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .o_led                              (o_led)
    );
    
endmodule
///////////////////////////////////////////////////////////////////
module top_loadable_watch (
    input       wire                        i_clk,
    input       wire                        i_reset, // btn Left
    input       wire                        i_btn_u_mode_sel,
    input       wire                        i_btn_c_inc_min,
    input       wire                        i_btn_r_inc_sec,
    output      wire                        o_led_set,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel
);

    // clock_div_100, 1000, 60 Clock Pulses
    wire                                    w_cp_usec;
    wire                                    w_cp_msec;
    wire                                    w_cp_sec;
    wire                                    w_cp_min;

    // loadable_counter_bcd_60 RTC Mode Wires
    wire    [3 : 0]                         w_rtc_mode_bcd_tens_min;
    wire    [3 : 0]                         w_rtc_mode_bcd_ones_min;
    wire    [3 : 0]                         w_rtc_mode_bcd_tens_sec;
    wire    [3 : 0]                         w_rtc_mode_bcd_ones_sec;
    wire    [15 : 0]                        w_rtc_4digit_value;

    // loadable_counter_bcd_60 SET Mode Wires
    wire    [3 : 0]                         w_set_mode_bcd_tens_min;
    wire    [3 : 0]                         w_set_mode_bcd_ones_min;
    wire    [3 : 0]                         w_set_mode_bcd_tens_sec;
    wire    [3 : 0]                         w_set_mode_bcd_ones_sec;
    wire    [15 : 0]                        w_set_4digit_value;

    // Selected, RTC or SET
    wire    [15 : 0]                        w_fnd_4digit_value;

    // Select Signal of Mux, RTC at Low, SET at High
    wire                                    w_tff_mode_sel;

    // Edge of Selected Signal
    wire                                    w_rtc_mode_to_set_mode; // Posedge of Selected Signal
    wire                                    w_set_mode_to_rtc_mode; // Negedge of Selected Signal

    // Button Edges
    wire                                    w_btn_u_sel_mode;
    wire                                    w_btn_r_inc_sec;
    wire                                    w_btn_c_inc_min;

    // Buttons
    //////////////////////////////////////////////////////////////
    buttonControl                           BTN_u_RTC_MODE (
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_u_mode_sel),
        .o_btn_posedge                      (w_btn_u_sel_mode),
        .o_btn_negedge                      ()
    );
    
    buttonControl                           BTN_r_SEC_MODE (
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_r_inc_sec),
        .o_btn_posedge                      (w_btn_r_inc_sec),
        .o_btn_negedge                      ()
    );
    
    buttonControl                           BTN_c_MIN_MODE (
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_c_inc_min),
        .o_btn_posedge                      (w_btn_c_inc_min),
        .o_btn_negedge                      ()
    );

    T_flip_flop_p                           MODE_SELECTOR(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_btn_u_sel_mode),
        .o_q                                (w_tff_mode_sel),
        .o_q_bar                            ()
    );

    edge_detector_p                         ED_MODE_SEL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_tff_mode_sel),
        .o_posedge                          (w_rtc_mode_to_set_mode),
        .o_negedge                          (w_set_mode_to_rtc_mode)
    );

    // Clocks
    //////////////////////////////////////////////////////////////
    clock_div_100                       CLK_DIV_USEC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .o_cp                           (w_cp_usec),
        .o_tick_posedge                 (),
        .o_tick_negedge                 ()
    );

    clock_div_1000                      CLK_DIV_MSEC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_cp_usec),
        .o_cp                           (w_cp_msec),
        .o_tick_posedge                 (),
        .o_tick_negedge                 ()
    );

    clock_div_1000                      CLK_DIV_SEC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_cp_msec),
        .o_cp                           (w_cp_sec),
        .o_tick_posedge                 (),
        .o_tick_negedge                 ()
    );

    clock_div_60                        CLK_DIV_MIN(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_inc_sec),
        .o_cp                           (w_cp_min),
        .o_tick_posedge                 (),
        .o_tick_negedge                 ()
    );

    // Counters
    //////////////////////////////////////////////////////////////
    loadable_counter_bcd_60             RTC_MIN(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_load                         (w_set_mode_to_rtc_mode),
        .i_bcd_tens                     (w_set_mode_bcd_tens_min),
        .i_bcd_ones                     (w_set_mode_bcd_ones_min),
        .i_cp                           (w_cp_min),
        .o_bcd_tens                     (w_rtc_mode_bcd_tens_min),
        .o_bcd_ones                     (w_rtc_mode_bcd_ones_min)
    );

    loadable_counter_bcd_60             RTC_SEC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_load                         (w_set_mode_to_rtc_mode),
        .i_bcd_tens                     (w_set_mode_bcd_tens_sec),
        .i_bcd_ones                     (w_set_mode_bcd_ones_sec),
        .i_cp                           (w_cp_sec),
        .o_bcd_tens                     (w_rtc_mode_bcd_tens_sec),
        .o_bcd_ones                     (w_rtc_mode_bcd_ones_sec)
    );

    loadable_counter_bcd_60             LD_MIN(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_load                         (w_rtc_mode_to_set_mode),
        .i_bcd_tens                     (w_rtc_mode_bcd_tens_min),
        .i_bcd_ones                     (w_rtc_mode_bcd_ones_min),
        .i_cp                           (w_btn_c_inc_min),
        .o_bcd_tens                     (w_set_mode_bcd_tens_min),
        .o_bcd_ones                     (w_set_mode_bcd_ones_min)
    );

    loadable_counter_bcd_60             LD_SEC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_load                         (w_rtc_mode_to_set_mode),
        .i_bcd_tens                     (w_rtc_mode_bcd_tens_sec),
        .i_bcd_ones                     (w_rtc_mode_bcd_ones_sec),
        .i_cp                           (w_btn_r_inc_sec),
        .o_bcd_tens                     (w_set_mode_bcd_tens_sec),
        .o_bcd_ones                     (w_set_mode_bcd_ones_sec)
    );

    // FND Controller
    //////////////////////////////////////////////////////////////
    fndControl                          FND_CTRL(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_value                        (w_fnd_4digit_value),
        .o_fnd                          (o_fnd),
        .o_fnd_sel                      (o_fnd_sel)
    );

    assign w_fnd_4digit_value   =   (w_tff_mode_sel) ?  (w_set_4digit_value) :
                                                        (w_rtc_4digit_value);

    assign w_set_4digit_value   =  {w_set_mode_bcd_tens_min,
                                    w_set_mode_bcd_ones_min,
                                    w_set_mode_bcd_tens_sec,
                                    w_set_mode_bcd_ones_sec};

    assign w_rtc_4digit_value   =  {w_rtc_mode_bcd_tens_min,
                                    w_rtc_mode_bcd_ones_min,
                                    w_rtc_mode_bcd_tens_sec,
                                    w_rtc_mode_bcd_ones_sec};

    assign w_inc_sec            =   (w_tff_mode_sel) ? (w_btn_r_inc_sec) : (w_cp_sec);
    assign o_led_set            =   w_tff_mode_sel;

endmodule
///////////////////////////////////////////////////////////////////
module top_stop_watch (
    input       wire                        i_clk,
    input       wire                        i_reset, // btn Left
    input       wire                        i_btn_c_mode_startStop,
    input       wire                        i_btn_r_mode_lap,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_led_pause,
    output      wire                        o_led_lap
);

    // clock_div_100, 1000, 60 Clock Pulses
    wire                                    w_cp_usec;
    wire                                    w_cp_msec;
    wire                                    w_cp_csec;
    wire                                    w_cp_sec;
    // wire                                 w_cp_min;

    wire                                    w_btn_c_mode_puase_posedge;
    wire                                    w_pause_mode_toggle;
    wire                                    w_btn_r_mode_lap_posedge;
    wire                                    w_lap_mode_toggle;

    // RTC Mode Wires
    wire    [3 : 0]                         w_rtc_mode_bcd_tens_sec;
    wire    [3 : 0]                         w_rtc_mode_bcd_ones_sec;
    wire    [3 : 0]                         w_rtc_mode_bcd_tens_csec;
    wire    [3 : 0]                         w_rtc_mode_bcd_ones_csec;
    wire    [15 : 0]                        w_rtc_4digit_value;

    // lap register
    reg     [15 : 0]                        r_lap_register;

    // Selected FND Value
    wire    [15 : 0]                        w_fnd_4digit_value;

    // Clock Selected Signal
    wire                                    w_selected_clk;


    // Buttons
    //////////////////////////////////////////////////////////////
    buttonControl                           BTN_c_START_MODE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_c_mode_startStop),
        .o_btn_posedge                      (w_btn_c_mode_puase_posedge),
        .o_btn_negedge                      ()
    );

    T_flip_flop_p                           TOGGLE_BTN_c_START_MODE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_btn_c_mode_puase_posedge),
        .o_q                                (),
        .o_q_bar                            (w_pause_mode_toggle)
    );

    buttonControl                           BTN_r_lap_MODE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_r_mode_lap),
        .o_btn_posedge                      (w_btn_r_mode_lap_posedge),
        .o_btn_negedge                      ()
    );

    T_flip_flop_p                           TOGGLE_BTN_r_lap_MODE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_btn_r_mode_lap_posedge),
        .o_q                                (w_lap_mode_toggle),
        .o_q_bar                            ()
    );

    // Clocks
    //////////////////////////////////////////////////////////////
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

    clock_div_10                            CLK_DIV_CSEC(
        .i_clk                              (w_selected_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_cp_msec),
        .o_cp                               (w_cp_csec),
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

    // Counters
    //////////////////////////////////////////////////////////////
    counter_bcd_60                          RTC_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_cp_sec),
        .o_bcd_tens                         (w_rtc_mode_bcd_tens_sec),
        .o_bcd_ones                         (w_rtc_mode_bcd_ones_sec)
    );
    
    counter_bcd_99                          RTC_CSEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_cp_csec),
        .o_bcd_tens                         (w_rtc_mode_bcd_tens_csec),
        .o_bcd_ones                         (w_rtc_mode_bcd_ones_csec)
    );

    // FND Controller
    //////////////////////////////////////////////////////////////
    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_fnd_4digit_value),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_lap_register <= {16{1'b0}};     
        end
        else begin
            if (w_btn_r_mode_lap_posedge) begin
                r_lap_register <= w_rtc_4digit_value;
            end
            else begin
                r_lap_register <= r_lap_register;
            end
        end
    end

    assign w_rtc_4digit_value   = {     w_rtc_mode_bcd_tens_sec,
                                        w_rtc_mode_bcd_ones_sec,
                                        w_rtc_mode_bcd_tens_csec,
                                        w_rtc_mode_bcd_ones_csec     };

    assign w_fnd_4digit_value   = (w_lap_mode_toggle) ? (r_lap_register) : (w_rtc_4digit_value);
   
    assign w_selected_clk       = (w_pause_mode_toggle) ? (1'b0) : (i_clk);
    assign o_led_pause          = w_pause_mode_toggle;
    assign o_led_lap            = w_lap_mode_toggle;

endmodule
///////////////////////////////////////////////////////////////////
module top_cooking_timer (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_btn_c_startStop,
    input       wire                        i_btn_u_reset_timer,
    input       wire                        i_btn_l_inc_min,
    input       wire                        i_btn_r_inc_sec,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_led_stop,
    output      wire        [3 : 0]         o_led_alarm,
    output      wire                        o_buzz_clk
);

    // Wire - Clock
    wire                                    w_cp_usec;
    wire                                    w_cp_msec;
    wire                                    w_cp_sec;
    wire                                    w_cp_min;
    wire                                    w_selected_clk;

    wire                                    w_long_key_min;
    wire                                    w_long_key_sec;

    wire                                    w_bcd_zero_sec;
    wire                                    w_bcd_zero_min;
    wire                                    w_bcd_all_zero;

    // Wire - Button
    wire                                    w_btn_c_startStop_posedge;
    wire                                    w_startStop_toggle;
    wire                                    w_startStop_toggle_posedge;

    wire                                    w_btn_u_reset_timer_posedge;

    wire                                    w_btn_l_inc_min_posedge;
    wire                                    w_btn_r_inc_sec_posedge;
    wire                                    w_btn_l_inc_min_negedge;
    wire                                    w_btn_r_inc_sec_negedge;

    wire                                    w_toggle_button_l_inc_min;
    wire                                    w_t_button_l_inc_min;

    wire                                    w_toggle_button_r_inc_sec;
    wire                                    w_t_button_r_inc_sec;

    wire                                    w_short_key_min;
    wire                                    w_short_key_sec;

    // Reg - Alarm
    reg  [3 : 0]                            r_led_alarm;
    reg                                     r_startStop;

    // Wire - BCD Value
    wire [3 : 0]                            w_set_bcd_tens_min;
    wire [3 : 0]                            w_set_bcd_tens_sec;
    wire [3 : 0]                            w_set_bcd_ones_min;
    wire [3 : 0]                            w_set_bcd_ones_sec;
    
    wire [3 : 0]                            w_rtc_bcd_tens_min;
    wire [3 : 0]                            w_rtc_bcd_tens_sec;
    wire [3 : 0]                            w_rtc_bcd_ones_min;
    wire [3 : 0]                            w_rtc_bcd_ones_sec;

    // Wire - 4 Digit Value
    wire [15 : 0]                           w_rtc_4digit_value;
    wire [15 : 0]                           w_set_4digit_value;
    wire [15 : 0]                           w_fnd_4digit_value;

    reg                                     r_buzz_clk;
    reg [25 : 0]                            r_buzz_count;

    // r_buzz_count
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_buzz_count         <=      0;
        end
        else if (r_led_alarm[0]) begin
            r_buzz_count         <=      r_buzz_count + 1;
        end
        else begin
            r_buzz_count         <=      0;
        end
    end

    // Button Center - Start/Stop Mode
    /////////////////////////////////////////////////////////////////////
    buttonControl                           BTN_c_START_STOP(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_c_startStop),
        .o_btn_posedge                      (w_btn_c_startStop_posedge),
        .o_btn_negedge                      ()
    );

    /////////////////////////////////////////////////////////////////////
    
    // Button Left - Increase Minute Value Mode
    /////////////////////////////////////////////////////////////////////
    buttonControl                           BTN_l_INC_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_l_inc_min),
        .o_btn_posedge                      (w_btn_l_inc_min_posedge),
        .o_btn_negedge                      (w_btn_l_inc_min_negedge)
    );

    T_flip_flop_n                           TOGGLE_BTN_l_INC_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_t_button_l_inc_min),
        .o_q                                (w_toggle_button_l_inc_min),
        .o_q_bar                            ()
    );

    /////////////////////////////////////////////////////////////////////
    
    // Button Right - Increase Second Value Mode
    /////////////////////////////////////////////////////////////////////
    buttonControl                           BTN_r_INC_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_r_inc_sec),
        .o_btn_posedge                      (w_btn_r_inc_sec_posedge),
        .o_btn_negedge                      (w_btn_r_inc_sec_negedge)
    );

    T_flip_flop_n                           TOGGLE_BTN_r_INC_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_t_button_r_inc_sec),
        .o_q                                (w_toggle_button_r_inc_sec),
        .o_q_bar                            ()
    );

    /////////////////////////////////////////////////////////////////////

    // Button Up - Alarm Off and Reset Timer Mode
    /////////////////////////////////////////////////////////////////////
    buttonControl                           BTN_u_RESET_TIMER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_u_reset_timer),
        .o_btn_posedge                      (w_btn_u_reset_timer_posedge),
        .o_btn_negedge                      ()
    );

    // Clock Divider
    /////////////////////////////////////////////////////////////////////
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
    /////////////////////////////////////////////////////////////////////
    
    // Loadable Up Counter
    /////////////////////////////////////////////////////////////////////
    long_key_detector                       INC_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_toggle_button_l_inc_min),
        .o_long_key                         (w_long_key_min),
        .o_short_key                        (w_short_key_min)
    );

    counter_bcd_60                          SET_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_jump                             (w_long_key_min),
        .i_cp                               (w_short_key_min),
        .o_bcd_tens                         (w_set_bcd_tens_min),
        .o_bcd_ones                         (w_set_bcd_ones_min)
    );

    long_key_detector                       INC_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_toggle_button_r_inc_sec),
        .o_long_key                         (w_long_key_sec),
        .o_short_key                        (w_short_key_sec)
    );

    counter_bcd_60                          SET_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_jump                             (w_long_key_sec),
        .i_cp                               (w_short_key_sec),
        .o_bcd_tens                         (w_set_bcd_tens_sec),
        .o_bcd_ones                         (w_set_bcd_ones_sec)
    );
    /////////////////////////////////////////////////////////////////////
        
    // Loadable Down Counter
    /////////////////////////////////////////////////////////////////////
    loadable_down_counter_bcd_60            RTC_MIN(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_load                             (w_btn_c_startStop_posedge),
        .i_bcd_tens                         (w_set_bcd_tens_min),
        .i_bcd_ones                         (w_set_bcd_ones_min),
        .i_cp                               (w_bcd_zero_sec),
        .o_bcd_tens                         (w_rtc_bcd_tens_min),
        .o_bcd_ones                         (w_rtc_bcd_ones_min),
        .o_bcd_zero                         (w_bcd_zero_min)
    );

    loadable_down_counter_bcd_60            RTC_SEC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_load                             (w_btn_c_startStop_posedge),
        .i_bcd_tens                         (w_set_bcd_tens_sec),
        .i_bcd_ones                         (w_set_bcd_ones_sec),
        .i_cp                               (w_cp_sec),
        .o_bcd_tens                         (w_rtc_bcd_tens_sec),
        .o_bcd_ones                         (w_rtc_bcd_ones_sec),
        .o_bcd_zero                         (w_bcd_zero_sec)
    );
    /////////////////////////////////////////////////////////////////////
    
    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_fnd_4digit_value),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );
    /////////////////////////////////////////////////////////////////////

    // r_startStop
    // r_led_alarm
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_startStop <= 0;
            r_led_alarm <= 0;
        end
        else if (w_btn_u_reset_timer_posedge) begin
            r_startStop <= 0;
            r_led_alarm <= 0;
        end
        else begin
            if (w_btn_c_startStop_posedge) begin
                r_startStop <= ~r_startStop;
                r_led_alarm <= 4'h0;
            end
            else if (r_startStop == 1 && w_rtc_4digit_value == 0) begin
                r_startStop <= 0;
                r_led_alarm <= 4'hF;
            end
        end
    end

    buzzerControl                           #(
        .ACTIVE                             (1)
    )                                       ALARM_BUZZER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (r_buzz_count[25]),
        .o_buzz_clk                         (o_buzz_clk)
    );

    // Long Key
    assign w_t_button_l_inc_min = w_btn_l_inc_min_posedge | w_btn_l_inc_min_negedge;
    assign w_t_button_r_inc_sec = w_btn_r_inc_sec_posedge | w_btn_r_inc_sec_negedge;

    // Pausing Timer
    assign w_selected_clk       =   (r_startStop)    ?   (i_clk)                :       (1'b0);

    // FND Driving
    assign w_fnd_4digit_value   =   (r_startStop)    ?   (w_rtc_4digit_value)   :       (w_set_4digit_value);

    assign w_set_4digit_value   =  {w_set_bcd_tens_min,
                                    w_set_bcd_ones_min,
                                    w_set_bcd_tens_sec,
                                    w_set_bcd_ones_sec};

    assign w_rtc_4digit_value   =  {w_rtc_bcd_tens_min,
                                    w_rtc_bcd_ones_min,
                                    w_rtc_bcd_tens_sec,
                                    w_rtc_bcd_ones_sec};

    // LED Driving
    assign o_led_stop           =   r_startStop;
    assign o_led_alarm          =   r_led_alarm & {4{o_buzz_clk}};

endmodule
///////////////////////////////////////////////////////////////////
module top_key_pad (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire        [3 : 0]         i_row,
    output      wire        [3 : 0]         o_col,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire        [3 : 0]         o_led_key,
    output      wire                        o_led
);

    wire [3 : 0]                            w_key_value;
    wire [15 : 0]                           w_fnd_4digit_value;

    keyPadControl                           KEYPAD_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_row                              (i_row),
        .o_col                              (o_col),
        .o_key_value                        (w_key_value),
        .o_key_valid                        (o_led)
    );

    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_fnd_4digit_value),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    assign w_fnd_4digit_value   = {4'h0, 4'h0, 4'h0, w_key_value};
    assign o_led_key            = w_key_value;

endmodule
///////////////////////////////////////////////////////////////////////////////////////
module top_DHT_11 (
    input       wire                        i_clk,
    input       wire                        i_reset,
    inout       wire                        io_data,
    input       wire                        i_sw_sensitivity,
    input       wire                        i_sw_format,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire        [6 : 0]         o_state_led,
    output      wire        [1 : 0]         o_read_state_led
);
    
    wire [7 : 0]                            w_humidity_value_hex;
    wire [11 : 0]                           w_humidity_value_bcd;

    wire [7 : 0]                            w_temperature_value_hex;
    wire [11 : 0]                           w_temperature_value_bcd;

    wire [15 : 0]                           w_fnd_4digit_value;
    
    DHT11_Control                           i_DHT_11(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .io_data                            (io_data),
        .o_humidity                         (w_humidity_value_hex),
        .o_temperature                      (w_temperature_value_hex),
        .o_state_led                        (o_state_led),
        .o_read_state_led                   (o_read_state_led)
    );

    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_fnd_4digit_value),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    bin2Dec                                 BIN_2_BCD_TEMPERATURE(
        .i_bin                              (w_temperature_value_hex),
        .o_bcd                              (w_temperature_value_bcd)
    );

    bin2Dec                                 BIN_2_BCD_HUMIDITY(
        .i_bin                              (w_humidity_value_hex),
        .o_bcd                              (w_humidity_value_bcd)
    );
                                    // H : Humidity         H : Hex
    assign w_fnd_4digit_value   =   (i_sw_sensitivity  &&  i_sw_format) ? ({8'h0, w_humidity_value_hex})        :
                                    (i_sw_sensitivity  && ~i_sw_format) ? ({4'h0, w_humidity_value_bcd})        :
                                    (~i_sw_sensitivity &&  i_sw_format) ? ({8'h0, w_temperature_value_hex})     :
                                    (~i_sw_sensitivity && ~i_sw_format) ? ({4'h0, w_temperature_value_bcd})     : (16'hFFFF);

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////
module top_HC_SR04 (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_echo,
    output      wire                        o_trigger,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire        [2 : 0]         o_state_led,
    output      wire        [1 : 0]         o_read_state_led
);

    wire    [8 : 0]                         w_distance_cm;
    wire    [11 : 0]                        w_distance_hex;
    wire    [15 : 0]                        w_distance_bcd;
    wire    [15 : 0]                        w_fnd_4digit_value;

    reg     [8 : 0]                         r_distance_cm;
    reg    [11 : 0]                         r_distance_bcd;

    HC_SR04_Control                         i_HC_SR04(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_echo                             (i_echo),
        .o_trigger                          (o_trigger),
        .o_distance                         (w_distance_cm),
        .o_state_led                        (o_state_led),
        .o_read_state_led                   (o_read_state_led)
    );

    bin_to_dec                              BIN_2_BCD_DISTANCE(
        .bin                                (w_distance_hex),
        .bcd                                (w_distance_bcd)
    );

    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_fnd_4digit_value),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_distance_cm <= 0;
        end
        else begin
            r_distance_cm <= w_distance_cm;
        end
    end

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_distance_bcd <= 0;
        end
        else begin
            r_distance_bcd <= w_distance_bcd;
        end
    end

    assign w_distance_hex = {2'h0, r_distance_cm};
    assign w_fnd_4digit_value = {7'h0, r_distance_bcd};

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////
module top_collision_detector (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_echo,
    output      wire                        o_trigger,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_buzz_clk
);
    localparam                              TH      =   9'h5;
    localparam                              DO      =   (20'h5D2EF / 2); // Count TH = 381,679
    
    wire                                    w_en_buzzer;
    wire [8 : 0]                            w_distance;

    HC_SR04_Control                         SENSOR(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_echo                             (i_echo),
        .o_trigger                          (o_trigger),
        .o_distance                         (w_distance),
        .o_state_led                        (),
        .o_read_state_led                   ()
    );

    buzzerControl                           BUZZER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (w_en_buzzer),
        .o_buzz_clk                         (o_buzz_clk)
    );

    assign w_en_buzzer = (w_distance <= TH) ? (1'b1) : (1'b0);
    
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////
module top_pwm_rgb_led (
    input       wire                        i_clk,
    input       wire                        i_reset,
    output      wire                        o_led,
    output      wire                        o_r,
    output      wire                        o_g,
    output      wire                        o_b
);

    parameter                               LED_PWM_FREQ         =   10_000;
    parameter                               LED_PWM_RESOLUTION   =   128;
    parameter                               LED_BIT_RESOLUTION   =   7;

    reg [27 : 0]    r_clk_div;
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_clk_div <= 0;
        end
        else begin
            r_clk_div <= r_clk_div + 1;
        end
    end

    pwm                                     #(
        .LED_PWM_FREQ                       (LED_PWM_FREQ),
        .LED_PWM_RESOLUTION                 (LED_PWM_RESOLUTION),
        .LED_BIT_RESOLUTION                 (LED_BIT_RESOLUTION)
    )                                       LED_DRIVER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (r_clk_div[27 -: LED_BIT_RESOLUTION]),
        .o_pwm                              (o_led)
    );

    pwm                                     #(
        .LED_PWM_FREQ                       (LED_PWM_FREQ),
        .LED_PWM_RESOLUTION                 (LED_PWM_RESOLUTION),
        .LED_BIT_RESOLUTION                 (LED_BIT_RESOLUTION)
    )                                       RGB_DRIVER_R(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (r_clk_div[27 -: LED_BIT_RESOLUTION]),
        .o_pwm                              (o_r)
    );
    
    pwm                                     #(
        .LED_PWM_FREQ                       (LED_PWM_FREQ),
        .LED_PWM_RESOLUTION                 (LED_PWM_RESOLUTION),
        .LED_BIT_RESOLUTION                 (LED_BIT_RESOLUTION)
    )                                       RGB_DRIVER_G(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (r_clk_div[26 -: LED_BIT_RESOLUTION]),
        .o_pwm                              (o_g)
    );
    
    pwm                                     #(
        .LED_PWM_FREQ                       (LED_PWM_FREQ),
        .LED_PWM_RESOLUTION                 (LED_PWM_RESOLUTION),
        .LED_BIT_RESOLUTION                 (LED_BIT_RESOLUTION)
    )                                       RGB_DRIVER_B(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (r_clk_div[25 -: 7]),
        .o_pwm                              (o_b)
    );
    
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////
module top_pwm_dc_motor (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_sw,
    output      wire        [6 : 0]         o_led_duty,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_EnA,
    output      wire                        o_input_1,
    output      wire                        o_input_2
);

    parameter                               DC_PWM_FREQ          =   100;
    parameter                               DC_PWM_RESOLUTION    =   128;
    parameter                               DC_BIT_RESOLUTION    =   7;

    wire [6 : 0]                            w_duty;
    wire [11 : 0]                           w_duty_hex;
    wire [15 : 0]                           w_duty_bcd;
    reg [31 : 0]                            r_clk_div;

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_clk_div <= 0;
        end
        else if (i_sw) begin
            r_clk_div <= r_clk_div + 1;
        end
        else begin
            r_clk_div <= 0;
        end
    end

    pwm                                     #(
        .PWM_FREQ                           (DC_PWM_FREQ),
        .PWM_RESOLUTION                     (DC_PWM_RESOLUTION),
        .BIT_RESOLUTION                     (DC_BIT_RESOLUTION)
    )                                       MOTOR_DRIVER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (w_duty),
        .o_pwm                              (o_EnA)
    );

    bin2Dec                                 BIN_2_DEC(
        .i_bin                              (w_duty_hex),
        .o_bcd                              (w_duty_bcd)
    );

    fndControl                              FND_CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_duty_bcd),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    assign w_duty               =       r_clk_div[28 -: 7];
    assign w_duty_hex           =       w_duty;
    assign o_led_duty           =       w_duty;
    assign o_input_1            =       1'b1;
    assign o_input_2            =       ~o_input_1;
    
endmodule
///////////////////////////////////////////////////////////////////////////////////////////////
module top_functionalWatch (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_btn_u,
    input       wire                        i_btn_c,
    input       wire                        i_btn_l,
    input       wire                        i_btn_r,
    input       wire                        i_btn_d,
    output      wire        [3 : 0]         o_led_alarm,
    output      wire        [2 : 0]         o_led_function,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_buzz
);

    localparam [2 : 0]                      MODE_WATCH           = 3'b001;
    localparam [2 : 0]                      MODE_STOP_WATCH      = 3'b010;
    localparam [2 : 0]                      MODE_COOKING_TIMER   = 3'b100;

    // Watch
    /////////////////////////////////////////////////////////////
    wire                                    w_watch_mode_set;
    wire                                    w_watch_inc_min;
    wire                                    w_watch_inc_sec;

    wire        [7 : 0]                     w_fnd_watch;
    wire        [3 : 0]                     w_fnd_sel_watch;

    // Stop Watch
    /////////////////////////////////////////////////////////////
    wire                                    w_stop_watch_startStop;
    wire                                    w_stop_watch_lap;

    wire        [7 : 0]                     w_fnd_stop_watch;
    wire        [3 : 0]                     w_fnd_sel_stop_watch;

    // Cooking Timer
    /////////////////////////////////////////////////////////////
    wire                                    w_cooking_timer_startStop;
    wire                                    w_cooking_timer_clear;
    wire                                    w_cooking_timer_inc_min;
    wire                                    w_cooking_timer_inc_sec;

    wire        [3 : 0]                     w_led_cooking_timer_alarm;

    wire        [7 : 0]                     w_fnd_cooking_timer;
    wire        [3 : 0]                     w_fnd_sel_cooking_timer;
    /////////////////////////////////////////////////////////////
    
    // Buzzer
    /////////////////////////////////////////////////////////////
    wire                                    w_en_button2Buzz;
    wire                                    w_buzz_alarm;
    wire                                    w_buzz_button;

    // Function Control
    /////////////////////////////////////////////////////////////
    wire                                    w_btn_c_posedge;
    wire        [2  : 0]                    w_function_select;

    buttonControl                           BTN_C(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_c),
        .o_btn_posedge                      (w_btn_c_posedge),
        .o_btn_negedge                      ()
    );

    functionalWatchControl                  CTRL(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_mode                             (w_btn_c_posedge),
        .o_function_select                  (w_function_select)
    );

    // DEVICES
    top_loadable_watch                      WATCH(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn_u_mode_sel                   (w_watch_mode_set),
        .i_btn_c_inc_min                    (w_watch_inc_min),
        .i_btn_r_inc_sec                    (w_watch_inc_sec),
        .o_led_set                          (),
        .o_fnd                              (w_fnd_watch),
        .o_fnd_sel                          (w_fnd_sel_watch)
    );

    top_stop_watch                          STOP_WATCH(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn_c_mode_startStop             (w_stop_watch_startStop),
        .i_btn_r_mode_lap                   (w_stop_watch_lap),
        .o_fnd                              (w_fnd_stop_watch),
        .o_fnd_sel                          (w_fnd_sel_stop_watch),
        .o_led_pause                        (),
        .o_led_lap                          ()
    );

    top_cooking_timer                       COOKING_TIMER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn_c_startStop                  (w_cooking_timer_startStop),
        .i_btn_u_reset_timer                (w_cooking_timer_clear),
        .i_btn_l_inc_min                    (w_cooking_timer_inc_min),
        .i_btn_r_inc_sec                    (w_cooking_timer_inc_sec),
        .o_fnd                              (w_fnd_cooking_timer),
        .o_fnd_sel                          (w_fnd_sel_cooking_timer),
        .o_led_stop                         (),
        .o_led_alarm                        (o_led_alarm),
        .o_buzz_clk                         (w_buzz_alarm)
    );
    // //////////////////

    button2Buzz                             #(
        .ACTIVE                             (1)
    )                                       BUTTON_BUZZER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (w_en_button2Buzz),
        .o_buzz_clk                         (w_buzz_button)
    );

    assign w_en_button2Buzz             =   i_btn_u | i_btn_c | i_btn_l | i_btn_r | i_btn_d;

    // Watch
    assign w_watch_mode_set             =   (w_function_select == MODE_WATCH)           ?   (i_btn_u) : (1'b0);
    assign w_watch_inc_min              =   (w_function_select == MODE_WATCH)           ?   (i_btn_l) : (1'b0);
    assign w_watch_inc_sec              =   (w_function_select == MODE_WATCH)           ?   (i_btn_r) : (1'b0);
    
    // Stop Watch
    assign w_stop_watch_startStop       =   (w_function_select == MODE_STOP_WATCH)      ?   (i_btn_u) : (1'b0);
    assign w_stop_watch_lap             =   (w_function_select == MODE_STOP_WATCH)      ?   (i_btn_r) : (1'b0);

    // Cooking Timer   
    assign w_cooking_timer_startStop    =   (w_function_select == MODE_COOKING_TIMER)   ?   (i_btn_u) : (1'b0);
    assign w_cooking_timer_clear        =                                                   (i_btn_d);
    assign w_cooking_timer_inc_min      =   (w_function_select == MODE_COOKING_TIMER)   ?   (i_btn_l) : (1'b0);
    assign w_cooking_timer_inc_sec      =   (w_function_select == MODE_COOKING_TIMER)   ?   (i_btn_r) : (1'b0);

    // FND
    assign o_fnd                        =   (w_function_select == MODE_WATCH)           ?   (w_fnd_watch)               :
                                            (w_function_select == MODE_STOP_WATCH)      ?   (w_fnd_stop_watch)          :
                                            (w_function_select == MODE_COOKING_TIMER)   ?   (w_fnd_cooking_timer)       :   8'hFF;

    // FND select
    assign o_fnd_sel                    =   (w_function_select == MODE_WATCH)           ?   (w_fnd_sel_watch)           :
                                            (w_function_select == MODE_STOP_WATCH)      ?   (w_fnd_sel_stop_watch)      :
                                            (w_function_select == MODE_COOKING_TIMER)   ?   (w_fnd_sel_cooking_timer)   :   4'hF;
    
    // LED
    assign o_led_function               =   w_function_select;

    // BUZZ
    assign o_buzz                       =   w_buzz_button | w_buzz_alarm;

endmodule
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module top_SG90 (
    input       wire                        i_clk,
    input       wire                        i_reset,
    input       wire                        i_sw,
    input       wire                        i_btn_u,
    input       wire                        i_btn_d,
    input       wire                        i_btn_r,
    input       wire                        i_btn_l,
    output      wire                        o_pwm,
    output      wire        [7 : 0]         o_fnd,
    output      wire        [3 : 0]         o_fnd_sel,
    output      wire                        o_led_enable,
    output      wire                        o_led_servo_neutral
);
    parameter                               SERVO_MAX               =   12'd516;
    parameter                               SERVO_NEUTRAL           =   12'd307;
    parameter                               SERVO_MIN               =   12'd102;
    parameter                               SERVO_1_DEGREE          =   12'd2;
    parameter                               SERVO_10_DEGREE         =   12'd23;

    wire                                    w_btn_u_posedge;
    wire                                    w_btn_u_negedge;
    wire                                    w_btn_d_posedge;
    wire                                    w_btn_r_posedge;
    wire                                    w_btn_l_posedge;

    wire    [11 : 0]                        w_duty_hex;
    wire    [11 : 0]                        w_duty_deg_hex;
    wire    [15 : 0]                        w_duty_bcd;
    
    reg     [11 : 0]                        r_duty_wiper;
    reg                                     r_duty_direction;

    reg     [20 : 0]                        delay_counter;
    wire                                    w_delay_counter_posedge;

    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            delay_counter <= 0;
        end
        else begin
            delay_counter <= delay_counter + 1;
        end
    end

    edge_detector_n                         ED(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (delay_counter[20]), 
        .o_posedge                          (w_delay_counter_posedge),
        .o_negedge                          ()
    );

    // 0.002 sec = 2ms
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_duty_direction     <=      1;
            r_duty_wiper         <=      SERVO_MIN;
        end
        else if (w_btn_u_negedge) begin
            r_duty_direction <= ~r_duty_direction;
        end
        else if (i_sw && w_delay_counter_posedge) begin
            // Min to Max
            if      (r_duty_direction) begin
                // Reach to Max
                if (r_duty_wiper >= SERVO_MAX) begin
                    r_duty_direction <= 0;
                end
                else begin
                    r_duty_wiper <= r_duty_wiper + SERVO_1_DEGREE;
                end
            end
            // Max to Min
            else if (!r_duty_direction) begin
                // Reach to Min
                if (r_duty_wiper <= SERVO_MIN) begin
                    r_duty_direction <= 1;
                end
                else begin
                    r_duty_wiper <= r_duty_wiper - SERVO_1_DEGREE;
                end
            end
        end
    end

    // Button
    //////////////////////////////////////////////////////////
    buttonControl                           BTN_U_INC10_CCW(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_u),
        .o_btn_posedge                      (w_btn_u_posedge),
        .o_btn_negedge                      (w_btn_u_negedge)
    );
    
    buttonControl                           BTN_D_DEC10_CW(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_d),
        .o_btn_posedge                      (w_btn_d_posedge),
        .o_btn_negedge                      ()
    );

    buttonControl                           BTN_R_INC_CCW(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_r),
        .o_btn_posedge                      (w_btn_r_posedge),
        .o_btn_negedge                      ()
    );
    
    buttonControl                           BTN_L_DEC_CW(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_l),
        .o_btn_posedge                      (w_btn_l_posedge),
        .o_btn_negedge                      ()
    );

    // Servo
    //////////////////////////////////////////////////////////
    SG90_Control                            SG90(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (i_sw),
        .i_duty                             (r_duty_wiper),
        .o_servo_enable                     (o_led_enable),
        .o_servo_neutral                    (o_led_servo_neutral),
        .o_duty                             (w_duty_hex),
        .o_pwm                              (o_pwm)
    );

    SG90_LUT                                LUT(
        .i_reset                            (i_reset),
        .i_duty                             (w_duty_hex),
        .o_duty                             (w_duty_deg_hex)
    );

    // FND
    //////////////////////////////////////////////////////////
    bin2Dec                                 BIN_2_DEC(
        .i_bin                              (w_duty_deg_hex),
        .o_bcd                              (w_duty_bcd)
    );

    fndControl                              DISPLAY_DEGREE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_duty_bcd),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );
    //////////////////////////////////////////////////////////

endmodule
///////////////////////////////////////////////////////////////////////////////////////////////////
module top_ADC (
    input           wire                    i_clk,
    input           wire                    i_reset,
    input           wire                    i_adc_p,
    input           wire                    i_adc_n,
    output          wire    [11 : 0]        o_adc_data
    // output          wire    [7 : 0]         o_fnd,
    // output          wire    [3 : 0]         o_fnd_sel
);

    wire    [6 : 0]                     w_adc_daddr_in;
    wire    [4 : 0]                     w_adc_channel_out;
    wire                                w_en_adc;
    wire                                w_adc_eoc_out;
    wire                                w_adc_eoc_out_posedge;
    wire    [15 : 0]                    w_adc_data_out;
    reg     [11 : 0]                    r_adc_data;
    wire    [15 : 0]                    w_adc_data_bcd;

    edge_detector_n                     ED_EOC(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_adc_eoc_out),
        .o_posedge                      (w_adc_eoc_out_posedge),
        .o_negedge                      ()
    );

    xadc_wiz_0                          ADC_CH_6_PORT_P1_N7 (
        .di_in(di_in),              // input wire [15 : 0] di_in
        .dwe_in(dwe_in),            // input wire dwe_in
        .drdy_out(drdy_out),        // output wire drdy_out
        .vp_in(vp_in),              // input wire vp_in
        .vn_in(vn_in),              // input wire vn_in
        .alarm_out(alarm_out),      // output wire alarm_out
        .eos_out(eos_out),          // output wire eos_out
        .busy_out(busy_out),        // output wire busy_out
        .daddr_in                       (w_adc_daddr_in),           // input wire [6 : 0] daddr_in
        .den_in                         (w_en_adc),                 // input wire den_in
        .do_out                         (w_adc_data_out),           // output wire [15 : 0] do_out
        .dclk_in                        (i_clk),                    // input wire dclk_in
        .reset_in                       (i_reset),                  // input wire reset_in
        .vauxp6                         (i_adc_p),                  // input wire vauxp6
        .vauxn6                         (i_adc_n),                  // input wire vauxn6
        .channel_out                    (w_adc_channel_out),        // output wire [4 : 0] channel_out
        .eoc_out                        (w_adc_eoc_out)             // output wire eoc_out
    );

    bin2Dec                             BIN_2_BCD(
        .i_bin                          (r_adc_data),
        .o_bcd                          (w_adc_data_bcd)
    );

    // fndControl                          FND(
    //     .i_clk                          (i_clk),
    //     .i_reset                        (i_reset),
    //     .i_value                        (w_adc_data_bcd),
    //     .o_fnd                          (o_fnd),
    //     .o_fnd_sel                      (o_fnd_sel)
    // );

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_adc_data <= 0;
        end
        else if (w_adc_eoc_out_posedge) begin
            r_adc_data <= w_adc_data_out[15 -: 12];
        end
    end

    assign w_en_adc         =   w_adc_eoc_out;
    assign w_adc_daddr_in   =   {2'h0, w_adc_channel_out};
    assign o_adc_data       =   r_adc_data;
    
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
module top_knob_to_servo (
    input           wire                    i_clk,
    input           wire                    i_reset,
    input           wire                    i_sw,
    input           wire                    i_adc_p,
    input           wire                    i_adc_n,
    output          wire                    o_pwm,
    output          wire                    o_led_enable,
    output          wire                    o_led_servo_neutral,
    output          wire    [7 : 0]         o_fnd,
    output          wire    [3 : 0]         o_fnd_sel
);
    parameter                               SERVO_MAX               =   12'd516;
    parameter                               SERVO_NEUTRAL           =   12'd307;
    parameter                               SERVO_MIN               =   12'd102;

    reg     [11 : 0]                        r_adc_to_duty;
    wire    [11 : 0]                        w_adc_data;
    wire    [11 : 0]                        w_adc_to_duty;
    wire    [11 : 0]                        w_servo_duty;
    wire    [11 : 0]                        w_duty_deg_hex;
    wire    [15 : 0]                        w_duty_bcd;

    top_ADC                                 KNOB(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_adc_p                            (i_adc_p),
        .i_adc_n                            (i_adc_n),
        .o_adc_data                         (w_adc_data)
    );

    // Servo
    //////////////////////////////////////////////////////////
    SG90_Control                            SG90(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (i_sw),
        .i_duty                             (w_adc_to_duty),
        .o_servo_enable                     (o_led_enable),
        .o_servo_neutral                    (o_led_servo_neutral),
        .o_duty                             (w_servo_duty),
        .o_pwm                              (o_pwm)
    );

    SG90_LUT                                LUT(
        .i_reset                            (i_reset),
        .i_duty                             (w_servo_duty),
        .o_duty                             (w_duty_deg_hex)
    );
    //////////////////////////////////////////////////////////


    // FND
    //////////////////////////////////////////////////////////
    bin2Dec                                 BIN_2_DEC(
        .i_bin                              (w_duty_deg_hex),
        .o_bcd                              (w_duty_bcd)
    );

    fndControl                              DISPLAY_DEGREE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_duty_bcd),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );
    //////////////////////////////////////////////////////////

    always @(*) begin
        if (i_reset) begin
            r_adc_to_duty = 0;
        end
        else begin
            if      (w_adc_data >= SERVO_MAX) begin
                r_adc_to_duty = r_adc_to_duty;
            end
            else if (w_adc_data <= SERVO_MIN) begin
                r_adc_to_duty = r_adc_to_duty;
            end
            else begin
                r_adc_to_duty = w_adc_data;
            end
        end
    end
    assign w_adc_to_duty        =           {2'h0, r_adc_to_duty[11 -: 9]};
    
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
module top_led_dimmer (
    input           wire                    i_clk,
    input           wire                    i_reset,
    input           wire                    i_adc_p,
    input           wire                    i_adc_n,
    output          wire    [7 : 0]         o_fnd,
    output          wire    [3 : 0]         o_fnd_sel,
    output          wire    [15 : 0]        o_led
);

    parameter                               ADC_BIT_RESOLUTION      = 12;
    parameter                               LED_PWM_FREQ            = 10_000;
    parameter                               LED_PWM_RESOLUTION      = 128;
    parameter                               LED_PWM_BIT_RESOLUTION  = 7;

    wire    [LED_PWM_BIT_RESOLUTION - 1 : 0]w_duty;
    wire    [15 : 0]                        w_duty_bcd;
    wire    [ADC_BIT_RESOLUTION - 1 : 0]    w_adc_data;
    wire                                    w_led;

    top_ADC                                 ADC(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_adc_p                            (i_adc_p),
        .i_adc_n                            (i_adc_n),
        .o_adc_data                         (w_adc_data)
    );

    pwm #(
        .PWM_FREQ                           (LED_PWM_FREQ),
        .PWM_RESOLUTION                     (LED_PWM_RESOLUTION),
        .BIT_RESOLUTION                     (LED_PWM_BIT_RESOLUTION)
    )                                       LED_DRIVER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (w_duty),
        .o_pwm                              (w_led)
    );

    bin2Dec                                 BIN_2_BCD(
        .i_bin                              (w_duty),
        .o_bcd                              (w_duty_bcd)
    );

    fndControl                              FND(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_duty_bcd),
        .o_fnd                              (o_fnd),
        .o_fnd_sel                          (o_fnd_sel)
    );

    assign w_duty           =               w_adc_data[11 -: 7];
    assign o_led            =               {16{w_led}};
    
endmodule
//////////////////////////////////////////////////////////////////////////////////////////
module top_functionalFan (
    // System Interface
    input           wire                    i_clk,
    input           wire                    i_reset,                // U18 (BTNC)

    // Ultrasonic Interface
    input           wire                    i_sw_detect_mode,
    input           wire                    i_ultra_l_echo,
    output          wire                    o_ultra_l_trig,
    input           wire                    i_ultra_m_echo,
    output          wire                    o_ultra_m_trig,
    input           wire                    i_ultra_r_echo,
    output          wire                    o_ultra_r_trig,

    // User Input Interface
    input           wire                    i_btn_d,                // T18 (BTNU)
    input           wire                    i_btn_u,                // U17 (BTND)
    input           wire                    i_btn_l,                // W19 (BTNL)
    input           wire                    i_btn_r,                // T17 (BTNR)
    input           wire                    i_sw_charge,            // V17 (SW0)

    // User Output Interface

    output          wire                    o_led_system_enable,    // U16 (LD0)
    output          wire                    o_led_charge,           // E19 (LD1)
    output          wire                    o_pwm_backlight,        // U19 (LD2)
    output          wire        [3 : 0]     o_led_fan_power,        // W3 V3 V13 V14 (LD10 LD9 LD8 LD7)
    output          wire        [3 : 0]     o_led_timer_set,        // P3 N3 P1 L1 (LD15 LD14 LD13 LD12)

        // FND
    output          wire        [7 : 0]     o_fnd,                  // W7 W6 U8 V8 U5 V6 U7 V7
    output          wire        [3 : 0]     o_fnd_sel,              // W4 V4 U4 U2
    
    // DC Motor Interface
    output          wire                    o_pwm_dc,               // J1 (JA1)

    // Servo Motor Interface
    output          wire                    o_pwm_servo             // H1 (JA7)
);

    // System
    wire                                    w_system_enable_t;
    wire                                    w_system_enable_q;
    wire                                    w_system_enable_q_negedge;

    // Fan Backlight
    wire                                    w_backlight_change;

    // Button
    wire                                    w_btn_u_posedge;
    wire                                    w_btn_l_posedge;
    wire                                    w_btn_r_posedge;
    wire                                    w_btn_d_posedge;

    // Fan Blade Power (DC Motor)
    wire            [11 : 0]                w_duty_dc;
    wire                                    w_power_change;
    wire            [3 : 0]                 w_state_fan_power;
    wire                                    w_selected_power_change;

    // Fan Timer
    wire                                    w_time_set_change;
    wire                                    w_time_load;
    wire                                    w_time_load_posedge;
    wire                                    w_time_out;
    wire                                    w_time_out_posedge;
    wire            [15 : 0]                w_time_value;
    wire            [15 : 0]                w_time_value_load;
    wire                                    w_timer_enable;

    // Fan Head Oscillator (Servo Motor)
    wire                                    w_ultra_enable;
    wire                                    w_ultra_l_trig;
    wire                                    w_ultra_m_trig;
    wire                                    w_ultra_r_trig;
    wire            [8 : 0]                 w_distance_l;
    wire            [8 : 0]                 w_distance_m;
    wire            [8 : 0]                 w_distance_r;
    wire            [11 : 0]                w_duty_servo;

    // FND Controller
    wire            [7 : 0]                 w_fnd_spin_decoder;
    wire            [7 : 0]                 w_fnd_timer;
    wire            [3 : 0]                 w_state_timer;
    wire            [7 : 0]                 w_fnd;
    wire            [3 : 0]                 w_fnd_sel;

    // Button
    /////////////////////////////////////////////////////////////////
    buttonControl                           BTN_D_SYS_ENABLE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_d),
        .o_btn_posedge                      (w_btn_d_posedge),
        .o_btn_negedge                      ()
    );

    T_flip_flop_n                           TOGGLE_SYS_ENABLE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_t                                (w_system_enable_t),
        .o_q                                (w_system_enable_q),
        .o_q_bar                            ()
    );

    edge_detector_n                         ED_SYSTEM_DISABLE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_system_enable_q),
        .o_posedge                          (),
        .o_negedge                          (w_system_enable_q_negedge)
    );

    buttonControl                           BTN_U_POWER_SET(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_u),
        .o_btn_posedge                      (w_btn_u_posedge),
        .o_btn_negedge                      ()
    );

    buttonControl                           BTN_L_TIMER_SET(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_l),
        .o_btn_posedge                      (w_btn_l_posedge),
        .o_btn_negedge                      ()
    );

    buttonControl                           BTN_R_BCKLGT_SET(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_btn                              (i_btn_r),
        .o_btn_posedge                      (w_btn_r_posedge),
        .o_btn_negedge                      ()
    );
    /////////////////////////////////////////////////////////////////

    // Control
    /////////////////////////////////////////////////////////////////
    fanPowerControl                         FAN_POWER_CTRL(
        .clk                                (i_clk),
        .reset_p                            (i_reset),
        .power_change                       (w_power_change),
        .power_disable                      (w_system_enable_q_negedge),
        .duty                               (w_duty_dc),
        .state                              (w_state_fan_power)
    );

    fanTimerControl                         FAN_TIMER_CTRL(
        .clk                                (i_clk),
        .reset_p                            (i_reset),
        .time_set_change                    (w_time_set_change),
        .timer_disable                      (w_system_enable_q_negedge),
        .state                              (w_state_timer),
        .bcd                                (w_time_value_load),
        .load                               (w_time_load),
        .enable                             (w_timer_enable)
    );

    fanBackLightControl                     FAN_BKLGT_CTRL(
        .clk                                (i_clk),
        .reset_p                            (i_reset),
        .bklgt_disable                      (w_system_enable_q_negedge),
        .bklgt_change                       (w_backlight_change),
        .back_light_pwm                     (o_pwm_backlight)
    );
    /////////////////////////////////////////////////////////////////

    // DC Motor
    /////////////////////////////////////////////////////////////////
    DC_Motor_Control                        DC_FAN_BLADE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (w_duty_dc),
        .o_pwm                              (o_pwm_dc)
    );
    /////////////////////////////////////////////////////////////////
    
    // Servo Motor
    /////////////////////////////////////////////////////////////////
    HC_SR04_Control                         ULTRA_LEFT(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (w_ultra_enable),
        .i_echo                             (i_ultra_l_echo),
        .o_trigger                          (w_ultra_l_trig),
        .o_distance                         (w_distance_l)
    );

    HC_SR04_Control                         ULTRA_MIDDLE(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (w_ultra_enable),
        .i_echo                             (i_ultra_m_echo),
        .o_trigger                          (w_ultra_m_trig),
        .o_distance                         (w_distance_m)
    );

    HC_SR04_Control                         ULTRA_RIGHT(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (w_ultra_enable),
        .i_echo                             (i_ultra_r_echo),
        .o_trigger                          (w_ultra_r_trig),
        .o_distance                         (w_distance_r)
    );

    ultra2Servo                             ULTRA_TO_SERVO(
        .clk                                (i_clk),
        .reset_p                            (i_reset),
        .mode                               (i_sw_detect_mode),
        .distance_l                         (w_distance_l),
        .distance_m                         (w_distance_m),
        .distance_r                         (w_distance_r),
        .duty                               (w_duty_servo)
    );

    SG90_Control                            SERVO_FAN_HEAD(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_duty                             (w_duty_servo),
        .o_pwm                              (o_pwm_servo)
    );
    /////////////////////////////////////////////////////////////////

    // Timer
    /////////////////////////////////////////////////////////////////
    edge_detector_n                         ED_LOAD_BCD(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_time_load),
        .o_posedge                          (w_time_load_posedge),
        .o_negedge                          ()
    );

    timer                                   FAN_TIMER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_enable                           (w_timer_enable),
        .i_load                             (w_time_load_posedge),
        .i_time_bcd                         (w_time_value_load),
        .o_time_bcd                         (w_time_value),
        .o_time_out                         (w_time_out)
    );

    edge_detector_n                         ED_TIME_OUT(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_cp                               (w_time_out),
        .o_posedge                          (w_time_out_posedge),
        .o_negedge                          ()
    );

    /////////////////////////////////////////////////////////////////

    // FND
    /////////////////////////////////////////////////////////////////
    fndControl                              TIMER_DISPLAY(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_value                            (w_time_value),
        .o_fnd                              (w_fnd_timer),
        .o_fnd_sel                          (w_fnd_sel)
    );

    functionalFan7SegSpinner                FND_SPIN_DECODER(
        .i_clk                              (i_clk),
        .i_reset                            (i_reset),
        .i_fan_power                        (w_state_fan_power),
        .o_fnd_value                        (w_fnd_spin_decoder)
    );

    fanFndSelector                          SELECT_DISPLAY(
        .i_reset                            (i_reset),
        .i_functionalFan_enable             (w_system_enable_q),
        .i_fnd_sel                          (w_fnd_sel),
        .i_state_timer                      (w_state_timer),
        .i_fnd_spin_decoder                 (w_fnd_spin_decoder),
        .i_fnd_timer                        (w_fnd_timer),
        .o_fnd                              (w_fnd)
    );
    /////////////////////////////////////////////////////////////////

    assign w_system_enable_t                =       w_time_out_posedge | w_btn_d_posedge;
    assign o_fnd                            =       w_fnd;
    assign o_fnd_sel                        =       w_fnd_sel;
    assign o_led_timer_set                  =       w_state_timer;
    assign o_led_fan_power                  =       w_state_fan_power;
    assign o_led_system_enable              =       w_system_enable_q;
    assign o_led_charge                     =       i_sw_charge;
    assign w_ultra_enable                   =       w_system_enable_q;
    assign o_ultra_l_trig                   =       w_ultra_l_trig;
    assign o_ultra_m_trig                   =       w_ultra_m_trig;
    assign o_ultra_r_trig                   =       w_ultra_r_trig;
    assign w_power_change                   =       w_btn_u_posedge & w_system_enable_q;
    assign w_time_set_change                =       w_btn_l_posedge & w_system_enable_q;
    assign w_backlight_change               =       w_btn_r_posedge & w_system_enable_q;

endmodule

