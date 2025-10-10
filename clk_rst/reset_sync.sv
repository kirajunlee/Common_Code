// ============================================================
// File Name: reset_sync
// VERSION  : V1.0
// DATA     : 2025/02/17
// Author   : lijun
// ============================================================
// 功能：本模块实现异步复位同步释放的功能;
// ============================================================
module reset_sync #(
    parameter                 I_RESET_LEVEL = 1'b0             //输入复位电平;0,Low lever rst;1,High lever rst;
    parameter                 O_RESET_LEVEL = 1'b0             //复位同步化后需要的复位电平;0,Low lever rst;1,High lever rst;
)(
    input                     clk                             ,
    input                     rst_i                           , //复位输入;
    output    logic           rst_o                             //复位同步化输出;
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
    logic                     rst_s1                          ;
    logic                     rst_s2                          ;
// ============================================================
// 逻辑处理
// ============================================================
assign rst_o = rst_s2 ;

generate
    if (I_RESET_LEVEL == 1'b0) begin : I_LOW_LEVER_RST
        //两级同步器降低异步的亚稳态概率；
        always @(posedge clk, negedge rst_i) begin
            if (~rst_n) begin
                rst_s1 <= O_RESET_LEVEL ;  //复位时2级触发器复位值等于复位电平;
                rst_s2 <= O_RESET_LEVEL ;
            end
            else begin
                rst_s1 <= ~O_RESET_LEVEL ; //复位撤销第一级Reg在时钟边沿变为非复位状态;
                rst_s2 <= rst_s1 ;
            end
        end
    end
    else begin : I_HIGH_LEVER_RST
        always @(posedge clk, posedge rst_i) begin
            if (~rst_n) begin
                rst_s1 <= O_RESET_LEVEL ;  //复位时2级触发器复位值等于复位电平;
                rst_s2 <= O_RESET_LEVEL ;
            end
            else begin
                rst_s1 <= ~O_RESET_LEVEL ;  //复位撤销第一级Reg在时钟边沿变为非复位状态;
                rst_s2 <= rst_s1 ;
            end
        end
    end
endgenerate

endmodule
