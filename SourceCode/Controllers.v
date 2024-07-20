`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////
module fndControl(
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire        [15 : 0]    i_value,
    output      wire        [7 : 0]     o_fnd,
    output      wire        [3 : 0]     o_fnd_sel
);

    reg     [3 : 0]                     r_hex_value;
    wire    [3 : 0]                     w_hex_value;
    
    decoder7Seg                         FND_VALUE(
        .i_hex_value                    (w_hex_value),
        .o_fnd_value                    (o_fnd)
    );

    ringCounterFnd                      FND_SELECT(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .o_fnd_sel                      (o_fnd_sel)
    );
    
    always @(posedge i_clk)begin
        case(o_fnd_sel)
            4'b1110 : r_hex_value <= i_value[3   :   0];
            4'b1101 : r_hex_value <= i_value[7   :   4];
            4'b1011 : r_hex_value <= i_value[11  :   8];
            4'b0111 : r_hex_value <= i_value[15  :   12];
        endcase
    end

    assign w_hex_value = r_hex_value;
    
endmodule
///////////////////////////////////////////////////////////////////////////
module buttonControl(
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_btn,
    output      wire                    o_btn_posedge,
    output      wire                    o_btn_negedge
);
    
    reg     [16 : 0]                    r_delay_counter;
    wire                                r_delay_counter_posedge;

    reg                                 r_debounced_btn;
    wire                                w_debounced_btn;
    
    edge_detector_n                     ED_DELAY_COUNTER(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset), 
        .i_cp                           (r_delay_counter[16]),
        .o_posedge                      (r_delay_counter_posedge),
        .o_negedge                      ()
    );
    
    edge_detector_n                     ED_BTN(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_debounced_btn), 
        .o_posedge                      (o_btn_posedge),
        .o_negedge                      (o_btn_negedge)
    );

    always @(posedge i_clk) begin
       r_delay_counter <= r_delay_counter + 1; 
    end
        
    always @(posedge i_clk or posedge i_reset)begin
        if (i_reset) begin
            r_debounced_btn <= 0;
        end
        else if (r_delay_counter_posedge) begin
            r_debounced_btn <= i_btn;
        end
    end

    assign w_debounced_btn = r_debounced_btn;

endmodule
///////////////////////////////////////////////////////////////////////////
module keyPadControl (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire        [3 : 0]     i_row,
    output      wire        [3 : 0]     o_col,
    output      wire        [3 : 0]     o_key_value,
    output      wire                    o_key_valid
);
    reg     [3 : 0]                     r_col;
    reg     [3 : 0]                     r_key_value;
    reg                                 r_key_valid;

    // Delay for Debouncing
    reg     [19 : 0]                    r_delay_counter;
    wire                                w_delayed_clk;
    wire                                w_delayed_clk_posedge;
    wire                                w_delayed_clk_negedge;

    // State Machine
    reg     [2 : 0]                     present_state;
    reg     [2 : 0]                     next_state;

    localparam [2 : 0]                  SCAN_0001    =   3'h0;
    localparam [2 : 0]                  SCAN_0010    =   3'h1;
    localparam [2 : 0]                  SCAN_0100    =   3'h2;
    localparam [2 : 0]                  SCAN_1000    =   3'h3;
    localparam [2 : 0]                  KEY_PROCESS  =   3'h4;

    edge_detector_n                     ED_WIRE_DELAYED_CLK(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_delayed_clk),
        .o_posedge                      (w_delayed_clk_posedge),
        .o_negedge                      (w_delayed_clk_negedge)
    );
    
    // Delay
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_delay_counter <= 0;
        end
        else begin
            r_delay_counter <= r_delay_counter + 1;
        end
    end
    /////////////////////////////////////////////////////////////////////

    // FSM
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            present_state <= SCAN_0001;
        end
        else if (w_delayed_clk_posedge) begin
            present_state <= next_state;
        end
    end

    always @(*) begin
        if (i_reset) begin
            next_state = SCAN_0001;
        end
        else begin
            case (present_state)
                SCAN_0001    : begin
                    if (i_row == 0) begin
                        next_state = SCAN_0010;
                    end 
                    else begin
                        next_state = KEY_PROCESS;
                    end
                end
            
                SCAN_0010    : begin
                    if (i_row == 0) begin
                        next_state = SCAN_0100;
                    end 
                    else begin
                        next_state = KEY_PROCESS;
                    end
                end
            
                SCAN_0100    : begin
                    if (i_row == 0) begin
                        next_state = SCAN_1000;
                    end 
                    else begin
                        next_state = KEY_PROCESS;
                    end
                end
            
                SCAN_1000    : begin
                    if (i_row == 0) begin
                        next_state = SCAN_0001;
                    end 
                    else begin
                        next_state = KEY_PROCESS;
                    end
                end
            
                KEY_PROCESS    : begin
                    if (i_row == 0) begin
                        next_state = SCAN_0001;
                    end 
                    else begin
                        next_state = KEY_PROCESS;
                    end
                end

                default: begin
                    next_state = SCAN_0001;
                end
            endcase
        end
    end

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_col       <= 4'b0001;
            r_key_value <= 4'h0;
            r_key_valid <= 1'b0;
        end
        else if (w_delayed_clk_negedge) begin
            case (present_state)
                SCAN_0001    : begin r_col <= 4'b0001; r_key_valid <= 1'b0;  end
                SCAN_0010    : begin r_col <= 4'b0010; r_key_valid <= 1'b0;  end
                SCAN_0100    : begin r_col <= 4'b0100; r_key_valid <= 1'b0;  end
                SCAN_1000    : begin r_col <= 4'b1000; r_key_valid <= 1'b0;  end
                KEY_PROCESS  : begin r_col <= r_col;   r_key_valid <= 1'b1;
                    case ({r_col, i_row})
                        8'b0001_0001 : r_key_value <= 4'h0;
                        8'b0010_0001 : r_key_value <= 4'h1;
                        8'b0100_0001 : r_key_value <= 4'h2;
                        8'b1000_0001 : r_key_value <= 4'h3;
                        8'b0001_0010 : r_key_value <= 4'h4;
                        8'b0010_0010 : r_key_value <= 4'h5;
                        8'b0100_0010 : r_key_value <= 4'h6;
                        8'b1000_0010 : r_key_value <= 4'h7;
                        8'b0001_0100 : r_key_value <= 4'h8;
                        8'b0010_0100 : r_key_value <= 4'h9;
                        8'b0100_0100 : r_key_value <= 4'hA;
                        8'b1000_0100 : r_key_value <= 4'hB; 
                        8'b0001_1000 : r_key_value <= 4'hC;
                        8'b0010_1000 : r_key_value <= 4'hD;
                        8'b0100_1000 : r_key_value <= 4'hE;
                        8'b1000_1000 : r_key_value <= 4'hF;
                    endcase
                end
            endcase
        end
    end
    /////////////////////////////////////////////////////////////////////

    assign w_delayed_clk    =   r_delay_counter[17];
    assign o_col            =   r_col;
    assign o_key_value      =   r_key_value;
    assign o_key_valid      =   r_key_valid;

endmodule
////////////////////////////////////////////////////////////////////////////////
module DHT11_Control (
    input       wire                    i_clk,
    input       wire                    i_reset,
    inout       wire                    io_data,
    output      wire        [7 : 0]     o_humidity,
    output      wire        [7 : 0]     o_temperature,
    output      wire        [6 : 0]     o_state_led,
    output      wire        [1 : 0]     o_read_state_led
);

    localparam  [22 : 0]                IDLE_DELAY             =   23'd3_000_000;
    localparam  [22 : 0]                MCU_SEND_OUT_DELAY     =   23'd18_000;
    localparam  [22 : 0]                DHT_TIME_OUT           =   23'd100_000;

    localparam  [6 : 0]                 IDLE                    =   7'b000_0001;
    localparam  [6 : 0]                 MCU_SEND_OUT            =   7'b000_0010;
    localparam  [6 : 0]                 MCU_PULLS_UP            =   7'b000_0100;
    localparam  [6 : 0]                 DHT_SEND_OUT            =   7'b000_1000;
    localparam  [6 : 0]                 DHT_PULLS_UP            =   7'b001_0000;
    localparam  [6 : 0]                 MCU_READ_DATA           =   7'b010_0000;
    localparam  [6 : 0]                 DONE                    =   7'b100_0000;

    localparam  [1 : 0]                 MCU_WAIT_POSEDGE        =   2'b01;
    localparam  [1 : 0]                 MCU_WAIT_NEGEDGE        =   2'b10;

    reg     [6 : 0]                     present_state;
    reg     [6 : 0]                     next_state;
    reg     [1 : 0]                     read_state;

    reg     [7 : 0]                     r_humidity;
    reg     [7 : 0]                     r_temperature;

    reg     [22 : 0]                    r_count_usec;
    reg                                 r_en_count_usec;

    wire                                w_tick_usec_posedge;

    reg     [5 : 0]                     r_count_data;
    reg     [39 : 0]                    r_byte_data;
    reg                                 r_data;

    wire                                w_DHT_data_posedge;
    wire                                w_DHT_data_negedge;

    clock_div_100                       CLK_DIV_US(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .o_cp                           (),
        .o_tick_posedge                 (w_tick_usec_posedge),
        .o_tick_negedge                 ()
    );

    edge_detector_n                     ED_INPUT_DHT11_DATA(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (io_data),
        .o_posedge                      (w_DHT_data_posedge),
        .o_negedge                      (w_DHT_data_negedge)
    );

    // present_state
    // Clock Polarity : Negedge
    // To ensure state transition (at posedge)
    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            present_state <= IDLE;
        end
        else begin
            present_state <= next_state;
        end
    end
    
    // r_count_usec
    // Clock Polarity : Negedge
    // To ensure clear counter (conditioned at posedge)
    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_count_usec = 0;
        end
        else if (w_tick_usec_posedge && r_en_count_usec) begin
            r_count_usec = r_count_usec + 1;
        end
        else if (!r_en_count_usec) begin
            r_count_usec = 0;
        end
    end

    // next_state
    // read_state
    // r_count_data
    // r_data
    // r_en_count_usec
    // r_humidity
    // r_temperature
    // r_byte_data
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            next_state          =      IDLE;
            read_state          =      MCU_WAIT_POSEDGE;

            r_data              =      1'bz;
            r_en_count_usec     =      0;
            
            r_humidity          =      0;
            r_temperature       =      0;
            
            r_count_data        =      0;
            r_byte_data         =      0;
        end
        else begin
            case (present_state)
            
                IDLE                :   begin
                    if (r_count_usec < IDLE_DELAY) begin
                        // Same as pulled up ('bz)
                        r_data              =      1'b1;
                        r_en_count_usec     =      1;
                    end
                    else begin
                        next_state          =      MCU_SEND_OUT;
                        r_data              =      1'b0;
                        r_en_count_usec     =      0;
                    end
                end

                MCU_SEND_OUT    :   begin
                    if (r_count_usec < MCU_SEND_OUT_DELAY) begin
                        r_data              =      1'b0;
                        r_en_count_usec     =      1;
                    end
                    else begin
                        next_state          =      MCU_PULLS_UP;
                        r_en_count_usec     =      0;
                        r_data              =      1'bz;
                    end
                end

                MCU_PULLS_UP   :   begin
                    r_en_count_usec     =      1;
                    // Escape when Inf Looping
                    if (r_count_usec > DHT_TIME_OUT) begin
                        next_state          =      IDLE;
                        r_en_count_usec     =      0;
                    end
                    if (w_DHT_data_negedge) begin
                        next_state          =      DHT_SEND_OUT;
                        r_en_count_usec     =      0;
                    end
                end

                DHT_SEND_OUT    :    begin
                    r_en_count_usec     =      1;
                    // Escape when Inf Looping
                    if (r_count_usec > DHT_TIME_OUT) begin
                        next_state          =      IDLE;
                        r_en_count_usec     =      0;
                    end
                    if (w_DHT_data_posedge) begin
                        next_state          =      DHT_PULLS_UP;
                        r_data              =      1'bz;
                        r_en_count_usec     =      0;
                    end
                end

                DHT_PULLS_UP   :   begin
                    r_en_count_usec     =      1;
                    // Escape when Inf Looping
                    if (r_count_usec > DHT_TIME_OUT) begin
                        next_state          =      IDLE;
                        r_en_count_usec     =      0;
                    end
                    if (w_DHT_data_negedge) begin
                        next_state          =      MCU_READ_DATA;
                        r_data              =      1'bz;
                        r_en_count_usec     =      0;
                    end
                end

                MCU_READ_DATA       :   begin
                    case (read_state)
                        MCU_WAIT_POSEDGE    : begin
                            if (w_DHT_data_posedge) begin
                                read_state          =      MCU_WAIT_NEGEDGE;
                            end
                            else begin
                                r_en_count_usec     =      0;
                            end
                        end

                        MCU_WAIT_NEGEDGE    : begin
                            if (w_DHT_data_negedge) begin
                                if (r_count_usec < 23'd45) begin
                                    r_byte_data     =      {r_byte_data[38 : 0], 1'b0};
                                end
                                else begin
                                    r_byte_data     =      {r_byte_data[38 : 0], 1'b1};
                                end
                                r_count_data        =      r_count_data + 1;

                                if (r_count_data >= 6'd40) begin
                                    r_count_data    =      0;
                                    next_state      =      DONE;
                                    r_humidity      =      r_byte_data[39 -: 8];
                                    r_temperature   =      r_byte_data[23 -: 8];
                                end
                                else begin
                                    next_state      =      MCU_READ_DATA;
                                end
                                read_state          =      MCU_WAIT_POSEDGE;
                            end
                            else begin
                                r_en_count_usec     =      1;
                            end
                            if (r_count_usec > DHT_TIME_OUT) begin
                                next_state          =       IDLE;
                                r_en_count_usec     =       0;
                                read_state          =      MCU_WAIT_POSEDGE;
                            end
                        end
                    endcase
                end

                DONE                :   begin
                    next_state          =      IDLE;
                end

                default             :   begin
                    next_state          =      IDLE;
                end
            endcase
        end
    end

    assign io_data              =       r_data;
    assign o_humidity           =       r_humidity;
    assign o_temperature        =       r_temperature;
    assign o_state_led          =       present_state;
    assign o_read_state_led     =       read_state;

endmodule
////////////////////////////////////////////////////////////////////////////////
module HC_SR04_Control (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_enable,
    input       wire                    i_echo,
    output      wire                    o_trigger,
    output      wire        [8 : 0]     o_distance
);
    // For Debugging
    // output      wire        [2 : 0]     o_state_led,
    // output      wire        [1 : 0]     o_read_state_led

    parameter                           IDLE_DELAY          =       32'd500_000;
    parameter                           TRIGGER_PULSE_WIDTH =       32'd10;
    parameter                           ESCAPE_TH           =       32'd24_000;

    // Onehot, Not to make 32-bit adder
    localparam  [2 : 0]                 IDLE                =       3'b001;
    localparam  [2 : 0]                 TRIG                =       3'b010;
    localparam  [2 : 0]                 ECHO                =       3'b100;

    localparam  [1 : 0]                 WAIT_ECHO_POSEDGE   =       2'b01;
    localparam  [1 : 0]                 WAIT_ECHO_NEGEDGE   =       2'b10;

    // State
    reg [2 : 0]                         present_state;
    reg [2 : 0]                         next_state;
    reg [1 : 0]                         read_state;

    // Trigger
    reg                                 r_trigger;
    reg                                 r_en_trigger_pulse_count;
    reg [31 : 0]                        r_trigger_pulse_count;

    // 1 Microsecond
    wire                                w_cp_usec;
    wire                                w_tick_usec_posedge;

    // Echo
    wire                                w_echo_posedge;
    wire                                w_echo_negedge;
    reg                                 r_en_echo_pulse_count;
    reg [8 : 0]                         r_echo_pulse_count;

    // 58 Microsecond
    wire                                w_tick_58usec_posedge;

    // Distance
    reg [8 : 0]                         r_distance_pulse_width;
    reg [8 : 0]                         r_distance_pipeline;

    clock_div_100                       CLK_DIV_US(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .o_cp                           (w_cp_usec),
        .o_tick_posedge                 (w_tick_usec_posedge),
        .o_tick_negedge                 ()
    );

    clock_div_58                        CLK_DIV_58(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (w_cp_usec),
        .o_cp                           (),
        .o_tick_posedge                 (w_tick_58usec_posedge),
        .o_tick_negedge                 ()
    );

    edge_detector_n                     ED_INPUT_ECHO_DATA(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_cp                           (i_echo),
        .o_posedge                      (w_echo_posedge),
        .o_negedge                      (w_echo_negedge)
    );

    // r_echo_pulse_count
    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_echo_pulse_count <= 0;
        end
        else if (w_tick_58usec_posedge && r_en_echo_pulse_count) begin
            r_echo_pulse_count <= r_echo_pulse_count + 1;
        end
        else if (!r_en_echo_pulse_count) begin
            r_echo_pulse_count <= 0;
        end
    end

    // r_trigger_pulse_count
    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_trigger_pulse_count <= 0;
        end
        else if (w_tick_usec_posedge && r_en_trigger_pulse_count) begin
            r_trigger_pulse_count <= r_trigger_pulse_count + 1;
        end
        else if (!r_en_trigger_pulse_count) begin
            r_trigger_pulse_count <= 0;
        end
    end

    // present_state
    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            present_state = IDLE;
        end
        else begin
            present_state = next_state;
        end
    end

    // next_state
    // read_state
    // r_en_trigger_pulse_count
    // r_en_echo_pulse_count
    // r_trigger
    // r_distance_pulse_width
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            next_state                      =   IDLE;
            read_state                      =   WAIT_ECHO_POSEDGE;
            r_en_trigger_pulse_count        =   0;
            r_en_echo_pulse_count           =   0;
            r_trigger                       =   0;
            r_distance_pulse_width          =   0;
        end
        else begin
            case (present_state)
                
                IDLE : begin
                    if (i_enable) begin
                        if (r_trigger_pulse_count       >=  IDLE_DELAY) begin
                            next_state                  =   TRIG;
                            r_en_trigger_pulse_count    =   0;
                            r_trigger                   =   0;
                        end
                        else begin
                            next_state                  =   IDLE;
                            r_en_trigger_pulse_count    =   1;
                            r_trigger                   =   0;
                        end
                    end
                    else begin
                        next_state                  =   IDLE;
                        r_en_trigger_pulse_count    =   1;
                        r_trigger                   =   0;
                    end
                end 

                TRIG : begin
                    if (r_trigger_pulse_count       >=  TRIGGER_PULSE_WIDTH) begin
                        next_state                  =   ECHO;
                        r_en_trigger_pulse_count    =   0;
                        r_trigger                   =   0;
                    end
                    else begin
                        next_state                  =   TRIG;
                        r_en_trigger_pulse_count    =   1;
                        r_trigger                   =   1;
                    end
                end

                ECHO : begin
                    case (read_state)
                        WAIT_ECHO_POSEDGE    : begin
                            if (w_echo_posedge) begin
                                read_state                  =   WAIT_ECHO_NEGEDGE;
                                r_en_echo_pulse_count       =   1;
                            end
                        end
                        WAIT_ECHO_NEGEDGE   : begin
                            if (w_echo_negedge) begin
                                read_state                  =   WAIT_ECHO_POSEDGE;
                                next_state                  =   IDLE;
                                r_en_echo_pulse_count       =   0;
                                r_distance_pulse_width      =   r_echo_pulse_count;
                            end
                            // Escape
                            if (r_trigger_pulse_count       >   ESCAPE_TH) begin
                                r_en_trigger_pulse_count    =   0;
                                r_en_echo_pulse_count       =   0;
                                read_state                  =   WAIT_ECHO_POSEDGE;
                                next_state                  =   IDLE;
                            end
                        end
                        default : begin
                            next_state = IDLE;
                        end 
                    endcase
                end
                default : begin
                    next_state = IDLE;
                end
            endcase
        end
    end

    // r_distance_pipeline
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_distance_pipeline <= 0;
        end
        else begin
            r_distance_pipeline <= r_distance_pulse_width;
        end
    end

    assign o_trigger            =       r_trigger;
    assign o_state_led          =       present_state;
    assign o_read_state_led     =       read_state;
    assign o_distance           =       r_distance_pipeline;
    
endmodule
////////////////////////////////////////////////////////////////////////////////
module buzzerControl #(
    parameter                           ACTIVE  =   1,
    parameter                           NOTE    =   (20'h5D2EF / 2)
) (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_enable,
    output      wire                    o_buzz_clk
);

    reg                                 r_buzz_clk;
    reg [19 : 0]                        r_buzz_count;

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_buzz_clk           <=      0;
            r_buzz_count         <=      0;
        end
        else if (i_enable) begin
            if (ACTIVE) begin
                r_buzz_clk       <=     1;
            end
            else begin
                // PASSIVE
                if (r_buzz_count >= NOTE) begin
                    r_buzz_clk           <=      ~r_buzz_clk;
                    r_buzz_count         <=      0;
                end
                else begin
                    r_buzz_clk           <=      r_buzz_clk;
                    r_buzz_count         <=      r_buzz_count + 1;
                end
            end
        end
        else begin
            r_buzz_clk           <=      0;
            r_buzz_count         <=      0;
        end
    end

    assign o_buzz_clk = r_buzz_clk;

endmodule
////////////////////////////////////////////////////////////////////////////////
module functionalWatchControl (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_mode,
    output      wire        [2 : 0]     o_function_select
);

    localparam [2 : 0] MODE_WATCH           = 3'b001;
    localparam [2 : 0] MODE_STOP_WATCH      = 3'b010;
    localparam [2 : 0] MODE_COOKING_TIMER   = 3'b100;

    reg [2 : 0] present_state;
    reg [2 : 0] next_state;

    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            present_state <= MODE_WATCH; 
        end
        else begin
            present_state <= next_state;
        end
    end

    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            next_state <= MODE_WATCH;
        end
        else begin
            case (present_state)
            
                MODE_WATCH          : if (i_mode)   next_state <= MODE_STOP_WATCH;
                MODE_STOP_WATCH     : if (i_mode)   next_state <= MODE_COOKING_TIMER;
                MODE_COOKING_TIMER  : if (i_mode)   next_state <= MODE_WATCH;
                default             :               next_state <= MODE_WATCH;

            endcase
        end
    end

    assign o_function_select = present_state;
    
endmodule
////////////////////////////////////////////////////////////////////////////////
module DC_Motor_Control (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire        [11 : 0]    i_duty,
    output      wire                    o_pwm
);

    parameter                           DC_MOTOR_PWM_FREQ           =   100;
    parameter                           DC_MOTOR_PWM_RESOLUTION     =   4096;
    parameter                           DC_MOTOR_BIT_RESOLUTION     =   12;

    pwm #(
        .PWM_FREQ                       (DC_MOTOR_PWM_FREQ),
        .PWM_RESOLUTION                 (DC_MOTOR_PWM_RESOLUTION),
        .BIT_RESOLUTION                 (DC_MOTOR_BIT_RESOLUTION)
    )                                   MOTOR_DRIVER(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_duty                         (i_duty),
        .o_pwm                          (o_pwm)
    );

endmodule
////////////////////////////////////////////////////////////////////////////////
module SG90_Control (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire    [11 : 0]        i_duty,
    output      wire                    o_pwm
);

    parameter                           SERVO_PWM_FREQ          =   50;
    parameter                           SERVO_PWM_RESOLUTION    =   4096;
    parameter                           SERVO_BIT_RESOLUTION    =   12;

    parameter                           SERVO_MAX               =   12'd516;
    parameter                           SERVO_NEUTRAL           =   12'd307;
    parameter                           SERVO_MIN               =   12'd102;
    parameter                           SERVO_1_DEGREE          =   12'd2;
    parameter                           SERVO_10_DEGREE         =   12'd23;

    reg  [11 : 0]                       r_duty;
    wire [11 : 0]                       w_servo_duty;

    pwm                                 #(
        .PWM_FREQ                       (SERVO_PWM_FREQ),
        .PWM_RESOLUTION                 (SERVO_PWM_RESOLUTION),
        .BIT_RESOLUTION                 (SERVO_BIT_RESOLUTION)
    )                                   SERVO_DRIVER(
        .i_clk                          (i_clk),
        .i_reset                        (i_reset),
        .i_duty                         (w_servo_duty),
        .o_pwm                          (o_pwm)
    );

    assign w_servo_duty         =       i_duty;
    // assign o_servo_enable       =       i_enable;
    // assign o_servo_neutral      =       (r_duty == SERVO_NEUTRAL);
    // assign o_duty               =       i_duty;

endmodule
////////////////////////////////////////////////////////////////////////////////
module SG90_Rotator (
    input       wire                    i_clk,
    input       wire                    i_reset,
    input       wire                    i_enable,
    input       wire                    i_load,
    input       wire    [11 : 0]        i_duty_load,
    output      wire    [11 : 0]        o_duty
);
    parameter                           SERVO_MAX               =   12'd516;
    parameter                           SERVO_NEUTRAL           =   12'd307;
    parameter                           SERVO_MIN               =   12'd102;
    parameter                           SERVO_1_DEGREE          =   12'd2;
    parameter                           SERVO_10_DEGREE         =   12'd23;

    reg     [11 : 0]                    r_duty_wiper;
    reg                                 r_duty_direction;

    reg     [20 : 0]                    delay_counter;
    wire                                w_delay_counter_posedge;

    always @(negedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            delay_counter <= 0;
        end
        else begin
            delay_counter <= delay_counter + 1;
        end
    end

    // 0.002 sec = 2ms
    always @(posedge i_clk or posedge i_reset) begin
        if (i_reset) begin
            r_duty_direction     <=      1;
            r_duty_wiper         <=      SERVO_MIN;
        end
        else if (i_load) begin
            r_duty_wiper        <=      i_duty_load;
        end
        else if (i_enable && w_delay_counter_posedge) begin
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

    assign o_duty = r_duty_wiper;

endmodule
////////////////////////////////////////////////////////////////////////////////
module fanTimerControl(
    input clk, reset_p,
    input time_set_change,
    input timer_disable,
    output [3:0] state,
    output reg [15:0] bcd,
    output reg enable,
    output reg load
);

    parameter STATE_NO_SET      = 4'b0001;
    parameter STATE_TIME_SET_1H = 4'b0010;
    parameter STATE_TIME_SET_3H = 4'b0100;
    parameter STATE_TIME_SET_5H = 4'b1000;
    
    reg [3:0] time_set_state, time_set_next_state;

    assign state = time_set_state;

    always @(negedge clk or posedge reset_p) begin
        if (reset_p)
            time_set_state <= STATE_NO_SET;
        else
            time_set_state <= time_set_next_state;
    end

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            time_set_next_state <= STATE_NO_SET;
            load <= 0;
            enable <= 0;
            bcd <= 0;
        end else begin
            case (time_set_state)
                STATE_NO_SET: begin
                    if (timer_disable) begin
                        load <= 0;
                        enable <= 0;
                        bcd <= 16'b0000_0000_0000_0000;
                    end
                    else if (time_set_change) begin
                        time_set_next_state <= STATE_TIME_SET_1H;
                        bcd <= 16'b0000_0001_0000_0000;
                        enable <= 1;
                        load <= 1;
                    end else begin
                        load <= 0;
                        enable <= 0;
                        bcd <= 16'b0000_0000_0000_0000;
                    end
                end

                STATE_TIME_SET_1H: begin
                    if (timer_disable) begin
                        time_set_next_state <= STATE_NO_SET;
                        load <= 0;
                        enable <= 0;
                        bcd <= 16'b0000_0000_0000_0000;
                    end
                    else if (time_set_change) begin
                        time_set_next_state <= STATE_TIME_SET_3H;
                        bcd <= 16'b0000_0011_0000_0000;
                        enable <= 1;
                        load <= 1;
                    end else begin
                        bcd <= 16'b0000_0001_0000_0000;
                        enable <= 1;
                        load <= 0;
                    end
                end

                STATE_TIME_SET_3H: begin
                    if (timer_disable) begin
                        time_set_next_state <= STATE_NO_SET;
                        load <= 0;
                        enable <= 0;
                        bcd <= 16'b0000_0000_0000_0000;
                    end
                    else if (time_set_change) begin
                        time_set_next_state <= STATE_TIME_SET_5H;
                        bcd <= 16'b0000_0101_0000_0000;
                        enable <= 1;
                        load <= 1;
                    end else begin
                        bcd <= 16'b0000_0011_0000_0000;
                        enable <= 1;
                        load <= 0;
                    end
                end

                STATE_TIME_SET_5H: begin
                    if (timer_disable) begin
                        time_set_next_state <= STATE_NO_SET;
                        load <= 0;
                        enable <= 0;
                        bcd <= 16'b0000_0000_0000_0000;
                    end
                    else if (time_set_change) begin
                        time_set_next_state <= STATE_NO_SET;
                        bcd <= 16'b0000_0000_0000_0000;
                        enable <= 1;
                        load <= 0;
                    end else begin
                        bcd <= 16'b0000_0101_0000_0000;
                        enable <= 1;
                        load <= 0;
                    end
                end

                default: time_set_next_state <= STATE_NO_SET;
            endcase
        end
    end
endmodule
////////////////////////////////////////////////////////////////////////////////
module fanBackLightControl(
    input clk, reset_p,
    input bklgt_change,
    input bklgt_disable,
    output back_light_pwm
);

    parameter STATE_NO_SET   = 4'b0001;
    parameter STATE_LGT_SET1 = 4'b0010;
    parameter STATE_LGT_SET2 = 4'b0100;
    parameter STATE_LGT_SET3 = 4'b1000;
    
    reg [3:0] lgt_set_state, lgt_set_next_state;
    reg [11:0] cnt;


    pwm #(.PWM_FREQ(100_00), .PWM_RESOLUTION(4096), .BIT_RESOLUTION(12)) led_back_light(.i_clk(clk), .i_reset(reset_p), .i_duty(cnt), .o_pwm(back_light_pwm));

    always @(negedge clk or posedge reset_p) begin
        if (reset_p)
            lgt_set_state <= STATE_NO_SET;
        else
            lgt_set_state <= lgt_set_next_state;
    end

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            lgt_set_next_state <= STATE_NO_SET;
            cnt <= 0;
        end else begin
            case (lgt_set_state)
                STATE_NO_SET: begin
                    if (bklgt_disable) begin
                        lgt_set_next_state <= STATE_NO_SET;
                        cnt <= 0;
                    end
                    else if (bklgt_change) begin
                        lgt_set_next_state <= STATE_LGT_SET1;
                        cnt <= 1365;
                    end else begin
                        cnt <= 0;
                    end
                end

                STATE_LGT_SET1: begin
                    if (bklgt_disable) begin
                        lgt_set_next_state <= STATE_NO_SET;
                        cnt <= 0;
                    end
                    else if (bklgt_change) begin
                        lgt_set_next_state <= STATE_LGT_SET2;
                        cnt <= 2730;
                    end else begin
                        cnt <= 1365;
                    end
                end

                STATE_LGT_SET2: begin
                    if (bklgt_disable) begin
                        lgt_set_next_state <= STATE_NO_SET;
                        cnt <= 0;
                    end
                    else if (bklgt_change) begin
                        lgt_set_next_state <= STATE_LGT_SET3;
                        cnt <= 4095;
                    end else begin
                        cnt <= 2730;
                    end
                end

                STATE_LGT_SET3: begin
                    if (bklgt_disable) begin
                        lgt_set_next_state <= STATE_NO_SET;
                        cnt <= 0;
                    end
                    else if (bklgt_change) begin
                        lgt_set_next_state <= STATE_NO_SET;
                        cnt <= 0;
                    end else begin
                        cnt <= 4095;
                    end
                end

                default: lgt_set_next_state <= STATE_NO_SET;
            endcase
        end
    end
endmodule
////////////////////////////////////////////////////////////////////////////////
module fanPowerControl(
    input clk, reset_p,
    input power_change,
    input power_disable,
    output reg [11:0] duty,
    output [3:0] state
);

    parameter POWOFF = 4'b0001;
    parameter POWLOW = 4'b0010;
    parameter POWMID = 4'b0100;
    parameter POWMAX = 4'b1000;
    
    reg [3:0] power_set_state, power_set_next_state;
    
    assign state = power_set_state;
    

    always @(negedge clk or posedge reset_p) begin
        if (reset_p)
            power_set_state <= POWOFF;
        else
            power_set_state <= power_set_next_state;
    end

    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            power_set_next_state <= POWOFF;
            duty <= 0;
        end else begin
            case (power_set_state)
                POWOFF: begin
                    if(power_disable) power_set_next_state <= POWOFF;
                    else begin
                        if (power_change) begin
                        power_set_next_state <= POWLOW;
                    end else begin
                        duty <= 0;
                    end
                    end
                   
                end

                POWLOW: begin
                    if(power_disable) power_set_next_state <= POWOFF;
                    else begin
                    if (power_change) begin
                        power_set_next_state <= POWMID;
                    end else begin
                        duty <= 1500;
                    end
                    end

                end

                POWMID: begin
                    if(power_disable) power_set_next_state <= POWOFF;
                    else begin
                    if (power_change) begin
                        power_set_next_state <= POWMAX;
                    end else begin
                        duty <= 2730;
                        
                    end
                    end

                end

                POWMAX: begin
                    if(power_disable) power_set_next_state <= POWOFF;
                    else begin
                    if (power_change) begin
                        power_set_next_state <= POWOFF;
                    end else begin
                        duty <= 4095;
                    end
                    end
                end

                default: power_set_next_state <= POWOFF;
            endcase
        end
    end
endmodule
////////////////////////////////////////////////////////////////////////////////
module ultrasonic (
    input clk, reset_p,
    input echo,                     // From Sensor to MCU
    output reg trig,                // From MCU to Sensor
    output reg [9:0] distance);
   


    reg [9:0] count;    
    parameter S_IDLE        = 3'b001;
    parameter TRIG          = 3'b010;
    parameter ECHO          = 3'b100;
                             
    parameter S_WAIT_PEDGE  = 2'b01;
    parameter S_WAIT_NEDGE  = 2'b10;

    reg [19:0] count_usec;
    wire clk_usec;

    reg count_usec_e;
    // clock_div_100 clk_us(.clk(clk), .reset_p(reset_p), .clk_div_100(clk_usec));
    clock_div_100               clk_us(
        .i_clk                  (clk),
        .i_reset                (reset_p),
        .o_cp                   (),
        .o_tick_posedge         (),
        .o_tick_negedge         (clk_usec)
    );

    reg cnt_e;
    wire [11:0] cm;

    // sr_04_div_58 clk_cm(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec), .cnt_e(cnt_e), .cm(cm));
    clock_div_58                clk_58(
        .i_clk                  (clk),
        .i_reset                (reset_p),
        .i_cp                   (clk_usec),
        .o_cp                   (o_cp),
        .o_tick_posedge         (o_tick_posedge),
        .o_tick_negedge         (o_tick_negedge)
    );

    always @(negedge clk or posedge reset_p) begin
        if (reset_p)
            count_usec = 0;
        else if (clk_usec && count_usec_e)
            count_usec = count_usec + 1;
        else if (count_usec_e == 0)
            count_usec = 0;
    end

 
    wire echo_nedge, echo_pedge;
    edge_detector_p ed(
        .i_clk(clk), .i_reset(reset_p), .i_cp(echo),
        .o_negedge(echo_nedge), .o_posedge(echo_pedge));

    reg [2:0] state, next_state;
    reg [1:0] read_state;

    always @(negedge clk or posedge reset_p) begin
        if (reset_p)
            state <= S_IDLE;
        else
            state <= next_state;
    end


    always @(posedge clk or posedge reset_p) begin
        if (reset_p) begin
            count_usec_e <= 0;
            next_state <= S_IDLE;
            read_state <= S_WAIT_PEDGE;
            cnt_e <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    if (count_usec < 22'd100_000) begin       // if manage this number, you can set sensor lunch time faster or not. but 60ms is the minimum value (1_000_000 this value is 1s)
                        count_usec_e <= 1;
                        trig <= 0;
                    end else begin
                        next_state <= TRIG;
                        count_usec_e <= 0;
                        trig <= 1;
                    end
                end
                    TRIG: begin
                    if (count_usec < 22'd10) begin
                        count_usec_e <= 1;
                        trig <= 1;
                    end else begin
                        next_state <= ECHO;
                        count_usec_e <= 0;
                        trig <= 0;
                    end
                end
                ECHO: begin
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            if(echo_pedge)begin
                            read_state = S_WAIT_NEDGE;
                            cnt_e = 1;
                            end
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin
                                    next_state = S_IDLE;
                                    distance = cm;
                                    cnt_e = 0;
                                    read_state = S_WAIT_PEDGE;      
                                    // read_state and next_state are other register
                            end
                            else count_usec_e = 1; 
                        end
                    endcase
                end
                default: next_state <= S_IDLE;
            endcase
        end
    end
endmodule