// ============================================================
// File Name: sfifo
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：本模块实现同步fifo的功能;
// ============================================================
module sfifo #(
    parameter    DEPTH                = 4                      , //FIFO深度;
    parameter    WIDTH                = 8                      , //FIFO位宽;
    parameter    DOUT_REG             = "false"
)(   
    input                             clk                      ,
    input                             rst_n                    , //复位输入;
    input                             fifo_wen                 ,
    input         [WIDTH-1: 0]        fifo_wdat                ,
    input                             fifo_ren                 ,
    output  logic [WIDTH-1: 0]        fifo_rdat                ,
    output  logic                     fifo_empty               ,
    output  logic                     fifo_full                ,
    output  logic [DEPTH-1: 0]        fifo_depth
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
    logic                            wen                      ;
    logic       [DEPTH  : 0]         waddr                    ;
    logic                            ren                      ;
    logic       [DEPTH  : 0]         raddr                    ;
// ============================================================
// 逻辑处理
// ============================================================
//写使能;
    assign wen = fifo_wen & ~fifo_full ; //写使能有效,且fifo未满产生真正的写;
//写地址
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            waddr <= 'd0 ;  //复位写地址初始化到0;
        end
        else if (wen) begin //写使能为1,且没有写满则地址加1;
            waddr <= waddr + 1'b1 ;
        end
    end
//读使能;
    assign ren = fifo_ren & ~fifo_empty ; //读使能为1,且没有读空,产生真正的读;
//读地址
    always @(posedge clk, negedge rst_n) begin
        if (~rst_n) begin
            raddr <= 'd0 ;  //复位写地址初始化到0;
        end
        else if (ren) begin //则地址加1;
            raddr <= raddr + 1'b1 ;
        end
    end
//满判断;
    assign fifo_full  = ({~waddr[DEPTH], waddr[DEPTH-1:0]} == raddr)? 1'b1 : 1'b0 ; //高位地址相反,低位地址相同则为满;
//空判断;
    assign fifo_empty = (waddr == raddr)? 1'b1 : 1'b0 ; //地址相同则为满;
//深度判断;
    add_sub_cnt #(
        .CNT_WIDTH         ( DEPTH               ), //计数器位宽;
        .CNT_LIMIT         ( 1'b1                )  //计数器限制,即计数器上下溢不做操作;
    ) u_add_sub_cnt
    (
        .clk               ( clk                 ),
        .rst_n             ( rst_n               ), //复位输入;
        .add               ( wen                 ), //加
        .sub               ( ren                 ), //减
        .cnt               ( fifo_depth          ), //计数器
        .cnt_overflow      (                     ),
        .cnt_underflow     (                     )
    );
//Fifo RAM例化;
    simple_dpram_logic #(
        .ADDR_WIDTH        ( DEPTH               ), //地址位宽
        .DATA_WIDTH        ( WIDTH               ), //数据位宽
        .RD_DUR_WR_USE_NEW ( "false"             ), //读写冲突使用新数据;
        .DOUT_REG          ( "false"             )  //寄存器输出;
    ) u_simple_dpram
    (
        .clk               ( clk                 ), //时钟
        .wen               ( wen                 ), //写使能
        .waddr             ( waddr               ), //写地址
        .wdata             ( fifo_wdat           ), //写数据
        .ren               ( ren                 ), //读使能
        .raddr             ( raddr               ), //读地址
        .rdata             ( fifo_rdat           )  //读数据
    );

endmodule
