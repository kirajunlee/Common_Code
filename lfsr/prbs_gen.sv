// ============================================================
// File Name: prbs_gen
// Version  : V1.0
// Data     : 2025/11/25
// Author   : lijun
// Func：   : 
// ============================================================
module prbs_gen #(
    parameter       PRBS_WIDTH           = 32                 ,  //PRBS output width,should >= LFSR_WIDTH;
    parameter       LFSR_WIDTH           = 31                 ,  //LFSR width,should be 7,15,23,31;
    parameter       TAP1                 = 30                 ,  //TAP1 position,should be set according to LFSR_WIDTH;
    parameter       TAP2                 = 27                 ,  //TAP2 position,should be set according to LFSR_WIDTH;
    parameter       SEED                 = {LFSR_WIDTH{1'b1}}    //LFSR seed value;
)
(
    input                                clk                  ,
    input                                rst                  ,
    input                                prbs_en              , // prbs enable
    input                                prbs_init            , // prbs init signal
    output  logic  [PRBS_WIDTH-1: 0]     prbs_data              // prbs data output
);
//=============================================================
// localparam define
// ============================================================
//
// ============================================================
// struct define
// ============================================================
// 
// ============================================================
// signal define
// ============================================================
//
    logic          [LFSR_WIDTH-1: 0]     lfsr_temp            ;
    logic          [PRBS_WIDTH-1: 0]     prbs_temp            ;
// ============================================================
// process
// ============================================================
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            prbs_data <= 'd0 ;
        end
        else if (prbs_init) begin
            if (PRBS_WIDTH > LFSR_WIDTH) begin  //PRBS_WIDTH > LFSR_WIDTH
                prbs_data <= {SEED, prbs_temp[PRBS_WIDTH-1:LFSR_WIDTH]} ;
            end
            else begin  //PRBS_WIDTH == LFSR_WIDTH
                prbs_data <= SEED ;
            end
        end
        else if (prbs_en) begin
            prbs_data <= prbs_temp ;
        end
    end

    always_comb begin

        lfsr_temp = prbs_init? SEED[LFSR_WIDTH-1:0] : prbs_data[LFSR_WIDTH-1:0] ;
        
        for (int i = 0; i < PRBS_WIDTH; i++) begin
            // update lfsr one step;
            lfsr_temp = {lfsr_temp[LFSR_WIDTH-2:0], lfsr_temp[TAP1] ^ lfsr_temp[TAP2]};
            // lfsr result output high bit;
            prbs_temp[PRBS_WIDTH-1-i] = lfsr_temp[0];
        end

    end
    
endmodule