// ============================================================
// File Name: spram_logic
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：本模块实现逻辑搭建简单双端口ram,基于1个时钟,一侧只有写,一侧
// 只有读; 
// ============================================================
module spram_logic
#(
    parameter       ADDR_WIDTH          =   8                 , //地址位宽
    parameter       DATA_WIDTH          =   8                 , //数据位宽
    parameter       DOUT_REG            =  "false"              //寄存器输出;
)
(
    input                               clk                   , //时钟
    input                               wen                   , //写使能
    input          [ADDR_WIDTH-1: 0]    addr                  , //写地址
    input          [DATA_WIDTH-1: 0]    wdata                 , //写数据
    output  logic  [DATA_WIDTH-1: 0]    rdata                   //读数据
);
//=============================================================
// 本地参数
// ============================================================
//
// ============================================================
// 结构体定义
// ============================================================
//
// ============================================================
// 信号声明
// ============================================================
    logic   [DATA_WIDTH-1: 0]                     ram_dout    ;
    logic   [DATA_WIDTH-1: 0]                     ram_reg     ;
    logic   [2**ADDR_WIDTH-1: 0][DATA_WIDTH-1: 0] ram         ;
// ============================================================
// 逻辑处理
// ============================================================
// Init
`ifdef SIM_RAM_INIT
    initial begin
        ram_dout = {WIDTH_DATA{1'b0}};
        ram_reg  = {WIDTH_DATA{1'b0}};
        for (int i = 0; i < (2**ADDR_WIDTH); i++) begin
            ram[i] = {WIDTH_DATA{1'b0}};
        end
    end
`endif
// Write
    always @(posedge clk) begin
        if (wen) begin
            ram[addr] <= wdata ; 
        end
    end
// Read
    always @(posedge clk) begin
        if (~wen) begin
            ram_dout <= ram[addr] ;
        end
    end

    generate
        if (DOUT_REG == "true")begin
            always @(posedge clk)begin
                ram_reg <= ram_dout ;
            end

            assign rdata = ram_reg  ;
        end
        else begin
            assign rdata = ram_dout ;
        end
    endgenerate

endmodule